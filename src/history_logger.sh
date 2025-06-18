#!/bin/bash

set -e

# History logging functions for cteam orders
# This script manages the logging of order history including:
# - Original order instructions
# - Manager-Developer interactions
# - Task delegations
# - Completion reports
# - Final status

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
HISTORY_DIR="$PROJECT_ROOT/cteam_history"

# Source modules
. "$SCRIPT_DIR/logger.sh"

# Ensure history directory exists
mkdir -p "$HISTORY_DIR"

# Generate order ID based on timestamp
generate_order_id() {
    echo "order_$(date +%Y%m%d_%H%M%S)"
}

# Initialize a new order history file
init_order_history() {
    local order_id="$1"
    local instruction="$2"
    local history_file="$HISTORY_DIR/${order_id}.txt"
    
    cat > "$history_file" << EOF
================================================================================
CTEAM ORDER HISTORY
================================================================================
Order ID: $order_id
Timestamp: $(date '+%Y-%m-%d %H:%M:%S')
Status: IN_PROGRESS

================================================================================
ORIGINAL INSTRUCTION
================================================================================
$instruction

================================================================================
MANAGER-DEVELOPER INTERACTION LOG
================================================================================

EOF
    
    echo "$history_file"
}

# Log manager actions
log_manager_action() {
    local history_file="$1"
    local action="$2"
    local details="$3"
    
    cat >> "$history_file" << EOF
[$(date '+%H:%M:%S')] MANAGER: $action
$details

EOF
}

# Log developer actions
log_developer_action() {
    local history_file="$1"
    local action="$2"
    local details="$3"
    
    cat >> "$history_file" << EOF
[$(date '+%H:%M:%S')] DEVELOPER: $action
$details

EOF
}

# Log task delegation
log_task_delegation() {
    local history_file="$1"
    local task_desc="$2"
    local objective="$3"
    local requirements="$4"
    local branch_name="$5"
    
    log_manager_action "$history_file" "TASK_DELEGATION" "📋 TASK: $task_desc
🎯 OBJECTIVE: $objective
📝 REQUIREMENTS: $requirements
🌿 BRANCH: $branch_name"
}

# Log completion report
log_completion_report() {
    local history_file="$1"
    local completed_task="$2"
    local implementation_summary="$3"
    local testing_status="$4"
    local files_modified="$5"
    local ready_for="$6"
    
    log_developer_action "$history_file" "COMPLETION_REPORT" "📋 COMPLETED: $completed_task
✨ IMPLEMENTATION: $implementation_summary
🧪 TESTING: $testing_status
📁 FILES: $files_modified
🚀 READY FOR: $ready_for"
}

# Mark order as completed
complete_order_history() {
    local history_file="$1"
    local completion_summary="$2"
    
    # Update status in file
    sed -i 's/Status: IN_PROGRESS/Status: COMPLETED/' "$history_file"
    
    cat >> "$history_file" << EOF

================================================================================
ORDER COMPLETION SUMMARY
================================================================================
Completed at: $(date '+%Y-%m-%d %H:%M:%S')
Summary: $completion_summary

================================================================================
END OF ORDER HISTORY
================================================================================
EOF
}

# Mark order as failed
fail_order_history() {
    local history_file="$1"
    local failure_reason="$2"
    
    # Update status in file
    sed -i 's/Status: IN_PROGRESS/Status: FAILED/' "$history_file"
    
    cat >> "$history_file" << EOF

================================================================================
ORDER FAILURE
================================================================================
Failed at: $(date '+%Y-%m-%d %H:%M:%S')
Reason: $failure_reason

================================================================================
END OF ORDER HISTORY
================================================================================
EOF
}

# Get current order ID from environment or generate new one
get_current_order_id() {
    if [ -n "$CURRENT_ORDER_ID" ]; then
        echo "$CURRENT_ORDER_ID"
    else
        generate_order_id
    fi
}

# Get history file path for current order
get_current_history_file() {
    local order_id="$(get_current_order_id)"
    echo "$HISTORY_DIR/${order_id}.txt"
}

# Export environment variable for current order
export_order_env() {
    local order_id="$1"
    export CURRENT_ORDER_ID="$order_id"
    echo "export CURRENT_ORDER_ID='$order_id'" > "$HISTORY_DIR/.current_order"
}

# Source current order environment
source_order_env() {
    if [ -f "$HISTORY_DIR/.current_order" ]; then
        . "$HISTORY_DIR/.current_order"
    fi
}

# Main function dispatcher
case "${1:-}" in
    "init")
        order_id=$(generate_order_id)
        history_file=$(init_order_history "$order_id" "$2")
        export_order_env "$order_id"
        echo "$history_file"
        ;;
    "log_manager")
        source_order_env
        log_manager_action "$(get_current_history_file)" "$2" "$3"
        ;;
    "log_developer")
        source_order_env
        log_developer_action "$(get_current_history_file)" "$2" "$3"
        ;;
    "log_delegation")
        source_order_env
        log_task_delegation "$(get_current_history_file)" "$2" "$3" "$4" "$5"
        ;;
    "log_completion")
        source_order_env
        log_completion_report "$(get_current_history_file)" "$2" "$3" "$4" "$5" "$6"
        ;;
    "complete")
        source_order_env
        complete_order_history "$(get_current_history_file)" "$2"
        rm -f "$HISTORY_DIR/.current_order"
        ;;
    "fail")
        source_order_env
        fail_order_history "$(get_current_history_file)" "$2"
        rm -f "$HISTORY_DIR/.current_order"
        ;;
    *)
        echo "Usage: $0 {init|log_manager|log_developer|log_delegation|log_completion|complete|fail} [args...]"
        exit 1
        ;;
esac