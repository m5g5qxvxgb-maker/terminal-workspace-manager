#!/bin/bash
# Start 8 terminal services with persistent shared tmux sessions

for i in {1..8}; do
    port=$((7680 + i))
    session="terminal-$i"
    
    # Create tmux session if it doesn't exist
    if ! tmux has-session -t "$session" 2>/dev/null; then
        # Create new session with copilot running
        tmux new-session -d -s "$session" -n "copilot-$i" "cd /root && copilot; bash"
        echo "Created new tmux session: $session with copilot"
    else
        echo "Reusing existing tmux session: $session"
    fi
    
    # Start ttyd with writable mode (-W flag), smaller font, and interface binding
    # -t fontSize=13 - smaller font for mobile (13px instead of default 15px)
    # -i 127.0.0.1 - only local access (nginx will proxy)
    nohup ttyd -i 127.0.0.1 -p "$port" -W -t fontSize=13 bash -c "tmux attach-session -t $session" > "/var/log/ttyd-$i.log" 2>&1 &
    
    echo "Started terminal $i on port $port (session: $session)"
done

echo ""
echo "✅ All 8 terminals started!"
echo "📡 Ports: 7681-7688"
echo "🔗 Sessions: terminal-1 through terminal-8"
echo ""
echo "💡 Same session is shared across all devices!"
echo "📋 To list sessions: tmux list-sessions"
