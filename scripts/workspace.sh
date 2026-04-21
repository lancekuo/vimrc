#!/usr/bin/env bash
# Workspace launcher – creates a tmux session with predefined windows.
# Usage: ~/.tmux/scripts/workspace.sh [session-name]

SESSION="${1:-work}"

# If already inside this session, bail
if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Session '$SESSION' already exists. Attaching..."
  exec tmux attach-session -t "$SESSION"
fi

# Window 0: k9s — start with aws sso login, then k9s
tmux new-session -d -s "$SESSION" -n k9s
tmux send-keys -t "$SESSION:0" 'aws sso login && k9s' Enter

# Window 1: claude — resume session
tmux new-window -t "$SESSION" -n claude
tmux send-keys -t "$SESSION:1" 'cd ~/project && claude --resume' Enter

# Window 2: eks-ts — claude for EKS troubleshooting
tmux new-window -t "$SESSION" -n eks-ts
tmux send-keys -t "$SESSION:2" 'cd ~/project && claude "we are going to troubleshoot our eks issue, get ready to use kubectl"' Enter

# Window 3: chore — general purpose
tmux new-window -t "$SESSION" -n chore
tmux send-keys -t "$SESSION:3" 'cd ~/project' Enter

# Window 9: agtop - monitor Claude Code / Codex sessions
tmux new-window -t "$SESSION:9" -n usage
tmux send-keys -t "$SESSION:9" 'agtop' Enter

# Start on window 0
tmux select-window -t "$SESSION:0"
tmux attach-session -t "$SESSION"
