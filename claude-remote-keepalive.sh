#!/bin/bash

SESSION="claude-remote"
LOG="/var/log/claude-remote-keepalive.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"
}

# Check if tmux session exists
if tmux has-session -t "$SESSION" 2>/dev/null; then
    # Session exists — check if claude is actually running inside it
    if tmux list-panes -t "$SESSION" -F "#{pane_current_command}" | grep -q "^claude$"; then
        log "Claude remote control is running. Nothing to do."
        exit 0
    else
        log "Session exists but Claude is not running. Restarting."
        tmux kill-session -t "$SESSION"
    fi
else
    log "No session found. Starting Claude remote control."
fi

# Start a new detached tmux session and launch claude with /remote-control
tmux new-session -d -s "$SESSION" -x 220 -y 50
tmux send-keys -t "$SESSION" "claude" Enter
# Wait for claude to start up, then send the /remote-control command
sleep 5
tmux send-keys -t "$SESSION" "/remote-control" Enter

log "Claude remote control session started (tmux session: $SESSION)."
