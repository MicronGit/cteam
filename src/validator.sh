#!/bin/bash

# Input validation module for Claude Team
# This module provides consistent input validation across all scripts

# Source logger
. "$(dirname "${BASH_SOURCE[0]}")/logger.sh"

# Validate required string parameter
validate_required_param() {
    local param_value="$1"
    local param_name="$2"
    
    if [ -z "$param_value" ]; then
        log_error "Required parameter '$param_name' is missing"
        return 1
    fi
    return 0
}

# Validate string parameter matches pattern
validate_pattern_param() {
    local param_value="$1"
    local param_name="$2"
    local pattern="$3"
    
    if ! echo "$param_value" | grep -qE "$pattern"; then
        log_error "Parameter '$param_name' does not match required pattern: $pattern"
        return 1
    fi
    return 0
}

# Validate file exists
validate_file() {
    local file_path="$1"
    local file_desc="$2"
    
    if [ ! -f "$file_path" ]; then
        log_error "$file_desc not found: $file_path"
        return 1
    fi
    return 0
}

# Validate directory exists
validate_directory() {
    local dir_path="$1"
    local dir_desc="$2"
    
    if [ ! -d "$dir_path" ]; then
        log_error "$dir_desc not found: $dir_path"
        return 1
    fi
    return 0
}

# Validate command exists in PATH
validate_command() {
    local command="$1"
    local command_desc="$2"
    
    if ! command -v "$command" &> /dev/null; then
        log_error "$command_desc command not found: $command"
        return 1
    fi
    return 0
}

# Validate tmux session exists
validate_session() {
    local session_name="$1"
    
    if [ -z "$session_name" ]; then
        log_error "Session name is required"
        return 1
    fi
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        log_error "Session '$session_name' not found"
        return 1
    fi
    return 0
}

# Validate tmux pane exists
validate_pane() {
    local session_name="$1"
    local pane_index="$2"
    
    if [ -z "$session_name" ] || [ -z "$pane_index" ]; then
        log_error "Session name and pane index are required"
        return 1
    fi
    
    if ! tmux list-panes -t "$session_name:0" -F '#{pane_index}' | grep -q "^$pane_index$"; then
        log_error "Pane $pane_index not found in session '$session_name'"
        return 1
    fi
    return 0
}