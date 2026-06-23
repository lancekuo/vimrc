---
description: "Search across all past Claude Code sessions by metadata or full message content"
usage: '/search-sessions "query" [--deep] [--limit N] [--project FILTER]'
---

# Search Sessions

Search across all past Claude Code session history.

**Modes:**
- **Index search (default)**: Searches session metadata (summary, firstPrompt, projectPath, gitBranch). Near-instant.
- **Deep search (`--deep`)**: Searches actual message text via ripgrep. Sub-second.

**Options:**
- `--deep` — Search full message content
- `--limit N` — Maximum results (default: 20)
- `--project FILTER` — Filter to projects matching substring

**Examples:**
```
/search-sessions "kubernetes RBAC"
/search-sessions "auth flow" --deep
/search-sessions "billing" --project myapp
```

!search-sessions {{$1}}

Present the results to the user. If index search returned no results, suggest trying `--deep`.
