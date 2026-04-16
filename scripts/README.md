# ~/.local/bin Tools

## md2docx

Convert Obsidian markdown files (with mermaid diagrams) to DOCX for Google Docs sharing via Google Drive sync.

### Usage

```bash
md2docx <file.md>                              # outputs <file>.docx in same directory
md2docx <file.md> -o ~/Google\ Drive/out.docx  # specify output path
md2docx <file.md> --title "Custom Title"       # override document title
```

### What it does

1. Strips Confluence metadata headers (`<!-- Space: -->`, `<!-- Parent: -->`, `<!-- Title: -->`)
2. Fixes Obsidian blockquote line breaks (Obsidian renders consecutive `>` lines separately, pandoc merges them)
3. Renders mermaid code blocks as PNG images embedded in the docx
4. Applies custom reference doc styling (table borders, bold header row, 0.5" page margins)
5. Post-processes table column widths to fill 100% page width

### Title resolution order

1. `--title` flag (if provided)
2. `<!-- Title: ... -->` Confluence header in the markdown
3. First `# Heading` in the file
4. Filename (without `.md`)

### Dependencies

- `pandoc` — `brew install pandoc`
- `mmdc` — `npm install -g @mermaid-js/mermaid-cli`
- `python3` — pre-installed on macOS

### Files

```
~/.local/bin/
  md2docx                          # main script
  md2docx-reference/
    mermaid-filter.lua             # pandoc Lua filter (mermaid rendering, code block
                                   #   gray background, heading bookmark removal,
                                   #   full-width tables)
    reference.docx                 # pandoc reference doc (table borders, bold gray
                                   #   header row, 0.5" margins, 100% table width)
```

### Styling applied

| Element | Style |
|---|---|
| Page margins | 0.5 inch all sides |
| Tables | 100% width, light gray borders (#BBBBBB) |
| Table header row | Bold, light gray background (#F2F2F2) |
| Code blocks | Light gray background (#F2F2F2), monospace |
| Mermaid diagrams | Rendered as PNG (white background) |
| Heading bookmarks | Stripped (no anchor icons in Google Docs) |

### Google Docs workflow

The docx stays in compatibility mode (not native Google Docs) because the Google Drive API
is locked down by the org's Workspace admin. This means:

- Reading and commenting works fine
- No real-time co-editing or suggest-edits mode
- Fully functional for review workflows

```bash
# Convert all deliverables to Google Drive
GDRIVE=~/Library/CloudStorage/GoogleDrive-lance@cognichip.ai/My\ Drive/deliverables
SRC=~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/2023/plan/deliverables

for f in "$SRC"/*.md; do
  md2docx "$f" -o "$GDRIVE/$(basename "${f%.md}.docx")"
done
```

---

## md2gdoc

Older version of the markdown-to-docx converter. Uses a Python script to pre-process
mermaid blocks instead of the Lua filter approach.

### Usage

```bash
md2gdoc <file.md>                              # outputs <file>.docx in same directory
md2gdoc <file.md> -o output.docx               # specify output path
md2gdoc <file.md> --title "Custom Title"       # override document title
```

### Differences from md2docx

| | md2docx | md2gdoc |
|---|---|---|
| Mermaid rendering | Lua filter (pandoc-native) | Python pre-processing |
| Table styling | Reference doc + post-processing | Pandoc defaults (no borders) |
| Code block background | Gray (#F2F2F2) | None |
| Page margins | 0.5 inch | 1 inch (default) |
| Blockquote fix | Yes | No |
| Heading bookmarks | Stripped | Present |

**Recommendation:** Use `md2docx` for all new work. `md2gdoc` is kept for backward compatibility.

---

## workspace

Tmux session launcher with predefined windows for daily workflow.

### Usage

```bash
workspace          # creates/attaches "work" session
workspace myname   # creates/attaches custom-named session
```

### Windows

| Window | Name | Purpose |
|---|---|---|
| 0 | k9s | AWS SSO login + k9s (Kubernetes UI) |
| 1 | claude | Claude Code with session resume |
| 2 | eks-ts | Claude Code for EKS troubleshooting |
| 3 | chore | General purpose shell |
