!/Bin/Bash

# Define An Array Of Destination Directories (Can Be 1 Or Many)
DESTINATIONS=("/mnt/user/backup/unraid_usb")

# Define Source Directory
SRC="/boot"

# List anything you may want to exclude
EXCLUDE=(--exclude=**/.git/ --exclude=**/.vscode/ --exclude=**/.vscode-server/ --exclude=/logs/)

#### END USER DEFINABLE ####

# Loop Over Each Destination
for DEST in "${DESTINATIONS[@]}"; do # Create a timestamp TIMESTAMP=$(date +"%Y-%m-%d--%H-%M-%S")

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

echo "------------------------Rsync Done!----------------------------" ```
