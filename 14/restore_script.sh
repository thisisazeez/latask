#!/bin/bash

BACKUP_DIR="/backup"
RESTORE_DIR="/var/www"

list_backups() {
    echo "Available backups:"
    ls -la "$BACKUP_DIR"/www_backup_*.tar.gz 2>/dev/null | nl
}

if [ $# -eq 0 ]; then
    echo "Usage: $0 <backup_filename>"
    echo "Example: $0 www_backup_20241206_143052.tar.gz"
    echo ""
    list_backups
    exit 1
fi

BACKUP_FILE="$BACKUP_DIR/$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file '$BACKUP_FILE' not found!"
    echo ""
    list_backups
    exit 1
fi

echo "WARNING: This will overwrite the current contents of /var/www/html"
echo "Restoring from: $BACKUP_FILE"
read -p "Are you sure you want to continue? (y/N): " confirm

if [[ $confirm =~ ^[Yy]$ ]]; then
    CURRENT_BACKUP="/tmp/html_backup_before_restore_$(date +%Y%m%d_%H%M%S).tar.gz"
    echo "Creating backup of current state: $CURRENT_BACKUP"
    tar -czf "$CURRENT_BACKUP" -C /var/www html 2>/dev/null
    
    echo "Restoring from $BACKUP_FILE..."
    tar -xzf "$BACKUP_FILE" -C "$RESTORE_DIR"
    
    if [ $? -eq 0 ]; then
        echo "Restore completed successfully!"
    else
        echo "Restore failed!"
        exit 1
    fi
else
    echo "Restore cancelled."
    exit 0
fi