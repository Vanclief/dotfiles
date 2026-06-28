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

-- Use the font's own powerline/half-circle glyphs instead of WezTerm's
-- geometric custom-drawn ones. WezTerm's built-in versions render the pill caps
-- less rounded than Alacritty/tmux, which draw the font glyph (Hack) directly.
config.custom_block_glyphs = false

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

    -- Workspaces (= tmux sessions). s = fuzzy switch/list (tmux prefix s).
    { key = 's', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
    -- w = create-or-switch to a named workspace (SwitchToWorkspace makes it if new).
    { key = 'w', mods = 'LEADER', action = act.PromptInputLine {
      description = 'Workspace (new or existing):',
      action = wezterm.action_callback(function(window, pane, line)
        if line ~= nil and line ~= '' then
          window:perform_action(act.SwitchToWorkspace { name = line }, pane)
        end
      end),
    } },
    -- r = rename the current workspace.
    { key = 'r', mods = 'LEADER', action = act.PromptInputLine {
      description = 'Rename workspace:',
      action = wezterm.action_callback(function(window, _pane, line)
        if line ~= nil and line ~= '' then
          wezterm.mux.rename_workspace(window:active_workspace(), line)
        end
      end),
    } },
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
-- Status bar -- tabline.wez (github.com/michaelbrusegard/tabline.wez)
------------------------------------------------------------------------------
if not TRIAL then
  -- Plain terminal: no WezTerm bar, so tmux's own status line owns the screen.
  config.enable_tab_bar = false
  return config
end

-- Plugins are loaded from local clones via file://, not the documented
-- https:// URL. Reason: this machine's gitconfig rewrites https://github.com
-- -> ssh:// (insteadOf), and WezTerm's bundled libgit2 has no SSH transport,
-- so a network require fails with "unsupported URL protocol". We clone with
-- *system* git (which does have SSH) into PLUGIN_SRC, then require via file://
-- (libgit2's local transport). Update the clones with scripts/wezterm-update-plugins.sh.
local PLUGIN_SRC = (os.getenv 'HOME') .. '/.local/share/wezterm/plugins-src/'

local function require_plugin(name, url)
  local dir = PLUGIN_SRC .. name
  local head = io.open(dir .. '/.git/HEAD')
  if head then
    head:close()
  else
    -- First run: clone with system git so the gitconfig SSH rewrite works.
    wezterm.run_child_process { 'git', 'clone', '--depth', '1', url, dir }
  end
  return wezterm.plugin.require('file://' .. dir)
end

local tabline = require_plugin('tabline.wez', 'https://github.com/michaelbrusegard/tabline.wez')

-- RAM as a percentage, matching Activity Monitor's "Memory Used"
-- (App + Wired + Compressed) / total physical memory. tabline's built-in `ram`
-- reports GB only, and tmux-mem.sh under-reports (it counts cached/purgeable
-- memory as free), so compute it directly from vm_stat + hw.memsize. macOS only.
-- Throttled to ~3s like the other components.
local mem_cache = { val = '--', t = 0 }
local function mem_text()
  local now = os.time()
  if now - mem_cache.t >= 3 then
    mem_cache.t = now
    local ok_v, vm = wezterm.run_child_process { 'vm_stat' }
    local ok_t, total = wezterm.run_child_process { 'sysctl', '-n', 'hw.memsize' }
    if ok_v and ok_t then
      local page = tonumber(vm:match 'page size of (%d+) bytes')
      local anon = tonumber(vm:match 'Anonymous pages:%s+(%d+)')
      local purge = tonumber(vm:match 'Pages purgeable:%s+(%d+)')
      local wired = tonumber(vm:match 'Pages wired down:%s+(%d+)')
      local comp = tonumber(vm:match 'Pages occupied by compressor:%s+(%d+)')
      local total_bytes = tonumber(total)
      if page and anon and purge and wired and comp and total_bytes then
        local used = (anon - purge + wired + comp) * page
        mem_cache.val = string.format('%.0f%%', used / total_bytes * 100)
      end
    end
  end
  return 'mem ' .. mem_cache.val
end

-- CPU % via the existing tmux-cpu.sh ("cpu NN%"). `top` is slow, so throttle ~10s.
local cpu_cache = { val = 'cpu --', t = 0 }
local function cpu_text()
  local now = os.time()
  if now - cpu_cache.t >= 10 then
    cpu_cache.t = now
    local ok, out = wezterm.run_child_process { (os.getenv 'HOME') .. '/dotfiles/scripts/tmux-cpu.sh' }
    if ok then cpu_cache.val = (out:gsub('%s+$', '')) end
  end
  return cpu_cache.val
end

local function clock_text()
  return wezterm.strftime '%H:%M'
end

-- Right-side status pills (like the old tmux bar): cpu / mem / clock, each a
-- rounded colored pill. tabline sections don't do separate pills natively, so
-- build each from raw format items (rounded caps) wrapping the dynamic value,
-- all inside tabline_x. The value may be a function so it refreshes each update.
local LCAP = utf8.char(0xe0b6) -- î‚¶ left half circle
local RCAP = utf8.char(0xe0b4) -- î‚´ right half circle
local function pill(value, color, txt)
  txt = txt or P.pilltxt
  return {
    { Foreground = { Color = color } }, { Background = { Color = P.bg } }, { Text = LCAP },
    { Foreground = { Color = txt } }, { Background = { Color = color } },
    { Attribute = { Intensity = 'Bold' } }, { Text = ' ' },
    value, -- function or string; renders bold in txt-on-color from items above
    { Text = ' ' },
    { Attribute = { Intensity = 'Normal' } },
    { Foreground = { Color = color } }, { Background = { Color = P.bg } }, { Text = RCAP },
  }
end
local function flatten(...)
  local out = {}
  for _, arr in ipairs { ... } do
    for _, el in ipairs(arr) do out[#out + 1] = el end
  end
  return out
end
local SPACE = { { Text = ' ' } }
local right_pills = flatten(
  pill(cpu_text, P.green),
  SPACE,
  pill(mem_text, P.orange),
  SPACE,
  pill(clock_text, P.surface, P.fg),
  SPACE
)

-- Tab label "<index> <folder> <zoomed>" -- same name whether active or
-- inactive so the text doesn't change on select. Inactive tabs get a trailing
-- thin chevron so the "> > >" rhythm continues between tabs; active tabs
-- already end in the filled pennant arrow (so they don't need one).
local function tab_label(bold)
  local fmt = {}
  -- Bold attribute first so the components below inherit it (active tab only,
  -- like tmux bolds the active window).
  if bold then
    fmt[#fmt + 1] = { Attribute = { Intensity = 'Bold' } }
  end
  fmt[#fmt + 1] = 'index'
  -- left = 0: 'index' already adds a right pad of 1, so this avoids a double
  -- space between the number and the folder name.
  fmt[#fmt + 1] = { 'cwd', padding = { left = 0, right = 1 } }
  fmt[#fmt + 1] = { 'zoomed', padding = 0 }
  return fmt
end
local tab_active_fmt = tab_label(true)
local tab_inactive_fmt = tab_label(false)

tabline.setup {
  options = {
    icons_enabled = true,
    -- Derive the tabline palette from our One Dark colors above.
    theme = config.colors,
    -- The derived theme makes section/tab backgrounds nearly identical, so the
    -- powerline wedges (and the active tab) don't stand out. Override the
    -- section colors with distinct One Dark shades so they have contrast:
    --   a = accent (mode), b = surface, c = window bg; active tab = accent.
    theme_overrides = {
      normal_mode = {
        a = { fg = P.pilltxt, bg = P.blue },
        b = { fg = P.fg, bg = P.bg },
        c = { fg = P.grey, bg = P.bg },
      },
      copy_mode = {
        a = { fg = P.pilltxt, bg = P.green },
        b = { fg = P.fg, bg = P.bg },
        c = { fg = P.grey, bg = P.bg },
      },
      search_mode = {
        a = { fg = P.pilltxt, bg = P.orange },
        b = { fg = P.fg, bg = P.bg },
        c = { fg = P.grey, bg = P.bg },
      },
      tab = {
        -- Active = filled blue pennant; inactive = plain dim text (no box).
        active = { fg = P.pilltxt, bg = P.blue },
        inactive = { fg = P.grey, bg = P.bg },
        inactive_hover = { fg = P.fg, bg = P.surface },
      },
    },
    -- Filled "pennant" dividers: a colored segment flows into a solid arrow of
    -- the same color. No rhomboids because tabs only get the AFTER separator
    -- (tab_separators.right, drawn *before* the tab, is empty).
    section_separators = {
      left = wezterm.nerdfonts.pl_left_hard_divider,
      right = wezterm.nerdfonts.pl_right_hard_divider,
    },
    -- No component separators: the right-side pills are hand-built from raw
    -- format items, and tabline otherwise jams a chevron between each one.
    -- (Every other section holds a single component, so nothing needs them.)
    component_separators = { left = '', right = '' },
    -- Pill-shaped tabs: a rounded half-circle cap on each end. tabline puts
    -- .right *before* the tab (left cap) and .left *after* (right cap). The caps
    -- take the tab's color, so the active tab is a rounded blue pill; inactive
    -- caps render in the background color (invisible), leaving plain text.
    tab_separators = {
      left = wezterm.nerdfonts.ple_right_half_circle_thick,
      right = wezterm.nerdfonts.ple_left_half_circle_thick,
    },
  },
  sections = {
    tabline_a = { 'mode' },
    -- Per-window workspace name. The built-in 'workspace' component uses the
    -- GLOBAL active workspace (wezterm.mux.get_active_workspace()), so every
    -- window shows the same value and background windows go stale. A function
    -- component gets the real window, so window:active_workspace() is correct
    -- per window and refreshes on switch.
    tabline_b = {
      -- Note: function components render as raw text with NO auto-padding (the
      -- built-in 'workspace' component got padding for free), so pad manually.
      function(window)
        return ' ' .. wezterm.nerdfonts.cod_terminal_tmux .. ' ' .. window:active_workspace() .. ' '
      end,
    },
    tabline_c = { ' ' },
    -- Same name on both (defined above); inactive carries a trailing chevron.
    tab_active = tab_active_fmt,
    tab_inactive = tab_inactive_fmt,
    tabline_x = right_pills, -- cpu / mem / clock pills, built above
    tabline_y = {},
    tabline_z = {},
  },
}
tabline.apply_to_config(config)

-- Tab bar at the bottom (tmux-style). Note: this reintroduces WezTerm's
-- sub-cell "unusable space" as a thin gap between content and the bar when the
-- window height isn't an exact multiple of the cell height (see wezterm #1010).
config.tab_bar_at_bottom = true

-- Restore the macOS window buttons. tabline's apply_to_config forces
-- window_decorations = 'RESIZE' (no title bar, no buttons). With the tab bar at
-- the bottom, INTEGRATED_BUTTONS would drop the traffic lights at the bottom,
-- so use a normal top title bar instead.
config.window_decorations = 'TITLE|RESIZE'

-- Align terminal content to the bottom so it sits flush against the bottom tab
-- bar (the sub-cell remainder goes to the top instead of showing as a gap).
config.window_content_alignment = { horizontal = 'Left', vertical = 'Bottom' }

return config
