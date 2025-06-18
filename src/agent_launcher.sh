#!/bin/bash

set -e

# Source modules
. "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
. "$(dirname "${BASH_SOURCE[0]}")/validator.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_ROLE="${1:-user}"
PROJECT_ROOT="${2:-$(pwd)}"

# Source configuration
eval "$("$SCRIPT_DIR/config.sh" "$PROJECT_ROOT")"

# Validate inputs
validate_required_param "$AGENT_ROLE" "agent_role" || exit 1
validate_directory "$PROJECT_ROOT" "Project directory" || exit 1

# Check if claude command is available
validate_command "claude" "Claude Code CLI" || {
    log_error "Please install Claude Code CLI"
    log_info "Visit: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
}

setup_agent_context() {
    local role="$1"
    local context_file="$CONFIG_DIR/contexts/${role}_context.md"
    
    validate_file "$context_file" "Context file for role '$role'" || exit 1
cat "$context_file"
}

launch_agent() {
    local role="$1"
    local context_file="$CONFIG_DIR/contexts/${role}_context.md"
    
    log_info "Launching Claude Code as $role agent..."
    log_info "Working directory: $PROJECT_ROOT"
    log_info "Loading context from: $context_file"
    
    # Verify context file exists
    validate_file "$context_file" "Context file" || exit 1
    
    log_info "================================================"
    log_info "Claude Code - $role Agent"
    log_info "================================================"
    echo ""
    log_info "📄 Loading agent context..."
    setup_agent_context "$role"
    echo ""
    log_success "Context loaded successfully!"
    echo ""
    log_info "Type 'exit' to quit this agent."
    log_info "Use tmux commands to interact with other panes:"
    log_info "  Use helper scripts in src/ directory for agent communication"
    echo ""
    
    # Launch Claude Code with the role context
    cd "$PROJECT_ROOT"
    exec claude --model claude-3-5-sonnet-20241022 --dangerously-skip-permissions
}

# Main execution
case "$AGENT_ROLE" in
    "manager"|"developer")
        launch_agent "$AGENT_ROLE"
        ;;
    *)
        log_info "Usage: $0 {manager|developer}"
        log_info "Available roles:"
        log_info "  manager    - Launch Manager Agent"
        log_info "  developer  - Launch Developer Agent"
        exit 1
        ;;
esac