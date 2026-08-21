# agentic-mac-setup

**A macOS environment where LLM agents write most of your code and you
drive quality, direction, and doctrine.** Adapted from Kun Chen's
["L8 Principal's Agentic Engineering Workflow"][video] and his
public [`axi`][axi-repo] / [`gnhf`][gnhf] / [`no-mistakes`][nomistakes]
/ [`treehouse`][treehouse] / [`firstmate`][firstmate] tools, tuned for
**enterprise-managed developer Macs** where the vanilla Nix bootstrap
triggers MDM alerts.

> **On Windows?** See the sibling repo
> [`rcha0s/agentic-windows-setup`][win-setup] — the same stack ported
> to Windows / WSL2 with a single PowerShell command, no Nix, and a
> WSL→host CDP browser bridge.

### Why bother

The numbers cited in Kun's [published AXI benchmarks][axi-site] are
the reason:

- **12× cost reduction** on CI-failure triage (AXI $0.065 vs. MCP $0.758)
- **40% token savings** from AXI's TOON output format vs. equivalent JSON
- **100% task success rate** on 490 browser-automation runs with
  `chrome-devtools-axi` at $0.074/task and 21.5s average duration
- **100% task success rate** on 425 GitHub-workflow runs with `gh-axi`
  at $0.050/task — cheaper *and* more reliable than either the vanilla
  `gh` CLI (86% success) or the official GitHub MCP server (87%
  success, $0.148/task)

Kun Chen's insight: **CLIs designed for agents outperform MCPs and
human-facing CLIs alike**, so long as they emit structured output the
model can parse cheaply. This repo installs those CLIs, wires them
into a session-persistent tmux + Neovim + WezTerm environment, and
adds a **filesystem-bridge status system** that surfaces every running
Claude agent's state at a glance so you never lose track of what your
fleet is doing.

### What ships here

- Kun's full agentic stack (7 CLIs) with install scripts that skip the
  Nix-based bootstrap corporate MDM will flag
- WezTerm + tmux + Neovim + zsh configs, cross-referenced against
  installed versions, with a persistence layer (`tmux-resurrect` +
  `continuum`) so agent sessions survive reboots
- Generic Claude Code turn-lifecycle hooks that render per-pane and
  session-wide agent state directly in the tmux status bar (see the
  [state-file bridge][bridge-section] section)
- ~5000 words of learning docs (`docs/LEARN-*.md`, `docs/PRIMER-*.md`)
  because getting fluent on this stack is the actual bottleneck
- Explicit **security-review templates** for enterprise IT approval of
  third-party tools (currently populated for OpenSuperWhisper)
- The doctrine layer (`AGENTS.md`, `OPINIONS.md`, `settings.json`) is
  personal to each user and lives in a **private companion repo** — the
  maintainer's is [`rcha0s/claude-config`][claude-config] as a
  reference shape

