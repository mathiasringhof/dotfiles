#!/bin/bash

front_app=(
  icon.drawing=on
  script="$PLUGIN_DIR/front_app.sh"
  icon.padding_left=8
  icon.padding_right=0
  label.padding_left=8
  label.padding_right=8
  icon.font="sketchybar-app-font:Regular:17.0"
)

sketchybar \
  --add item front_app left \
  --set front_app "${front_app[@]}" \
  --subscribe front_app front_app_switched
