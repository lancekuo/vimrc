---
name: gitlab
description: "GitLab operations via glab CLI. Use when user mentions: MR, merge request, gitlab issue, pipeline, CI status, glab, or when git remote shows gitlab.com or self-hosted GitLab."
---

# GitLab CLI (glab)

## When to Use This Skill

Use `glab` for GitLab repositories. To detect GitLab:

```bash
git remote -v | grep -i gitlab
````

If the remote contains `gitlab.com` or a known GitLab instance, use this skill.

## Before Any Operation

Always verify authentication first:

```bash
glab auth status
```

If not authenticated, guide the user to run:

```bash
glab auth login
```

## Behavioral Guidelines

1. **Creating MRs**: Always check for uncommitted changes first with `git status`
2. **Viewing MRs/Issues**: Prefer `--comments` flag when user wants full context
3. **CI Operations**: Check `glab ci status` before suggesting `glab ci run`
4. **Use `--web`**: When the user might benefit from the browser UI
5. **MR/issue descriptions with code blocks**:

   * Pass `--description` as a direct string
   * Never use `$()` with a heredoc
   * Triple backticks inside `$()` get escaped as `\```` and break rendering

Example:

```bash
glab mr create --title "..." --description "## Summary

\`\`\`bash
some command
\`\`\`
"
```

### Using the API Command

The `glab api` command provides direct GitLab API access:

```bash
# Basic API call
glab api projects/:id/merge_requests

# IMPORTANT: Pagination uses query parameters in URL, NOT flags
# ❌ WRONG: glab api --per-page=100 projects/:id/jobs
# ✓ CORRECT: glab api "projects/:id/jobs?per_page=100"

# Auto-fetch all pages
glab api --paginate "projects/:id/pipelines/123/jobs?per_page=100"

# POST with data
glab api --method POST projects/:id/issues --field title="Bug" --field description="Details"
```

## Best Practices

1. **Verify authentication** before executing commands: `glab auth status`
2. **Use `--help`** to explore command options: `glab <command> --help`
3. **Link MRs to issues** using "Closes #123" in MR description
4. **Lint CI config** before pushing: `glab ci lint`
5. **Check repository context** when commands fail: `git remote -v`

## Common Commands Quick Reference

**Merge Requests:**
- `glab mr list --assignee=@me` - Your assigned MRs
- `glab mr list --reviewer=@me` - MRs for you to review
- `glab mr create` - Create new MR
- `glab mr checkout <number>` - Test MR locally
- `glab mr approve <number>` - Approve MR
- `glab mr merge <number>` - Merge approved MR

**Issues:**
- `glab issue list` - List all issues
- `glab issue create` - Create new issue
- `glab issue close <number>` - Close issue

**CI/CD:**
- `glab pipeline ci view` - Watch pipeline
- `glab ci status` - Check status
- `glab ci lint` - Validate .gitlab-ci.yml
- `glab ci retry` - Retry failed pipeline

**Repository:**
- `glab repo clone owner/repo` - Clone repository
- `glab repo view` - View repo details
- `glab repo fork` - Fork repository
