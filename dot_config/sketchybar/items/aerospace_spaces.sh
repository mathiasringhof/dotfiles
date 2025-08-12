#!/bin/bash

sketchybar --add event aerospace_workspace_change

for sid in $(aerospace list-workspaces --all); do
  sketchybar \
    --add item space.$sid left \
    --subscribe space.$sid aerospace_workspace_change \
    --set space.$sid \
    background.drawing=off \
    label="$sid" \
    icon.padding_left=8 \
    icon.padding_right=0 \
    label.padding_left=0 \
    label.padding_right=8 \
    click_script="aerospace workspace $sid" \
    script="$PLUGIN_DIR/aerospace.sh $sid"
done

sketchybar --add event aerospace_mode_change
sketchybar \
  --add bracket spaces '/space\..*/' \
  --subscribe spaces aerospace_mode_change \
  --set spaces "${bracket_defaults[@]}" \
  script="$PLUGIN_DIR/aerospace_bracket.sh"
