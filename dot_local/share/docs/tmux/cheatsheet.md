# Tmux Cheatsheet

`Prefix = Ctrl-a`

Use `Ctrl-a ?` for this popup. Use `Ctrl-a F1` for the full tmux key list.

Source: [`.tmux.conf`](./.tmux.conf)

## Most Useful Keys

| Keys | What it does |
| --- | --- |
| `Ctrl-a ?` | Open this cheatsheet |
| `Ctrl-a F1` | Show all tmux keybindings |
| `Ctrl-a :` | Open the tmux command prompt |
| `Ctrl-a Ctrl-a` | Send a literal `Ctrl-a` to the current program |
| `Ctrl-a r` | Reload tmux config |
| `Ctrl-a d` | Detach from tmux |
| `Ctrl-a s` | Session list/tree |
| `Ctrl-a w` | Window list |
| `Ctrl-a c` | New window |
| `Ctrl-a n` / `p` | Next / previous window |
| `Ctrl-a 1..9` | Jump to a window by number |
| `Ctrl-a ,` | Rename current window |

## Panes

| Keys | What it does |
| --- | --- |
| `Ctrl-a \|` | Split pane left/right |
| `Ctrl-a -` | Split pane top/bottom |
| `Ctrl-a h` / `j` / `k` / `l` | Move left / down / up / right |
| `Ctrl-a <` / `>` | Swap pane left / right |
| `Ctrl-a H` / `J` / `K` / `L` | Resize pane by 5 cells |
| `Ctrl-a z` | Zoom/unzoom the current pane |
| `Ctrl-a o` | Cycle to the next pane |
| `Ctrl-a q` | Show pane numbers |
| `Ctrl-a x` | Kill the current pane |
| `Ctrl-a !` | Break the current pane into its own window |
| `Ctrl-a Space` | Cycle pane layouts |
| `Ctrl-a {` / `}` | Swap pane up / down |

## Copy And Paste

| Keys | What it does |
| --- | --- |
| `Ctrl-a [` | Enter copy mode |
| `h` / `j` / `k` / `l` in copy mode | Move with Vim keys |
| `Enter` in copy mode | Copy selection to the system clipboard with `xclip` |
| Mouse drag | Copy selection to the system clipboard |
| `Ctrl-a ]` | Paste the last tmux buffer |

## Helpful Suggestions

- Learn these first: `|`, `-`, `h/j/k/l`, `z`, `c`, `s`, `d`, `[`.
- If you prefer commands over keybinds, `Ctrl-a :` opens the tmux prompt for things like `split-window`, `display-popup`, and `new-window`.
- New splits open in the current pane's working directory, so split from the pane that is already in the project you want.
- `tmux-layout dev ~/src/project` creates or reattaches a named session with a top pane and a 5-line bottom pane.
- `Ctrl-a y` toggles synchronized panes. Use it when you need to run the same command in several panes, then turn it back off.
- `Ctrl-a z` is the fastest way to focus on one busy pane without rearranging your layout.
- If you get lost, use `Ctrl-a s` for sessions, `Ctrl-a w` for windows, and `Ctrl-a q` for pane numbers.
- Mouse support is on, so you can click panes, scroll history, and drag pane borders when that is faster than keybinds.

## Small Config Notes

- Windows and panes start at `1`, not `0`.
- Windows renumber automatically after one is closed.
- The status bar turns yellow when the prefix key is active.
