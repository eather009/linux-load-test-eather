#!/bin/bash

set -e

SVC_NAME="${SVC_NAME:-bgdsvc_eather}"
KEY_FILE="$HOME/.ssh/${SVC_NAME}_key"
SVC_HOME="/home/${SVC_NAME}"
SSH_DIR="${SVC_HOME}/.ssh"
AUTHORIZED_KEYS="${SSH_DIR}/authorized_keys"

echo "=== SSH access setup for ${SVC_NAME} ==="

# Create SSH key if it does not already exist
if [ -f "${KEY_FILE}" ] && [ -f "${KEY_FILE}.pub" ]; then
    echo "SSH key already exists: ${KEY_FILE}"
else
    echo "Generating Ed25519 SSH key..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -f "$KEY_FILE"
fi

# Create service account SSH directory
sudo mkdir -p "$SSH_DIR"

# Install public key
sudo cp "${KEY_FILE}.pub" "$AUTHORIZED_KEYS"

# Set ownership
sudo chown -R "${SVC_NAME}:${SVC_NAME}" "$SSH_DIR"

# Set permissions
sudo chmod 700 "$SSH_DIR"
sudo chmod 600 "$AUTHORIZED_KEYS"

# Enable interactive SSH access for this lab
sudo usermod -s /bin/bash "$SVC_NAME"

echo
echo "=== SSH configuration complete ==="
echo "User: ${SVC_NAME}"
echo "SSH directory: ${SSH_DIR}"
echo "Authorized keys: ${AUTHORIZED_KEYS}"
echo "Login shell: /bin/bash"

