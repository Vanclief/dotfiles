#!/bin/zsh
# Memory usage % for the status bar (macOS), matching Activity Monitor's
# "Memory Used" = (App + Wired + Compressed) / total physical memory.
#
# Previously this used `memory_pressure`'s "free percentage", which counts
# cached/purgeable memory as free and badly under-reports usage. Compute it
# from vm_stat + hw.memsize instead so it matches Activity Monitor.
total=$(sysctl -n hw.memsize)
vm_stat | awk -v total="$total" '
  /page size of/            { for (i = 1; i <= NF; i++) if ($i ~ /^[0-9]+$/) page = $i }
  /Anonymous pages/         { gsub(/\./, "", $NF); anon  = $NF }
  /Pages purgeable/         { gsub(/\./, "", $NF); purge = $NF }
  /Pages wired down/        { gsub(/\./, "", $NF); wired = $NF }
  /occupied by compressor/  { gsub(/\./, "", $NF); comp  = $NF }
  END { printf "%.0f%%", (anon - purge + wired + comp) * page * 100 / total }
'
