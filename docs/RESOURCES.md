# Deep-Dive Resources

Two or three verified sources per tool. Every YouTube link below has been oembed-verified as live, with titles pulled from that API.

For Kun's own tools (`gh-axi`, `chrome-devtools-axi`, `tasks-axi`, `lavish-axi`, `gnhf`, `no-mistakes`, `treehouse`, `firstmate`), Kun's own video is the canonical reference.

---

## Kun Chen's video

**[L8 Principal's Agentic Engineering Workflow](https://youtu.be/iQyg-KypKAA)** by Kun Chen. Watch it once end-to-end before anything else.

Also:
- Blog: <https://blog.kunchenguid.com/>
- AXI principles: <https://axi.md>
- Kun's GitHub: <https://github.com/kunchenguid>

---

## WezTerm

- **[How I Use Wezterm & Zsh For An Amazing Terminal Setup On My Mac](https://www.youtube.com/watch?v=TTgQV21X0SQ)** by Josean Martinez.
- Official docs: <https://wezterm.org/>.

See `docs/LEARN-WEZTERM.md` for the cheat-sheet.

---

## tmux

- **[Tmux has forever changed the way I write code](https://www.youtube.com/watch?v=DzNmUNvnB04)** by Dreams of Code. Best "why tmux" pitch.
- **[Complete tmux Tutorial](https://www.youtube.com/watch?v=Yl7NFenTgIo)** by HackerSploit. Longer, methodical.
- **[My dev workflow using tmux and vim](https://www.youtube.com/watch?v=sSOfr2MtRU8)** by devaslife.
- Book: *tmux 2: Productive Mouse-Free Development* by Brian Hogan.
- Cheat sheet: <https://tmuxcheatsheet.com/>.

See `docs/PRIMER-TMUX.md` and `docs/LEARN-TMUX.md`.

---

## Neovim

- **[Vim Diesel's OFFICIAL Vimtutor Let's Play](https://www.youtube.com/watch?v=d8XtNXutVto)** by Luke Smith. Do this alongside `vimtutor`.
- **[0 to LSP: Neovim RC From Scratch](https://www.youtube.com/watch?v=w7i4amO_zaE)** by ThePrimeagen. Build a config from nothing.
- **[Effective Neovim: Instant IDE](https://www.youtube.com/watch?v=stqUbv-5u2s)** by TJ DeVries (Neovim core maintainer). `kickstart.nvim` walkthrough.
- **[How I Setup Neovim On My Mac](https://www.youtube.com/watch?v=vdn_pKJUda8)** by Josean Martinez. Full 1-hr practical setup.
- Plugin repos: [oil.nvim](https://github.com/stevearc/oil.nvim), [neogit](https://github.com/NeogitOrg/neogit), [snacks.nvim](https://github.com/folke/snacks.nvim), [lazy.nvim](https://lazy.folke.io).

See `docs/LEARN-NEOVIM.md`.

---

## zsh

- **[zsh: Syntax Highlighting, vi-mode, Autocomplete](https://www.youtube.com/watch?v=eLEo4OQ-cuQ)** by Luke Smith. Covers the plugin ecosystem this setup uses.
- Official user guide: <https://zsh.sourceforge.io/Guide/>.
- Starship config: <https://starship.rs/config/>.

Note: most YouTube zsh tutorials push Oh My Zsh. This setup deliberately avoids it. Skip anything that starts with "install Oh My Zsh".

See `docs/PRIMER-ZSH.md`.

---

## Claude Code

- **[Mastering Claude Code in 30 minutes](https://www.youtube.com/watch?v=6eBSHbLKuN0)** by Anthropic. Official primer from the Claude Code team.
- Official docs: <https://docs.claude.com/en/docs/claude-code/overview>.
- `CLAUDE.md` / memory best practices: <https://docs.claude.com/en/docs/claude-code/memory>.
- Skills: <https://docs.claude.com/en/docs/claude-code/skills>.
- Hooks: <https://docs.claude.com/en/docs/claude-code/hooks>.

For the practitioner perspective (blog, not video): [Simon Willison](https://simonwillison.net/) is the reference for how experts drive LLM CLIs.

---

## Kun's tools

For all of these, [Kun's video (iQyg-KypKAA)](https://youtu.be/iQyg-KypKAA) is the canonical resource. Each also has its own repo:

| Tool | Repo |
|---|---|
| `gh-axi` | <https://github.com/kunchenguid/gh-axi> |
| `chrome-devtools-axi` | <https://github.com/kunchenguid/chrome-devtools-axi> |
| `tasks-axi` | <https://github.com/kunchenguid/tasks-axi> |
| `lavish-axi` | <https://github.com/kunchenguid/lavish-axi> |
| `gnhf` | <https://github.com/kunchenguid/gnhf> |
| `no-mistakes` | <https://kunchenguid.github.io/no-mistakes/> |
| `treehouse` | <https://github.com/kunchenguid/treehouse> |
| `firstmate` | <https://github.com/kunchenguid/firstmate> |

AXI theory: <https://axi.md> and <https://github.com/kunchenguid/axi>.

See `docs/LEARN-AGENTIC.md` for the day-to-day workflow.

---

## Remote access (mosh + Tailscale)

- **mosh**: installed. SSH replacement that survives network drops; docs at <https://mosh.org/>.
- **Tailscale**: not installed on this Mac. It creates a second encrypted tunnel that a corporate security stack can't inspect (split-tunnel flag), which is worth calling out if your Mac is enterprise-managed. On a personal Mac: `brew install --cask tailscale`.

---

## Adding a new video

Verify it's live before opening a PR:

```
curl -s -o /dev/null -w "%{http_code}\n" \
 "https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=VIDEO_ID&format=json"
```

Should return `200`. Then add it here with the exact title from the oembed response.
