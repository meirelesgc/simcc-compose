#!/bin/bash

SCRIPT_DIR="./scripts"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <script number(s)>"
    exit 1
fi

for num in "$@"; do
    script_path="$SCRIPT_DIR/$(printf "%03d" "$num")_*.sh"
    
    if ls $script_path 1> /dev/null 2>&1; then
        echo "Executing $script_path..."
        chmod +x $script_path
        $script_path
    else
        echo "Script $script_path not found!"
    fi
done
