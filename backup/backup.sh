#!/bin/bash

echo "Server backup started..."

# How many backups to keep 
RETENTION=48

until mcrcon -H atm9 -P 25575 -p "$RCON_PASSWORD" "list"; do
    echo "waiting for RCON..."
    sleep 2
done

echo "Server is ready!"

while true; do
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    BACKUP_DIR="/BackUps/$TIMESTAMP"

    echo "======================================"
    echo "Starting backup: $TIMESTAMP"
    echo "======================================"

    mkdir -p "$BACKUP_DIR"

    # 1. Notify players that backup is starting
    mcrcon -H atm9 -P 25575 -p "$RCON_PASSWORD" \
        "say [Backup] Staring world backup..."

    # 2. Force save
    mcrcon -H atm9 -P 25575 -p "$RCON_PASSWORD" "save-all flush"
    sleep 5

    # 3. Stop auto-saving
    mcrcon -H atm9 -P 25575 -p "$RCON_PASSWORD" "save-off"

    # 4. Backup files 
    if [ -d "/server/world/"]; then 
        rsync -a /server/world/ "$BACKUP_DIR/world/"
    fi 

    #if [ -d "server/config/"]; then
    #    rsync -a /server/config/ "$BACKUP_DIR/config/"
    #fi

    #if [ -d "/server/kubejs" ]; then
    #    rsync -a /server/kubejs/ "$BACKUP_DIR/kubejs/"
    #fi

    #if [ -d "/server/defaultconfigs" ]; then
    #    rsync -a /server/defaultconfigs/ "$BACKUP_DIR/defaultconfigs/"
    #fi

    # 5. Re-enable auto-saving
    mcrcon -H atm9 -P 25575 -p "$RCON_PASSWORD" "save-on"

    # 6. Notify players that backup is complete
    mcrcon -H atm9 -P 25575 -p "$RCON_PASSWORD" \
        "say [Backup] Backup complete!"

    echo "Backup complete: $BACKUP_DIR"

    echo "Cleaning old backups (keeping last $RETENTION)..."

    ls -1dt /BackUps/* 2>/dev/null | tail -n 49 | xargs -r rm -rf

    echo "Sleeping for 30 minutes"
    sleep 1800 # 30 minutes
done