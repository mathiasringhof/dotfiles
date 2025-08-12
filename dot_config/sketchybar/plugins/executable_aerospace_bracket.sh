#!/bin/sh

# Source color palette
source "$CONFIG_DIR/colors.sh"

# Script to control the bracket border based on aerospace mode
# The bracket surrounds all workspace items and provides visual indication
# when in "move" mode with blinking border effect

CURRENT_MODE=$(aerospace list-modes --current)

# Tokyo Night colors
DEFAULT_BORDER=$BAR_BORDER_COLOR
HIGHLIGHT_BORDER=$(getcolor orange)

if [ "$CURRENT_MODE" = "move" ]; then
  # Increase border width to 2px and start blinking sequence
  # Sequence: thicker border + blue -> orange -> blue -> orange (final)
  sketchybar --set "$NAME" background.border_width=2
  sketchybar --animate linear 12 --set "$NAME" background.border_color="$HIGHLIGHT_BORDER" \
    --animate linear 12 --set "$NAME" background.border_color="$DEFAULT_BORDER" \
    --animate linear 12 --set "$NAME" background.border_color="$HIGHLIGHT_BORDER"
else
  # Return to normal: 1px blue border
  sketchybar --set "$NAME" background.border_width=1 background.border_color="$DEFAULT_BORDER"
fi
