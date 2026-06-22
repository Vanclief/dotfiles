local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- Trial of native WezTerm multiplexing (leader keybindings + pill status bar).
-- Set to false to fall back to a plain terminal so tmux runs inside WezTerm
-- cleanly (no duplicated status bar, and Ctrl-S stays tmux's prefix).
local TRIAL = true

-- Fix: Finder/dock launches inherit a stripped-down environment from macOS's
-- launchd (a minimal PATH, none of your shell setup), unlike launches from an
-- existing terminal. That mismatch is why clicking the icon behaved differently
-- from `wezterm start`. Prepend Homebrew so tmux (and friends) are always
-- reachable, regardless of how WezTerm was launched.
local homebrew = '/opt/homebrew/bin:/opt/homebrew/sbin'
config.set_environment_variables = {
  PATH = homebrew .. ':' .. (os.getenv 'PATH' or '/usr/bin:/bin:/usr/sbin:/sbin'),
}

-- Run the shell as a login shell so ~/.zprofile (which does `brew shellenv`)
-- and ~/.zshrc are sourced the same way on every launch.
config.default_prog = { '/bin/zsh', '-l' }

-- Font (from alacritty config)
config.font = wezterm.font_with_fallback {
  { family = 'Hack Nerd Font', weight = 'Regular' },
}
config.font_size = 16.0

-- Scrollback (tmux: history-limit 10000)
config.scrollback_lines = 10000

------------------------------------------------------------------------------
-- One Dark palette (onedark "deep") -- shared by colors + status bar
------------------------------------------------------------------------------
local P = {
  bg      = '#1a212e', -- window / tab-bar background (matches nvim)
  fg      = '#abb2bf', -- default foreground
  pilltxt = '#1e2127', -- dark text on light-colored pills (tmux @bg)
  grey    = '#5c6370', -- inactive window text
  surface = '#3e4452', -- clock pill background / pane borders
  purple  = '#c678dd', -- session/workspace pill
  blue    = '#61afef', -- active window pill / active border
  green   = '#98c379', -- cpu pill
  orange  = '#d19a66', -- memory pill
}

config.bold_brightens_ansi_colors = true
config.colors = {
  background = P.bg,
  foreground = P.fg,

  ansi = {
    '#1e2127', -- black
    '#e06c75', -- red
    '#98c379', -- green
    '#d19a66', -- yellow
    '#61afef', -- blue
    '#c678dd', -- magenta
    '#56b6c2', -- cyan
    '#828791', -- white
  },
  brights = {
    '#5c6370', -- bright black
    '#e06c75', -- bright red
    '#98c379', -- bright green
    '#d19a66', -- bright yellow
    '#61afef', -- bright blue
    '#c678dd', -- bright magenta
    '#56b6c2', -- bright cyan
    '#e6efff', -- bright white
  },

  -- Pane borders (tmux: pane-border-style / pane-active-border-style).
  -- WezTerm exposes a single split color, so the active pane is not
  -- highlighted separately -- closest single-color match.
  split = P.surface,

  tab_bar = { background = P.bg },
}

------------------------------------------------------------------------------
-- Keybindings. macOS new window is always on; the leader-based tmux-style
-- bindings only when trialling native multiplexing.
------------------------------------------------------------------------------
config.keys = {
  -- macOS new window (from alacritty config)
  { key = 'n', mods = 'CMD', action = act.SpawnWindow },
}

if TRIAL then
  -- Leader = Ctrl-S (tmux prefix2). WezTerm allows only one leader.
  config.leader = { key = 's', mods = 'CTRL', timeout_milliseconds = 2000 }

  for _, k in ipairs {
    -- Splits, inheriting the current pane's cwd (tmux: \ and -).
    -- cwd inheritance needs OSC 7 -- see note in the chat / shell integration.
    { key = '\\', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = '-',  mods = 'LEADER', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },

    -- New window ("tab") in the current pane's cwd (tmux: prefix c)
    { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },

    -- vim-style pane navigation (tmux: prefix h/j/k/l)
    { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

    -- Next / previous window (C-s n / C-s p)
    { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
    { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },

    -- Close the current tab (C-s x), confirming if a process is running
    { key = 'x', mods = 'LEADER', action = act.CloseCurrentTab { confirm = true } },

    -- Rename the current window (tmux: prefix ,). Empty input clears the
    -- manual name and reverts to the auto directory label.
    { key = ',', mods = 'LEADER', action = act.PromptInputLine {
      description = 'Rename tab:',
      action = wezterm.action_callback(function(window, _pane, line)
        if line ~= nil then window:active_tab():set_title(line) end
      end),
    } },

    -- Move the current window to a specific index (tmux: prefix .).
    -- 1-based to match base-index 1 (e.g. enter 2 -> second position).
    { key = '.', mods = 'LEADER', action = act.PromptInputLine {
      description = 'Move tab to index:',
      action = wezterm.action_callback(function(window, pane, line)
        local idx = tonumber(line or '')
        if idx ~= nil then window:perform_action(act.MoveTab(idx - 1), pane) end
      end),
    } },

    -- Enter copy mode (tmux: prefix [). vi-style v/y are built into
    -- WezTerm's default copy_mode key table (v = select, y = copy + close).
    { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
  } do
    config.keys[#config.keys + 1] = k
  end

  -- Jump straight to a window by number (tmux base-index 1 -> C-s 1 = first tab)
  for i = 1, 9 do
    config.keys[#config.keys + 1] =
      { key = tostring(i), mods = 'LEADER', action = act.ActivateTab(i - 1) }
  end
end

------------------------------------------------------------------------------
-- Status bar -- rounded "pill" style, ported from the tmux status line.
------------------------------------------------------------------------------
if not TRIAL then
  -- Plain terminal: no WezTerm bar, so tmux's own status line owns the screen.
  config.enable_tab_bar = false
  return config
end

-- Retro tab bar at the bottom behaves like a tmux status line: left status,
-- the windows (tabs), then right status, all on one row.
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false

local LCAP = utf8.char(0xe0b6) -- î‚¶  left half circle
local RCAP = utf8.char(0xe0b4) -- î‚´  right half circle

-- Build a pill: leftcap + text + rightcap, colored `color`, text `txt`.
-- Bold text, snug against the rounded caps (no inner space padding) -- the
-- half-circle caps already provide the rounded breathing room on each end.
local function pill(text, color, txt)
  txt = txt or P.pilltxt
  return {
    { Background = { Color = P.bg } }, { Foreground = { Color = color } }, { Text = LCAP },
    { Background = { Color = color } }, { Foreground = { Color = txt } },
    { Attribute = { Intensity = 'Bold' } }, { Text = text },
    { Attribute = { Intensity = 'Normal' } },
    { Background = { Color = P.bg } }, { Foreground = { Color = color } }, { Text = RCAP },
  }
end

local function append(dst, src)
  for _, v in ipairs(src) do dst[#dst + 1] = v end
end

-- A gap of `n` spaces on the bar background, for padding between pills.
local function spacer(n)
  return { { Background = { Color = P.bg } }, { Text = string.rep(' ', n or 2) } }
end

-- Throttled CPU/mem readout -- reuses the existing tmux scripts. The cpu
-- script samples `top` (~0.3s), so refresh only every 10s (tmux status-interval).
local sys = { cpu = 'cpu --', mem = '--', t = 0 }
local function sysinfo()
  local now = os.time()
  if now - sys.t >= 10 then
    sys.t = now
    local home = os.getenv 'HOME'
    local ok_c, cpu = wezterm.run_child_process { home .. '/dotfiles/scripts/tmux-cpu.sh' }
    if ok_c then sys.cpu = (cpu:gsub('%s+$', '')) end
    local ok_m, mem = wezterm.run_child_process { home .. '/dotfiles/scripts/tmux-mem.sh' }
    if ok_m then sys.mem = (mem:gsub('%s+$', '')) end
  end
  return sys.cpu, sys.mem
end

-- Left status: workspace pill (closest WezTerm concept to a tmux session).
wezterm.on('update-status', function(window, _pane)
  local left = {}
  append(left, pill(window:active_workspace(), P.purple))
  append(left, spacer(2))
  window:set_left_status(wezterm.format(left))

  local cpu, mem = sysinfo()
  local right = {}
  append(right, pill(cpu, P.green))
  append(right, spacer(2))
  append(right, pill('mem ' .. mem, P.orange))
  append(right, spacer(2))
  append(right, pill(wezterm.strftime '%H:%M', P.surface, P.fg))
  append(right, spacer(2))
  window:set_right_status(wezterm.format(right))
end)

-- basename: last path segment of a string (also works on a file:// URL).
local function basename(s)
  return (s or ''):gsub('/+$', ''):gsub('.*[/\\]', '')
end

-- Windows (tabs): active = blue pill, inactive = plain grey text.
-- tmux base-index 1 -> show tab_index + 1. Label = current directory name,
-- falling back to the running process, then "zsh".
wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, _hover, _max_width)
  local p = tab.active_pane
  -- A manually set title (C-s ,) wins over the auto directory label.
  local name = tab.tab_title
  if name == nil or name == '' then
    local d = p.current_working_dir
    name = d and basename(d.file_path or tostring(d)) or ''
    if name == '' then name = basename(p.foreground_process_name) end
    if name == '' then name = 'zsh' end
  end
  local zoom = p.is_zoomed and ' î¬€' or ''
  local label = (tab.tab_index + 1) .. ':' .. name .. zoom

  -- Leading gap so tabs don't butt against each other / the workspace pill.
  local out = spacer(1)
  if tab.is_active then
    append(out, pill(label, P.blue))
  else
    append(out, {
      { Background = { Color = P.bg } },
      { Foreground = { Color = P.grey } },
      { Text = label },
    })
  end
  return out
end)

return config
