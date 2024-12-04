#!/bin/bash

# ================================================
# Script to Kill Processes on Specific Ports and
# Delete Specified Directories
# ================================================

# Exit immediately if a command exits with a non-zero status
# set -e

# ================================================
# Constants
# ================================================

# Base deployment directory
DEPLOYMENT_DIR="/Users/chathura/wso2_observability"

# Ports to kill processes on
PORTS=(5601 9200)

# Directories to delete relative to DEPLOYMENT_DIR
SUBDIRS=(
    "fluentbit"
    "opensearch"
    "opensearch-dashboards"
)

# ================================================
# Functions
# ================================================

# Function to display messages with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to kill process on a given port
kill_process_on_port() {
    local port=$1
    log "Attempting to find process listening on port $port..."

    # Find the PID(s) listening on the port
    PIDS=$(lsof -t -i :"$port" 2>/dev/null || true)

    if [[ -z "$PIDS" ]]; then
        log "No process found on port $port."
        return
    fi

    for PID in $PIDS; do
        log "Found process with PID $PID on port $port. Attempting to kill..."
        
        # Try to gracefully terminate the process
        kill "$PID" 2>/dev/null && log "Sent SIGTERM to PID $PID."

        # Wait for the process to terminate
        sleep 2

        # Check if the process is still running
        if kill -0 "$PID" 2>/dev/null; then
            log "Process PID $PID did not terminate. Force killing..."
            kill -9 "$PID" && log "Force killed PID $PID." || log "Failed to kill PID $PID."
        else
            log "Process PID $PID terminated successfully."
        fi
    done
}

# Function to delete a directory
delete_directory() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        log "Deleting directory: $dir"
        rm -rf "$dir" && log "Deleted directory: $dir." || log "Failed to delete directory: $dir."
    else
        log "Directory does not exist: $dir"
    fi
}

kill_fluent_bit() {
    log "Attempting to find and kill Fluent Bit process..."

    # Define the search pattern
    SEARCH_PATTERN="fluent-bit -c /Users/chathura/wso2_observability/fluentbit/wso2-integration.conf"

    log "Searching for process matching the pattern:"

    # Use pgrep to find the PID(s) of the matching process
    PIDS=$(pgrep -f "$SEARCH_PATTERN")

    log "Found process ID(s): $PIDS"

    # Check if any PID was found
    if [ -z "$PIDS" ]; then
        log "No process found matching the pattern:"
        log "$SEARCH_PATTERN"
        return 0
    fi

    # Display the PID(s) to be killed
    log "Found process ID(s): $PIDS"
    log "Attempting to terminate the process(es)..."

    # Attempt to gracefully terminate the process(es)
    kill -9 $PIDS
}

# ================================================
# Main Execution
# ================================================

log "Script started."

# Kill processes on specified ports
for PORT in "${PORTS[@]}"; do
    kill_process_on_port "$PORT"
done

kill_fluent_bit

delete_directory "$DEPLOYMENT_DIR"

Delete specified directories
for SUBDIR in "${SUBDIRS[@]}"; do
    FULL_DIR="$DEPLOYMENT_DIR/$SUBDIR"
    delete_directory "$FULL_DIR"
done

log "Script completed successfully."

exit 0
