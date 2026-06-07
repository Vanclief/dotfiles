#!/bin/zsh
# CPU usage % for the tmux status bar (macOS)
idle=$(top -l 1 | awk '/CPU usage/ {print $(NF-1)}' | tr -d '%')
printf "cpu %.0f%%" $((100 - idle))
