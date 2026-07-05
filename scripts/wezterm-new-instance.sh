#!/bin/zsh
# Spawn a brand-new, INDEPENDENT WezTerm instance (its own process = its own
# multiplexer, hence its own workspace state). WezTerm has a single global
# active workspace per mux, so a second window in the SAME instance can't sit on
# a different workspace -- switching in one switches all. A separate process is
# the only way to get per-window workspaces. See config/wezterm/wezterm.lua.
#
# Usage: wezterm-new-instance.sh [workspace-name] [cwd]
#   workspace-name  initial workspace for the new instance (default: "default")
#   cwd             directory the first pane opens in    (default: $HOME)

workspace="${1:-default}"
cwd="${2:-$HOME}"

# open -n            : launch a *separate* macOS app instance, detached from this
#                     shell (survives closing the pane that launched it).
# --always-new-process: don't let that instance hand the command off to the
#                     already-running GUI -- force it to keep its own mux.
open -n -a WezTerm --args \
  start --always-new-process --workspace "$workspace" --cwd "$cwd"
