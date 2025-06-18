#!/bin/bash

# Centralized configuration module for Claude Team
# This module provides consistent configuration access across all scripts

# Get the absolute path to the script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -z "$SCRIPT_DIR" ] && { echo "Error: Failed to determine script directory" >&2; exit 1; }

# Source the logger
source "$SCRIPT_DIR/logger.sh"

# Configuration constants
CONFIG_CHECK_INTERVAL=5  # seconds
CONFIG_SCHEMA='{"type":"object","required":["session"],"properties":{"session":{"type":"object","required":["name"],"properties":{"name":{"type":"string","pattern":"^[a-zA-Z0-9_-]+$"}}},"log":{"type":"object","properties":{"level":{"type":"string","enum":["ERROR","WARN","INFO","DEBUG"]}}},"environment":{"type":"string","enum":["development","production"]}}}}'

# Set project root directory
CTEAM_ROOT="$(dirname "$SCRIPT_DIR")"
mkdir -p "$CTEAM_ROOT/.cteam"

# Get environment-specific config path
get_env_config_path() {
    local config_dir="$1"
    local env_type="${CTEAM_ENV:-development}"
    echo "$config_dir/config.$env_type.yaml"
}

# Validate configuration against schema
validate_config() {
    local config_file="$1"
    local config_content
    config_content=$(cat "$config_file")

    # Basic YAML validation
    if ! echo "$config_content" | grep -q "^session:" || ! echo "$config_content" | grep -q "^\s\+name:"; then
        log_error "Invalid YAML structure in $config_file"
        return 1
    fi

    # Session name validation
    local session_name
    session_name=$(echo "$config_content" | grep "name:" | sed 's/.*name: *//' | tr -d '\n\r')
    if ! echo "$session_name" | grep -qE "^[a-zA-Z0-9_-]+$"; then
        log_error "Invalid session name format in $config_file"
        return 1
    fi

    return 0
}

# Configuration loading function
load_config() {
    local project_root="${1:-$(pwd)}"
    local config_dir="$project_root/.cteam"
    local env_config
    env_config=$(get_env_config_path "$config_dir")
    
    # Return the configuration values as key=value pairs
    echo "CTEAM_ROOT=\"$CTEAM_ROOT\""
    echo "CONFIG_DIR=\"$config_dir\""
    
    # Load configuration from environment-specific file
    if [ -f "$env_config" ] && validate_config "$env_config"; then
        local session_name
        session_name=$(grep -A1 "^session:" "$env_config" | grep "name:" | sed 's/.*name: *//' | tr -d '\n\r')
        echo "SESSION_NAME=\"$session_name\""
        
        # Load environment type
        local env_type
        env_type=$(grep "^environment:" "$env_config" | sed 's/.*: *//' | tr -d '\n\r')
        [ -n "$env_type" ] && echo "CTEAM_ENV=\"$env_type\""
        
        # Load log level if specified
        local log_level
        log_level=$(grep -A2 "^log:" "$env_config" | grep "level:" | sed 's/.*: *//' | tr -d '\n\r')
        [ -n "$log_level" ] && echo "LOG_LEVEL=\"$log_level\""
    else
        # Generate default session name from project directory
        local default_name
        default_name="$(basename "$project_root" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g')"
        echo "SESSION_NAME=\"$default_name\""
        log_warn "Using default configuration. Create $env_config for environment-specific settings."
    fi
    
    # Add tmux pane identifiers
    echo "MANAGER_PANE=\"\$SESSION_NAME:0.1\""
    echo "DEVELOPER_PANE=\"\$SESSION_NAME:0.2\""
    echo "USER_PANE=\"\$SESSION_NAME:0.0\""
}

# Session validation function
validate_session() {
    local session_name="$1"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "Error: Claude Team session '$session_name' not found" >&2
        return 1
    fi
    return 0
}

# Pane validation function
validate_pane() {
    local session_name="$1"
    local pane_id="$2"
    
    if ! tmux list-panes -t "$session_name:0" -F '#{pane_index}' | grep -q "^${pane_id}$"; then
        echo "Error: Pane $pane_id not found in session $session_name" >&2
        return 1
    fi
    return 0
}

# Hot reload configuration check
check_config_changes() {
    local config_file="$1"
    local config_hash="$2"
    local current_hash

    if [ -f "$config_file" ]; then
        current_hash=$(md5sum "$config_file" | cut -d' ' -f1)
        if [ "$current_hash" != "$config_hash" ]; then
            log_info "Configuration file changed, reloading..."
            return 0
        fi
    fi
    return 1
}

# Start configuration hot reload monitoring
start_config_monitor() {
    local config_dir="$1"
    local env_config
    env_config=$(get_env_config_path "$config_dir")
    local config_hash

    if [ -f "$env_config" ]; then
        config_hash=$(md5sum "$env_config" | cut -d' ' -f1)
        
        while true; do
            if check_config_changes "$env_config" "$config_hash"; then
                # Reload configuration
                eval "$(load_config "$(dirname "$config_dir")")"
                config_hash=$(md5sum "$env_config" | cut -d' ' -f1)
            fi
            sleep "$CONFIG_CHECK_INTERVAL"
        done
    fi
}

# Export functions for use in other scripts
export -f load_config
export -f validate_config
export -f start_config_monitor

# Main execution: load and output configuration if not sourced
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    load_config "$@"
fi