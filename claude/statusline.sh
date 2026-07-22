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

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; TRUE_RESET='\033[0m'

# --- GPG signing-key cache status -> statusline background ---
GPG_CACHE_FILE="/tmp/statusline-gpg-cache-$SESSION_ID"
GPG_CACHE_MAX_AGE=5  # seconds

gpg_cache_is_stale() {
    [ ! -f "$GPG_CACHE_FILE" ] || \
    [ $(($(date +%s) - $(stat -f %m "$GPG_CACHE_FILE" 2>/dev/null || stat -c %Y "$GPG_CACHE_FILE" 2>/dev/null || echo 0))) -gt $GPG_CACHE_MAX_AGE ]
}

if gpg_cache_is_stale; then
    GIT_EMAIL=$(git config --global user.email 2>/dev/null)
    KEYGRIP=$(gpg --with-keygrip --list-secret-keys "$GIT_EMAIL" 2>/dev/null | awk '/Keygrip/{print $3; exit}')
    if [ -n "$KEYGRIP" ]; then
        CACHED_FLAG=$(gpg-connect-agent 'keyinfo --list' /bye 2>/dev/null | awk -v kg="$KEYGRIP" '$3 == kg {print $7}')
        [ "$CACHED_FLAG" = "1" ] && echo "CACHED" > "$GPG_CACHE_FILE" || echo "EXPIRED" > "$GPG_CACHE_FILE"
    else
        echo "NONE" > "$GPG_CACHE_FILE"
    fi
fi
GPG_STATE=$(cat "$GPG_CACHE_FILE" 2>/dev/null)

BG_BLACK='\033[40m'; BG_YELLOW='\033[43m'
# sign cmd primes gpg-agent cache (forces pinentry) so git commit won't hang
GPG_SIGN_CMD='echo x | gpg --clearsign'
[ "$GPG_STATE" = "CACHED" ] && { GPG_BG="$BG_BLACK"; GPG_ICON=""; } || { GPG_BG="$BG_YELLOW"; GPG_ICON="🔑 ${GPG_SIGN_CMD} "; }

# any inline "reset" clears attrs then re-asserts the chosen background,
# so fg colors below don't blow away the outer bg chip
RESET="${TRUE_RESET}${GPG_BG}"

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

LINE="${GPG_BG}${GPG_ICON}"
[ -n "$CAVEMAN" ] && LINE+="${CAVEMAN}${RESET} | "
LINE+="${PCT}% | ${MODEL} | ${DIR} "
[ -n "$GIT_STATUS" ] && LINE+=" ${GIT_STATUS}"
printf '%b\n' "${LINE}${TRUE_RESET}"

