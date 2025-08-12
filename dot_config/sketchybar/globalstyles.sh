#!/bin/bash

# Load defined icons
source "$CONFIG_DIR/icons.sh"

# Load defined colors
source "$CONFIG_DIR/colors.sh"

PADDINGS=6
FONT="JetBrainsMono Nerd Font"

# Bar Appearance
bar=(
  color=$TRANSPARENT
  position=top
  topmost=off
  sticky=on
  height=32
  padding_left=4
  padding_right=4
  corner_radius=0
  blur_radius=32
  notch_width=170
)

# Item Defaults
item_defaults=(
  background.corner_radius=4
  background.height=24
  background.color=$(getcolor black 90)
  background.padding_left=$(($PADDINGS / 2))
  background.padding_right=$(($PADDINGS / 2))
  icon.background.corner_radius=4
  icon.color=$ICON_COLOR
  icon.font="$FONT:Regular:17"
  icon.highlight_color=$HIGHLIGHT
  icon.padding_left=0
  icon.padding_right=0
  label.color=$LABEL_COLOR
  label.font="$FONT:Bold:14"
  label.highlight_color=$HIGHLIGHT
  label.padding_left=$(($PADDINGS / 2))
  scroll_texts=on
  updates=when_shown
)

icon_defaults=(
  label.drawing=off
)

bracket_defaults=(
  background.corner_radius=6
  background.color=$BAR_COLOR
)
