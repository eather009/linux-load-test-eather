#!/bin/bash

SVC_NAME="${SVC_NAME:-bgdsvc_eather}"
TMPDIR="/mnt/${SVC_NAME}_tmp"

sudo mkdir -p "$TMPDIR"

if mountpoint -q "$TMPDIR"; then
    echo "$TMPDIR is already mounted."
else
    sudo mount -t tmpfs -o size=256M tmpfs "$TMPDIR"
    echo "Mounted 256M tmpfs at $TMPDIR."
fi

sudo chown "$SVC_NAME:$SVC_NAME" "$TMPDIR"

df -h "$TMPDIR"

