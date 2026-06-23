#!/bin/bash
# statusline-wrapper.sh — Compose caveman badge + Claude Code context-usage gauge.
# Reads Claude Code's statusLine JSON on stdin; calls caveman-statusline.sh
# (which doesn't itself read stdin); appends a context-percentage chip.

set -u

input=$(cat)

CAVEMAN_HOOK=$(ls -t "$HOME/.claude/plugins/cache/caveman/caveman/"*/src/hooks/caveman-statusline.sh 2>/dev/null | head -n 1)
CAVEMAN=$([ -n "$CAVEMAN_HOOK" ] && bash "$CAVEMAN_HOOK" 2>/dev/null || true)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
SESSION_ID=$(echo "$input" | jq -r '.session_id')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

GIT_STATUS=""
CACHE_FILE="/tmp/statusline-git-cache-$SESSION_ID"
CACHE_MAX_AGE=5  # seconds

cache_is_stale() {
    [ ! -f "$CACHE_FILE" ] || \
    # stat -f %m is macOS, stat -c %Y is Linux
    [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]
}

if cache_is_stale; then
    if git rev-parse --git-dir > /dev/null 2>&1; then
        BRANCH=$(git branch --show-current 2>/dev/null)
        STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        echo "$BRANCH|$STAGED|$MODIFIED" > "$CACHE_FILE"
    else
        echo "||" > "$CACHE_FILE"
    fi
fi

IFS='|' read -r BRANCH STAGED MODIFIED < "$CACHE_FILE"

if [ -n "$BRANCH" ]; then
    GIT_STATUS="🌿 $BRANCH ${GREEN}+$STAGED${YELLOW}~$MODIFIED${RESET}"
fi

LINE=""
[ -n "$CAVEMAN" ] && LINE+="${CAVEMAN}${RESET} | "
LINE+="${PCT}% | ${DIR}"
[ -n "$GIT_STATUS" ] && LINE+=" ${GIT_STATUS}"
printf '%b\n' "$LINE"

