# Learn WezTerm

WezTerm is your terminal emulator. In Kun's setup it's intentionally boring: **one frameless window, no tabs, no title bar, no status line**. All multiplexing (splits, sessions, windows) is done by tmux running *inside* WezTerm. Learn tmux, not WezTerm.

## Install

Workbrew blocked the `--cask` install. Pick one:

**Option A — request approval (corp-policy-friendly):**
```
brew workbrew request wezterm
```
Wait for your admin to approve, then:
```
brew install --cask wezterm
```

**Option B — download directly (bypasses Workbrew):**
1. Go to <https://wezterm.org/install/macos.html>
2. Download the latest `WezTerm-macos-*.zip`
3. Unzip; drag `WezTerm.app` to `/Applications`
4. Launch it — it reads `~/.config/wezterm/wezterm.lua`, which is already symlinked

## Config location

`~/.config/wezterm/wezterm.lua` → symlink → `~/github/agentic-mac-setup/files/.config/wezterm/wezterm.lua`

Edit the fork's copy; changes reload live (WezTerm watches the file).

## What our config sets

- **`window_decorations = "RESIZE"`** — no title bar, just a resize border
- **`enable_tab_bar = false`** — no tab bar
- **`native_macos_fullscreen_mode = true`** — Cmd-Enter to fullscreen properly
- Rose-pine-moon color scheme, Hack Nerd Font, 15pt on macOS
- 80% window opacity + macOS background blur

## Essential keybinds (all defaults)

| Action | Keybind |
|---|---|
| Copy | Cmd-C |
| Paste | Cmd-V |
| Increase font size | Cmd-`+` |
| Decrease font size | Cmd-`-` |
| Reset font size | Cmd-`0` |
| Show launcher | Cmd-Shift-P |
| Show debug overlay | Cmd-Shift-L |
| Fullscreen | Cmd-Enter |

That's all you need to know about WezTerm keybinds. Everything else lives in tmux.

## Debugging

- WezTerm crashes / renders weird: check `~/.local/share/wezterm/logs/` (verbose).
- Config error: `wezterm --config-file ~/.config/wezterm/wezterm.lua ls-fonts` prints errors.
- Font missing: `brew install --cask font-hack-nerd-font` — required for the icons in the tmux status line and Neovim UI.

## Learn more

- Official docs: <https://wezterm.org/> (short, well-organized)
- Config reference: <https://wezterm.org/config/files.html>
- Every option: <https://wezterm.org/config/lua/config/index.html>
- ThePrimeagen intro: <https://www.youtube.com/watch?v=TTgQV21X0SQ>
- Josean Martinez walk-through: <https://www.youtube.com/watch?v=ibCP0mHp0TA>

Kun's rationale for WezTerm-over-Alacritty/kitty: cross-platform, actively maintained, native Lua config, great macOS integration. He doesn't customize it much — tmux does the work.
