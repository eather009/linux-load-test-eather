#!/bin/bash

SVC_NAME="${SVC_NAME:-bgdsvc_eather}"
LOGFILE="/var/log/${SVC_NAME}/monitor.log"
TMPDIR="/mnt/${SVC_NAME}_tmp"

echo " ---- $(date) ---- " >> "$LOGFILE"
free -h >> "$LOGFILE"
df -h "$TMPDIR" >> "$LOGFILE" 2>&1
ps -u "$SVC_NAME" >> "$LOGFILE" 2>&1

