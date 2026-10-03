#!/bin/zsh
# CPU usage % for the tmux status bar (macOS and Linux)
if [[ $OSTYPE == darwin* ]]; then
  idle=$(top -l 1 | awk '/CPU usage/ {print $(NF-1)}' | tr -d '%')
else
  # Sample the aggregate /proc/stat counters twice; idle = idle + iowait.
  # Fields 2-9 are user..steal (guest time is already counted in user).
  idle=$({ head -1 /proc/stat; sleep 0.5; head -1 /proc/stat } | awk '
    { t = 0; for (i = 2; i <= 9; i++) t += $i; tot[NR] = t; idl[NR] = $5 + $6 }
    END { printf "%.1f", (idl[2] - idl[1]) * 100 / (tot[2] - tot[1]) }
  ')
fi
# An empty value would read as 0 idle and show a false 100%.
if [[ -z $idle ]]; then
  print -n "cpu ?"
  exit
fi
printf "cpu %.0f%%" $((100 - idle))
