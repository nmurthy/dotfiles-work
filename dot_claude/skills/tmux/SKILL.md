---
name: tmux
description: >
  Use when the user writes "tmux SESSION:WINDOW.PANE" (e.g. "tmux spx:0",
  "tmux debrid:1") as a shorthand target, or references a tmux session/window
  by name, or asks to check, read, list, capture, send commands to, or monitor
  a tmux session or window. Triggers: "tmux spx:0", session:window pattern,
  capture-pane, what's happening in, check on, run in, send to, list sessions.
---

# tmux Interaction

Work with tmux sessions and windows using `SESSION:WINDOW.PANE` shorthand.

## Canonical Trigger

The user invokes this skill by prefixing a target with `tmux`:

```
tmux spx:0
tmux debrid:1
tmux k8s_migration
```

This is an unambiguous signal that they are referring to a tmux session/window. Treat the rest of the phrase as the target to act on.

## Shorthand Format

```
SESSION:WINDOW.PANE
```

- **SESSION** — required. Tmux session name (e.g. `spx`, `debrid`, `k8s_migration`).
- **WINDOW** — optional. Window index or name.
  - **Only default to `0`** when the session has exactly one window.
  - If omitted and the session has multiple windows, run `list-windows` and ask the user which window.
- **PANE** — optional. Pane index, defaults to `0`. Use when a window has splits (e.g. `spx:0.1`).

The shorthand maps directly to tmux's `-t SESSION:WINDOW.PANE` target syntax.

**Examples:**

| Shorthand | Meaning |
|-----------|---------|
| `spx` | session `spx`, window 0 (only valid if session has one window) |
| `spx:0` | session `spx`, window 0, pane 0 |
| `debrid:1` | session `debrid`, window 1, pane 0 |
| `spx:0.1` | session `spx`, window 0, pane 1 |

## Core Commands

### Discovery

```bash
# All sessions
tmux list-sessions

# Windows in a session
tmux list-windows -t SESSION

# All panes across all sessions (session, window, pane, running command, cwd)
tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} #{pane_current_path}'
```

### Capture / Read

```bash
# Last 100 lines (default starting point)
tmux capture-pane -t SESSION:WINDOW.PANE -p -S -100

# Last 500 lines (if more context needed)
tmux capture-pane -t SESSION:WINDOW.PANE -p -S -500

# Entire scrollback
tmux capture-pane -t SESSION:WINDOW.PANE -p -S -
```

Start with `-S -100`. Only expand if the output appears truncated or the user needs more history.

### Create Session / Launch an Interactive Program

```bash
# New detached session with a working directory (check `list-sessions` first for name clashes)
tmux new-session -d -s SESSION -c /path/to/workdir

# Launch an interactive program in it
tmux send-keys -t SESSION:0 "claude --model MODEL" Enter
```

- For a long initial prompt/argument, write it to a file and expand it at the shell: `send-keys -t SESSION:0 'claude "$(cat prompt.md)"' Enter` — quoting a multi-line prompt directly through send-keys mangles it.
- After launching, verify with a short capture (`capture-pane -p -S -30`) that the program actually started and received the input; don't assume send-keys succeeded.

### Send Commands / Keys

```bash
# Run a shell command
tmux send-keys -t SESSION:WINDOW.PANE "command here" Enter

# Interrupt (Ctrl-C)
tmux send-keys -t SESSION:WINDOW.PANE C-c

# EOF (Ctrl-D)
tmux send-keys -t SESSION:WINDOW.PANE C-d

# Suspend (Ctrl-Z)
tmux send-keys -t SESSION:WINDOW.PANE C-z
```

Control characters (`C-c`, `C-d`, `C-z`) are passed bare — no quotes, no `Enter`.

### Check Pane Status

```bash
# What process is running in a pane?
tmux list-panes -t SESSION:WINDOW -F '#{pane_index} #{pane_current_command} #{pane_pid}'

# Quick idle check (look for shell prompt in last few lines)
tmux capture-pane -t SESSION:WINDOW.PANE -p -S -5
```

## Safety Principles

1. **Resolve shorthand first.** Parse the target before doing anything. If window is omitted and the session has multiple windows, run `list-windows` and ask.

2. **Capture before acting.** When asked to "check on" or interact with a window, capture its current output first to understand state.

3. **Protect interactive panes.** Before sending keys, check `pane_current_command`. If the pane is running any of these, warn the user and ask before proceeding:
   - `claude` — another Claude Code instance (injecting text could corrupt its session)
   - `nvim`, `vim`, `vi`, `nano`, `emacs` — text editors
   - `less`, `man`, `more` — pagers
   - `htop`, `top`, `btop` — process monitors
   - `python`, `node`, `irb`, `ghci` — interactive REPLs
   - Any other TUI app that would misinterpret typed text

4. **Small captures first.** `-S -100` covers most cases. Expand only when needed.

5. **Summarize, don't dump.** After capturing, report: what process is running, last meaningful output, any errors. Don't paste raw terminal escape sequences or long output unless the user asks for it.

## Common Patterns

| User says | Action |
|-----------|--------|
| "what's happening in spx:0" | `capture-pane -t spx:0 -p -S -100`, summarize |
| "list my sessions" | `list-sessions` |
| "check all windows in debrid" | `list-windows -t debrid` |
| "run npm test in debrid:1" | Check `pane_current_command` first, then `send-keys` |
| "send Ctrl-C to spx:0" | Check if pane is interactive, then `send-keys -t spx:0 C-c` |
| "is debrid:0 idle?" | `list-panes -t debrid:0 -F '#{pane_current_command}'` + capture last few lines |
| "what's running everywhere?" | `list-panes -a -F '...'`, summarize by session |
| "restart the server in spx:0" | Capture state, check process, C-c if safe, then send command |
