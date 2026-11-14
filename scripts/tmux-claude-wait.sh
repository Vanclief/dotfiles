#!/bin/sh
# Flag the tmux window of a Claude Code session that is waiting for input.
#
# Called from Claude Code hooks in ~/.claude/settings.json:
#   on   Stop, Notification (permission_prompt): flag the window, play a sound
#   off  UserPromptSubmit, SessionEnd: clear the flag
#
# tmux.conf renders @claude_wait as the orange pill in window-status-format.
# Does nothing outside tmux, so headless and non-tmux sessions stay silent.
[ -n "$TMUX_PANE" ] || exit 0

case "$1" in
  on)
    tmux set -w -t "$TMUX_PANE" @claude_wait 1
    afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 &
    ;;
  off)
    tmux set -wu -t "$TMUX_PANE" @claude_wait
    ;;
esac
