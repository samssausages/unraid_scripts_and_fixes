#!/bin/bash

# create 1 to 1 USB backup/copy, with a folder that keeps version changes.  (needs manual pruning right now
# folders to exclude, add/remove as needed
EXCLUDE=(--exclude=**/.git/ --exclude=**/.vscode/ --exclude=**/.vscode-server/ --exclude=/logs/)

# Define an array of destination directories, here we copy to another mounted USB and also to a share
DESTINATIONS=("/mnt/disks/usbbk" "/mnt/backups/unraid_usb")

# Define source directory
SRC="/boot"

# Loop over each destination
for DEST in "${DESTINATIONS[@]}"; do
    # Create a timestamp
    TIMESTAMP=$(date +"%Y-%m-%d--%H-%M-%S")

    # Backup directory path
    BACKUP_DIR="$DEST/backup_versions/$TIMESTAMP"

    # Options/flags for rsync
    RSYNC_FLAGS=(-rptgoDv --no-links --backup --backup-dir="$BACKUP_DIR")

    # Perform rsync backup
    rsync "${RSYNC_FLAGS[@]}" "${EXCLUDE[@]}" "$SRC/" "$DEST/"

    # Check if the backup directory has files
    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR")" ]; then
        # Compress the backup directory
        tar -cf - -C "$BACKUP_DIR" . | xz -9 > "$BACKUP_DIR.tar.xz"

        # Optionally, remove the uncompressed backup directory
        rm -rf "$BACKUP_DIR"
    else
        # Remove the potentially empty backup directory
        rm -rf "$BACKUP_DIR"
        echo "No files were changed, so no backup was created in $DEST."
    fi
done

echo "------------------------Rsync Done!----------------------------"