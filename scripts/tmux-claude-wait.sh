#!/bin/sh
# Flag the tmux window of a Claude Code session that is waiting for input.
#
# Called from Claude Code hooks in ~/.claude/settings.json:
#   on   Stop, Notification (permission_prompt): flag the window "unread" and
#        play a sound, or flag it "seen" when it is the one being looked at
#   off  UserPromptSubmit, SessionEnd: clear the flag
#
# tmux.conf renders @claude_wait in window-status-format (unread: orange pill,
# seen: white text) and turns unread into seen when the window is looked at.
# Does nothing outside tmux, so headless and non-tmux sessions stay silent.
[ -n "$TMUX_PANE" ] || exit 0

# True when a focused tmux client is showing this pane's window: the user is
# already looking at it, so a sound would only be noise.
watching() {
  window=$(tmux display -p -t "$TMUX_PANE" '#{window_id}')
  tmux list-clients -F '#{client_flags} #{window_id}' | grep -q "focused[^ ]* $window\$"
}

case "$1" in
  on)
    if watching; then
      tmux set -w -t "$TMUX_PANE" @claude_wait seen
    else
      tmux set -w -t "$TMUX_PANE" @claude_wait unread
      afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 &
    fi
    ;;
  off)
    tmux set -wu -t "$TMUX_PANE" @claude_wait
    ;;
esac
