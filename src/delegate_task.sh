#!/bin/bash

# Task delegation helper script for Manager Agent
# Usage: ./delegate_task.sh "task description" "objective" "requirements" "branch_name"

TASK_DESC="$1"
OBJECTIVE="$2"
REQUIREMENTS="$3"
BRANCH_NAME="$4"
SESSION_NAME="claude_team"
DEVELOPER_PANE="$SESSION_NAME:0.2"

# Check if tmux session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Error: Claude Team session '$SESSION_NAME' not found"
    exit 1
fi

# Create the task assignment message
TASK_MESSAGE="🔧 TASK ASSIGNMENT for Developer Agent:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 SUBTASK: $TASK_DESC
🎯 OBJECTIVE: $OBJECTIVE
📝 REQUIREMENTS: $REQUIREMENTS
🌿 BRANCH: $BRANCH_NAME
🔄 REPORT BACK: Please confirm completion when done
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Please acknowledge this task assignment and proceed with implementation."

# Send the task directly to Developer Agent as user input
tmux send-keys -t "$DEVELOPER_PANE" "$TASK_MESSAGE" && sleep 0.1 && tmux send-keys -t "$DEVELOPER_PANE" Enter

echo "✅ Task delegated to Developer Agent successfully!"