#!/bin/zsh
# Memory usage % for the status bar (macOS and Linux).
#
# macOS: matches Activity Monitor's
# "Memory Used" = (App + Wired + Compressed) / total physical memory.
# Previously this used `memory_pressure`'s "free percentage", which counts
# cached/purgeable memory as free and badly under-reports usage. Compute it
# from vm_stat + hw.memsize instead so it matches Activity Monitor.
#
# Linux: (MemTotal - MemAvailable) / MemTotal, which likewise treats
# reclaimable page cache as free.
if [[ $OSTYPE == darwin* ]]; then
  total=$(sysctl -n hw.memsize)
  vm_stat | awk -v total="$total" '
    /page size of/            { for (i = 1; i <= NF; i++) if ($i ~ /^[0-9]+$/) page = $i }
    /Anonymous pages/         { gsub(/\./, "", $NF); anon  = $NF }
    /Pages purgeable/         { gsub(/\./, "", $NF); purge = $NF }
    /Pages wired down/        { gsub(/\./, "", $NF); wired = $NF }
    /occupied by compressor/  { gsub(/\./, "", $NF); comp  = $NF }
    END { printf "%.0f%%", (anon - purge + wired + comp) * page * 100 / total }
  '
else
  awk '
    /^MemTotal:/     { total = $2 }
    /^MemAvailable:/ { avail = $2 }
    END { printf "%.0f%%", (total - avail) * 100 / total }
  ' /proc/meminfo
fi
