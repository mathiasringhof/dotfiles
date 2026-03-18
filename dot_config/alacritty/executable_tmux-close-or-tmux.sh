#!/usr/bin/env bash
set -uo pipefail

LOG="${HOME}/.config/alacritty/tmux-close-or-tmux.log"
exec >>"$LOG" 2>&1

echo "---- $(date) ----"

# Cmd+W handler for terminal (Alacritty / kitty).
# - If the front window is a tmux client: kill the current tmux window.
# - Otherwise: close the terminal window by sending SIGHUP to its shell.
#
# Requires the shell (fish_title) and tmux (set-titles-string) to include
# the TTY path (e.g. /dev/ttys004) in the window title.

# 1) Detect which terminal is frontmost and read its window title.
TITLE="$(
  osascript <<'APPLESCRIPT'
tell application "System Events"
  set frontApp to name of first application process whose frontmost is true
  if frontApp is "Alacritty" or frontApp is "kitty" then
    tell process frontApp
      try
        return name of front window
      on error
        return ""
      end try
    end tell
  else
    return ""
  end if
end tell
APPLESCRIPT
)"
echo "title: $TITLE"

# 2) Extract TTY path from title (e.g. /dev/ttys004).
TTY="$(printf "%s" "$TITLE" | sed -nE 's/.*(\/dev\/(ttys[0-9]+|pts\/[0-9]+)).*/\1/p' | head -n1)"
echo "tty: ${TTY:-<none>}"

if [[ -z "${TTY:-}" ]]; then
  echo "FAIL: no TTY in title"
  exit 1
fi

# 3) If tmux is running, find the client attached to this TTY and kill its window.
if command -v tmux >/dev/null 2>&1 && tmux info &>/dev/null; then
  CLIENT="$(tmux list-clients -F '#{client_tty} #{client_name}' \
    | awk -v tty="$TTY" '$1==tty {print $2; exit}')"
  echo "tmux-client: ${CLIENT:-<none>}"

  if [[ -n "${CLIENT:-}" ]]; then
    WIN_ID="$(tmux display-message -p -t "$CLIENT" '#{window_id}')"
    echo "tmux-window: ${WIN_ID:-<none>}"
    if [[ -n "${WIN_ID:-}" ]]; then
      tmux kill-window -t "$WIN_ID"
      echo "OK: killed tmux window $WIN_ID"
      exit 0
    fi
  fi
fi

# 4) No tmux on this TTY — close the window by killing its shell.
#    macOS pgrep/pkill misparses "ttys001" as pts/001, so use ps -t instead.
TTY_SHORT="${TTY#/dev/}"
PIDS="$(ps -t "$TTY_SHORT" -o pid= 2>/dev/null | tr '\n' ' ')"
echo "fallback: kill -SIGHUP pids=[$PIDS] on $TTY_SHORT"
if [[ -n "${PIDS:-}" ]]; then
  kill -SIGHUP $PIDS 2>/dev/null || true
  echo "OK: sent SIGHUP"
else
  echo "FAIL: no processes on $TTY_SHORT"
fi
