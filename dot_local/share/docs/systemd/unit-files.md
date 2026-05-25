# Systemd Unit File Notes

Start from the [Systemd cheatsheet](cheatsheet.md), or jump to
[troubleshooting notes](troubleshooting.md).

Unit files are plain text files that tell systemd how a service should be
named, ordered, started, stopped, restarted, and enabled.

Jump to:
[Unit Locations](#unit-locations) |
[Unit File Syntax](#unit-file-syntax) |
[Minimal Services](#minimal-services) |
[Common Directives](#common-directives) |
[Override Files](#override-files) |
[Template Services](#template-services) |
[Helpful Keys And Specifiers](#helpful-keys-and-specifiers) |
[Directive Values](#valid-values) |
[Reference Man Pages](#reference-man-pages) |
[Notes](#notes)

## Unit Locations

Related: [create a system service](cheatsheet.md#create-verify-and-start-a-system-service),
[create a user service](cheatsheet.md#create-verify-and-start-a-user-service)

### System unit locations
/etc/systemd/system/
/usr/lib/systemd/system/
/lib/systemd/system/

### User unit locations
~/.config/systemd/user/
/etc/systemd/user/
/usr/lib/systemd/user/

### Best place for your own system unit
/etc/systemd/system/my-service.service

### Best place for your own user unit
~/.config/systemd/user/my-service.service

### Show the unit systemd is actually using
systemctl cat my-service.service

### Show only the resolved fragment path
systemctl show -p FragmentPath my-service.service

---

## Unit File Syntax

Related: [common directives](#common-directives), [directive values](#valid-values)

### Basic shape
```ini
[Unit]
Description=Readable service name

[Service]
Type=exec
ExecStart=/absolute/path/to/program --flag value

[Install]
WantedBy=multi-user.target
```

### What the sections mean
| Section | Description |
| --- | --- |
| `[Unit]` | Name, docs, dependency order, and conditions. |
| `[Service]` | How to start, stop, restart, and run the service process. |
| `[Install]` | What `systemctl enable` should hook this unit into. |

### Basic rules
| Syntax | Description |
| --- | --- |
| `Key=value` | A directive named `Key` gets `value`. |
| `# comment` or `; comment` | Ignored comment line. |
| Blank line | Ignored. Use it for readability. |
| Spaces around `=` | Ignored. `Key=value` and `Key = value` both work. |
| Line ending with `\` | Continues on the next line. |
| Repeated key | List directives such as `Wants=`, `After=`, `Environment=`, and `ExecStartPre=` can be repeated. Single-value directives such as `Type=` and `User=` are replaced by the later value. |
| Empty assignment | For list directives, this resets the list before adding new values. This is required when replacing `ExecStart=` in an override. |

### ExecStart syntax
Exec lines look shell-like, but they are not a shell.

### Normal command
ExecStart=/usr/local/bin/my-service --config /etc/my-service.conf

### Command with a space in one argument
ExecStart=/usr/bin/notify-send "Backup finished"

### Use a shell when you need pipes, redirects, or &&
ExecStart=/bin/sh -c 'date >> /tmp/my-service.log && /usr/local/bin/my-service'

### Ignore failure for one command
ExecStart=-/usr/local/bin/best-effort-cleanup

### Important ExecStart rules
- Use an absolute path when possible.
- Services with `Type=simple`, `Type=exec`, `Type=forking`, `Type=notify`, `Type=notify-reload`, `Type=dbus`, or `Type=idle` use one `ExecStart=`.
- Multiple `ExecStart=` lines are for `Type=oneshot`.
- `ExecStartPre=` is for short setup commands, not background daemons.
- Use `/bin/sh -c '...'` when you need shell syntax.
- Use `%%` when you need a literal percent sign.

---

## Minimal Services

Related: [type values](#type-values), [restart values](#restart-values)

### Long-running system service
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

### Long-running user service
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

### One-shot task
```ini
[Unit]
Description=Run one setup task

[Service]
Type=oneshot
ExecStart=/usr/local/bin/setup-once
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

### Service with an environment file
```ini
[Unit]
Description=App With Environment File

[Service]
Type=exec
EnvironmentFile=-/etc/default/my-app
ExecStart=/usr/local/bin/my-app --port ${PORT}
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

---

## Common Directives

Related: [directive values](#valid-values), [dependency problems](troubleshooting.md#dependency-problems)

### Unit directives
| Key | Description | Example |
| --- | --- | --- |
| `Description=` | Human-readable name shown in `status`. | `Description=Sunshine Game Stream` |
| `Documentation=` | Links to docs or man pages. | `Documentation=man:sshd(8)` |
| `After=` | Start this unit after another unit. This is only ordering. See [Unit name values](#unit-name-values). | `After=network-online.target` |
| `Before=` | Start this unit before another unit. This is only ordering. See [Unit name values](#unit-name-values). | `Before=shutdown.target` |
| `Wants=` | Pull in another unit, but do not fail if it fails. See [Unit name values](#unit-name-values). | `Wants=network-online.target` |
| `Requires=` | Pull in another unit and fail if it cannot start. See [Unit name values](#unit-name-values). | `Requires=postgresql.service` |
| `ConditionPathExists=` | Start only if a path exists. | `ConditionPathExists=/etc/my-service.conf` |
| `OnFailure=` | Start another unit when this one fails. | `OnFailure=notify-failure@%n.service` |

### Service directives
| Key | Description | Example |
| --- | --- | --- |
| `Type=` | How systemd decides the service has started. See [Type values](#type-values). | `Type=exec` |
| `ExecStart=` | Main command to run. | `ExecStart=/usr/local/bin/app` |
| `ExecStartPre=` | Short command before `ExecStart=`. | `ExecStartPre=/usr/bin/test -f /etc/app.conf` |
| `ExecStartPost=` | Command after startup succeeds. | `ExecStartPost=/usr/bin/logger app started` |
| `ExecReload=` | Command for `systemctl reload`. | `ExecReload=/bin/kill -HUP $MAINPID` |
| `ExecStop=` | Custom stop command. Leave unset when `SIGTERM` cleanly stops the service. | `ExecStop=/usr/local/bin/appctl stop` |
| `WorkingDirectory=` | Directory the command starts in. | `WorkingDirectory=/srv/app` |
| `Environment=` | Inline environment variables. | `Environment=MODE=prod PORT=8080` |
| `EnvironmentFile=` | Load environment variables from a file. A leading `-` means missing file is okay. | `EnvironmentFile=-/etc/default/app` |
| `User=` | Run the process as this user. | `User=app` |
| `Group=` | Run the process as this group. | `Group=app` |
| `Restart=` | Whether systemd restarts the service. See [Restart values](#restart-values). | `Restart=on-failure` |
| `RestartSec=` | Wait time before restarting. See [Time values](#time-values). | `RestartSec=5s` |
| `TimeoutStartSec=` | Max startup time before failure. | `TimeoutStartSec=30s` |
| `TimeoutStopSec=` | Max stop time before force killing. | `TimeoutStopSec=30s` |
| `RemainAfterExit=` | Keep oneshot service active after command exits. See [Boolean values](#boolean-values). | `RemainAfterExit=yes` |
| `StandardOutput=` | Where stdout goes. See [Output values](#output-values). | `StandardOutput=journal` |
| `StandardError=` | Where stderr goes. Uses the same values as `StandardOutput=`. | `StandardError=journal` |
| `KillMode=` | Which processes systemd kills on stop. See [KillMode values](#killmode-values). | `KillMode=control-group` |
| `KillSignal=` | Signal sent first when stopping. | `KillSignal=SIGTERM` |

### Install directives
| Key | Description | Example |
| --- | --- | --- |
| `WantedBy=` | Target that should want this unit when enabled. See [Target values](#target-values). | `WantedBy=multi-user.target` |
| `RequiredBy=` | Like `WantedBy=`, but as a hard requirement. | `RequiredBy=my-stack.target` |
| `Alias=` | Extra name for the same unit. | `Alias=my-app.service` |
| `Also=` | Enable or disable these units together. | `Also=my-app.timer` |

### Ordering versus requirement
```ini
After=network-online.target
Wants=network-online.target
```

`After=` says "wait until that unit starts first."
`Wants=` says "also try to start that unit."
Use both when this service needs `network-online.target` to be started before
the service starts.

---

## Override Files

Related: [editing units](cheatsheet.md#editing-units), [edit test and restart loop](troubleshooting.md#edit-test-and-restart-loop)

### Edit a package-provided unit safely
sudo systemctl edit ssh.service

### Edit the whole unit file
sudo systemctl edit --full ssh.service

### Edit a user unit override
systemctl --user edit sunshine.service

### See base unit plus overrides
systemctl cat ssh.service

### Remove local overrides
sudo systemctl revert ssh.service

### Replace ExecStart in an override
```ini
[Service]
ExecStart=
ExecStart=/usr/local/bin/new-command
```

You need the empty `ExecStart=` because `ExecStart=` is a list-style directive.
The empty assignment clears the old command before adding the new one.

---

## Template Services

Related: [useful percent specifiers](#useful-percent-specifiers)

Templates let one unit file run many named instances.

### Template file name
worker@.service

### Start one instance
sudo systemctl start worker@alpha.service

### Template service using an instance name
```ini
[Unit]
Description=Worker for %i

[Service]
Type=exec
ExecStart=/usr/local/bin/worker --queue %i

[Install]
WantedBy=multi-user.target
```

### What the names mean
| Name | Description |
| --- | --- |
| `worker@.service` | Template file. |
| `worker@alpha.service` | Instance named `alpha`. |
| `%i` | Escaped instance name. |
| `%I` | Unescaped instance name. |

---

## Helpful Keys And Specifiers

Related: [unit file syntax](#unit-file-syntax), [template services](#template-services)

### Exec command prefixes
These go at the start of an `ExecStart=`, `ExecStop=`, or similar command.

| Prefix | Description | Example |
| --- | --- | --- |
| `-` | Treat failure as okay for this command. | `ExecStart=-/usr/bin/false` |
| `:` | Do not expand environment variables for this command. | `ExecStart=:/usr/bin/echo $USER` |
| `+` | Run this command with full privileges, bypassing service sandboxing for this command. | `ExecStart=+/usr/bin/id` |
| `!` | Bypass only `User=`, `Group=`, and supplementary group credential changes for this command. | `ExecStart=!/usr/bin/id` |
| `@` | Set a custom `argv[0]`, the process name seen by the executed program. | `ExecStart=@/usr/bin/python my-name app.py` |

### Useful percent specifiers
These are placeholders systemd expands in many unit settings.

| Key | Description | Example use |
| --- | --- | --- |
| `%n` | Full unit name, including suffix. | `notify@%n.service` |
| `%N` | Unit name without the `.service` suffix. | `/var/log/%N.log` |
| `%p` | Prefix before `@`, or name without suffix for normal units. | `worker@alpha.service` gives `worker` |
| `%i` | Instance name from a template unit. | `worker@alpha.service` gives `alpha` |
| `%I` | Unescaped instance name. | Use when the instance name was escaped from a path. |
| `%h` | Home directory of the systemd manager user. | `%h/.local/bin/app` |
| `%u` | User name of the systemd manager user. | `Environment=OWNER=%u` |
| `%U` | UID of the systemd manager user. | `Environment=OWNER_UID=%U` |
| `%t` | Runtime directory root. | `%t/my-app.sock` |
| `%S` | State directory root. | `%S/my-app` |
| `%E` | Config directory root. | `%E/my-app/config.toml` |
| `%C` | Cache directory root. | `%C/my-app` |
| `%%` | Literal percent sign. | `ExecStart=/usr/bin/printf '100%%\n'` |

### Common automatic environment variables
| Variable | Description |
| --- | --- |
| `$MAINPID` | Main process ID, useful in `ExecReload=` and `ExecStop=`. |
| `$USER` | User known to the service manager. |
| `$HOME` | Home directory known to the service manager. |
| `$INVOCATION_ID` | Unique ID for this service run, useful in logs. |

---

## Valid Values

These tables show common values and the directive keys they are valid for. For
the complete list on this machine, use [reference man pages](#reference-man-pages).

| Value section | Used by |
| --- | --- |
| [Type values](#type-values) | `Type=` |
| [Restart values](#restart-values) | `Restart=` |
| [Boolean values](#boolean-values) | `RemainAfterExit=`, `PrivateTmp=`, `NoNewPrivileges=`, `DynamicUser=`, and other boolean directives |
| [Time values](#time-values) | `RestartSec=`, `TimeoutStartSec=`, `TimeoutStopSec=`, `RuntimeMaxSec=`, `WatchdogSec=` |
| [Unit name values](#unit-name-values) | `After=`, `Before=`, `Wants=`, `Requires=`, `Conflicts=`, `PartOf=`, `BindsTo=` |
| [Target values](#target-values) | `WantedBy=`, `RequiredBy=`, and dependency directives when the dependency is a target |
| [KillMode values](#killmode-values) | `KillMode=` |
| [Output values](#output-values) | `StandardOutput=`, `StandardError=` |
| [Status words](#status-words) | `systemctl status`, `is-active`, `is-enabled`, `list-units`, `list-unit-files` |

### Type values
Used by: `Type=`

| Value | Description |
| --- | --- |
| `simple` | systemd considers the service started immediately after forking the process. |
| `exec` | Like `simple`, but startup fails if the executable cannot be launched. Use for normal foreground services. |
| `oneshot` | Run a short task and exit. Allows multiple `ExecStart=` lines. |
| `forking` | For daemons that start, fork into the background, and let the parent process exit. |
| `notify` | Service sends a readiness notification to systemd. The program must support `sd_notify`. |
| `notify-reload` | Like `notify`, with readiness notification for reloads too. |
| `dbus` | Service is ready when it acquires `BusName=` on D-Bus. |
| `idle` | Delays execution until active jobs are dispatched; use only when console output ordering matters. |

### Restart values
Used by: `Restart=`

| Value | Description |
| --- | --- |
| `no` | Do not restart automatically. |
| `on-failure` | Restart after non-zero exit, signal, timeout, or watchdog failure. Use for services that should recover from crashes. |
| `always` | Restart after almost any exit. Not valid for successful `Type=oneshot` exits. |
| `on-success` | Restart only after a clean exit. Use for repeated successful jobs that should immediately run again. |
| `on-abnormal` | Restart after signal, timeout, or watchdog failure. |
| `on-abort` | Restart after an uncaught signal. |
| `on-watchdog` | Restart after watchdog timeout only. |

### Boolean values
Used by: boolean directives such as `RemainAfterExit=`, `PrivateTmp=`,
`NoNewPrivileges=`, `DynamicUser=`, and other directives documented as boolean
in the man pages.

| True values | False values |
| --- | --- |
| `yes`, `true`, `on`, `1` | `no`, `false`, `off`, `0` |

### Time values
Used by: time directives such as `RestartSec=`, `TimeoutStartSec=`,
`TimeoutStopSec=`, `RuntimeMaxSec=`, and `WatchdogSec=`.

| Value | Description |
| --- | --- |
| `30` | 30 seconds. Bare numbers mean seconds. |
| `500ms` | 500 milliseconds. |
| `5s` | 5 seconds. |
| `2min` | 2 minutes. |
| `1h` | 1 hour. |
| `2min 30s` | Combined time span. |
| `infinity` | No timeout. Valid for timeout-style directives that document `infinity` support. |

### Unit name values
Used by: dependency directives such as `After=`, `Before=`, `Wants=`,
`Requires=`, `Conflicts=`, `PartOf=`, and `BindsTo=`.

`After=` does not have keyword values. Its values are unit names. Include the
unit suffix so the dependency is clear.

| Value shape | Description | Example |
| --- | --- | --- |
| `name.service` | A service unit. | `After=postgresql.service` |
| `name.target` | A target unit, often used as a synchronization point. | `After=network-online.target` |
| `name.socket` | A socket unit. | `After=dbus.socket` |
| `name.mount` | A mount unit. Use `systemd-escape` for path-based names. | `After=home.mount` |
| `name.device` | A device unit created by systemd/udev. | `After=dev-sda1.device` |
| `name.timer` | A timer unit. | `After=backup.timer` |
| `name.path` | A path unit. | `After=watch-config.path` |

### List loaded unit names
systemctl list-units --all

### List installed unit file names
systemctl list-unit-files

### Convert a path to a mount unit name
systemd-escape -p --suffix=mount /home

### Target values
Used by: install directives such as `WantedBy=` and `RequiredBy=`, and by
dependency directives such as `Wants=`, `Requires=`, `After=`, and `Before=`
when the dependency is a target unit.

| Target | Description |
| --- | --- |
| `multi-user.target` | Normal system service startup without requiring a desktop. |
| `graphical.target` | System startup with a graphical session stack. |
| `default.target` | Usual target for user services. |
| `timers.target` | Usual target for timer units, not plain services. |

### KillMode values
Used by: `KillMode=`

| Value | Description |
| --- | --- |
| `control-group` | Kill all processes in the service cgroup. This is the default. |
| `mixed` | Send the first signal to the main process, then final kill to the whole cgroup. |
| `process` | Kill only the main process. Child processes may survive. |
| `none` | Do not kill service processes. Use only when another supervisor owns shutdown. |

### Output values
Used by: `StandardOutput=` and `StandardError=`

| Value | Description |
| --- | --- |
| `journal` | Send output to the systemd journal. |
| `journal+console` | Send output to the journal and console. |
| `null` | Discard output. |
| `inherit` | Inherit output handling from the service manager. |
| `tty` | Send output to a TTY configured elsewhere. |
| `file:/path/to/file` | Write output to a file. |
| `append:/path/to/file` | Append output to a file. |
| `truncate:/path/to/file` | Replace the file each time. |

### Status words
Shown by: `systemctl status`, `systemctl is-active`, `systemctl is-enabled`,
`systemctl list-units`, and `systemctl list-unit-files`.

| Word | Description |
| --- | --- |
| `active` | Running or considered started. |
| `inactive` | Not running. |
| `activating` | In the middle of starting. |
| `deactivating` | In the middle of stopping. |
| `failed` | Failed and needs inspection. |
| `enabled` | Will start at boot or login. |
| `disabled` | Will not start automatically. |
| `static` | Cannot be enabled directly; it has no `[Install]` hook and is started by dependency or manual start. |
| `masked` | Blocked from starting. |

---

## Reference Man Pages

### Service unit directives
man systemd.service

### Common unit directives
man systemd.unit

### General unit file syntax
man systemd.syntax

### Execution environment directives
man systemd.exec

### Every known directive by name
man systemd.directives

### Time span syntax
man systemd.time

---

## Notes

- Use `/etc/systemd/system/` for your own system units.
- Use `~/.config/systemd/user/` for your own user units.
- Prefer `Type=exec` for normal long-running services.
- Use `Restart=on-failure` for services that should recover from crashes.
- Use `systemctl edit` for package-provided units so your changes live in overrides.
- Run `daemon-reload` after creating, deleting, or editing unit files.
- Use [troubleshooting notes](troubleshooting.md) when a service fails to start.
