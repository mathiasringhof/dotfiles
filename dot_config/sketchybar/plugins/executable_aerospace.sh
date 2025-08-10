#!/usr/bin/env bash

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME background.drawing=on background.color=0xff7aa2f7 label.color=0xff1a1b26 icon.color=0xff1a1b26
else
  sketchybar --set $NAME background.drawing=off label.color=0xffa9b1d6 icon.color=0xffa9b1d6
fi
