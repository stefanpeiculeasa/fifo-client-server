#!/bin/bash

# Cleanup function to remove FIFO on exit
cleanup() {
    if [[ -p "$CLIENT_FIFO" ]]; then
        rm -f "$CLIENT_FIFO"
        echo "Client FIFO $CLIENT_FIFO removed. Client instance closed."
    fi
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

# Source configuration file
if [[ ! -f "config.cfg" ]]; then
    echo "Error: config.cfg not found."
    exit 1
fi

source config.cfg

CLIENT_PID=$$
WORKING_DIR=$(pwd)
CLIENT_FIFO="$WORKING_DIR/client_fifo-$CLIENT_PID"

if [[ ! -d "$WORKING_DIR" ]]; then
    mkdir -p "$WORKING_DIR"
fi

if [[ -e "$CLIENT_FIFO" ]]; then
    if [[ ! -p "$CLIENT_FIFO" ]]; then
        echo "Error: $CLIENT_FIFO exists but is not a FIFO."
        exit 1
    fi
else
    mkfifo "$CLIENT_FIFO" || {
        echo "Error: Failed to create client FIFO."
        exit 1
    }
fi

if [[ -z "$SERVER_FIFO" ]]; then
    echo "Error: SERVER_FIFO not set in configuration."
    exit 1
fi

SERVER_FIFO="$WORKING_DIR/$SERVER_FIFO"

if [[ ! -p "$SERVER_FIFO" ]]; then
    echo "Error: Server FIFO not found. Is the server running?"
    exit 1
fi

echo "Client is ready. Type your commands (type 'quit' or 'q' to exit):"

while true; do
    read -r -p "> " input

    if [[ "$input" == "quit" || "$input" == "q" ]]; then
        echo "Exiting..."
        break
    fi
    
    if [[ -z "$input" ]]; then
        continue
    fi
    
    if command -v "$input" > /dev/null 2>&1; then
        echo "BEGIN-REQ [$CLIENT_PID: $input] END-REQ" > "$SERVER_FIFO"
        
        # Wait for response with timeout
        if timeout 5 cat "$CLIENT_FIFO" 2>/dev/null; then
            echo ""
            echo "Response received!"
        else
            echo "Error: Timeout waiting for server response."
        fi
    else
        echo "Invalid command: '$input'. Please try again."
    fi
done