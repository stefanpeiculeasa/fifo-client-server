#!/bin/bash

# Redirect errors to /dev/null for cleaner output
exec 2>/dev/null

# Cleanup function to remove FIFO on exit
cleanup() {
    if [[ -p "$SERVER_FIFO" ]]; then
        rm -f "$SERVER_FIFO"
        echo -e "\e[32mServer FIFO removed. Server shut down successfully.\e[0m"
    fi
    # Kill the background process
    if [[ -n "$TERMINAL_HANDLER_PID" ]]; then
        kill "$TERMINAL_HANDLER_PID" 2>/dev/null
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

WORKING_DIR=$(pwd)
SERVER_FIFO="$WORKING_DIR/$SERVER_FIFO"

if [[ -e "$SERVER_FIFO" ]]; then
    if [[ -d "$SERVER_FIFO" ]]; then
        echo "Error: $SERVER_FIFO is a directory, not a FIFO."
        exit 1
    elif [[ ! -p "$SERVER_FIFO" ]]; then
        echo "Error: $SERVER_FIFO exists but is not a FIFO."
        exit 1
    fi
else
    mkfifo "$SERVER_FIFO" || {
        echo "Error: Failed to create server FIFO."
        exit 1
    }
fi

echo -e "\e[32mServer is running. Listening for requests (type 'quit' or 'q' to exit)...\e[0m"

SERVER_RUNNING=true

handle_terminal_input() {
    while $SERVER_RUNNING; do
        if read -r -t 1 TERMINAL_INPUT < /dev/tty 2>/dev/null; then
            if [[ "$TERMINAL_INPUT" == "quit" || "$TERMINAL_INPUT" == "q" ]]; then
                echo -e "\e[31mShutting down server...\e[0m"
                SERVER_RUNNING=false
                exit 0
            fi
        fi
    done
}

handle_terminal_input &
TERMINAL_HANDLER_PID=$!

while $SERVER_RUNNING; do
    if [[ -p "$SERVER_FIFO" ]]; then
        if read -t 1 -r REQUEST < "$SERVER_FIFO"; then
            echo "Received request: $REQUEST"

            if [[ "$REQUEST" =~ BEGIN-REQ\ \[([0-9]+):\ ([a-zA-Z0-9_-]+)\]\ END-REQ ]]; then
                CLIENT_PID="${BASH_REMATCH[1]}"
                COMMAND_NAME="${BASH_REMATCH[2]}"
                
                CLIENT_FIFO="$WORKING_DIR/client_fifo-$CLIENT_PID"

                # Wait briefly for client FIFO to be ready
                sleep 0.1
                
                if [[ ! -p "$CLIENT_FIFO" ]]; then
                    echo "Error: Client FIFO not found for PID $CLIENT_PID"
                    continue
                fi

                if command -v "$COMMAND_NAME" > /dev/null 2>&1; then
                    man "$COMMAND_NAME" > "$CLIENT_FIFO" 2>/dev/null
                    echo "Sent manual page for $COMMAND_NAME to client $CLIENT_PID"
                else
                    echo "Error: Command '$COMMAND_NAME' not found." > "$CLIENT_FIFO"
                fi
            else
                echo -e "\e[31mError: Invalid request format.\e[0m"
            fi
        fi
    else
        echo -e "\e[31mError: Server FIFO was removed unexpectedly.\e[0m"
        break
    fi
done
