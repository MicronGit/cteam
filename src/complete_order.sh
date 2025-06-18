#!/bin/bash

set -e

# Source modules
. "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
. "$(dirname "${BASH_SOURCE[0]}")/validator.sh"

# Order completion helper script for Manager Agent
# Usage: ./complete_order.sh "completion_summary"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${2:-$(pwd)}"

# Source configuration
eval "$("$SCRIPT_DIR/config.sh" "$PROJECT_ROOT")"

COMPLETION_SUMMARY="$1"

# Validate inputs
validate_required_param "$COMPLETION_SUMMARY" "completion_summary" || exit 1

# Mark order as completed in history
"$SCRIPT_DIR/history_logger.sh" complete "$COMPLETION_SUMMARY"

log_success "Order marked as completed in history!"
log_info "📝 Final completion summary: $COMPLETION_SUMMARY"