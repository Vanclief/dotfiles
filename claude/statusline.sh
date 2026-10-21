#!/usr/bin/env bash
# Claude Code statusline.
# Shape: "<dir> (<branch>) | <model> <effort> | <remaining>% context | <weekly>% weekly | <account>"
# Any segment whose backing field isn't available is dropped (no dangling " | ").
set -euo pipefail

input="$(cat)"

# Also hand the payload to Orca's hook, which reports usage limits to the Orca
# app. It no-ops outside Orca terminals; backgrounded so its curl never delays this line.
orca_hook="$HOME/.orca/agent-hooks/claude-statusline.sh"
if [ -x "$orca_hook" ]; then
  printf '%s' "$input" | /bin/sh "$orca_hook" >/dev/null 2>&1 &
fi

if command -v jq >/dev/null 2>&1; then
  # --- jq path ---------------------------------------------------------
  dir="$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')"
  base="$(basename -- "$dir" 2>/dev/null || true)"

  # Branch: prefer JSON (only present for --worktree sessions), else ask git.
  branch="$(printf '%s' "$input" | jq -r '.worktree.branch // empty')"
  if [ -z "$branch" ] && [ -n "$dir" ]; then
    branch="$(git -C "$dir" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  fi

  model="$(printf '%s' "$input" | jq -r '.model.display_name // empty')"
  effort="$(printf '%s' "$input" | jq -r '.effort.level // empty')"

  remaining="$(printf '%s' "$input" | jq -r '.context_window.remaining_percentage // empty')"
  weekly="$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')"
else
  # --- python3 fallback (no jq available) -------------------------------
  eval "$(printf '%s' "$input" | python3 -c '
import json, sys, shlex

def esc(v):
    return shlex.quote("" if v is None else str(v))

try:
    data = json.load(sys.stdin)
except Exception:
    data = {}

workspace = data.get("workspace") or {}
model = data.get("model") or {}
effort = data.get("effort") or {}
context_window = data.get("context_window") or {}
rate_limits = data.get("rate_limits") or {}
seven_day = rate_limits.get("seven_day") or {}
worktree = data.get("worktree") or {}

print("dir=%s" % esc(workspace.get("current_dir") or data.get("cwd")))
print("branch=%s" % esc(worktree.get("branch")))
print("model=%s" % esc(model.get("display_name")))
print("effort=%s" % esc(effort.get("level")))
print("remaining=%s" % esc(context_window.get("remaining_percentage")))
print("weekly=%s" % esc(seven_day.get("used_percentage")))
')"
  base="$(basename -- "${dir:-}" 2>/dev/null || true)"
  if [ -z "${branch:-}" ] && [ -n "${dir:-}" ]; then
    branch="$(git -C "$dir" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  fi
fi

# --- account -------------------------------------------------------------
# The payload has no account field. Claude Code keeps the logged-in account in
# .claude.json: at $HOME when CLAUDE_CONFIG_DIR is unset, otherwise inside it.
if [ -n "${CLAUDE_CONFIG_DIR:-}" ]; then
  account_file="${CLAUDE_CONFIG_DIR}/.claude.json"
else
  account_file="${HOME}/.claude.json"
fi
account=""
if [ -r "$account_file" ]; then
  if command -v jq >/dev/null 2>&1; then
    account="$(jq -r '.oauthAccount.emailAddress // empty' "$account_file" 2>/dev/null || true)"
  else
    account="$(python3 -c '
import json, sys
try:
    data = json.load(open(sys.argv[1]))
except Exception:
    data = {}
print((data.get("oauthAccount") or {}).get("emailAddress") or "")
' "$account_file" 2>/dev/null || true)"
  fi
fi

# --- assemble segments ---------------------------------------------------

if [ -n "${branch:-}" ]; then
  seg1="${base} (${branch})"
else
  seg1="${base}"
fi

if [ -n "${effort:-}" ]; then
  seg2="${model} ${effort}"
else
  seg2="${model}"
fi

seg3=""
if [ -n "${remaining:-}" ] && [ "${remaining}" != "null" ]; then
  seg3="$(printf '%.0f' "${remaining}")% context"
fi

seg4=""
if [ -n "${weekly:-}" ] && [ "${weekly}" != "null" ]; then
  seg4="$(printf '%.0f' "${weekly}")% weekly"
fi

seg5="${account:-}"

out=""
for seg in "$seg1" "$seg2" "$seg3" "$seg4" "$seg5"; do
  [ -z "$seg" ] && continue
  if [ -z "$out" ]; then
    out="$seg"
  else
    out="${out} | ${seg}"
  fi
done

printf '%s\n' "$out"
