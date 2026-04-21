---
name: life-align
description: Processes user-provided data (file paths, URLs) to maintain an Obsidian base knowledge file ({hostname}.md) with system diagrams, personas, plan checklist, and deliverables tracker. Syncs deliverable statuses and phases. Only uses data the user provides. Invoke with data sources to populate or update.
argument-hint: [<path-or-url> ...] [--canvas]
allowed-tools: Read, Write, Edit, WebFetch, Glob, Grep, Bash, AskUserQuestion
---

## Setup

All output files live under a hostname-specific directory in the user's Obsidian vault.

Resolve paths by running:
```bash
HOSTNAME=$(hostname -s)
BASE="${LIFE_ALIGN_VAULT:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/2023/plan}"
VAULT="$BASE/$HOSTNAME"
```

Directory structure:
```
{VAULT}/
  {hostname}.md                ← base knowledge (main output)
  superpowers/plans/           ← implementation plans
  meetings/                    ← meeting notes per person
  deliverables/                ← deliverables with phase prefixes
```

Store the resolved `VAULT` and `HOSTNAME` for the rest of this skill.

### Deliverable phases

Phases are assigned during planning, not derived from filenames or file content. The phase for each deliverable is stored only in the **Deliverables Tracker table** (Section 4 of `{hostname}.md`). When adding a new deliverable to the tracker, ask the user which phase it belongs to if not obvious from context.

Example phases: `Days 1-15`, `Days 1-30`, `Days 30-60`, `Days 60-90`

### Default data locations

When no arguments are provided, automatically read from:

```
{VAULT}/{hostname}.md              ← base knowledge (read first)
{VAULT}/meetings/*                 ← meeting notes
{VAULT}/deliverables/*.md          ← deliverables (extract status, remaining tasks, phase)
{VAULT}/superpowers/plans/*.md     ← implementation plans (extract status, blockers)
```

Read all files in each directory as input data.

---

## Step 1 - Read existing state

- Read `{VAULT}/{hostname}.md` if it exists — this is the base knowledge (system map, personas, plan checklist, deliverables tracker).

This is the current state from previous runs. Keep in memory for merging.

If the file does not exist, you will create it from scratch in Step 3.

---

## Step 2 - Acquire and process user data

### 2a - Parse arguments

If `$ARGUMENTS` are provided, parse them as:
- **File paths** (e.g. `notes.md`, `/path/to/meeting.md`) → read with the Read tool
- **Directories** (ending with `/`) → list files with Bash `ls`, then read each file
- **URLs** (starting with `http`) → fetch with WebFetch
- **`clean`** → reset output file to empty state and stop
- **`--canvas`** → also generate/update the canvas file (Step 4). Without this flag, skip Step 4.

If **no arguments** are provided, automatically read from the **default data locations** defined in Setup.

This means running `/life-align` with no args will re-process all known meetings, deliverables, and plans against the current base knowledge.

If arguments are provided but unclear, use AskUserQuestion to clarify:
- What kind of data is this? (meeting notes, org chart, roadmap, etc.)

### 2b - Extract information from the data

Extract everything relevant from the user-provided data:
- **People:** names, roles, titles, what they own or are responsible for
- **Components:** repos, services, tools, systems mentioned
- **Relationships:** how components connect, who depends on what
- **Goals / plans / roadmap items:** deliverables, deadlines, expectations, focus areas
- **Progress signals:** completed work, blockers, new assignments, status updates

### 2c - Sync deliverable statuses

Read each file in `{VAULT}/deliverables/*.md` and extract:
- **Phase** from filename prefix (see Deliverable phases table)
- **Status** from the file content (look for `Status:`, checklist completion ratio, or explicit status lines)
- **Remaining tasks** — count unchecked `- [ ]` items
- **Blockers** — look for "blocked on", "depends on", "waiting for" patterns

Use this to update the Deliverables Tracker in Section 4 of the base knowledge file.

### 2d - Map against existing plan (if one exists)

If `{hostname}.md` already has a Plan Checklist (Section 3), map the new findings against it:
- Which checklist items does this new data affect?
- Are there new people who should be assigned to existing plan items?
- Does the data reveal new sub-tasks needed under existing goals?
- Should any checklist items be marked as done or blocked?

If no plan exists yet, use the goals/roadmap extracted from the data to create one.

