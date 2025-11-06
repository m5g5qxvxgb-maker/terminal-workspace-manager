// Terminal Workspace Manager - Notification Helper
// This script can be sourced in your shell to automatically trigger notifications

// Example usage in bash:
// 
// # Show notification on workspace 1
// curl -s http://localhost:8888/notify?workspace=1&type=warning&icon=!
//
// # Show success notification
// curl -s http://localhost:8888/notify?workspace=1&type=success&icon=✓
//
// # Clear notification
// curl -s http://localhost:8888/notify?workspace=1&clear=true

// Bash functions you can add to ~/.bashrc:

/*
# Notify when command finishes
notify_finish() {
    "$@"
    local status=$?
    if [ $status -eq 0 ]; then
        curl -s "http://localhost:8888/notify?workspace=${WORKSPACE_ID:-1}&type=success&icon=✓" &>/dev/null
    else
        curl -s "http://localhost:8888/notify?workspace=${WORKSPACE_ID:-1}&type=error&icon=✗" &>/dev/null
    fi
    return $status
}

# Notify on long-running command
notify_long() {
    local start=$(date +%s)
    "$@"
    local status=$?
    local end=$(date +%s)
    local duration=$((end - start))
    
    if [ $duration -gt 10 ]; then
        if [ $status -eq 0 ]; then
            curl -s "http://localhost:8888/notify?workspace=${WORKSPACE_ID:-1}&type=success&icon=✓" &>/dev/null
        else
            curl -s "http://localhost:8888/notify?workspace=${WORKSPACE_ID:-1}&type=error&icon=!" &>/dev/null
        fi
    fi
    return $status
}

# Set workspace ID for notifications
export WORKSPACE_ID=1  # Change to your workspace number

# Usage examples:
# notify_finish npm install
# notify_long ./long-running-script.sh
*/

// JavaScript API (use in browser console or custom scripts):
/*
// Show notification with custom icon
notifyWorkspace(1, 'warning', '⚠');

// Show success
notifySuccess(1);

// Show error
notifyError(1);

// Clear notification
clearNotify(1);

// Auto-notify after 5 seconds (example)
setTimeout(() => notifySuccess(1), 5000);
*/
