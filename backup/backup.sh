#!/bin/bash

# How many backups to keep 
RETENTION=48

echo "Waiting for the server to launch..."
sleep 240 # 4 minutes, as that is how long the minecraft server took to launch when it was timed. May be adjusted later
until mcrcon -H mcServer -P 25575 -p "$RCON_PASSWORD" "list"; do
    echo "waiting for RCON..."
    sleep 30
done

echo "Server is ready!"
#sleep 1800 # 30 minutes
sleep 1800

while true; do
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    BACKUP_DIR="/BackUps/$TIMESTAMP"

    echo "======================================"
    echo "Starting backup: $TIMESTAMP"
    echo "======================================"

    mkdir -p "$BACKUP_DIR"

    # 1. Notify players that backup is starting
    mcrcon -H mcServer -P 25575 -p "$RCON_PASSWORD" \
        "say [Backup] Staring world backup..."

    # 2. Force save
    mcrcon -H mcServer -P 25575 -p "$RCON_PASSWORD" "save-all flush"
    sleep 5

    # 3. Stop auto-saving
    mcrcon -H mcServer -P 25575 -p "$RCON_PASSWORD" "save-off"

    # 4. Backup files 
    if [ -d "/server/world/" ]; then 
        rsync -a /server/world/ "$BACKUP_DIR/world/"
        echo "World backup OK"
    else 
        echo "WARNING: /server/world not found!"
    fi

    #if [ -d "server/config/" ]; then
    #    rsync -a /server/config/ "$BACKUP_DIR/config/"
    #    echo "Config backup OK"
    #else 
    #    echo "WARNING: /server/config not found!"
    #fi

    #if [ -d "/server/kubejs" ]; then
    #    rsync -a /server/kubejs/ "$BACKUP_DIR/kubejs/"
    #   echo "Kubejs backup OK"
    #else 
    #   echo "WARNING: /server/kubejs not found!"
    #fi

    #if [ -d "/server/defaultconfigs" ]; then
    #   rsync -a /server/defaultconfigs/ "$BACKUP_DIR/defaultconfigs/"
    #   echo "DefaultConfigs backup OK"
    #else 
    #    echo "WARNING: /server/defaultconfigs not found!" 
    #fi

    # 5. Re-enable auto-saving
    mcrcon -H mcServer -P 25575 -p "$RCON_PASSWORD" "save-on"

    # 6. Notify players that backup is complete
    mcrcon -H mcServer -P 25575 -p "$RCON_PASSWORD" \
        "say [Backup] Backup complete!"

    echo "Backup complete: $BACKUP_DIR"

    echo "Cleaning old backups (keeping last $RETENTION)..."
    COUNT=$(ls -ld /BackUps/* 2>/dev/null | wc -l)
    echo "Current backup count: $COUNT"

    # Is COUNT > RETENTION ? 
    if [ "$COUNT" -gt "$RETENTION" ]; then
        echo "More than $COUNT backups, deleting older backups..."

        ls -1dt /BackUps/* \
        | tail -n +$((RETENTION + 1)) \
        | xargs -r rm -rf
    else 
        echo "Less than $COUNT backups, no cleanup needed"
    fi

    echo "Sleeping for 30 minutes"
    sleep 1800 # 30 minutes
done