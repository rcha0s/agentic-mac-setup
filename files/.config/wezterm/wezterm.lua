local wezterm = require("wezterm")

local config = wezterm.config_builder()

local is_windows = os.getenv("OS") and os.getenv("OS"):lower():find("windows")
local is_macos = wezterm.target_triple:lower():find("darwin") ~= nil

config.color_scheme = "rose-pine-moon"
config.max_fps = 120

-- Font: prefer Hack Nerd Font (used for Kun's setup — installs powerline/nerd
-- glyphs for tmux status + starship). Falls back to Menlo (built-in on macOS)
-- if the Nerd variant isn't installed. Ordered list is evaluated left-to-right.
config.font = wezterm.font_with_fallback({
  { family = "Hack Nerd Font", weight = "DemiBold" },
  { family = "Menlo" },
})
-- Suppress the "font variant not installed" nag when only the regular Menlo
-- weight resolves. The frameless setup has no visible bold anyway.
config.warn_about_missing_glyphs = false

-- Frameless single-window mode (Kun-style):
-- No title bar, no tab bar, no status line. tmux is the load-bearing session
-- manager on top of this, so WezTerm intentionally has zero chrome.
config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.window_padding = {
  left = 4,
  right = 4,
  top = 2,
  bottom = 0,
}
config.window_frame = {
  font = wezterm.font_with_fallback({
    { family = "Hack Nerd Font", weight = "Bold" },
    { family = "Menlo", weight = "Bold" },
  }),
}
config.inactive_pane_hsb = {
  saturation = 0.0,
  brightness = 0.5,
}

-- Blank the right status area explicitly (belt + suspenders on top of
-- enable_tab_bar = false), because a plugin or future change could re-enable
-- the bar and we don't want a status line to appear.
wezterm.on("update-right-status", function(window)
  window:set_right_status("")
end)

-- Dim unfocused windows so the focused one is obvious at a glance. Adapted
-- from Kun Chen's kunchenguid/dotfiles (commit 7857db1). Only matters when
-- >1 WezTerm window is open; single-window + tmux users see no effect.
--
-- The identity-comparison of get_config_overrides() is load-bearing: that
-- API hands back a COPY, so `==` on the returned table is never equal to
-- what we last stored — comparing fields prevents an infinite reload loop.
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 0.62

local function same_text_hsb(actual, expected)
  if actual == nil or expected == nil then
    return actual == expected
  end
  return actual.hue == expected.hue
    and actual.saturation == expected.saturation
    and actual.brightness == expected.brightness
end

wezterm.on("window-focus-changed", function(window)
  local overrides = window:get_config_overrides() or {}
  local text_hsb, opacity
  if not window:is_focused() then
    text_hsb = UNFOCUSED_FOREGROUND_TEXT_HSB
    opacity = UNFOCUSED_WINDOW_BACKGROUND_OPACITY
  end

  -- Skip the write if nothing we own has actually changed; a redundant
  -- set_config_overrides() call triggers another config reload.
  if same_text_hsb(overrides.foreground_text_hsb, text_hsb)
    and overrides.window_background_opacity == opacity then
    return
  end

  overrides.foreground_text_hsb = text_hsb
  overrides.window_background_opacity = opacity
  window:set_config_overrides(overrides)
end)

if is_windows then
  config.win32_system_backdrop = "Acrylic"
  config.window_background_opacity = 0.7
  config.window_frame.font_size = 10.0
end

if is_macos then
  -- Solid window (was 0.8 with a 50pt background blur, which made tmux's
  -- dark status bar look washed out because 20% of the wallpaper bled
  -- through). Solid means tmux colors render as intended.
  config.window_background_opacity = 1.0
  config.font_size = 15.0
  config.window_frame.font_size = 13.0
  config.native_macos_fullscreen_mode = true
end

-- Keybind: CMD+Shift+H opens a new WezTerm window that skips the tmux
-- auto-attach in zshrc.local (SKIP_TMUX=1) and launches herdr instead.
-- This is the "parallel coexistence" pattern: default windows go to tmux,
-- one keybind gives you herdr on demand without breaking the fleet-status
-- workflow. Removing this keybind fully reverts the setup.
config.keys = config.keys or {}
table.insert(config.keys, {
  key = "H",
  mods = "CMD|SHIFT",
  action = wezterm.action.SpawnCommandInNewWindow({
    args = { "/bin/zsh", "-l", "-c", "SKIP_TMUX=1 exec herdr" },
  }),
})

return config
