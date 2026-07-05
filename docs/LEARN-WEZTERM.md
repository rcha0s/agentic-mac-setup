# Learn WezTerm

WezTerm is your terminal emulator. In Kun's setup it's intentionally boring: **one frameless window, no tabs, no title bar, no status line**. All multiplexing (splits, sessions, windows) is done by tmux running *inside* WezTerm. Learn tmux, not WezTerm.

## Install

Default path:

```
brew install --cask wezterm
```

If your Mac uses an enterprise Homebrew wrapper (Workbrew or similar) and the
cask is blocked by an allowlist, either request it (`brew workbrew request wezterm`
where supported, then re-run the install) or download the app directly:

1. Go to <https://wezterm.org/install/macos.html>
2. Download the latest `WezTerm-macos-*.zip`
3. Unzip; drag `WezTerm.app` to `/Applications` (or `~/Applications/` if
   `/Applications` is locked)
4. Launch it. WezTerm reads `~/.config/wezterm/wezterm.lua`, which is already
   symlinked by `setup/install-noix.sh`.

## Config location

`~/.config/wezterm/wezterm.lua` → symlink → `~/github/agentic-mac-setup/files/.config/wezterm/wezterm.lua`

Edit the fork's copy; changes reload **live** (WezTerm watches the file and
re-parses on save). If the config has a Lua syntax error the current window
keeps its old settings and a notification shows the error. Use
`wezterm --config-file <path> ls-fonts` from a shell to validate a config
change without waiting for the reload.

## What our config sets

- **`window_decorations = "RESIZE"`**: no title bar, just a resize border
- **`enable_tab_bar = false`**: no tab bar
- **`native_macos_fullscreen_mode = true`**: cleaner native fullscreen behavior
- Rose-pine-moon color scheme, Hack Nerd Font, 15pt on macOS
- 80% window opacity + macOS background blur

## Essential keybinds (defaults on macOS)

Verified against `wezterm show-keys` for WezTerm build `20240203-110809`.
Note: WezTerm uses **Ctrl+Shift** for its command-palette / debug shortcuts,
not `Cmd+Shift` like most macOS apps. And fullscreen is bound to
**Option+Enter**, not `Cmd+Enter`.

| Action | Keybind |
|---|---|
| Copy | `Cmd-C` |
| Paste | `Cmd-V` |
| Search selection / prompt | `Cmd-F` |
| Clear scrollback | `Cmd-K` |
| Decrease font size | `Cmd--` |
| Reset font size | `Cmd-0` |
| Increase font size | `Ctrl-Shift-+` |
| **Show command palette** | `Ctrl-Shift-P` |
| **Show debug overlay** | `Ctrl-Shift-L` |
| **Toggle fullscreen** | `Option-Enter` |

That's all you need to know about WezTerm keybinds. Everything else lives in
tmux.

If you want the more macOS-conventional bindings (`Cmd-Shift-P`, `Cmd-Enter`,
etc.), you can override them explicitly in `wezterm.lua`:

```lua
config.keys = {
  { key = "p", mods = "SUPER|SHIFT", action = wezterm.action.ActivateCommandPalette },
  { key = "l", mods = "SUPER|SHIFT", action = wezterm.action.ShowDebugOverlay },
  { key = "Enter", mods = "SUPER", action = wezterm.action.ToggleFullScreen },
}
```

Kun does not do this; he leans on tmux for everything and rarely touches
WezTerm's own commands.

## Debugging

- WezTerm crashes / renders weird: check `~/.local/share/wezterm/logs/` (verbose).
- Config error: `wezterm --config-file ~/.config/wezterm/wezterm.lua ls-fonts` prints errors.
- Font missing: `brew install --cask font-hack-nerd-font`, required for the icons in the tmux status line and Neovim UI.

## Learn more

- Official docs: <https://wezterm.org/> (short, well-organized)
- Config reference: <https://wezterm.org/config/files.html>
- Every option: <https://wezterm.org/config/lua/config/index.html>
- **[Josean Martinez: How I Use Wezterm & Zsh For An Amazing Terminal Setup On My Mac](https://www.youtube.com/watch?v=TTgQV21X0SQ)**: concrete config walkthrough
- See `docs/RESOURCES.md` for the full index

Kun's rationale for WezTerm-over-Alacritty/kitty: cross-platform, actively maintained, native Lua config, great macOS integration. He doesn't customize it much, tmux does the work.
