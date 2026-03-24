---
name: acli
description: Use this skill when the user asks about Jira operations, tickets, issues, sprints, comments, assignments, or status transitions. Keywords: jira, acli, ticket, issue, sprint, SIM-, comment, assign, transition, move, workitem.
---

# Jira CLI (acli)

Use `acli jira` for all Jira operations.

## Installation

```bash
brew tap atlassian/homebrew-acli
brew install acli
```

## Configuration

- **Site**: stored in `$ATLASSIAN_SITE` (e.g. `yourorg.atlassian.net`)
- **Email**: stored in `$ATLASSIAN_EMAIL`
- **Token**: stored in `$ATLASSIAN_TOKEN`

All three are set in `~/.bash_profile`.

## Authentication

Re-authenticate if you see `Unauthorized`:

```bash
echo "$ATLASSIAN_TOKEN" | acli jira auth login --site "$ATLASSIAN_SITE" --email "$ATLASSIAN_EMAIL" --token
```

## Command Reference

| Command | Purpose |
|---|---|
| `acli jira workitem view <KEY>` | View issue details |
| `acli jira workitem list` | List issues |
| `acli jira workitem create` | Create a new issue |
| `acli jira workitem edit <KEY>` | Edit an issue |
| `acli jira workitem comment add <KEY>` | Add a comment |
| `acli jira workitem assign <KEY>` | Assign an issue |
| `acli jira workitem move <KEY>` | Transition issue status |
| `acli jira sprint list` | List sprints |
