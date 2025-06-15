#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SESSION_NAME="claude_team"

start_session() {
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "Session '$SESSION_NAME' already exists. Attaching..."
        tmux attach-session -t "$SESSION_NAME"
        return 0
    fi

    echo "Creating new tmux session: $SESSION_NAME"
    
    # Create new session with the first window
    tmux new-session -d -s "$SESSION_NAME" -x 120 -y 40
    
    # Rename the first window
    tmux rename-window -t "$SESSION_NAME:0" "claude-team"
    
    # Split horizontally (left and right)
    tmux split-window -h -t "$SESSION_NAME:0"
    
    # Split the bottom pane vertically (top and bottom on the right side)
    tmux split-window -v -t "$SESSION_NAME:0.1"
    
    # Set pane titles
    tmux send-keys -t "$SESSION_NAME:0.0" "echo '=== USER PANE ===' && echo 'This is your workspace. You can run commands here.'" Enter
    tmux send-keys -t "$SESSION_NAME:0.1" "echo '=== MANAGER AGENT PANE ===' && echo 'Initializing Manager Claude Agent...'" Enter
    tmux send-keys -t "$SESSION_NAME:0.2" "echo '=== DEVELOPER AGENT PANE ===' && echo 'Initializing Developer Claude Agent...'" Enter
    
    # Start Claude Code agents in respective panes
    tmux send-keys -t "$SESSION_NAME:0.1" "cd '$PROJECT_ROOT' && '$SCRIPT_DIR/agent_launcher.sh' manager" Enter
    tmux send-keys -t "$SESSION_NAME:0.2" "cd '$PROJECT_ROOT' && '$SCRIPT_DIR/agent_launcher.sh' developer" Enter
    
    # Focus on user pane
    tmux select-pane -t "$SESSION_NAME:0.0"
    
    # Set window layout
    tmux select-layout -t "$SESSION_NAME:0" main-vertical
    
    echo "Session created successfully!"
    echo "Attaching to session..."
    
    # Attach to the session
    tmux attach-session -t "$SESSION_NAME"
}

stop_session() {
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "Stopping Claude Team session: $SESSION_NAME"
        
        # Send exit commands to all Claude Code agents before killing the session
        echo "Sending exit commands to all agents..."
        
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
        echo "Terminating tmux session..."
        tmux kill-session -t "$SESSION_NAME"
        
        echo "✅ Claude Team session terminated successfully"
        echo "Returned to original shell process"
    else
        echo "Session '$SESSION_NAME' does not exist or is already stopped"
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
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac