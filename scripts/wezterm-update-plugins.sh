#!/bin/zsh
# Update locally-cloned WezTerm plugins.
#
# WezTerm's bundled libgit2 has no SSH transport, and this machine's gitconfig
# rewrites https://github.com -> ssh:// (insteadOf), so plugins are kept as
# local clones under plugins-src and loaded via file:// (see
# config/wezterm/wezterm.lua). This script git-pulls each clone with the system
# git (which supports SSH) and clears WezTerm's managed copies so they re-clone
# fresh from the updated sources on next launch.

set -e

src="$HOME/.local/share/wezterm/plugins-src"

if [ ! -d "$src" ]; then
  echo "No plugin sources at $src — nothing to update."
  exit 0
fi

for dir in "$src"/*/; do
  [ -d "$dir/.git" ] || continue
  echo "Updating ${dir:t:h}..."
  git -C "$dir" pull --ff-only
done

# Drop WezTerm's managed clones (macOS and Linux data dirs) so the next launch
# re-clones from the freshly-pulled sources via file://.
for managed in \
  "$HOME/Library/Application Support/wezterm/plugins" \
  "$HOME/.local/share/wezterm/plugins"; do
  if [ -d "$managed" ]; then
    rm -rf "$managed"/*(N) 2>/dev/null || true
  fi
done

echo "Done. Restart WezTerm (or reload the config) to pick up the updates."
