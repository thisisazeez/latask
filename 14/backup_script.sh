#!/bin/bash

SOURCE_DIR="/var/www/html"
BACKUP_DIR="/backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="www_backup_$TIMESTAMP.tar.gz"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

mkdir -p "$BACKUP_DIR"

echo "Starting backup of $SOURCE_DIR..."
tar -czf "$BACKUP_PATH" -C /var/www html

if [ $? -eq 0 ]; then
    echo "Backup completed successfully!"
    echo "Backup saved as: $BACKUP_PATH"
    echo "Backup size: $(du -h "$BACKUP_PATH" | cut -f1)"
else
    echo "Backup failed!"
    exit 1
fi