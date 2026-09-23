The service account was initially created with /usr/sbin/nologin as specified in Part 1. 

SSH public-key authentication succeeded, but the interactive session was rejected because of the login shell.
To complete the SSH access requirement in Part 4, the account shell was changed to /bin/bash.

Ubuntu uses systemd socket activation for SSH.
Although sshd -T showed both ports 22 and 2222, the active ssh.socket initially listened only on port 22. After configuring the socket, port 2222 became available and SSH key authentication succeeded.


Part 5: SSH Hardening

The AWS Security Group initially allowed SSH on TCP port 22. TCP port 2222 was added before changing the SSH configuration so that the new SSH path could be tested safely.

The final effective SSH configuration was:
- Port 22
- Port 2222
- PermitRootLogin no
- PasswordAuthentication no
- AllowUsers bgdsvc_eather

SSH configuration validation with sshd -t completed successfully. A new SSH connection using the service account's Ed25519 key successfully connected through port 2222.

Port 22 was kept enabled during testing to avoid losing administrative access to the EC2 instance.


Part 6: Monitoring and Cron

The cron service was already installed, enabled, and running on the system.

The monitoring script was tested manually and successfully recorded the timestamp, memory usage, tmpfs usage, and processes belonging to the service account.

The monitoring script was installed under /usr/local/bin and scheduled through root's crontab to run every 5 minutes.

Cron execution was verified using journalctl. The cron log showed /usr/local/bin/bgdsvc_eather_monitor.sh executing at 16:35:01 UTC, and a corresponding timestamped entry appeared in monitor.log.

The cleanup script was configured to remove files older than one day from the service account's tmpfs directory. It was not manually executed during testing because the tmpfs contained files used as evidence from the earlier stress-testing exercise.




Part 7: Log Rotation

A logrotate configuration was created for /var/log/bgdsvc_eather/*.log.

The configuration uses daily rotation, keeps 5 rotations, compresses rotated logs, skips missing and empty logs, and creates new logs with 0640 permissions owned by bgdsvc_eather.

The configuration was first checked using logrotate debug mode. The debug output showed that the current monitor.log was below the 10 MB size threshold.

A forced rotation was then performed using logrotate -f. The result was:
- monitor.log — newly created empty log
- monitor.log.1.gz — compressed rotated log

Both files were owned by bgdsvc_eather:bgdsvc_eather, with the expected 0640 permissions.

The 'size' option overrides the 'daily' option as the rotation trigger when both are specified. This was observed in the logrotate debug output.


