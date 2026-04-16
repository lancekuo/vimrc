#!/usr/bin/env bash
# md2gdoc - Convert markdown (with mermaid diagrams) to DOCX
# Dependencies: pandoc, mmdc (mermaid-cli)
#
# Usage:
#   md2gdoc <file.md> [-o output.docx] [--title "Custom Title"]

set -euo pipefail

# --- Parse args ---
INPUT=""
OUTPUT=""
TITLE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o)       OUTPUT="$2"; shift 2 ;;
    --title)  TITLE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: md2gdoc <file.md> [-o output.docx] [--title \"Title\"]"
      exit 0 ;;
    *) INPUT="$1"; shift ;;
  esac
done

if [[ -z "$INPUT" ]]; then
  echo "Error: No input file specified" >&2
  echo "Usage: md2gdoc <file.md> [-o output.docx] [--title \"Title\"]" >&2
  exit 1
fi

if [[ ! -f "$INPUT" ]]; then
  echo "Error: File not found: $INPUT" >&2
  exit 1
fi

# --- Check dependencies ---
for cmd in pandoc mmdc; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd is not installed" >&2
    exit 1
  fi
done

# --- Setup temp dir ---
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# --- Derive title ---
if [[ -z "$TITLE" ]]; then
  TITLE=$(sed -n 's/^<!--[[:space:]]*Title:[[:space:]]*\(.*[^ ]\)[[:space:]]*-->/\1/p' "$INPUT" | head -1)
  if [[ -z "$TITLE" ]]; then
    TITLE=$(grep -m1 '^# ' "$INPUT" | sed 's/^# //' || true)
  fi
  if [[ -z "$TITLE" ]]; then
    TITLE=$(basename "$INPUT" .md)
  fi
fi

echo "📄 Title: $TITLE"
echo "📂 Processing: $INPUT"

# --- Step 1: Strip Confluence headers ---
PROCESSED="$TMPDIR/processed.md"
sed -E '/^<!--[[:space:]]*(Space|Parent|Title):/d' "$INPUT" > "$PROCESSED"

# --- Step 2: Render mermaid blocks to PNG ---
MERMAID_SCRIPT="$TMPDIR/render_mermaid.py"
cat > "$MERMAID_SCRIPT" << 'PYEOF'
import re, subprocess, sys, os

processed_md = sys.argv[1]
tmpdir = sys.argv[2]

with open(processed_md, 'r') as f:
    content = f.read()

counter = 0

def render_mermaid(match):
    global counter
    counter += 1
    mermaid_code = match.group(1)
    mmd_file = os.path.join(tmpdir, f'diagram_{counter}.mmd')
    png_file = os.path.join(tmpdir, f'diagram_{counter}.png')

    with open(mmd_file, 'w') as f:
        f.write(mermaid_code)

    try:
        subprocess.run(
            ['mmdc', '-i', mmd_file, '-o', png_file, '-b', 'white', '-s', '3'],
            check=True, capture_output=True, text=True
        )
        print(f"  ✅ Rendered diagram {counter}")
        return f'![Diagram {counter}]({png_file})'
    except subprocess.CalledProcessError as e:
        print(f"  ⚠️  Diagram {counter} failed: {e.stderr[:200]}", file=sys.stderr)
        return match.group(0)

result = re.sub(r'```mermaid\n(.*?)```', render_mermaid, content, flags=re.DOTALL)

with open(processed_md, 'w') as f:
    f.write(result)

print(f"  📊 {counter} mermaid diagram(s) processed")
PYEOF
python3 "$MERMAID_SCRIPT" "$PROCESSED" "$TMPDIR"

# --- Step 3: Convert to DOCX via pandoc ---
if [[ -z "$OUTPUT" ]]; then
  OUTPUT="${INPUT%.md}.docx"
fi

echo "📝 Converting to DOCX..."
pandoc "$PROCESSED" -o "$OUTPUT" \
  --resource-path="$TMPDIR" \
  --wrap=none \
  2>/dev/null

FILESIZE=$(wc -c < "$OUTPUT" | tr -d ' ')
echo ""
echo "✅ $OUTPUT (${FILESIZE} bytes)"
