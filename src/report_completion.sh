#!/bin/bash

set -e

# Source modules
. "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
. "$(dirname "${BASH_SOURCE[0]}")/validator.sh"

# Task completion report helper script for Developer Agent
# Usage: ./report_completion.sh "completed_task" "implementation_summary" "testing_status" "files_modified" "ready_for"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${6:-$(pwd)}"

# Source configuration
eval "$("$SCRIPT_DIR/config.sh" "$PROJECT_ROOT")"

COMPLETED_TASK="$1"
IMPLEMENTATION_SUMMARY="$2"
TESTING_STATUS="$3"
FILES_MODIFIED="$4"
READY_FOR="$5"

# Validate inputs
validate_required_param "$COMPLETED_TASK" "completed_task" || exit 1
validate_required_param "$IMPLEMENTATION_SUMMARY" "implementation_summary" || exit 1
validate_required_param "$TESTING_STATUS" "testing_status" || exit 1

# Validate session and pane
validate_session "$SESSION_NAME" || exit 1
validate_pane "$SESSION_NAME" "1" || exit 1

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

# Log the completion report
"$SCRIPT_DIR/history_logger.sh" log_completion "$COMPLETED_TASK" "$IMPLEMENTATION_SUMMARY" "$TESTING_STATUS" "$FILES_MODIFIED" "$READY_FOR"

log_success "Completion report sent to Manager Agent successfully!"