#!/bin/bash

set -e

# Source modules
. "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
. "$(dirname "${BASH_SOURCE[0]}")/validator.sh"

# Simple completion report script for Developer Agent
# Usage: ./complete.sh "task description"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${2:-$(pwd)}"

# Source configuration
eval "$("$SCRIPT_DIR/config.sh" "$PROJECT_ROOT")"

TASK_DESC="$1"

# Validate inputs
validate_required_param "$TASK_DESC" "task_description" || exit 1

if [ $# -lt 1 ]; then
    log_error "Usage: ./complete.sh \"task description\""
    exit 1
fi

# Validate session and pane
validate_session "$SESSION_NAME" || exit 1
validate_pane "$SESSION_NAME" "1" || exit 1

# Create a simple completion message
COMPLETION_MESSAGE="✅ TASK COMPLETED: $TASK_DESC

Please review the completed work and let me know if you need any modifications or have additional tasks."

# Send the completion report to Manager Agent
tmux send-keys -t "$MANAGER_PANE" "$COMPLETION_MESSAGE" && sleep 0.1 && tmux send-keys -t "$MANAGER_PANE" Enter

log_success "Task completion notification sent to Manager Agent!"