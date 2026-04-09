---
name: life-align
description: Processes user-provided data (file paths, URLs) to maintain two Obsidian files — {hostname}.md (base knowledge with mermaid diagrams, personas, plan checklist) and {hostname}.canvas (interactive relationship graph grouped by function). Only uses data the user provides. Invoke with data sources to populate or update.
argument-hint: [<path-or-url> ...]
allowed-tools: Read, Write, Edit, WebFetch, Glob, Grep, Bash, AskUserQuestion
---

## Setup

Two output files live in the user's Obsidian vault. The base path is determined by:

1. Environment variable `$LIFE_ALIGN_VAULT` (if set)
2. Fallback: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/2023/plan`

Resolve the vault path by running: `echo "${LIFE_ALIGN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/2023/plan}"`

Resolve `{hostname}` by running: `hostname -s`

Output files:
```
{vault}/{hostname}.md      ← base knowledge
{vault}/{hostname}.canvas   ← relationship graph
```

Store the full resolved paths as `OBSIDIAN_MD` and `OBSIDIAN_CANVAS` for the rest of this skill.

### Default data locations

When no arguments are provided, automatically search these paths for data:

```
{vault}/{hostname}.md           ← base knowledge (read first)
{vault}/meetings/{hostname}/*   ← meeting notes per person
```

Resolve `{vault}` and `{hostname}` using the values from above. List all files in the meetings directory and read them as input data.

---

## Step 1 — Read existing state

- Read `OBSIDIAN_MD` if it exists — this is the base knowledge (system map, personas, plan checklist).
- Read `OBSIDIAN_CANVAS` if it exists — this is the current relationship graph.

These are the current state from previous runs. Keep in memory for merging.

If neither file exists, you will create them from scratch in Steps 3 and 4.

---

## Step 2 — Acquire and process user data

### 2a — Parse arguments

If `$ARGUMENTS` are provided, parse them as:
- **File paths** (e.g. `notes.md`, `/path/to/meeting.md`) → read with the Read tool
- **Directories** (ending with `/`) → list files with Bash `ls`, then read each file
- **URLs** (starting with `http`) → fetch with WebFetch
- **`clean`** → reset both output files to empty state and stop

If **no arguments** are provided, automatically read from the **default data locations** defined in Setup:
1. Read `OBSIDIAN_MD` (already done in Step 1)
2. List and read all files in `{vault}/meetings/{hostname}/*`

This means running `/life-align` with no args will re-process all known meeting notes against the current base knowledge.

If arguments are provided but unclear, use AskUserQuestion to clarify:
- What kind of data is this? (meeting notes, org chart, roadmap, etc.)

### 2b — Extract information from the data

Extract everything relevant from the user-provided data:
- **People:** names, roles, titles, what they own or are responsible for
- **Components:** repos, services, tools, systems mentioned
- **Relationships:** how components connect, who depends on what
- **Goals / plans / roadmap items:** deliverables, deadlines, expectations, focus areas
- **Progress signals:** completed work, blockers, new assignments, status updates

### 2c — Map against existing plan (if one exists)

If `OBSIDIAN_MD` already has a Plan Checklist (Section 3), map the new findings against it:
- Which checklist items does this new data affect?
- Are there new people who should be assigned to existing plan items?
- Does the data reveal new sub-tasks needed under existing goals?
- Should any checklist items be marked as done or blocked?

If no plan exists yet, use the goals/roadmap extracted from the data to create one.

If the data contains no goals or plan information, and no plan exists yet, use AskUserQuestion to ask the user to describe their goals or roadmap.

---

## Step 3 — Write or update `OBSIDIAN_MD` (base knowledge)

Write or update `OBSIDIAN_MD` with three sections. Add `> Last updated: YYYY-MM-DD` at the top.

### Section 1: System Diagram & Component Summary

A markdown table with columns: `Component | Description | Stack | Owner | Status`
- Status values: `active`, `new`, `changed`
- Only include components found in user-provided data (current + previous runs)
- If updating, add new components with status `new`, mark changed ones as `changed`

Follow the table with **Mermaid diagrams** using ` ```mermaid ` fenced code blocks (renders natively in Obsidian). Create separate diagrams for distinct concerns:

- **System Architecture** — `graph TB` showing infrastructure planes, core services, AI/ML layer, observability. Use `subgraph` blocks to group by functional area. Label edges with relationship type.
- **CI/CD Pipeline** — `graph LR` showing the build/deploy flow.
- **Data / Model Pipeline** — `graph LR` if model training or data flows exist in the data.

Mermaid rules:
- Use `<br/>` for line breaks inside node labels
- Use `<i>...</i>` for secondary info (stack, notes)
- Use `subgraph Name["Display Title"]` for grouping
- Label edges: `-->|"label"|`
- Keep node IDs short and lowercase (e.g. `infra`, `agent`, `rmq`)

### Section 2: Team Personas

For each person found in the data:

**[Name]** — [Role/Title]
- **Owns:** [list of components or repos]
- **Focus:** [current goals or responsibilities]
- **Contact for:** [what situations to involve this person]

If updating, merge new info into existing personas and mark updates with the current date.

### Section 3: Plan Checklist

A checklist of goals and tasks extracted from user data, assigned to personas:

```
- [ ] Task description — **Owner: Name** — _Component: repo-name_
  - Note: [status update or blocker, dated]
```

Rules for updating:
- **Preserve** all existing items — never delete or overwrite completed items (`[x]`)
- **Check off** items (`[x]`) if the new data shows they are done
- **Add sub-tasks** under existing goals if the data reveals needed work
- **Assign owners** to unassigned items if the data reveals who should own them
- **Add notes** (indented under items) for blockers or status updates found in the data

---

## Step 4 — Write or update `OBSIDIAN_CANVAS` (relationship graph)

Create or update `OBSIDIAN_CANVAS` — an Obsidian Canvas file (JSON format) that visualizes the system as an interactive node-and-edge graph, **grouped by functional area**.

### Canvas JSON structure

```json
{
  "nodes": [
    {
      "id": "unique-id",
      "type": "text",
      "text": "## Title\n**Owner: Name**\n\nDescription",
      "x": 0, "y": 0,
      "width": 320, "height": 150,
      "color": "1"
    }
  ],
  "edges": [
    {
      "id": "edge-id",
      "fromNode": "source-id",
      "fromSide": "bottom",
      "toNode": "target-id",
      "toSide": "top",
      "label": "relationship"
    }
  ]
}
```

### Grouping by functional area

Lay out nodes in spatial clusters by function. Use consistent x-ranges for each group:

| Functional Group | Color | x-range (approx) | Description |
|---|---|---|---|
| Infrastructure / Platform | `"1"` (red) | center, top | Infra, control plane, service clusters, inference |
| Core Services | `"4"` (blue) | center | Backend services, job queues, message brokers |
| AI / ML | `"3"` (green) | right of center | Model integration, RAG, training pipelines |
| Observability | `"2"` (orange) | top corners | Grafana, PagerDuty, monitors |
| New / Q2 Work | `"5"` (magenta) | far right | New models, new features, upcoming projects |
| Supporting Services | `"6"` (cyan) | bottom | CI/CD, external tools, middleware |
| Team Personas | `"0"` (grey) | far left column | One node per person with ownership summary |

### Node content format

Each node's `text` field should use markdown:
```
## Component Name
**Owner: Name**

Key detail 1
Key detail 2
_Italic note for planned/future state_
```

### Edge rules

- Every relationship extracted from the data should have an edge
- Use `label` to describe the relationship (e.g. "provisions", "posts jobs", "monitors", "deploy Q2")
- Use `fromSide` / `toSide` values: `"top"`, `"bottom"`, `"left"`, `"right"`
- Persona nodes connect to their primary owned component
- New models/features connect to their deployment target

### Updating an existing canvas

When `OBSIDIAN_CANVAS` already exists:
- Read the existing JSON
- Add new nodes for new components/people (with status indicators like 🆕)
- Add new edges for new relationships
- Update existing node text if ownership or descriptions changed
- Preserve node positions (`x`, `y`) for existing nodes — only reposition if the layout is broken
- Remove nodes/edges for components that no longer exist in the data

---

## Step 5 — Report

After writing both files, summarize in chat:
- What data was processed
- Which personas were added or updated
- Which components were added or changed
- Which checklist items were affected (new, completed, reassigned, blocked)
- Canvas changes (nodes/edges added or updated)
- Full paths to both updated files
