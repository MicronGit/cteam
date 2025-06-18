#!/bin/bash

set -e

# Source modules
. "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
. "$(dirname "${BASH_SOURCE[0]}")/validator.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${2:-$(pwd)}"

# Source configuration
eval "$("$SCRIPT_DIR/config.sh" "$PROJECT_ROOT")"

start_session() {
    # Clean session name output for debugging
    log_info "Using session name: '$SESSION_NAME'"
    
    # Check if we're in a tmux session already
    if [ -n "$TMUX" ]; then
        log_error "Already in a tmux session. Please exit current session first."
        exit 1
    fi
    
    # Check if session already exists
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_info "Session '$SESSION_NAME' already exists. Attaching..."
        TERM=xterm-256color exec tmux attach-session -t "$SESSION_NAME"
    fi

    log_info "Creating new tmux session: $SESSION_NAME"
    
    # Create new session with the first window
    TERM=xterm-256color tmux new-session -d -s "$SESSION_NAME" -x 120 -y 40
    
    # Rename the first window
    tmux rename-window -t "$SESSION_NAME:0" "claude-team"
    
    # Split horizontally (left and right)
    tmux split-window -h -t "$SESSION_NAME:0"
    
    # Split the bottom pane vertically (top and bottom on the right side)
    tmux split-window -v -t "$SESSION_NAME:0.1"
    
    # Set pane titles and change to project directory
    tmux send-keys -t "$SESSION_NAME:0.0" "cd '$PROJECT_ROOT' && echo '=== USER PANE ===' && echo 'This is your workspace. You can run commands here.'" Enter
    tmux send-keys -t "$SESSION_NAME:0.1" "cd '$PROJECT_ROOT' && echo '=== MANAGER AGENT PANE ===' && echo 'Initializing Manager Claude Agent...'" Enter
    tmux send-keys -t "$SESSION_NAME:0.2" "cd '$PROJECT_ROOT' && echo '=== DEVELOPER AGENT PANE ===' && echo 'Initializing Developer Claude Agent...'" Enter
    
    # Start Claude Code agents in respective panes
    tmux send-keys -t "$SESSION_NAME:0.1" "'$SCRIPT_DIR/agent_launcher.sh' manager '$PROJECT_ROOT'" Enter
    tmux send-keys -t "$SESSION_NAME:0.2" "'$SCRIPT_DIR/agent_launcher.sh' developer '$PROJECT_ROOT'" Enter
    
    # Focus on user pane
    tmux select-pane -t "$SESSION_NAME:0.0"
    
    # Set window layout
    tmux select-layout -t "$SESSION_NAME:0" main-vertical
    
    log_success "Session created successfully!"
    log_info "Attaching to session..."
    
    # Attach to the session
    TERM=xterm-256color exec tmux attach-session -t "$SESSION_NAME"
}

stop_session() {
    if ! validate_session "$SESSION_NAME"; then
        exit 1
fi

if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_info "Stopping Claude Team session: $SESSION_NAME"
        
        # Send exit commands to all Claude Code agents before killing the session
        log_info "Sending exit commands to all agents..."
        
        # Send Ctrl+C and exit to manager pane
        tmux send-keys -t "$SESSION_NAME:0.1" C-c 2>/dev/null || true
        tmux send-keys -t "$SESSION_NAME:0.1" "exit" Enter 2>/dev/null || true
        
        # Send Ctrl+C and exit to developer pane  
        tmux send-keys -t "$SESSION_NAME:0.2" C-c 2>/dev/null || true
        tmux send-keys -t "$SESSION_NAME:0.2" "exit" Enter 2>/dev/null || true
        
        # Give agents time to exit gracefully
        sleep 1
        
        # Notify user pane
        tmux send-keys -t "$SESSION_NAME:0.0" "echo '👋 Claude Team session is ending. All agents have been stopped.'" Enter 2>/dev/null || true
        
        # Give user time to see the message
        sleep 2
        
        # Kill the entire session
        log_info "Terminating tmux session..."
        tmux kill-session -t "$SESSION_NAME"
        
        log_success "Claude Team session terminated successfully"
        log_info "Returned to original shell process"
    else
        log_warn "Session '$SESSION_NAME' does not exist or is already stopped"
    fi
}

case "${1:-}" in
    "start")
        start_session
        ;;
    "stop")
        stop_session
        ;;
    *)
        log_info "Usage: $0 {start|stop}"
        exit 1
        ;;
esac