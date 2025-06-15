#!/bin/bash

# Simple completion report script for Developer Agent
# Usage: ./complete.sh "task description"

TASK_DESC="$1"
SESSION_NAME="claude_team"
MANAGER_PANE="$SESSION_NAME:0.1"

if [ -z "$TASK_DESC" ]; then
    echo "Usage: ./complete.sh \"task description\""
    exit 1
fi

# Check if tmux session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Error: Claude Team session '$SESSION_NAME' not found"
    exit 1
fi

# Create a simple completion message
COMPLETION_MESSAGE="✅ TASK COMPLETED: $TASK_DESC

Please review the completed work and let me know if you need any modifications or have additional tasks."

# Send the completion report to Manager Agent
tmux send-keys -t "$MANAGER_PANE" "$COMPLETION_MESSAGE" && sleep 0.1 && tmux send-keys -t "$MANAGER_PANE" Enter

echo "✅ Task completion notification sent to Manager Agent!"