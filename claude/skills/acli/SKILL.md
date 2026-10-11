---
name: acli
description: "Use when working with Jira Cloud from the terminal or scripts via acli (Atlassian CLI) — JQL searches, reading tickets or custom fields, posting formatted comments or ticket descriptions (headings, tables, ADF), bulk operations, an `InvalidPayloadException: INVALID_INPUT` / \"can't be edited\" failure, or when Jira MCP tools are unavailable or overflow context."
---

# acli — Atlassian CLI (Jira Cloud)

## Overview

Official Atlassian CLI (`brew install acli`). Command tree: `acli jira <group> <verb>`; tickets live under `workitem` (NOT `issue` — that's Bob Swift's third-party ACLI). `--json` output pipes cleanly to `jq`, so it suits bulk/scripted reads without MCP context blowup.

Check auth first: `acli jira auth status`

## Quick reference (verified on v1.3.22)

| Task | Command |
|---|---|
| JQL search | `acli jira workitem search --jql "..." --limit 50 --json` |
| View ticket, all fields | `acli jira workitem view KEY-1 --fields "*all" --json` |
| View specific fields | `acli jira workitem view KEY-1 --fields "summary,customfield_10034" --json` |
| Create comment | `acli jira workitem comment create --key KEY-1 --body-file adf.json` |
| Update comment | `acli jira workitem comment update --key KEY-1 --id <id> --body-adf adf.json` |
| Delete comment | `acli jira workitem comment delete --key KEY-1 --id <id>` |

Also available (not covered here): `workitem create/edit/assign/transition/link`, `sprint`, `board`, `project`, `filter`. Run `--help` per subcommand.

## Gotchas — each verified live

| Trap | Reality |
|---|---|
| `view --key KEY-1` | Unknown flag. `view` takes the key positionally: `view KEY-1` |
| Custom fields in `search --fields` | Rejected — strict whitelist (issuetype,key,assignee,priority,status,summary). `*all` also rejected. Pattern: `search` for keys, then `view --fields` per key |
| Markdown in comment body | Renders as literal `# text` characters. Body is plain text or ADF JSON only — formatted comments require ADF |
| Verifying formatting via `comment list` | Flattens body to one plain string and silently drops bullet-item text. Use `view KEY-1 --fields comment --json` for raw ADF |
| Comment flag asymmetry | `update` has a dedicated `--body-adf <file>` flag; `create` doesn't — it auto-detects ADF passed via `--body-file` / `--body` |
| `comment delete` | Fires immediately, no confirmation prompt — careful in scripts |
| Comment delete id flag | `--id`, not `--comment-id`. Get it: `comment list --key KEY-1 --json \| jq -r '.comments[-1].id'` (shape is `{comments: [...]}`, not a bare array) |
| Finding custom field IDs | No `field list` subcommand. Use `view KEY-1 --fields "*all" --json \| jq '.fields \| keys'` on a representative ticket |

## ADF for formatted comments

Write ADF JSON to a file, pass via `--body-file` (create) or `--body-adf` (update). Skeleton with the common nodes:

```json
{ "version": 1, "type": "doc", "content": [
  { "type": "heading", "attrs": {"level": 1}, "content": [{"type":"text","text":"Title"}] },
  { "type": "paragraph", "content": [
    {"type":"text","text":"bold","marks":[{"type":"strong"}]},
    {"type":"text","text":" code","marks":[{"type":"code"}]} ] },
  { "type": "bulletList", "content": [
    { "type": "listItem", "content": [
      { "type": "paragraph", "content": [{"type":"text","text":"item"}] } ] } ] },
  { "type": "table", "attrs": {"isNumberColumnEnabled": false, "layout": "default"}, "content": [
    { "type": "tableRow", "content": [
      { "type": "tableHeader", "attrs": {}, "content": [{ "type": "paragraph", "content": [{"type":"text","text":"Col"}] }] } ] },
    { "type": "tableRow", "content": [
      { "type": "tableCell", "attrs": {}, "content": [{ "type": "paragraph", "content": [{"type":"text","text":"val"}] }] } ] } ] },
  { "type": "codeBlock", "attrs": {"language": "bash"}, "content": [{"type":"text","text":"echo hi"}] }
] }
```

Rules: table cells and list items always wrap text in a `paragraph`; header row uses `tableHeader`, data rows `tableCell`; inline marks (`strong`, `em`, `code`) survive the round-trip. Descriptions on `workitem create/edit` use the same ADF format.

## Posting rule — write to a file, check the rules, then post (mandatory)

Any malformed ADF makes acli fail with an opaque, permission-looking error:

```
✗ Failure: KEY-1 can't be edited: io.atlassian.micros.clibackend.exceptions.InvalidPayloadException: INVALID_INPUT, INVALID_INPUT
```

It is **not** a permission problem and nothing gets posted, so a retry after fixing is safe. Never pass ADF inline via `--body '<json>'` or `$(cat …)` — shell quoting mangles it. Always:

1. Build the ADF with a script (Python `json.dump`, not hand-typed JSON) into `$CLAUDE_JOB_DIR/tmp/<KEY>-comment.json` (or a `mktemp` file outside a job).
2. Before posting, check the file against every rule in the table below.
3. Post with `--body-file <file>` (`comment create`, `workitem create/edit` description) or `--body-adf <file>` (`comment update`).
4. Verify server-side (section below).

Causes seen live (each produced the error above):

| Cause | Fix |
|---|---|
| `text` value is a dict, not a string — Python helper `p((t("x")))`: single-element parentheses are not a tuple, so a node got nested inside `text` | Pass lists/`*args` explicitly; every `text` value must be a non-empty string |
| Raw string inside a `content` array (e.g. paragraph content `["foo"]`) | Every `content` entry must be a node object `{"type":…}` |
| Empty text node `{"type":"text","text":""}` (e.g. blank table cell) | Omit the text node: an empty cell is `{"type":"paragraph"}` with no content |
| `code` mark combined with `strong`/`em` | `code` may only pair with `link`; drop the other mark |
| Bare `text` directly under `listItem` / `tableCell` | Wrap in a `paragraph` |

## Verify a posted comment server-side

```bash
acli jira workitem view KEY-1 --fields comment --json \
  | jq '[.fields.comment.comments[-1].body.content[].type]'
# expect e.g. ["heading","paragraph","bulletList","table"]
```
