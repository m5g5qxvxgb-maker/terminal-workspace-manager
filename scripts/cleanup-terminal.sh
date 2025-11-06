#!/bin/bash

# Cleanup terminal session when workspace is deleted
# Usage: ./cleanup-terminal.sh <workspace_id>

WORKSPACE_ID=$1

if [ -z "$WORKSPACE_ID" ]; then
    echo "Usage: $0 <workspace_id>"
    exit 1
fi

SESSION_NAME="terminal-$WORKSPACE_ID"
PORT=$((7680 + WORKSPACE_ID))

echo "Cleaning up workspace $WORKSPACE_ID..."

# Kill ttyd process
if pgrep -f "ttyd.*-p $PORT" > /dev/null; then
    echo "Stopping ttyd on port $PORT..."
    pkill -f "ttyd.*-p $PORT"
fi

# Kill tmux session
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Killing tmux session: $SESSION_NAME"
    tmux kill-session -t "$SESSION_NAME"
fi

# Remove title file
rm -f "/var/www/terminal/api/title-$WORKSPACE_ID.json"

echo "✅ Workspace $WORKSPACE_ID cleaned up"