If the data contains no goals or plan information, and no plan exists yet, use AskUserQuestion to ask the user to describe their goals or roadmap.

---

## Step 3 - Write or update `{hostname}.md` (base knowledge)

Write or update `{VAULT}/{hostname}.md` with four sections. Add `> Last updated: YYYY-MM-DD` at the top.

### Section 1: System Diagram & Component Summary

A markdown table with columns: `Component | Description | Stack | Owner | Status`
- Status values: `active`, `new`, `changed`
- Only include components found in user-provided data (current + previous runs)
- If updating, add new components with status `new`, mark changed ones as `changed`

Follow the table with **Mermaid diagrams** using ` ```mermaid ` fenced code blocks (renders natively in Obsidian). Create separate diagrams for distinct concerns:

- **System Architecture** - `graph TB` showing infrastructure planes, core services, AI/ML layer, observability. Use `subgraph` blocks to group by functional area. Label edges with relationship type.
- **CI/CD Pipeline** - `graph LR` showing the build/deploy flow.
- **Data / Model Pipeline** - `graph LR` if model training or data flows exist in the data.

Mermaid rules:
- Use `<br/>` for line breaks inside node labels
- Use `<i>...</i>` for secondary info (stack, notes)
- Use `subgraph Name["Display Title"]` for grouping
- Label edges: `-->|"label"|`
- Keep node IDs short and lowercase (e.g. `infra`, `agent`, `rmq`)

### Section 2: Team Personas

For each person found in the data:

**[Name]** - [Role/Title]
- **Owns:** [list of components or repos]
- **Focus:** [current goals or responsibilities]
- **Contact for:** [what situations to involve this person]

If updating, merge new info into existing personas and mark updates with the current date.

### Section 3: Plan Checklist

A checklist of goals and tasks extracted from user data, assigned to personas:

```
- [ ] Task description - **Owner: Name** - _Component: repo-name_
  - Note: [status update or blocker, dated]
```

Rules for updating:
- **Check off** items (`[x]`) if the new data shows they are done
- **Add sub-tasks** under existing goals if the data reveals needed work
- **Assign owners** to unassigned items if the data reveals who should own them
- **Add notes** (indented under items) for blockers or status updates found in the data
- **Archive completed items:** Move items that have been `[x]` for more than 2 weeks to an `### Archived` subsection at the bottom of Section 3. This keeps the active checklist focused. Never delete completed items — archive them.

### Section 4: Deliverables Tracker

A table tracking all deliverables from `{VAULT}/deliverables/`, synced from the actual files:

```
| # | Deliverable | Phase | File | Status | Remaining |
|---|-------------|-------|------|--------|-----------|
```

- **#** — deliverable number (or `--` for unnumbered)
- **Phase** — assigned during planning (e.g. Days 1-30, Days 30-60). Preserved across updates — never overwrite an existing phase assignment. If a new deliverable has no phase, ask the user.
- **File** — filename (not full path)
- **Status** — synced from file content (look for status lines, checklist completion)
- **Remaining** — count of unchecked `- [ ]` items, or "Done" if all checked

This table is the single view of delivery progress. Status and remaining tasks are synced from the actual deliverable files. Phase assignments are maintained here only — they are not stored in the deliverable files themselves.

---

## Step 4 - Write or update canvas (optional, requires `--canvas` flag)

**Skip this step unless the user passed `--canvas` in the arguments.**

Create or update `{VAULT}/{hostname}.canvas` — an Obsidian Canvas file (JSON format) that visualizes the system as an interactive node-and-edge graph, **grouped by functional area**.

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

When the canvas file already exists:
- Read the existing JSON
- Add new nodes for new components/people
- Add new edges for new relationships
- Update existing node text if ownership or descriptions changed
- Preserve node positions (`x`, `y`) for existing nodes — only reposition if the layout is broken
- Remove nodes/edges for components that no longer exist in the data

---

## Step 5 - Report

After writing files, summarize in chat:
- What data was processed
- Which personas were added or updated
- Which components were added or changed
- Which checklist items were affected (new, completed, archived, reassigned, blocked)
- Deliverables tracker changes (status updates, new deliverables, phase assignments)
- If `--canvas` was used: canvas changes (nodes/edges added or updated)
- Full paths to updated files
