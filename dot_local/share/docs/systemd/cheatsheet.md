# Systemd Services Cheatsheet

Related: [unit file notes](unit-files.md), [troubleshooting notes](troubleshooting.md)

`systemctl` manages systemd units. Use it for service state, startup settings,
and unit inspection. Use `journalctl` for logs.

Use `--user` for user services under `~/.config/systemd/user/`.

Jump to:
[Daily Service Commands](#daily-service-commands) |
[Enable And Disable](#enable-and-disable) |
[User Services](#user-services) |
[Logs](#logs) |
[Listing And Searching](#listing-and-searching) |
[Unit Files](#unit-files) |
[Editing Units](#editing-units) |
[Troubleshooting Pointers](#troubleshooting-pointers) |
[Safety Controls](#safety-controls) |
[Common Patterns](#common-patterns) |
[Notes](#notes)

## Daily Service Commands

Related: [debug a failed service](troubleshooting.md#debug-a-failed-service)

### Show service status
systemctl status ssh.service

### Start a service now
sudo systemctl start ssh.service

### Stop a service now
sudo systemctl stop ssh.service

### Restart a service now
sudo systemctl restart ssh.service

### Reload service config without restarting, if supported
sudo systemctl reload ssh.service

### Restart if running
sudo systemctl try-restart ssh.service

### Show only whether it is active
systemctl is-active ssh.service

---

## Enable And Disable

Related: [install section](unit-files.md#install-directives), [target values](unit-files.md#target-values)

### Start at boot
sudo systemctl enable ssh.service

### Start now and at boot
sudo systemctl enable --now ssh.service

### Stop starting at boot
sudo systemctl disable ssh.service

### Disable and stop now
sudo systemctl disable --now ssh.service

### Check whether a service starts at boot
systemctl is-enabled ssh.service

### Show what enable created
systemctl list-dependencies multi-user.target | less

---

## User Services

Related: [user unit locations](unit-files.md#unit-locations), [user service debugging](troubleshooting.md#debug-a-user-service)

### Show user service status
systemctl --user status sunshine.service

### Start a user service
systemctl --user start sunshine.service

### Restart a user service
systemctl --user restart sunshine.service

### Enable user service at login
systemctl --user enable sunshine.service

### Enable and start a user service
systemctl --user enable --now sunshine.service

### Reload user unit files after editing
systemctl --user daemon-reload

### Let user services run after logout
loginctl enable-linger "$USER"

---

## Logs

Related: [journalctl patterns](troubleshooting.md#journalctl-patterns)

### Logs for a service
journalctl -u ssh.service

### Follow logs live
journalctl -fu ssh.service

### Logs since this boot
journalctl -b -u ssh.service

### Recent logs
journalctl -u ssh.service -n 100

### Logs since a time
journalctl -u ssh.service --since "1 hour ago"

### Logs for a user service
journalctl --user -u sunshine.service

### Follow user service logs live
journalctl --user -fu sunshine.service

---

## Listing And Searching

Related: [status words](unit-files.md#status-words), [dependency problems](troubleshooting.md#dependency-problems)

### Running services
systemctl list-units --type=service

### All services, including inactive
systemctl list-units --type=service --all

### Installed service unit files
systemctl list-unit-files --type=service

### Failed units
systemctl --failed

### Services matching a name
systemctl list-units --type=service --all '*ssh*'

### Show exact unit file path and contents
systemctl cat ssh.service

### Show service properties
systemctl show ssh.service

---

## Unit Files

Related: [unit file syntax](unit-files.md#unit-file-syntax), [common directives](unit-files.md#common-directives),
[directive values](unit-files.md#valid-values)

### Minimal system service
```ini
[Unit]
Description=My Service
After=network-online.target
Wants=network-online.target

[Service]
Type=exec
ExecStart=/usr/local/bin/my-service
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

### Minimal user service
```ini
[Unit]
Description=My User Service

[Service]
Type=exec
ExecStart=%h/.local/bin/my-user-service
Restart=on-failure

[Install]
WantedBy=default.target
```

### Reload system unit files after editing
sudo systemctl daemon-reload

### Reload user unit files after editing
systemctl --user daemon-reload

### Check a unit file for errors
systemd-analyze verify /etc/systemd/system/my-service.service

---

## Editing Units

Related: [override files](unit-files.md#override-files), [editing and restart loop](troubleshooting.md#edit-test-and-restart-loop)

### Edit a package-provided service override
sudo systemctl edit ssh.service

### Edit the full service file
sudo systemctl edit --full ssh.service

### Edit a user service override
systemctl --user edit sunshine.service

### Remove an override
sudo systemctl revert ssh.service

### Create a new system service
sudoedit /etc/systemd/system/my-service.service
sudo systemctl daemon-reload
sudo systemctl enable --now my-service.service

### Create a new user service
micro ~/.config/systemd/user/my-service.service
systemctl --user daemon-reload
systemctl --user enable --now my-service.service

---

## Troubleshooting Pointers

### Debug a failed system service
[Open troubleshooting note](troubleshooting.md#debug-a-failed-service)

systemctl status my-service.service
journalctl -u my-service.service -b -n 100

### Debug a failed user service
[Open troubleshooting note](troubleshooting.md#debug-a-user-service)

systemctl --user status my-service.service
journalctl --user -u my-service.service -b -n 100

### Clear failed state after fixing
sudo systemctl reset-failed my-service.service

### Show dependencies
systemctl list-dependencies my-service.service

### Show reverse dependencies
systemctl list-dependencies --reverse my-service.service

### Show startup timing
systemd-analyze blame

### Show dependency startup chain
systemd-analyze critical-chain my-service.service

---

## Safety Controls

Related: [masking and stuck services](troubleshooting.md#masked-or-stuck-services)

### Prevent a service from being started
sudo systemctl mask ssh.service

### Allow a masked service to start again
sudo systemctl unmask ssh.service

### Kill all processes in a service cgroup
sudo systemctl kill ssh.service

---

## Common Patterns

Related: [common fixes](troubleshooting.md#common-fixes), [service templates](unit-files.md#template-services)

### Edit a service and restart it
sudo systemctl edit ssh.service
sudo systemctl daemon-reload
sudo systemctl restart ssh.service
systemctl status ssh.service

### Create, verify, and start a system service
sudoedit /etc/systemd/system/my-service.service
systemd-analyze verify /etc/systemd/system/my-service.service
sudo systemctl daemon-reload
sudo systemctl enable --now my-service.service

### Create, verify, and start a user service
micro ~/.config/systemd/user/my-service.service
systemd-analyze --user verify ~/.config/systemd/user/my-service.service
systemctl --user daemon-reload
systemctl --user enable --now my-service.service

### Change a command in an override
sudo systemctl edit my-service.service
sudo systemctl daemon-reload
sudo systemctl restart my-service.service

Use [override files](unit-files.md#override-files) when replacing `ExecStart=`.

---

## Notes

- Add `.service` explicitly when it makes commands clearer.
- Use `sudo systemctl ...` for system services and `systemctl --user ...` for user services.
- Run `daemon-reload` after creating, deleting, or editing unit files.
- `enable` controls startup at boot or login; `start` controls the current running state.
- `After=` controls order; `Wants=` and `Requires=` control whether another unit is pulled in.
- `ExecStart=` is not a shell. Use `/bin/sh -c '...'` for shell features.
- Use [unit file notes](unit-files.md) when writing units and [troubleshooting notes](troubleshooting.md) when debugging.
