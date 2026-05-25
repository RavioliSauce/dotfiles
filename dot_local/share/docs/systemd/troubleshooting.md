# Systemd Troubleshooting Notes

Start from the [Systemd cheatsheet](cheatsheet.md), or review
[unit file notes](unit-files.md) when the failure is probably in the unit file.

Start service debugging with `systemctl status`, then `journalctl`, then the
merged unit file from `systemctl cat`.

Jump to:
[Debug A Failed Service](#debug-a-failed-service) |
[Debug A User Service](#debug-a-user-service) |
[Journalctl Patterns](#journalctl-patterns) |
[Edit Test And Restart Loop](#edit-test-and-restart-loop) |
[Unit File Problems](#unit-file-problems) |
[Dependency Problems](#dependency-problems) |
[Restart Loops](#restart-loops) |
[Permission Problems](#permission-problems) |
[Environment Problems](#environment-problems) |
[Network Startup Problems](#network-startup-problems) |
[Masked Or Stuck Services](#masked-or-stuck-services) |
[Boot Timing](#boot-timing) |
[Common Fixes](#common-fixes) |
[Notes](#notes)

## Debug A Failed Service

Related: [daily service commands](cheatsheet.md#daily-service-commands),
[unit file syntax](unit-files.md#unit-file-syntax)

### First look
systemctl status my-service.service

### Logs from this boot
journalctl -u my-service.service -b

### Last 100 log lines from this boot
journalctl -u my-service.service -b -n 100

### Follow logs while restarting
journalctl -fu my-service.service

### Show the unit file and overrides
systemctl cat my-service.service

### Show where the main unit file lives
systemctl show -p FragmentPath my-service.service

### Clear failed state after fixing
sudo systemctl reset-failed my-service.service

### Try the start again
sudo systemctl start my-service.service

---

## Debug A User Service

Related: [user services](cheatsheet.md#user-services), [user unit locations](unit-files.md#unit-locations)

### First look
systemctl --user status my-service.service

### User service logs
journalctl --user -u my-service.service -b

### Follow user service logs
journalctl --user -fu my-service.service

### Show user unit file and overrides
systemctl --user cat my-service.service

### Reload user units after editing
systemctl --user daemon-reload

### Clear user failed state
systemctl --user reset-failed my-service.service

### Let user services run after logout
loginctl enable-linger "$USER"

---

## Journalctl Patterns

Related: [logs](cheatsheet.md#logs)

### Current boot logs for one service
journalctl -b -u my-service.service

### Previous boot logs for one service
journalctl -b -1 -u my-service.service

### Follow logs live
journalctl -fu my-service.service

### Show newest lines first
journalctl -u my-service.service -r

### Show logs since a time
journalctl -u my-service.service --since "30 minutes ago"

### Show logs in a time window
journalctl -u my-service.service --since "2026-05-22 09:00" --until "2026-05-22 10:00"

### Show errors and worse from this boot
journalctl -b -p err

### Show only kernel logs from this boot
journalctl -k -b

### Show extra fields for one entry
journalctl -u my-service.service -n 1 -o verbose

---

## Edit Test And Restart Loop

Related: [editing units](cheatsheet.md#editing-units), [override files](unit-files.md#override-files)

### System service loop
sudo systemctl edit my-service.service
sudo systemctl daemon-reload
sudo systemctl restart my-service.service
systemctl status my-service.service
journalctl -u my-service.service -b -n 100

### User service loop
systemctl --user edit my-service.service
systemctl --user daemon-reload
systemctl --user restart my-service.service
systemctl --user status my-service.service
journalctl --user -u my-service.service -b -n 100

### Verify a system unit file
systemd-analyze verify /etc/systemd/system/my-service.service

### Verify a user unit file
systemd-analyze --user verify ~/.config/systemd/user/my-service.service

---

## Unit File Problems

Related: [unit file syntax](unit-files.md#unit-file-syntax), [common directives](unit-files.md#common-directives)

### See merged unit content
systemctl cat my-service.service

### Show unit load state
systemctl show -p LoadState -p UnitFileState -p FragmentPath my-service.service

### Reload unit files after editing
sudo systemctl daemon-reload

### Edited unit is not being used
sudo systemctl daemon-reload
sudo systemctl restart my-service.service

### ExecStart needs shell syntax
ExecStart=/bin/sh -c 'command one | command two'

### Override replaces ExecStart
```ini
[Service]
ExecStart=
ExecStart=/usr/local/bin/new-command
```

### Executable path is wrong
command -v my-service
ls -l /usr/local/bin/my-service

### Service starts then exits
Use `Type=oneshot` for a short task, or make the program stay in the foreground.

---

## Dependency Problems

Related: [ordering versus requirement](unit-files.md#ordering-versus-requirement)

### Show dependencies
systemctl list-dependencies my-service.service

### Show reverse dependencies
systemctl list-dependencies --reverse my-service.service

### Show failed dependencies
systemctl --failed

### Show dependency startup chain
systemd-analyze critical-chain my-service.service

### Network ordering pattern
```ini
[Unit]
After=network-online.target
Wants=network-online.target
```

`After=` controls order. `Wants=` pulls the other unit into the transaction.
Using only `After=` does not start the other unit.

---

## Restart Loops

Related: [restart values](unit-files.md#restart-values)

### Watch the loop
journalctl -fu my-service.service

### Show restart settings
systemctl show -p Restart -p RestartUSec -p NRestarts my-service.service

### Slow down restarts
```ini
[Service]
Restart=on-failure
RestartSec=10s
```

### Stop the loop while debugging
sudo systemctl stop my-service.service

### Clear failed state after fixing
sudo systemctl reset-failed my-service.service

---

## Permission Problems

Related: [service directives](unit-files.md#service-directives)

### Check the service user
systemctl show -p User -p Group my-service.service

### Check file permissions
ls -ld /srv/my-service
ls -l /usr/local/bin/my-service

### Test command as the service user
sudo -u app /usr/local/bin/my-service

### Set the working directory
```ini
[Service]
WorkingDirectory=/srv/my-service
```

### Run as a specific user
```ini
[Service]
User=app
Group=app
```

---

## Environment Problems

Related: [common directives](unit-files.md#common-directives), [ExecStart syntax](unit-files.md#execstart-syntax)

### Show environment-related properties
systemctl show -p Environment -p EnvironmentFiles my-service.service

### Add inline environment variables
```ini
[Service]
Environment=MODE=prod PORT=8080
```

### Load an environment file
```ini
[Service]
EnvironmentFile=-/etc/default/my-service
```

### Interactive shell note
`ExecStart=` is not your interactive shell. It does not read `.bashrc`, and
shell features need `/bin/sh -c '...'`.

---

## Network Startup Problems

Related: [dependency problems](#dependency-problems)

### Check network-online target
systemctl status network-online.target

### Add network ordering and pull-in
```ini
[Unit]
After=network-online.target
Wants=network-online.target
```

### Check what waited during boot
systemd-analyze critical-chain network-online.target

### When to use network-online.target
Use this only for services that truly need the network before starting. Many
daemons can start first and reconnect later.

---

## Masked Or Stuck Services

Related: [safety controls](cheatsheet.md#safety-controls), [status words](unit-files.md#status-words)

### Check whether it is masked
systemctl is-enabled my-service.service

### Unmask it
sudo systemctl unmask my-service.service

### Stop it
sudo systemctl stop my-service.service

### Kill remaining processes in its cgroup
sudo systemctl kill my-service.service

### Show service processes
systemctl status my-service.service

---

## Boot Timing

### Show slow units
systemd-analyze blame

### Show critical startup chain
systemd-analyze critical-chain

### Show chain for one service
systemd-analyze critical-chain my-service.service

### Show boot summary
systemd-analyze

---

## Common Fixes

### Edited a unit but nothing changed
sudo systemctl daemon-reload
sudo systemctl restart my-service.service

### Service says bad unit setting
systemd-analyze verify /etc/systemd/system/my-service.service

### Service starts too early
Add both `After=` and `Wants=` for the dependency you need.

### Service cannot find a command
Use the absolute path in `ExecStart=`.

### Service needs shell syntax
Use `/bin/sh -c '...'` in `ExecStart=`.

### Override did not replace ExecStart
Clear the old value first:

```ini
[Service]
ExecStart=
ExecStart=/usr/local/bin/new-command
```

### Service failed before but is fixed now
sudo systemctl reset-failed my-service.service
sudo systemctl start my-service.service

---

## Notes

- Start with `systemctl status` and `journalctl -u name.service -b`.
- Use `systemctl cat` before guessing what unit file is active.
- Use `systemd-analyze verify` after writing or heavily editing a unit.
- Check [unit file notes](unit-files.md) when a directive or value is unclear.
- A service that exits immediately needs either a foreground process or `Type=oneshot`.
