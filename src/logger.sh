#!/bin/bash

# Centralized logging module for Claude Team
# This module provides consistent logging patterns across all scripts

# Log configuration
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
LOG_DIR="$PROJECT_ROOT/.cteam/logs"
LOG_FILE="$LOG_DIR/cteam.log"
MAX_LOG_SIZE=10485760  # 10MB in bytes
MAX_LOG_FILES=5

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Log levels - using functions for compatibility
get_log_level() {
    case "$1" in
        ERROR) echo 0 ;;
        WARN) echo 1 ;;
        INFO) echo 2 ;;
        DEBUG) echo 3 ;;
        *) echo 0 ;;
    esac
}

# Default to INFO level if not set
LOG_LEVEL_NAME=${LOG_LEVEL:-INFO}
LOG_LEVEL=$(get_log_level "$LOG_LEVEL_NAME")

# ANSI color codes
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_GREEN='\033[0;32m'
COLOR_RESET='\033[0m'

# Format message as JSON
format_json_log() {
    local level=$1
    local message=$2
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
    echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"message\":\"${message//\"/\\\"}\",\"pid\":$$}"
}

# Rotate logs if needed
rotate_logs() {
    if [ -f "$LOG_FILE" ] && [ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE") -gt $MAX_LOG_SIZE ]; then
        for i in $(seq $((MAX_LOG_FILES-1)) -1 1); do
            if [ -f "$LOG_FILE.$i" ]; then
                mv "$LOG_FILE.$i" "$LOG_FILE.$((i+1))"
            fi
        done
        mv "$LOG_FILE" "$LOG_FILE.1"
        touch "$LOG_FILE"
    fi
}

# Logging functions
log_error() {
    local current_level=$(get_log_level "$LOG_LEVEL_NAME")
    if [ $(get_log_level "ERROR") -le $current_level ]; then
        echo -e "${COLOR_RED}[ERROR] $1${COLOR_RESET}" >&2
        rotate_logs
        format_json_log "ERROR" "$1" >> "$LOG_FILE"
    fi
}

log_warn() {
    local current_level=$(get_log_level "$LOG_LEVEL_NAME")
    if [ $(get_log_level "WARN") -le $current_level ]; then
        echo -e "${COLOR_YELLOW}[WARN] $1${COLOR_RESET}" >&2
        rotate_logs
        format_json_log "WARN" "$1" >> "$LOG_FILE"
    fi
}

log_info() {
    local current_level=$(get_log_level "$LOG_LEVEL_NAME")
    if [ $(get_log_level "INFO") -le $current_level ]; then
        echo -e "${COLOR_BLUE}[INFO] $1${COLOR_RESET}"
        rotate_logs
        format_json_log "INFO" "$1" >> "$LOG_FILE"
    fi
}

log_debug() {
    local current_level=$(get_log_level "$LOG_LEVEL_NAME")
    if [ $(get_log_level "DEBUG") -le $current_level ]; then
        echo -e "${COLOR_GREEN}[DEBUG] $1${COLOR_RESET}"
        rotate_logs
        format_json_log "DEBUG" "$1" >> "$LOG_FILE"
    fi
}

# Log success messages
log_success() {
    echo -e "${COLOR_GREEN}✅ $1${COLOR_RESET}"
    rotate_logs
    format_json_log "SUCCESS" "$1" >> "$LOG_FILE"
}

# Handle command failures with proper error logging
handle_error() {
    local exit_code=$?
    local error_msg="$1"
    
    if [ $exit_code -ne 0 ]; then
        local full_msg="$error_msg (Exit code: $exit_code)"
        log_error "$full_msg"
        exit $exit_code
    fi
}

# Clean up old log files
cleanup_old_logs() {
    find "$LOG_DIR" -name "cteam.log.*" -type f | sort -r | tail -n +$((MAX_LOG_FILES+1)) | xargs rm -f 2>/dev/null || true
}