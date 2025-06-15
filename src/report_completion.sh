#!/bin/bash

# Task completion report helper script for Developer Agent
# Usage: ./report_completion.sh "completed_task" "implementation_summary" "testing_status" "files_modified" "ready_for"

COMPLETED_TASK="$1"
IMPLEMENTATION_SUMMARY="$2"
TESTING_STATUS="$3"
FILES_MODIFIED="$4"
READY_FOR="$5"
SESSION_NAME="claude_team"
MANAGER_PANE="$SESSION_NAME:0.1"

# Check if tmux session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Error: Claude Team session '$SESSION_NAME' not found"
    exit 1
fi

# Create the completion report message
COMPLETION_MESSAGE="✅ TASK COMPLETION REPORT to Manager Agent:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 COMPLETED TASK: $COMPLETED_TASK
✨ IMPLEMENTATION SUMMARY: $IMPLEMENTATION_SUMMARY
🧪 TESTING STATUS: $TESTING_STATUS
📁 FILES MODIFIED: $FILES_MODIFIED
🚀 READY FOR: $READY_FOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Task completed successfully. Please review and proceed with next steps if needed."

# Send the completion report directly to Manager Agent as user input
tmux send-keys -t "$MANAGER_PANE" "$COMPLETION_MESSAGE" && sleep 0.1 && tmux send-keys -t "$MANAGER_PANE" Enter

echo "✅ Completion report sent to Manager Agent successfully!"