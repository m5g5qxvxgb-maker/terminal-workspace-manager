#!/bin/bash
# Stop all terminal services

pkill -f "ttyd -p 768"
echo "All terminal services stopped"
