#!/bin/bash
# Update terminal titles JSON every 5 seconds

mkdir -p /var/www/terminal/api

while true; do
    for i in {1..8}; do
        SESSION="terminal-$i"
        TITLE=$(tmux display-message -t "$SESSION" -p '#W' 2>/dev/null | tr -d '\n')
        
        if [ -z "$TITLE" ]; then
            echo '{"title":"inactive"}' > /var/www/terminal/api/title-$i.json
        else
            echo "{\"title\":\"$TITLE\"}" > /var/www/terminal/api/title-$i.json
        fi
    done
    sleep 3
done
