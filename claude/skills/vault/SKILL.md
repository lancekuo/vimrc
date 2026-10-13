---
name: vault
description: "Use when saving a design spec or implementation plan (superpowers brainstorming / writing-plans), or creating/moving/editing a CLAUDE*.md or AGENTS*.md in ~/project, or any doc meant for the Obsidian vault, or when asked where the Obsidian vault / notes / plans folder is on this machine. Resolves the iCloud-synced per-host vault folder from the hostname and keeps superpowers specs and plans there instead of in a repo's docs/, and keeps CLAUDE*/AGENTS*.md as vault files symlinked into ~/project."
---

# vault — per-host Obsidian folder (iCloud-synced)

The Obsidian vault syncs through iCloud. Each computer gets its own folder named after its **short hostname**, so plans and designs from different machines never collide.

## 1. Resolve this machine's vault folder

```bash
ROOT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/2023/plan"
VAULT="$ROOT/$(hostname -s)"
ls -d "$VAULT"
```

- Use `hostname -s` (e.g. `MacBook-Pro`). **Not** `hostname` (`MacBook-Pro.local`), and **not** `scutil --get ComputerName` / `LocalHostName` (e.g. `Lance-MacBook-Pro-DR9J0`) — those don't match the folder name.
- The path contains spaces: always quote `"$VAULT"`.
- If `$VAULT` does not exist: `ls "$ROOT"` and ask the user which folder is this machine's (hostname may have changed) before creating a new host folder. Never guess-create.
- `$VAULT/<hostname>.md` is the machine's base knowledge note.

## 2. Ensure the superpowers folders

```bash
mkdir -p "$VAULT/superpowers/specs" "$VAULT/superpowers/plans"
```

Same layout as the superpowers defaults, relocated from the repo into the vault:

| Superpowers skill | Default (don't use) | Save here instead |
|---|---|---|
| `brainstorming` (design spec) | `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` | `"$VAULT/superpowers/specs/YYYY-MM-DD-<topic>-design.md"` |
| `writing-plans` (implementation plan) | `docs/superpowers/plans/YYYY-MM-DD-<feature>.md` | `"$VAULT/superpowers/plans/YYYY-MM-DD-<feature>.md"` |

Both superpowers skills state "user preferences for location override this default" — this skill is that preference. Keep the date-prefixed filenames. Don't drop specs/plans loose at `$ROOT` or `$VAULT` root, and don't commit them to the repo unless the user asks.

## 3. Agent instruction files: `CLAUDE*.md` / `AGENTS*.md` live in the vault

Rule: every `CLAUDE*.md` and `AGENTS*.md` for the `~/project/` workspace root is a **real file in `$VAULT`**, and `~/project/` holds only a **symlink** to it. The vault copy syncs to every machine; a plain file in `~/project/` does not.

Scope: only files at the `~/project/` root. A `CLAUDE.md` / `AGENTS.md` tracked inside a git repo (e.g. `~/project/cogni-agent-ops/CLAUDE.md`) belongs to that repo — leave it there.

**Create a new one** — write it in the vault, then link:

```bash
ln -s "$VAULT/CLAUDE_NEW.md" "$HOME/project/CLAUDE_NEW.md"
```

**Adopt a plain local file** — move it into the vault (refuse if the vault already has that name), then link back:

```bash
f=CLAUDE_X.md
[ -L "$HOME/project/$f" ] || { [ -e "$VAULT/$f" ] && echo "COLLISION $f" || { mv "$HOME/project/$f" "$VAULT/$f" && ln -s "$VAULT/$f" "$HOME/project/$f"; }; }
```

**Audit** — run after creating or renaming any of these files:

```bash
cd "$HOME/project"
for f in CLAUDE*.md AGENTS*.md; do
  [ -e "$f" ] || [ -L "$f" ] || continue
  if [ -L "$f" ]; then [ -e "$f" ] || echo "BROKEN LINK $f"; else echo "PLAIN (adopt) $f"; fi
done
for f in "$VAULT"/CLAUDE*.md "$VAULT"/AGENTS*.md; do
  [ -e "$f" ] && [ ! -L "$HOME/project/$(basename "$f")" ] && echo "MISSING LINK $(basename "$f")"
done
```

**Editing through the link**
- Use the Edit tool or Python `open(p,'w')` — both write through and keep the link.
- macOS `sed -i` refuses symlinks (`in-place editing only works for regular files`).
- Never `mv`/`cp`/`Write` a fresh file over the link path — that replaces the symlink with a non-synced local copy. Check `[ -L "$HOME/project/$f" ]` after bulk edits.

## Gotchas

- **Deleting inside the iCloud container deletes on every device.** Never `rm` there; `mv` to `~/.Trash/` so it stays recoverable. To retire a linked doc: trash the vault file **and** `rm` the dangling link in `~/project/`.
- Other docs meant to sync follow the same pattern as §3: real file in `$VAULT`, symlink into the project if a session needs it.
- Old docs move to `"$VAULT/archived/"`, not the Trash, unless the user says delete.
