#!/bin/zsh
# Memory usage % for the tmux status bar (macOS)
free=$(memory_pressure | awk '/free percentage/ {print $NF}' | tr -d '%')
printf "%.0f%%" $((100 - free))
