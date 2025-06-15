#!/bin/bash

set -e

AGENT_ROLE="${1:-user}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$PROJECT_ROOT/config"

# Check if claude command is available
if ! command -v claude &> /dev/null; then
    echo "Error: 'claude' command not found. Please install Claude Code CLI."
    echo "Visit: https://docs.anthropic.com/en/docs/claude-code"
    exit 1
fi

setup_agent_context() {
    local role="$1"
    local context_file="$CONFIG_DIR/contexts/${role}_context.md"
    
    if [ -f "$context_file" ]; then
        cat "$context_file"
    else
        echo "Error: Context file for role '$role' not found at $context_file"
        exit 1
    fi
}

launch_agent() {
    local role="$1"
    local context_file="$CONFIG_DIR/contexts/${role}_context.md"
    
    echo "Launching Claude Code as $role agent..."
    echo "Working directory: $PROJECT_ROOT"
    echo "Loading context from: $context_file"
    
    # Verify context file exists
    if [ ! -f "$context_file" ]; then
        echo "Error: Context file not found: $context_file"
        exit 1
    fi
    
    echo "================================================"
    echo "Claude Code - $role Agent"
    echo "================================================"
    echo ""
    echo "📄 Loading agent context..."
    setup_agent_context "$role"
    echo ""
    echo "✅ Context loaded successfully!"
    echo ""
    echo "Type 'exit' to quit this agent."
    echo "Use tmux commands to interact with other panes:"
    echo "  tmux send-keys -t claude_team:0.0 'message' && sleep 0.1 && tmux send-keys -t claude_team:0.0 Enter  # Send to user pane"
    echo "  tmux send-keys -t claude_team:0.1 'message' Enter  # Send to manager pane"  
    echo "  tmux send-keys -t claude_team:0.2 'message' Enter  # Send to developer pane"
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
        echo "Usage: $0 {manager|developer}"
        echo "Available roles:"
        echo "  manager    - Launch Manager Agent"
        echo "  developer  - Launch Developer Agent"
        exit 1
        ;;
esac