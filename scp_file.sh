#!/bin/bash

WATCH_DIR="$HOME/robot_records"
WINDOWS_USER="robot"
WINDOWS_IP="192.168.x.xxx"
WINDOWS_PATH="/home/robot/Documents"
WIN_PASS="Ninos@2026"

echo "Monitoring $WATCH_DIR for new txt files..."

inotifywait -m -e close_write --format '%f' "$WATCH_DIR" | while IFS= read -r FILE
do
    if [[ "$FILE" == *.txt ]]; then
        echo "New file detected: $FILE"

        sshpass -p "$WIN_PASS" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$WATCH_DIR/$FILE" ${WINDOWS_USER}@${WINDOWS_IP}:"${WINDOWS_PATH}"

        if [ $? -eq 0 ]; then
            echo "File transferred successfully"
        else
            echo "Transfer failed"
        fi
    fi
done
