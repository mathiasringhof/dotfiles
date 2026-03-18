#!/usr/bin/env bash
set -uo pipefail

VERBOSE="${VERBOSE:-0}"
if [ "$VERBOSE" = "1" ]; then
  exec >> /tmp/kitty-close-window.log 2>&1
  log() { echo "$@"; }
else
  log() { :; }
fi

log "==== $(date) ===="
log "KITTY_LISTEN_ON=${KITTY_LISTEN_ON:-<unset>}"

KITTY="kitty @ --to ${KITTY_LISTEN_ON}"

RAW=$($KITTY ls 2>&1) || { log "kitty @ ls FAILED: $RAW"; exit 1; }

WINDOW_JSON=$(echo "$RAW" | jq -r '
  [.[] | select(.is_focused) | .tabs[] | select(.is_focused) | .windows[] | select(.is_focused)]
  | first
')
log "WINDOW_JSON=$WINDOW_JSON"

IS_TMUX=$(echo "$WINDOW_JSON" | jq -r '
  [.foreground_processes[].cmdline[0]]
  | any(endswith("tmux"))
')
log "IS_TMUX=$IS_TMUX"

if [ "$IS_TMUX" = "true" ]; then
  log "ACTION: tmux kill-window"
  tmux kill-window 2>&1 || log "tmux kill-window FAILED (exit $?)"
else
  WINDOW_ID=$(echo "$WINDOW_JSON" | jq -r '.id')
  log "ACTION: close kitty window id=$WINDOW_ID"
  $KITTY close-window --match "id:${WINDOW_ID}" 2>&1 || log "close-window FAILED (exit $?)"
fi

log "==== done ===="
