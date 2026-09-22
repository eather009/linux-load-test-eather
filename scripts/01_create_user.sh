#!/bin/bash

SVC_NAME="${SVC_NAME:-bgdsvc_eather}"

if id "$SVC_NAME" >/dev/null 2>&1; then
    echo "User $SVC_NAME already exists."
else
    sudo useradd -r -m -s /usr/sbin/nologin "$SVC_NAME"
    echo "User $SVC_NAME created."
fi

