#!/usr/bin/env bash
# md2docx - Convert markdown (with mermaid diagrams) to DOCX using pandoc + Lua filter
# Dependencies: pandoc, mmdc (mermaid-cli)
#
# Usage:
#   md2docx <file.md> [-o output.docx] [--title "Custom Title"]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REF_DIR="${SCRIPT_DIR}/md2docx-reference"
LUA_FILTER="${REF_DIR}/mermaid-filter.lua"
REFERENCE_DOC="${REF_DIR}/reference.docx"

# --- Parse args ---
INPUT=""
OUTPUT=""
TITLE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o)       OUTPUT="$2"; shift 2 ;;
    --title)  TITLE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: md2docx <file.md> [-o output.docx] [--title \"Title\"]"
      exit 0 ;;
    *) INPUT="$1"; shift ;;
  esac
done

if [[ -z "$INPUT" ]]; then
  echo "Error: No input file specified" >&2
  echo "Usage: md2docx <file.md> [-o output.docx] [--title \"Title\"]" >&2
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

if [[ ! -f "$LUA_FILTER" ]]; then
  echo "Error: Lua filter not found: $LUA_FILTER" >&2
  exit 1
fi

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

echo "Title: $TITLE"
echo "Processing: $INPUT"

# --- Strip Confluence headers + fix Obsidian line breaks ---
PROCESSED="$TMPDIR/processed.md"
sed -E '/^<!--[[:space:]]*(Space|Parent|Title):/d' "$INPUT" > "$PROCESSED"

# Obsidian renders consecutive blockquote lines as separate lines,
# but pandoc merges them into one paragraph. Add hard line breaks (backslash)
# so pandoc preserves the line-by-line layout.
python3 -c "
import re, sys
with open(sys.argv[1], 'r') as f:
    lines = f.readlines()
out = []
for i, line in enumerate(lines):
    stripped = line.rstrip('\n')
    # If this is a blockquote line and the next line is also a blockquote line,
    # append a backslash for a hard line break
    if stripped.startswith('>') and i + 1 < len(lines) and lines[i + 1].rstrip('\n').startswith('>'):
        out.append(stripped + '  \n')
    else:
        out.append(line)
with open(sys.argv[1], 'w') as f:
    f.writelines(out)
" "$PROCESSED"

# --- Convert to DOCX via pandoc + Lua filter ---
if [[ -z "$OUTPUT" ]]; then
  OUTPUT="${INPUT%.md}.docx"
fi

echo "Converting to DOCX..."
pandoc "$PROCESSED" -o "$OUTPUT" \
  --lua-filter="$LUA_FILTER" \
  --reference-doc="$REFERENCE_DOC" \
  --metadata title="$TITLE" \
  --wrap=none \
  2>&1

# --- Post-process: fix table grid widths to fill page ---
# Page width 12240 (8.5") - 720 left - 720 right = 10800 twips text area
FIXDIR="$TMPDIR/docx-fix"
mkdir -p "$FIXDIR"
cp "$OUTPUT" "$FIXDIR/doc.zip"
cd "$FIXDIR" && unzip -o doc.zip -d extracted > /dev/null 2>&1

python3 - "$FIXDIR/extracted/word/document.xml" << 'PYEOF'
import re, sys

PAGE_TEXT_WIDTH = 10800  # twips: 8.5" page - 0.5" left - 0.5" right

with open(sys.argv[1], 'r') as f:
    content = f.read()

def fix_table_grid(match):
    table_xml = match.group(0)
    cols = re.findall(r'<w:gridCol w:w="(\d+)"\s*/>', table_xml)
    if not cols:
        return table_xml
    ncols = len(cols)
    col_width = PAGE_TEXT_WIDTH // ncols
    remainder = PAGE_TEXT_WIDTH - (col_width * ncols)
    new_cols = []
    for i in range(ncols):
        w = col_width + (1 if i < remainder else 0)
        new_cols.append(f'<w:gridCol w:w="{w}" />')
    new_grid = '<w:tblGrid>' + ''.join(new_cols) + '</w:tblGrid>'
    table_xml = re.sub(r'<w:tblGrid>.*?</w:tblGrid>', new_grid, table_xml, flags=re.DOTALL)
    return table_xml

content = re.sub(r'<w:tbl>.*?</w:tbl>', fix_table_grid, content, flags=re.DOTALL)

with open(sys.argv[1], 'w') as f:
    f.write(content)
PYEOF

cd "$FIXDIR/extracted" && zip -r "$OUTPUT" . > /dev/null 2>&1

FILESIZE=$(wc -c < "$OUTPUT" | tr -d ' ')
echo ""
echo "Done: $OUTPUT (${FILESIZE} bytes)"