**Nothing here is proprietary.** Everything Kun published is credited
inline (see the [References](#references) section); this repo's own
value is the *enterprise-Mac adaptation*, the *learning docs*, and the
*Claude-agent-to-tmux visibility bridge* — all of which we call out
explicitly as our additions in the ["Layered on top"](#layered-on-top-our-additions) section.

### When *not* to use this repo

Be honest with yourself before cloning. Use **Kun's mainline
[`kunchenguid/dotfiles-mac-nix`][dotfiles]** directly if you:

- Run macOS on a personally-owned or startup-managed machine where
  Determinate Nix's system-level activation won't trigger MDM/EDR
- Are comfortable putting `AGENTS.md` / `OPINIONS.md` in a public
  repo (no internal tool names, MR numbers, or vendor decisions to
  hide)
- Are already fluent in tmux, Neovim, and zsh — don't need the
  ~5000 words of learning docs shipped here
- Want the freshest version of Kun's doctrine (this fork tracks
  upstream but lags on Kun's day-to-day improvements)

Use **[`rcha0s/agentic-windows-setup`][win-setup]** if you're on
Windows or WSL2 — same stack, different bootstrap.

**Stay here** if these apply: enterprise-managed Mac, private
doctrine required, want herdr as the primary multiplexer with
tmux as the opt-in fallback, and need the auto-permissions and
writing-style hook layer. That's the specific niche this fork
serves.

[bridge-section]: #claude-tmux-bridge

## Design principles (adapted from Kun Chen)

1. **Agent-agnostic tooling.** Avoid vendor-locked features like
   auto-managed memory or IDE-specific integrations so switching from
   one LLM harness to another costs nothing when a better model ships.
   This is why the setup uses standard `CLAUDE.md` / `AGENTS.md` files
   (readable by any harness) rather than opaque conversation history.

2. **Prefer agent-ergonomic CLIs over MCP or vanilla CLIs.** Kun's AXI
   ("Agent eXperience Interface") design principles produce CLIs that
   consume significantly fewer tokens per operation while achieving
   higher success rates. Numbers below are from Kun's published
   benchmarks ([axi.md][axi-site], [kunchenguid/axi][axi-repo]):

   | Domain | Tool | Success | Cost/task | Duration | Turns |
   |---|---|---|---|---|---|
   | Browser (490 runs, Claude Sonnet 4.6) | `chrome-devtools-axi` | **100%** | **$0.074** | **21.5s** | 4.5 |
   | Browser | `chrome-devtools-mcp` | 99% | $0.101 | 26.0s | 6.2 |
   | GitHub (425 runs, Claude Sonnet 4.6) | `gh-axi` | **100%** | **$0.050** | **15.7s** | 3 |
   | GitHub | `gh` (vanilla CLI) | 86% | $0.054 | 17.4s | 3 |
   | GitHub | GitHub MCP | 87% | $0.148 | 34.2s | 6 |

   TOON output format used by AXI delivers ~40% token savings vs.
   equivalent JSON ([axi.md][axi-site]). Kun's investigation-workflow
   comparison shows a **12× cost reduction** on CI-failure triage
   (AXI $0.065 vs. MCP $0.758).

3. **Plan → implement → validate.** Non-trivial changes flow through
   a pipeline: plan interactively (with [lavish-axi][lavish] rendering
   HTML artifacts for visual review when appropriate), implement
   autonomously, validate end-to-end (drive the real app; don't stop
   at unit tests), peer-review in a fresh agent context ([no-mistakes]
   [nomistakes] does this), escalate only ambiguity to the human.

4. **The captain's mindset.** The human sets direction and judges
   quality. Corrections update *doctrine* (the memory file, project
   `AGENTS.md`, skills) rather than being applied manually to code.
   When the agent errs, the fix is a rule change, not a keyboard
   intervention.

5. **Prune skills aggressively.** Every loaded skill consumes context
   window tokens on every session start. Language/framework skills for
   stacks you don't ship are pure bloat.

6. **Voice for prompting.** Typing long prompts is a bottleneck; voice
   input closes that gap. Ruan et al. (Stanford / Baidu, ACM CHI 2016)
   found speech input to be **~2.93× faster than keyboard typing** on
   English text (153 WPM vs. 52 WPM) with comparable final error rates
   ([Ruan 2016, arXiv:1608.07323][ruan]). Locally-running Whisper
   models make this available offline with no data egress.

## Layers of the setup

### Environment (all installed here)

| Component | Role | Config source |
|---|---|---|
| **herdr** | Primary terminal multiplexer. Replaces WezTerm as the daily driver — opens directly via macOS Terminal.app. `C-a` prefix (matches tmux), gruvbox theme, onboarding disabled. | `files/.config/herdr/config.toml` |
| **WezTerm** | Still installed; used when a second emulator is useful or when testing WezTerm-specific features. `CMD+Shift+H` keybind opens a herdr window. Ships dim-unfocused-windows hook. | `files/.config/wezterm/wezterm.lua` |
| **tmux** | Session multiplexer, opt-in (not auto-attached on shell start). Set `AUTO_ATTACH_TMUX=1` to restore always-attach behavior. `C-a` prefix, vi mode-keys. | `files/.tmux.conf` |
| **Neovim** | Editor. [oil.nvim][oil] for filesystem-as-buffer, [neogit][neogit] for Magit-style git UI, [snacks.nvim][snacks] for pickers/dashboard/notifier, [lazy.nvim][lazy] for plugin management | `files/.config/nvim/` |
| **zsh + starship + plugins** | Interactive shell with auto-suggestions and syntax highlighting. No Oh My Zsh (deliberate; see [PRIMER-ZSH][zsh-primer]) | `files/zshrc.local.example` |

### Agentic stack (Kun's tooling)

| Tool | Role | Repo |
|---|---|---|
| `gh-axi` | Agent-ergonomic GitHub CLI (see benchmarks above) | [kunchenguid/gh-axi][gh-axi] |
| `chrome-devtools-axi` | Agent-ergonomic browser automation | [kunchenguid/chrome-devtools-axi][cd-axi] |
| `tasks-axi` | Backlog / task manager over a hand-editable `backlog.md` | [kunchenguid/tasks-axi][tasks-axi] |
| `lavish-axi` | Renders agent output as reviewable HTML artifacts for visual planning | [kunchenguid/lavish-axi][lavish] |
| `gnhf` | Overnight autonomous loop for bounded objectives that don't fit one context window | [kunchenguid/gnhf][gnhf] |
| `no-mistakes` | Pre-push validation pipeline: fresh-context reviewer, forced E2E evidence, structured PR, CI-babysit-to-green | [kunchenguid/no-mistakes][nomistakes] |
| `treehouse` | Reusable git-worktree pool for parallel agents | [kunchenguid/treehouse][treehouse] |
| `firstmate` | Fleet supervisor: one liaison agent dispatches crewmates in worktrees, escalates only real decisions | [kunchenguid/firstmate][firstmate] |

### Layered on top (our additions) <a id="layered-on-top-our-additions"></a>

Items we added or extended beyond what Kun ships publicly:

- **Turn-lifecycle hooks + tmux status integration** (`files/claude-hooks/`
  and `files/tmux-scripts/`). Claude Code hooks wired to
  `UserPromptSubmit`, `Stop`, and `Notification` events rename the
  tmux window with a status glyph and write per-pane state files. The
  tmux side reads those state files to render a color-coded pane
  border and a session-wide "fleet" indicator showing every agent's
  state at a glance. Both sides are generic (no personal data) and
  ship in this repo. See [`docs/LEARN-TMUX.md`][learn-tmux] "Agent
  status indicators" and the "Why the bridge exists" section below.
- **macOS notification on long-running turns.** `Stop` hook plays
  `Tink` and posts a banner if the turn exceeded a threshold (default
  10 seconds; configurable via `CLAUDE_NOTIFY_THRESHOLD_SECONDS`).
- **Grid recipes and layout presets for multi-agent tmux work**
  ([`docs/LEARN-TMUX.md`][learn-tmux] "Recipes for common shapes").
- **Per-directory git identity via `includeIf`.** Anything under
  `~/github/*` uses a personal `rcha0s` + noreply identity; other
  paths default to the work identity. Set in `~/.gitconfig`; not
  tracked in the repo.
- **Neovim rose-pine colorscheme with visible cursor settings**, since
  Kun's public dotfiles ship no Neovim config at all.
- **Extensive learning documentation** covering tmux (basics + primer),
  Neovim (motions + our plugin keybinds), WezTerm (verified keybinds
  against the current release), zsh (bash-to-zsh translation guide),
  and the agentic tools (daily-driver workflow). See `docs/`.
- **Formal security-review report template** for enterprise IT
  approval of third-party apps (currently populated for
  OpenSuperWhisper). See `docs/security-review/`.
- **OPINIONS.md doctrine.** Adapted from Kun's blog post ["Everyone
  Should Have an OPINIONS.md"][opinions-post]. A durable record of
  the human's stated positions ("prefer AXI over MCP", "immutability
  in shared code, mutation in local scope") that complements the
  memory system. Every opinion has a **When to revisit** line so it
  doesn't calcify. The `Stop` hook that nudges you every 20 sessions
  (`session-reflect.sh`) ships in this repo; the `OPINIONS.md`
  content is personal and lives in your own private companion repo
  (the maintainer's is [`rcha0s/claude-config`][claude-config]).
  Manual review only, never auto-rewrite.
- **Auto-permissions hooks.** Two `UserPromptSubmit` / `PreToolUse`
  hooks (`auto-permissions-from-prompt.sh`, `auto-permissions-from-plan.sh`)
  ship in `files/claude-hooks/`. They nudge Claude to pre-authorize
  the narrow set of permissions each prompt or plan needs before the
  first tool call, reducing mid-session permission dialogs. A companion
  `writing-style.sh` hook fires when a prompt describes writing a
  Google Doc or Confluence page and nudges Claude to load the
  `writing-style` skill first.
- **Matt Pocock skills** (12 vendored skills, installed via
  `rcha0s/claude-config`). See the "Bootstrap your own doctrine layer"
  section for how the private companion repo pulls these in as `matt-*`
  symlinks under `~/.claude/skills/`.

### Explicitly omitted from Kun's setup (and why)

- **Nix / nix-darwin / Home Manager base.** Kun's [dotfiles-mac-nix]
  [dotfiles] installs [Determinate Nix][det-nix] as its foundation,
  creating an APFS volume at `/nix`, 32 system users, and a
  system-wide `launchd` daemon. On an enterprise-managed Mac, that
  triggers MDM/EDR alerts. This setup keeps the Nix files present as
  a reference path (`setup/mac.sh`, `nix/`, `flake.nix`) but the
  default install (`setup/install-noix.sh`) uses vanilla Homebrew
  and per-user symlinks with zero system-level changes.
- **Amethyst tiling window manager.** Optional in Kun's setup;
  skipped here because macOS's built-in Mission Control + tmux panes
  already cover the same ergonomics without the shortcut collisions
  Amethyst introduces.
- **OpenCode.** Kun uses OpenCode as his "everything except
  Anthropic" harness. Skipped since we drive Claude Code exclusively.
- **Tailscale.** Kun uses Tailscale + mosh for phone-to-Mac SSH.
  Tailscale creates a second encrypted tunnel that a corporate
  security stack cannot inspect (classic split-tunnel indicator), so
  on an enterprise Mac it is a very likely policy denial. mosh alone
  is installed; Tailscale left off. See [`docs/RESOURCES.md`][resources]
  "Remote access".
- **`baby-menu`** (macOS menu-bar app whose widgets an agent writes).
  Skipped because the tmux status bar + fleet indicator + OS
  notifications already cover the "at-a-glance" role.
  **When to revisit:** if a specific dashboard widget the tmux
  status can't show becomes valuable (e.g., real-time cost of API
  spend, aggregated CI status across many repos).
- **`wheelhouse`** (cross-repo IssueOps command center via GitHub
  Actions). Skipped because it only pays off across 5+ actively
  orchestrated repos, and the corp-managed repos I care about
  aren't drivable from GitHub Actions anyway.
  **When to revisit:** if I start owning multiple personal repos
  and want to fire cross-cutting work from GitHub mobile.
- **`gsh`** (LLM-backed generative POSIX shell). Skipped because it
  overlaps with Claude Code itself; the round-trip cost is the same
  order of magnitude and Claude Code is already always-on.
  **When to revisit:** if a "cheap one-off shell command" niche
  emerges that doesn't warrant booting Claude Code.

[opinions-post]: https://blog.kunchenguid.com/p/everyone-should-have-an-opinionsmd

## Quick start

Prerequisites: macOS on Apple Silicon (Intel likely works but is
untested), Homebrew, `gh` CLI, Google Chrome, Node 20+.

```
gh repo clone rcha0s/agentic-mac-setup ~/github/agentic-mac-setup
cd ~/github/agentic-mac-setup
bash setup/install-noix.sh
```

Post-install checklist (WezTerm cask, tmux plugin install, Neovim
plugin bootstrap, `gh auth login`, hook wiring, `no-mistakes init`
per-repo) is in [`HANDOFF.md`](./HANDOFF.md).

## Repo layout

```
agentic-mac-setup/
├── flake.nix, nix/                  # upstream Nix path (preserved, not used by default)
├── setup/
│   ├── mac.sh                       # Nix bootstrap (upstream, unused here)
│   ├── install-noix.sh              # no-Nix bootstrap ← default
│   └── agentic.sh                   # agentic stack installer (shared)
├── files/
│   ├── .config/wezterm/             # frameless WezTerm config, solid background
│   ├── .config/nvim/                # lazy.nvim + oil + neogit + snacks + rose-pine
│   ├── .config/starship.toml
│   ├── .tmux.conf                   # C-a prefix, vi mode, resurrect + continuum, mouse rebinds
│   ├── zshrc.local.example          # personal shell config template (tracked)
│   ├── claude-hooks/                # generic Claude turn-lifecycle hooks (event listeners + bridge)
│   ├── tmux-scripts/                # pure-tmux status readers (see bridge note below)
│   └── zshrc.local                  # per-machine local (git-ignored)
├── docs/
│   ├── PRIMER-TMUX.md               # conceptual model + config walkthrough
│   ├── PRIMER-ZSH.md                # for existing bash users
│   ├── LEARN-WEZTERM.md             # keybinds verified vs installed version
│   ├── LEARN-TMUX.md                # cheat-sheet + grid recipes + status indicators
│   ├── LEARN-NEOVIM.md              # motions, plugin keybinds, learning path
│   ├── LEARN-AGENTIC.md             # daily-driver flow across the 7 agentic tools
│   ├── INSTALL-VOICE.md             # OpenSuperWhisper install (local Whisper/Parakeet)
│   ├── RESOURCES.md                 # verified videos + docs for every tool
│   └── security-review/             # IT-approval templates
├── templates/
│   └── project-AGENTS.md            # per-repo AGENTS.md template no-mistakes reads
├── .claude/
│   └── settings.json                # repo-scoped Claude Code permissions
├── README.md
└── HANDOFF.md                       # post-install checklist
```

## Personal vs. shared config

Everything under this repo is **shareable and reusable** — a stranger
can fork it and get a working setup. That includes the Claude
turn-lifecycle hook scripts under `files/claude-hooks/`: they contain
no personal data, only generic wiring (write a state file when a
turn ends, rename a tmux window with a glyph). Fork it, install it,
it works.

The maintainer's own **personal doctrine layer** — `~/.claude/AGENTS.md`,
`~/.claude/OPINIONS.md`, and `~/.claude/settings.json` with real
Bedrock ARNs and token pointers — lives in a separate private repo
so its *content* doesn't leak. Anyone recreating this setup would
similarly keep their own doctrine files in their own private
companion repo. The reference companion is
[`rcha0s/claude-config`][claude-config] (private; the shape is
visible in the public README there).

### Bootstrap your own doctrine layer

The three files are personal by design, so we don't ship them — but
here's how to seed them from public sources.

**1. Create your private companion repo.** Any host works; the
maintainer's uses this shape:

```
your-claude-config/
├── AGENTS.md               # global agent behavior rules
├── OPINIONS.md             # durable stated preferences
├── settings.json.template  # Bedrock ARN + token placeholders
└── install.sh              # symlinks the above into ~/.claude/
```

Keep the repo private — `settings.json` will hold live secrets and
`OPINIONS.md` typically references internal tools, teams, and
incidents.

**2. Seed `OPINIONS.md` from Kun Chen's canonical example.** Kun's
blog post ["Everyone Should Have an
OPINIONS.md"][opinions-post] is the source of the pattern — read it
before writing your own. Copy his structure (a short front-matter
declaration; then a list of opinions each with a **When to revisit**
line so the doctrine doesn't calcify), and populate it with your
*own* positions. Example opening entries:

```markdown
# OPINIONS.md

Durable stated preferences for how I want agents to work with me.
Each opinion has a "When to revisit" line — no rule is permanent.

## Prefer AXI CLIs over MCP servers

For any operation where an AXI-style CLI exists (github, browser,
tasks, backlog), invoke it directly rather than reaching for the
MCP equivalent. Reason: 40% token savings + higher success rate
per Kun Chen's published benchmarks.

**When to revisit:** if an MCP starts outperforming AXI on a
specific operation, or if a critical AXI CLI stops being maintained.

## Immutability in shared code, mutation in local scope

Shared modules use immutable data structures; a function that mutates
a local variable inside its own body is fine. Bias the boundary
toward "shared = frozen" because most bugs at this codebase come
from unexpected mutation across module boundaries.

**When to revisit:** if performance profiles show immutable-copy
allocation is the hotspot, or if we adopt a language whose runtime
handles this differently (e.g. Rust ownership).
```

Add your own opinions as they solidify — every correction you make
to an agent twice is a candidate for an OPINIONS entry.

**3. Seed `AGENTS.md` from public references.** Start with a fork
of Anthropic's [Claude Code documentation
patterns](https://docs.claude.com/en/docs/claude-code) or the
Everything-Claude-Code plugin's [global AGENTS.md
example](https://github.com/affaan-m/everything-claude-code) —
whichever matches your workflow — then narrow it to your actual
tooling. The maintainer's ~13KB `AGENTS.md` merges Kun's doctrine
(from the [primary video][video] and his [blog][blog]) with the
Everything-Claude-Code common rules, plus a "no-mistakes doctrine"
section describing the validation pipeline. You don't need all of
that on day one; strip it to what you'll actually enforce.

**4. Seed `settings.json` from a template with placeholders.**
Never commit the real thing. The maintainer's private repo tracks
a `settings.json.template` with `${AWS_PROFILE}`, `${OPUS_PROFILE_ID}`,
`${SOURCEGRAPH_TOKEN}` etc. — resolved by the installer only on the
target machine. The template is visible in the
[`rcha0s/claude-config` README][claude-config] under "Filling in the
settings template" if you want the placeholder inventory.

**5. Wire it up with a two-line installer.** Symlinks the tracked
files into `~/.claude/` and refuses to overwrite an existing
`settings.json`:

```bash
ln -sfn "$REPO/AGENTS.md"   ~/.claude/AGENTS.md
ln -sfn "$REPO/OPINIONS.md" ~/.claude/OPINIONS.md
[ -f ~/.claude/settings.json ] || cp "$REPO/settings.json.template" ~/.claude/settings.json
```

Run `install-noix.sh` from *this* repo first (it symlinks the
generic hooks + tmux status scripts into `~/.claude/hooks/` and
`~/.tmux-scripts/`), then run your private repo's installer to
overlay the doctrine layer. The two never touch the same files.

[blog]: https://blog.kunchenguid.com

Concretely:

- `files/zshrc.local.example` is the tracked public template. On first
  run, `install-noix.sh` copies it to `files/zshrc.local` (git-ignored)
  where you put `JAVA_HOME`, corp CA cert paths, work AWS profile
  names, and other machine-specific things.
- `.claude/settings.json` in the repo is a narrow, tracked allowlist
  applied to any Claude Code session started in the repo. Machine-
  specific one-off approvals land in `.claude/settings.local.json`
  (git-ignored).

### Why the Claude → state-file → tmux bridge exists <a id="claude-tmux-bridge"></a>

Two sibling directories cooperate through a filesystem contract:

| Layer | Directory | Files | Trigger |
|---|---|---|---|
| **Event listeners** (Claude → filesystem) | `files/claude-hooks/` | `turn-start.sh`, `turn-done-notify.sh`, `turn-attention.sh`, `session-reflect.sh` | Claude Code `UserPromptSubmit` / `Stop` / `Notification` hooks |
| **Bridge** (rename window, write state) | `files/claude-hooks/` | `tmux-mark.sh` | Called by the event listeners above |
| **Display readers** (state → tmux format) | `files/tmux-scripts/` | `pane-status.sh`, `fleet-status.sh` | tmux `pane-border-format` and `status-right`, polled every `status-interval` seconds |

The event listeners fire on Claude events and call `tmux-mark.sh`,
which writes `~/.claude/state/pane-<id>.state`. The tmux display
readers, invoked by tmux itself via `#(...)`, poll those state files
and print colored format strings. Neither side imports or exec's the
other — they only share the state-directory contract.

Why not just tmux config? Because tmux has no way to observe "Claude
just finished a turn." Only Claude's `Stop` hook knows that. Why
two directories instead of one? Because the tmux-side scripts are
invoked by tmux with different lifecycle, arg conventions, and output
format expectations than the Claude-side hooks. Colocating them
would blur what invokes what. This split lets you swap either half
(different harness on the Claude side; different terminal multiplexer
on the display side) without touching the other.

## References

**Kun Chen's primary sources**
- Video (canonical): ["L8 Principal's Agentic Engineering Workflow"][video]
- Upstream dotfiles: [kunchenguid/dotfiles-mac-nix][dotfiles]
- Blog: <https://blog.kunchenguid.com>
- AXI design principles + benchmarks: [axi.md][axi-site] and
  [kunchenguid/axi][axi-repo] (with full [browser][bench-browser] and
  [GitHub][bench-github] benchmark studies)

**Research cited**
- Ruan, S., Wobbrock, J. O., Liou, K., Ng, A., & Landay, J. A. (2016).
  Comparing Speech and Keyboard Text Entry for Short Messages in Two
  Languages on Touchscreen Phones. *ACM CHI Extended Abstracts*.
  [arXiv:1608.07323][ruan]. Finding: speech input on smartphones
  achieved 2.93× faster text entry than keyboard on English (153 WPM
  vs. 52 WPM).
- Anthropic (2024). Model Context Protocol specification. Referenced
  in Kun's AXI comparison as the baseline for measuring token
  efficiency and success rate.
- Jones, A., & Kelly, C. (2025, November). Code execution with MCP:
  Building more efficient agents. *Anthropic Engineering Blog*.
- Varda, K., & Pai, S. (2025, September). Code Mode: The better way
  to use MCP. *Cloudflare Blog*.
- Mao, H., & Pradhan, R. (2026, March). MCP vs CLI is the wrong
  fight. *Smithery Blog*.

## License

MIT (same as upstream).

[video]: https://youtu.be/iQyg-KypKAA
[dotfiles]: https://github.com/kunchenguid/dotfiles-mac-nix
[axi-site]: https://axi.md
[axi-repo]: https://github.com/kunchenguid/axi
[bench-browser]: https://github.com/kunchenguid/axi/tree/main/bench-browser
[bench-github]: https://github.com/kunchenguid/axi/tree/main/bench-github
[gh-axi]: https://github.com/kunchenguid/gh-axi
[cd-axi]: https://github.com/kunchenguid/chrome-devtools-axi
[tasks-axi]: https://github.com/kunchenguid/tasks-axi
[lavish]: https://github.com/kunchenguid/lavish-axi
[gnhf]: https://github.com/kunchenguid/gnhf
[nomistakes]: https://kunchenguid.github.io/no-mistakes/
[treehouse]: https://github.com/kunchenguid/treehouse
[firstmate]: https://github.com/kunchenguid/firstmate
[claude-config]: https://github.com/rcha0s/claude-config
[win-setup]: https://github.com/rcha0s/agentic-windows-setup
[det-nix]: https://determinate.systems/nix-installer/
[oil]: https://github.com/stevearc/oil.nvim
[neogit]: https://github.com/NeogitOrg/neogit
[snacks]: https://github.com/folke/snacks.nvim
[lazy]: https://lazy.folke.io
[ruan]: https://arxiv.org/abs/1608.07323
[learn-tmux]: ./docs/LEARN-TMUX.md
[zsh-primer]: ./docs/PRIMER-ZSH.md
[resources]: ./docs/RESOURCES.md
