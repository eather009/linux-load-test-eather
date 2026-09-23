#!/bin/bash

SVC_NAME="${SVC_NAME:-bgdsvc_eather}"
TMPDIR="/mnt/${SVC_NAME}_tmp"
LOGFILE="/var/log/${SVC_NAME}/monitor.log"

find "$TMPDIR" -type f -mtime +1 -delete

echo "$(date): cleanup run — removed files older than 1 day from $TMPDIR" >> "$LOGFILE"

