#!/bin/sh

# Script to control the bracket border based on aerospace mode
# The bracket surrounds all workspace items and provides visual indication
# when in "move" mode with blinking border effect

CURRENT_MODE=$(aerospace list-modes --current)

# Tokyo Night colors
BLUE_BORDER=0xff3d59a1
ORANGE_BORDER=0xffff9e64

if [ "$CURRENT_MODE" = "move" ]; then
  # Increase border width to 2px and start blinking sequence
  # Sequence: thicker border + blue -> orange -> blue -> orange (final)
  sketchybar --set "$NAME" background.border_width=2
  sketchybar --animate linear 12 --set "$NAME" background.border_color="$ORANGE_BORDER" \
             --animate linear 12 --set "$NAME" background.border_color="$BLUE_BORDER" \
             --animate linear 12 --set "$NAME" background.border_color="$ORANGE_BORDER"
else
  # Return to normal: 1px blue border
  sketchybar --set "$NAME" background.border_width=1 background.border_color="$BLUE_BORDER"
fi

