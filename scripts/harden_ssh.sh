#!/bin/bash

set -e

SVC_NAME="${SVC_NAME:-bgdsvc_eather}"
SSHD_CONFIG="/etc/ssh/sshd_config"

echo "=== SSH hardening for ${SVC_NAME} ==="

# Backup SSH configuration
if [ ! -f "${SSHD_CONFIG}.bak" ]; then
    sudo cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak"
    echo "Created SSH configuration backup."
else
    echo "SSH configuration backup already exists."
fi

# Remove existing assignment-managed settings
sudo sed -i \
    -e '/^[[:space:]]*Port[[:space:]]/d' \
    -e '/^[[:space:]]*PermitRootLogin[[:space:]]/d' \
    -e '/^[[:space:]]*PasswordAuthentication[[:space:]]/d' \
    -e '/^[[:space:]]*AllowUsers[[:space:]]/d' \
    "$SSHD_CONFIG"

# Apply SSH hardening
sudo tee -a "$SSHD_CONFIG" > /dev/null <<EOF

# Linux Load Test Lab - Part 5 SSH Hardening
Port 22
Port 2222
PermitRootLogin no
PasswordAuthentication no
AllowUsers ${SVC_NAME}
EOF

# Validate configuration
sudo sshd -t

# Reload SSH
sudo systemctl reload ssh

echo
echo "=== Effective SSH configuration ==="
sudo sshd -T | grep -E '^(port|permitrootlogin|passwordauthentication|allowusers)'

echo
echo "SSH hardening completed successfully."
