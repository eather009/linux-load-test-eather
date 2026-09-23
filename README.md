# Linux Load Test & SysAdmin Lab

This repository contains my practical Linux SysAdmin / DevOps lab implementation based on the **Linux Deep Dive · DevOps Practical Lab** assignment.

The lab covers:

- Linux service account management
- `tmpfs` configuration and storage monitoring
- CPU, memory, and disk load testing
- SSH key-based access
- SSH hardening
- Cron-based monitoring and cleanup
- Log rotation with `logrotate`
- Safe and idempotent system cleanup
- Operational observations and evidence collection

The goal of this lab was not only to execute commands, but also to observe system behavior and document the results.

---

## Environment

- Cloud Platform: AWS EC2
- Operating System: Ubuntu Server 26.04 LTS
- Architecture: Linux x86_64
- Service Account: `bgdsvc_eather`
- Temporary Storage: `tmpfs`
- tmpfs Size: `256M`
- SSH Authentication: Ed25519 key
- Log Rotation: `logrotate`
- Monitoring: Bash + Cron

---

## Repository Structure

```text
linux-load-test-eather/
├── README.md
├── observations.md
├── scripts/
│   ├── 01_create_user.sh
│   ├── 02_setup_tmpfs.sh
│   ├── 03_stress_and_populate.sh
│   ├── 04_cleanup.sh
│   ├── bgdsvc_eather_monitor.sh
│   ├── bgdsvc_eather_cleanup_old_files.sh
│   ├── harden_ssh.sh
│   └── ssh_access.sh
└── screenshots/
    ├── 00_service_name.png
    ├── 01_id_created.png
    ├── 02_df_before.png
    ├── 02_df_after.png
    ├── 03_free_before.png
    ├── 03_free_during.png
    ├── 03_free_after.png
    ├── 03_dmesg_oom.png
    ├── 04_ssh_success.png
    ├── 05_crontab_l.png
    ├── 06_cleanup_verify.png
    └── 07_log_rotate.png
```

---

## Lab Tasks

### Part 1 — Service Account

Created a dedicated service account:

```text
bgdsvc_eather
```

The account was configured without normal password-based access.

The original assignment specifies `/usr/sbin/nologin` for the service account.

For the SSH portion of this lab, the shell was temporarily changed to `/bin/bash` so that interactive SSH access could be demonstrated.

This deviation is documented in `observations.md`.

---

### Part 2 — tmpfs

Created a temporary filesystem:

```text
/mnt/bgdsvc_eather_tmp
```

with a size limit of:

```text
256M
```

The directory was owned by:

```text
bgdsvc_eather:bgdsvc_eather
```

Disk usage was monitored before and after populating the filesystem.

---

### Part 3 — Load Testing

Performed three types of resource testing:

- CPU load
- Memory load
- Disk/tmpfs population

Disk testing populated the tmpfs with test files.

CPU and memory testing used `stress-ng`.

The combined test was also performed while monitoring the system from a second terminal.

The following tools were used during observation:

```bash
free -h
top
df -h
dmesg
```

No OOM event was observed during the combined test.

---

### Part 4 — SSH Key Access

Generated an Ed25519 SSH key specifically for the service account.

The public key was installed into:

```text
/home/bgdsvc_eather/.ssh/authorized_keys
```

The SSH directory and authorized key file were configured with restricted permissions.

Successful SSH access as `bgdsvc_eather` was verified.

---

### Part 5 — SSH Hardening

SSH hardening was tested using:

```text
Port 2222
PermitRootLogin no
PasswordAuthentication no
AllowUsers bgdsvc_eather
```

AWS Security Group access for TCP port `2222` was added before testing the new SSH path.

SSH configuration was validated before reloading the service.

Port 22 was kept available during testing to avoid losing administrative access.

After the lab cleanup, the SSH configuration was verified to ensure that normal administrative access remained available.

---

### Part 6 — Monitoring and Cron

Created a monitoring script that records:

- Memory usage
- tmpfs disk usage
- Processes owned by the service account

The monitoring log was stored under:

```text
/var/log/bgdsvc_eather/monitor.log
```

Cron jobs were configured for:

```text
Every 5 minutes:
monitoring

Every day at 02:00:
cleanup of files older than one day
```

Cron execution was verified using the system journal.

---

### Part 7 — Log Rotation

Configured `logrotate` for:

```text
/var/log/bgdsvc_eather/*.log
```

Configuration included:

- Daily rotation
- Maximum of 5 rotations
- Compression
- Missing-file handling
- Empty-file handling
- 10 MB size threshold
- New log permissions: `0640`
- Ownership: `bgdsvc_eather:bgdsvc_eather`

A forced rotation was performed and verified.

The resulting rotated file was:

```text
monitor.log.1.gz
```

The debug output also showed that the `size` option takes precedence over `daily` when both are configured.

---

### Part 8 — Cleanup

A dedicated cleanup script was created:

```text
scripts/04_cleanup.sh
```

The cleanup process removes:

- Service-account processes
- Service cron jobs
- Logrotate configuration
- Installed monitoring scripts
- tmpfs mount
- Temporary directory
- Monitoring logs
- Service account

The cleanup script was designed to be safe if earlier steps were already completed or partially failed.

The script also verifies that SSH port 22 is still available before removing the service account.

---

## Important Operational Observations

### tmpfs is memory-backed

The `tmpfs` filesystem consumes system memory rather than normal persistent disk storage.

A size limit was therefore used:

```text
256M
```

Without an appropriate limit, excessive tmpfs usage could consume available memory.

### Resource usage must be observed during load testing

A load test should not be evaluated only by whether the command succeeds.

CPU, memory, filesystem utilization, running processes, and kernel messages were monitored during testing.

### SSH changes can cause lockouts

When changing SSH configuration on a remote cloud server, the new access path should be opened and tested before removing the existing access path.

Port 22 was therefore kept available while port 2222 was tested.

### Cleanup must be performed carefully

System cleanup should not blindly remove unrelated configuration.

The cleanup script removes only the cron jobs and resources created for this lab.

---

## Security Notes

No private SSH keys are stored in this repository.

Private keys used during the lab were kept outside the Git repository.

Sensitive server information should be redacted before sharing screenshots or repository contents publicly.

---

## Evidence

The `screenshots/` directory contains evidence for:

1. Service account creation
2. tmpfs configuration
3. Resource load testing
4. OOM observation
5. SSH access
6. Cron configuration
7. Cleanup verification
8. Log rotation

Detailed observations are documented in:

```text
observations.md
```

---

## Cleanup Status

The lab environment was cleaned up after testing.

The final verification confirmed removal of the service account and lab resources while preserving administrative SSH access.

---

## Author

**eather009**

Linux / DevOps Practical Lab
