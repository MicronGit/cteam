#!/bin/bash

set -e

# Source modules
. "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
. "$(dirname "${BASH_SOURCE[0]}")/validator.sh"

# Task delegation helper script for Manager Agent
# Usage: ./delegate_task.sh "task description" "objective" "requirements" "branch_name"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${5:-$(pwd)}"

# Source configuration
eval "$("$SCRIPT_DIR/config.sh" "$PROJECT_ROOT")"

TASK_DESC="$1"
OBJECTIVE="$2"
REQUIREMENTS="$3"
BRANCH_NAME="$4"

# Validate inputs
validate_required_param "$TASK_DESC" "task_description" || exit 1
validate_required_param "$OBJECTIVE" "objective" || exit 1
validate_required_param "$REQUIREMENTS" "requirements" || exit 1

# Validate session and pane
validate_session "$SESSION_NAME" || exit 1
validate_pane "$SESSION_NAME" "2" || exit 1

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

# Log the task delegation
"$SCRIPT_DIR/history_logger.sh" log_delegation "$TASK_DESC" "$OBJECTIVE" "$REQUIREMENTS" "$BRANCH_NAME"

log_success "Task delegated to Developer Agent successfully!"