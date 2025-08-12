#!/usr/bin/env bash

# Source color palette
source "$CONFIG_DIR/globalstyles.sh"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME label.font="$FONT:ExtraBold:14.0" icon.font="$FONT:ExtraBold:17.0" label.color=$HIGHLIGHT icon.color=$HIGHLIGHT
else
  sketchybar --set $NAME label.font="$FONT:Bold:14.0" icon.font="$FONT:Bold:17.0" label.color=$LABEL_COLOR icon.color=$ICON_COLOR
fi
