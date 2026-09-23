#!/bin/bash

set -e

SVC_NAME="${SVC_NAME:-bgdsvc_eather}"
TMPDIR="/mnt/${SVC_NAME}_tmp"
LOGDIR="/var/log/${SVC_NAME}"
MONITOR_SCRIPT="/usr/local/bin/${SVC_NAME}_monitor.sh"
CLEANUP_SCRIPT="/usr/local/bin/${SVC_NAME}_cleanup_old_files.sh"
LOGROTATE_CONFIG="/etc/logrotate.d/${SVC_NAME}"

echo "Starting cleanup for ${SVC_NAME}..."

# 1. Stop processes owned by the service account
echo "[1/9] Stopping service-account processes..."
if id "$SVC_NAME" >/dev/null 2>&1; then
    sudo pkill -u "$SVC_NAME" 2>/dev/null || true
fi

# 2. Remove only our root cron jobs
echo "[2/9] Removing service cron jobs..."
sudo crontab -l 2>/dev/null | \
    grep -v "/usr/local/bin/${SVC_NAME}_monitor.sh" | \
    grep -v "/usr/local/bin/${SVC_NAME}_cleanup_old_files.sh" \
    | sudo crontab - || true

# 3. Remove logrotate configuration
echo "[3/9] Removing logrotate configuration..."
sudo rm -f "$LOGROTATE_CONFIG"

# 4. Remove installed monitoring scripts
echo "[4/9] Removing monitoring scripts..."
sudo rm -f "$MONITOR_SCRIPT"
sudo rm -f "$CLEANUP_SCRIPT"

# 5. Verify SSH access is still available before removing the service account
echo "[5/9] Verifying SSH configuration..."

sudo sshd -t

if ! sudo ss -lnt | grep -qE '0\.0\.0\.0:22|\[::\]:22'; then
    echo "ERROR: SSH port 22 is not listening."
    echo "Cleanup aborted before removing the service account."
    exit 1
fi

echo "SSH configuration is valid and port 22 is listening."


# 6. Unmount tmpfs
echo "[6/9] Removing tmpfs..."

if mountpoint -q "$TMPDIR"; then
    sudo umount "$TMPDIR"
fi

sudo rmdir "$TMPDIR" 2>/dev/null || true

# 7. Remove log directory
echo "[7/9] Removing log directory..."
sudo rm -rf "$LOGDIR"

# 8. Delete service account
echo "[8/9] Removing service account..."

if id "$SVC_NAME" >/dev/null 2>&1; then
    sudo userdel -r "$SVC_NAME"
fi

# 9. Final verification
echo "[9/9] Verifying cleanup..."

if id "$SVC_NAME" >/dev/null 2>&1; then
    echo "ERROR: Service account still exists."
    exit 1
fi

if mountpoint -q "$TMPDIR"; then
    echo "ERROR: tmpfs is still mounted."
    exit 1
fi

if [ -e "$LOGDIR" ]; then
    echo "ERROR: Log directory still exists."
    exit 1
fi

if [ -e "$MONITOR_SCRIPT" ] || [ -e "$CLEANUP_SCRIPT" ]; then
    echo "ERROR: Monitoring scripts still exist."
    exit 1
fi

if [ -e "$LOGROTATE_CONFIG" ]; then
    echo "ERROR: Logrotate configuration still exists."
    exit 1
fi

echo
echo "Cleanup completed successfully."

