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
    # Scale existing proportions to fill page width (preserves Lua filter ratios)
    current_total = sum(int(c) for c in cols)
    if current_total == 0:
        return table_xml
    scale = PAGE_TEXT_WIDTH / current_total
    new_widths = [int(int(c) * scale) for c in cols]
    # Fix rounding remainder
    remainder = PAGE_TEXT_WIDTH - sum(new_widths)
    new_widths[-1] += remainder
    new_cols = [f'<w:gridCol w:w="{w}" />' for w in new_widths]
    new_grid = '<w:tblGrid>' + ''.join(new_cols) + '</w:tblGrid>'
    table_xml = re.sub(r'<w:tblGrid>.*?</w:tblGrid>', new_grid, table_xml, flags=re.DOTALL)
    return table_xml

content = re.sub(r'<w:tbl>.*?</w:tbl>', fix_table_grid, content, flags=re.DOTALL)

# --- Scale images to full page width (preserve aspect ratio) ---
PAGE_TEXT_WIDTH_EMU = PAGE_TEXT_WIDTH * 635  # twips to EMU (1 twip = 635 EMU) = 6858000

def scale_drawing(match):
    drawing_xml = match.group(0)
    # Find the wp:extent (controls displayed size)
    ext_match = re.search(r'<wp:extent cx="(\d+)" cy="(\d+)"', drawing_xml)
    if not ext_match:
        return drawing_xml
    old_cx = int(ext_match.group(1))
    old_cy = int(ext_match.group(2))
    if old_cx == 0 or old_cx >= PAGE_TEXT_WIDTH_EMU:
        return drawing_xml
    scale = PAGE_TEXT_WIDTH_EMU / old_cx
    new_cx = PAGE_TEXT_WIDTH_EMU
    new_cy = int(old_cy * scale)
    # Update wp:extent
    drawing_xml = drawing_xml.replace(
        f'<wp:extent cx="{old_cx}" cy="{old_cy}"',
        f'<wp:extent cx="{new_cx}" cy="{new_cy}"', 1)
    # Update a:ext inside wp:inline (must match wp:extent)
    drawing_xml = drawing_xml.replace(
        f'<a:ext cx="{old_cx}" cy="{old_cy}"',
        f'<a:ext cx="{new_cx}" cy="{new_cy}"')
    return drawing_xml

content = re.sub(r'<w:drawing>.*?</w:drawing>', scale_drawing, content, flags=re.DOTALL)

with open(sys.argv[1], 'w') as f:
    f.write(content)
PYEOF

cd "$FIXDIR/extracted" && zip -r "$OUTPUT" . > /dev/null 2>&1

FILESIZE=$(wc -c < "$OUTPUT" | tr -d ' ')
echo ""
echo "Done: $OUTPUT (${FILESIZE} bytes)"
