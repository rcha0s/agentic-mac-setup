# agentic-mac-setup

Kun-Chen-style agentic engineering setup for macOS, extended with seeded configs
and learning docs.

**Origin:** fork of [`kunchenguid/dotfiles-mac-nix`](https://github.com/kunchenguid/dotfiles-mac-nix).
Two ways to run it:

- **`setup/install-noix.sh`**: no-Nix install path. Symlinks configs, brew-installs
 packages, runs the agentic-stack installer. Ideal for work laptops and existing
 Mac environments where a full Nix migration isn't wanted.
- **`setup/mac.sh`**: the upstream Nix path (Determinate Nix + nix-darwin +
 Home Manager + declarative Homebrew). Preserved for personal Macs or new-machine
 reproducibility.

## What you get

**Terminal + shell + editor + multiplexer**

- **WezTerm**: frameless single-window terminal
- **tmux**: persistent sessions (tmux-resurrect + tmux-continuum)
- **Neovim**: with `oil.nvim` (filesystem), `neogit` (git), `snacks.nvim` (pickers/dashboard/notifier)
- **zsh**: with `zsh-autosuggestions` + `zsh-syntax-highlighting` + `starship` prompt

**Agentic stack** (Kun's tools)

- **[gh-axi](https://github.com/kunchenguid/gh-axi)**: agent-ergonomic GitHub CLI
- **[chrome-devtools-axi](https://github.com/kunchenguid/chrome-devtools-axi)**: agent-ergonomic browser automation
- **[tasks-axi](https://github.com/kunchenguid/tasks-axi)**: backlog manager
- **[lavish-axi](https://github.com/kunchenguid/lavish-axi)**: reviewable HTML artifacts
- **[gnhf](https://github.com/kunchenguid/gnhf)**: overnight autonomous agent loop
- **[no-mistakes](https://kunchenguid.github.io/no-mistakes/)**: pre-push validation
- **[treehouse](https://github.com/kunchenguid/treehouse)**: reusable worktree pool
- **[firstmate](https://github.com/kunchenguid/firstmate)**: multi-agent fleet supervisor

The AXI tools install as Claude Code skills, auto-loaded when relevant tasks come up.

## Quick start (no-Nix path)

```
gh repo clone rcha0s/agentic-mac-setup ~/github/agentic-mac-setup
cd ~/github/agentic-mac-setup
bash setup/install-noix.sh
```

Post-install steps in [`HANDOFF.md`](./HANDOFF.md).

## Learning docs

- [`docs/PRIMER-TMUX.md`](./docs/PRIMER-TMUX.md), the conceptual model behind tmux + config walkthrough
- [`docs/PRIMER-ZSH.md`](./docs/PRIMER-ZSH.md), zsh for existing bash users
- [`docs/LEARN-WEZTERM.md`](./docs/LEARN-WEZTERM.md), terminal basics + config
- [`docs/LEARN-TMUX.md`](./docs/LEARN-TMUX.md), tmux cheat-sheet
- [`docs/LEARN-NEOVIM.md`](./docs/LEARN-NEOVIM.md), modes, motions, plugin keybinds
- [`docs/LEARN-AGENTIC.md`](./docs/LEARN-AGENTIC.md), day-to-day workflow across all 7 agentic tools

## Structure

```
agentic-mac-setup/
├── flake.nix, nix/ # upstream Nix path (preserved)
├── setup/
│ ├── mac.sh # Nix bootstrap
│ ├── install-noix.sh # no-Nix bootstrap ← we use this
│ └── agentic.sh # agentic stack installer (shared)
├── files/
│ ├── .config/wezterm/ # frameless WezTerm config
│ ├── .config/nvim/ # lazy.nvim + oil + neogit + snacks
│ ├── .config/starship.toml
│ ├── .tmux.conf # C-a prefix, vi-mode, resurrect + continuum
│ └── zshrc.local.example # personal shell config template (git-tracked)
│ # zshrc.local # your local, git-ignored, from install-noix.sh
├── docs/ # primers + learn docs
├── README.md
└── HANDOFF.md # post-install checklist
```

## Personal vs. shared config

The `files/zshrc.local.example` template is tracked publicly. On first run,
`setup/install-noix.sh` copies it to `files/zshrc.local` (git-ignored), that's where you put JAVA_HOME, work AWS profile names, corp CA cert paths,
and other machine-specific things.

## References

- Upstream: [kunchenguid/dotfiles-mac-nix](https://github.com/kunchenguid/dotfiles-mac-nix)
- Blog: [How I Built a Reproducible Mac Setup with Nix](https://blog.kunchenguid.com/p/how-i-built-a-reproducible-mac-setup)
- Video: [L8 Principal's Agentic Engineering Workflow](https://youtu.be/iQyg-KypKAA)
- AXI principles: <https://axi.md>

## License

MIT (same as upstream).
