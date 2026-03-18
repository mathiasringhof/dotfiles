#!/usr/bin/env bash
set -uo pipefail

LOG="/tmp/kitty-close-window.log"
exec >>"$LOG" 2>&1
echo "==== $(date) ===="
echo "KITTY_LISTEN_ON=${KITTY_LISTEN_ON:-<unset>}"

KITTY="kitty @ --to ${KITTY_LISTEN_ON}"

RAW=$($KITTY ls 2>&1) || { echo "kitty @ ls FAILED: $RAW"; exit 1; }

WINDOW_JSON=$(echo "$RAW" | jq -r '
  [.[] | select(.is_focused) | .tabs[] | select(.is_focused) | .windows[] | select(.is_focused)]
  | first
')
echo "WINDOW_JSON=$WINDOW_JSON"

IS_TMUX=$(echo "$WINDOW_JSON" | jq -r '
  [.foreground_processes[].cmdline[0]]
  | any(endswith("tmux"))
')
echo "IS_TMUX=$IS_TMUX"

if [ "$IS_TMUX" = "true" ]; then
  echo "ACTION: tmux kill-window"
  tmux kill-window 2>&1 || echo "tmux kill-window FAILED (exit $?)"
else
  WINDOW_ID=$(echo "$WINDOW_JSON" | jq -r '.id')
  echo "ACTION: close kitty window id=$WINDOW_ID"
  $KITTY close-window --match "id:${WINDOW_ID}" 2>&1 || echo "close-window FAILED (exit $?)"
fi

echo "==== done ===="
