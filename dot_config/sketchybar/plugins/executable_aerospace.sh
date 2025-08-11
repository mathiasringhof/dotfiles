#!/usr/bin/env bash

# Source color palette
source "$CONFIG_DIR/colors.sh"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME background.drawing=off label.font="JetBrainsMono Nerd Font:ExtraBold:14.0" icon.font="JetBrainsMono Nerd Font:ExtraBold:17.0" label.color=$SPACE_SELECTED icon.color=$SPACE_SELECTED
else
  sketchybar --set $NAME background.drawing=off label.font="JetBrainsMono Nerd Font:Bold:14.0" icon.font="JetBrainsMono Nerd Font:Bold:17.0" label.color=$SPACE_UNSELECTED icon.color=$SPACE_UNSELECTED
fi
