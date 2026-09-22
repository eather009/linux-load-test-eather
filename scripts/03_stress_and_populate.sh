#!/bin/bash

set -euo pipefail

SVC_NAME="${SVC_NAME:-bgdsvc_eather}"
TMPDIR="/mnt/${SVC_NAME}_tmp"

disk_stress() {
    echo "=== Disk stress ==="

    for i in $(seq 1 20); do
        echo "Creating file_${i}.dat..."

        sudo -u "$SVC_NAME" dd \
            if=/dev/urandom \
            of="${TMPDIR}/file_${i}.dat" \
            bs=1M \
            count=10 \
            status=progress

        df -h "$TMPDIR"
    done
}

cpu_stress() {
    echo "=== CPU stress ==="
    cd "$TMPDIR"
    sudo -u "$SVC_NAME" stress-ng --cpu 2 --timeout 30s
}

memory_stress() {
    echo "=== Memory stress ==="
    cd "$TMPDIR"
    sudo -u "$SVC_NAME" stress-ng --vm 1 --vm-bytes 200M --timeout 30s
}

usage() {
    echo "Usage: $0 --cpu|--mem|--disk|--all"
    exit 1
}

case "${1:-}" in
    --cpu)
        cpu_stress
        ;;

    --mem)
        memory_stress
        ;;

    --disk)
        disk_stress
        ;;

    --all)
        echo "=== Combined stress test ==="

        cpu_stress &
        CPU_PID=$!

        memory_stress &
        MEM_PID=$!

        disk_stress

        wait "$CPU_PID"
        wait "$MEM_PID"

        echo "=== Combined stress test completed ==="
        ;;

    *)
        usage
        ;;
esac
