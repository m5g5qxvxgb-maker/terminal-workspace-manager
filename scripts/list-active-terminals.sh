#!/bin/bash
# List all active terminal sessions that can be migrated

echo "=== Current Active Copilot Sessions ==="
echo ""
echo "TTY          PID      Status"
echo "----------------------------------------"
ps aux | grep copilot | grep -v grep | grep pts | awk '{printf "%-12s %-8s Running\n", $7, $2}'

echo ""
echo "=== Web Terminal Manager Sessions ==="
echo ""
tmux list-sessions 2>/dev/null | grep "terminal-" || echo "No web terminal sessions yet"

echo ""
echo "=== How to migrate ==="
echo "Run: migrate-session.sh <TTY> <terminal_number>"
echo "Example: migrate-session.sh /dev/pts/3 1"
