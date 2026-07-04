local wezterm = require("wezterm")

local config = wezterm.config_builder()

local is_windows = os.getenv("OS") and os.getenv("OS"):lower():find("windows")
local is_macos = wezterm.target_triple:lower():find("darwin") ~= nil

config.color_scheme = "rose-pine-moon"
config.max_fps = 120
config.font = wezterm.font("Hack Nerd Font", { weight = "DemiBold" })

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
  font = wezterm.font("Hack Nerd Font", { weight = "Bold" }),
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

if is_windows then
  config.win32_system_backdrop = "Acrylic"
  config.window_background_opacity = 0.7
  config.window_frame.font_size = 10.0
end

if is_macos then
  config.window_background_opacity = 0.8
  config.macos_window_background_blur = 50
  config.font_size = 15.0
  config.window_frame.font_size = 13.0
  config.native_macos_fullscreen_mode = true
end

return config
