#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

CURRENT_MODE=$(aerospace list-modes --current)

if [ "$CURRENT_MODE" = "move" ]; then
  BACKGROUND_DRAWING="on"
else
  BACKGROUND_DRAWING="off"
fi

sketchybar --set "$NAME" \
  background.drawing="$BACKGROUND_DRAWING"
