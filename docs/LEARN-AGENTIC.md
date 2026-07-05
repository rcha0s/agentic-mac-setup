# Learn the Agentic Stack

Kun Chen's agentic workflow, every tool you now have installed, when to use it, and how they fit together.

## The mental model

```
┌────────────────────────────────────────────────────────────────┐
│ You (in a WezTerm + tmux session, editing in Neovim) │
└────────────────────────────────────────────────────────────────┘
 │
 │ talk to
 ▼
┌────────────────────────────────────────────────────────────────┐
│ Claude Code │
│ ├── Skills auto-load: gh-axi, chrome-devtools-axi, tasks-axi,│
│ │ lavish (installed as claude skills) │
│ └── SessionStart hooks inject ambient state (open PRs, │
│ backlog, active browser tab) each time you open a session │
└────────────────────────────────────────────────────────────────┘
 │
 │ optional orchestration:
 ▼
┌────────────────────────────────────────────────────────────────┐
│ gnhf → run agents overnight in a loop │
│ treehouse → give each agent an isolated worktree │
│ firstmate → captain + crewmates: one liaison agent │
│ dispatches parallel jobs │
│ no-mistakes → pre-push validation pipeline │
└────────────────────────────────────────────────────────────────┘
```

## The individual tools

### AXI skills (auto-loaded in Claude Code)

| Tool | Manual form | What it does | When Claude Code uses it |
|---|---|---|---|
| **gh-axi** | `gh-axi issue list`, `gh-axi pr view 42`, `gh-axi run list` | Agent-ergonomic wrapper over `gh` | Any task touching GitHub |
| **chrome-devtools-axi** | `chrome-devtools-axi open <url>`, `snapshot`, `click @<uid>` | Browser automation | Any web task |
| **tasks-axi** | `tasks-axi` (shows backlog) | Backlog manager over `backlog.md` | Backlog / task ops |
| **lavish-axi** | agent-invoked | Turns HTML artifacts into reviewable surfaces | When output is easier to grasp visually |

You don't call these yourself in a Claude Code session, Claude decides. Verify they're active by running `claude` in any repo; the SessionStart output should mention gh/chrome/tasks ambient context.

Try it now:
```bash
gh-axi                 # dashboard for current repo (no args needed)
gh-axi issue list      # list issues in agent-ergonomic form
tasks-axi              # shows backlog for current dir
chrome-devtools-axi    # list subcommands
```

Full subcommand set for each: run the CLI with `--help`. Notable ones:
`gh-axi` uses **singular** nouns (`issue`, `pr`, `run`, `workflow`, `release`,
`repo`, `label`, `secret`, `variable`, `search`, `api`). `chrome-devtools-axi`
uses `open <url>` (not `navigate`), plus `snapshot`, `click`, `fill`,
`screenshot`, `eval`, `pages`.

### gnhf: "Good Night, Have Fun"

Overnight autonomous loop. You give it an objective; it iterates, commits, retries on failure, until it hits your caps or the objective is done.

Basic use:
```bash
gnhf "add unit tests for the auth module" --max-iterations 5
```

Parallel with worktrees (needs treehouse or built-in worktree flag):
```bash
gnhf --worktree "refactor the payments module"
```

Config: `~/.gnhf/config.yml` (already created, `agent: claude`, `preventSleep: true`, conventional commits).

**When to use:** end-of-day, well-scoped objectives where you'd otherwise wake up and do the same busywork. Don't use for open-ended research.

### no-mistakes: pre-push validation

Intercepts `git push` to a special `no-mistakes` remote and runs review + tests + lint + CI in an **isolated worktree** before forwarding to `origin` and opening a PR.

Per-repo setup:
```bash
cd <your-repo>
no-mistakes init
```

Daily use:
```bash
git checkout -b my-feature
# do work, commit
git push no-mistakes
no-mistakes # opens TUI to review the pipeline
```

**When to use:** any repo where you want automatic pre-push safety without adding a CI check first.

### treehouse: reusable worktree pool

Instead of manually creating git worktrees for parallel agents, treehouse maintains a pool. `treehouse get` drops you in a clean worktree instantly; `treehouse return` puts it back.

```bash
cd <any-repo>
treehouse init # once per repo
treehouse get # acquire a clean worktree, drops you in it
# do work in isolation
treehouse return # release back to the pool
treehouse status # what's in the pool
```

**When to use:** running multiple agents against the same repo without file conflicts. Also useful even solo, e.g., quickly try a change on a scratch branch.

### firstmate: fleet supervisor

Multi-agent orchestration. You talk to **one** "first mate" agent in a Claude Code session inside `~/github/firstmate/`. It dispatches parallel "crewmates" (each in a treehouse worktree) for ship tasks (deliver PR) or scout tasks (investigate + report).

Boot:
```bash
cd ~/github/firstmate
claude
```

Inside, address it as "captain" and describe the work. It routes to the right project and spawns crewmates. Read `~/github/firstmate/AGENTS.md` inside the repo for the full operating manual (this is intentionally long, firstmate has real complexity).

**When to use:** you have >1 non-trivial task and want them running in parallel while you focus on one thing.

## Daily-driver workflow

Here is what a typical Kun-style day looks like:

1. **Open WezTerm** → shell auto-attaches to tmux `main` session
2. **`cd` into your project** → tmux window per project
3. **Start Claude Code:** `claude` (or `cc` alias)
 - SessionStart shows: open PRs in this repo, current backlog, any active browser tab
4. **Talk to Claude**, Claude uses `gh-axi` / `chrome-devtools-axi` / `tasks-axi` under the hood without you asking
5. **Complex tasks** → let Claude do it in-session
6. **Overnight / batch** → `gnhf "objective"` before EOD
7. **Ready to push** → `git push no-mistakes`, review TUI, merges to origin + opens PR
8. **Multiple parallel jobs** → `cd ~/github/firstmate && claude`, tell the captain

## Learning path (2 weeks)

**Week 1, get comfortable with the AXI skills**

- Day 1-2: use Claude Code in a real repo. Notice how it uses gh-axi automatically. Peek at what SessionStart shows.
- Day 3-4: try `tasks-axi` for a real backlog. Add items with the CLI, let Claude read them.
- Day 5-7: give Claude a web task. Watch it use `chrome-devtools-axi`.

**Week 2, orchestration**

- Day 8-9: pick one repo, `no-mistakes init`, use it for a week.
- Day 10-11: try `treehouse` for a scratch branch instead of `git worktree add`.
- Day 12-13: run a real `gnhf` overnight loop on a bounded task.
- Day 14: read `~/github/firstmate/AGENTS.md`, boot firstmate, try one ship task.

## Resources

**Kun's own writing (canonical):**

- Kun's blog: <https://blog.kunchenguid.com/>
 - **["Everyone Should Have an OPINIONS.md"](https://blog.kunchenguid.com/p/everyone-should-have-an-opinionsmd)**: his agent-maintained "durable beliefs" doc
 - **["How I Built a Reproducible Mac Setup with Nix"](https://blog.kunchenguid.com/p/how-i-built-a-reproducible-mac-setup)**: the setup this fork is based on
 - **["Evaluating the Effectiveness of Programming Languages for Agents"](https://blog.kunchenguid.com/p/evaluating-the-effectiveness-of-programming)**: why he picks the languages he does
- Kun's YouTube channel: <https://www.youtube.com/@kunchenguid>
 - **"L8 Principal's Agentic Engineering Workflow"**: the video you're reproducing: <https://youtu.be/iQyg-KypKAA>
- Kun's GitHub: <https://github.com/kunchenguid>

**Per-tool docs:**

- axi principles + implementations: <https://axi.md>
- gh-axi: <https://github.com/kunchenguid/gh-axi>
- chrome-devtools-axi: <https://github.com/kunchenguid/chrome-devtools-axi>
- tasks-axi: <https://github.com/kunchenguid/tasks-axi>
- lavish-axi: <https://github.com/kunchenguid/lavish-axi>
- gnhf: <https://github.com/kunchenguid/gnhf>
- no-mistakes: <https://kunchenguid.github.io/no-mistakes/>
- treehouse: <https://github.com/kunchenguid/treehouse>
- firstmate: <https://github.com/kunchenguid/firstmate>

**Claude Code fundamentals:**

- Claude Code docs: <https://docs.claude.com/en/docs/claude-code/overview>
- CLAUDE.md best practices: <https://docs.claude.com/en/docs/claude-code/memory>
- Skills concept: <https://docs.claude.com/en/docs/claude-code/skills>
- Hooks: <https://docs.claude.com/en/docs/claude-code/hooks>

**Agent-native workflow (broader field):**

- **[Simon Willison's blog](https://simonwillison.net/)**: pioneered many "agent as CLI user" patterns; ongoing running commentary on LLM tooling
- **[Ampcode blog](https://ampcode.com/blog)**: perspective from another agent harness
- **[Anthropic: Mastering Claude Code in 30 minutes](https://www.youtube.com/watch?v=6eBSHbLKuN0)**: the Claude Code team's own primer

## Rules of thumb from Kun

- **Agent-agnostic first.** He deliberately avoids vendor gimmicks (auto-managed memory, IDE-locked-in features) so switching costs stay near zero.
- **CLI over MCP.** For most operations. Reads the AXI principles doc (axi.md), token-efficient, well-scoped output beats stateful MCP servers.
- **tmux is not optional.** Layouts persist across everything. Attach from your phone. Kill the terminal, sessions live.
- **Frameless everything.** Fewer distractions, more content.
- **Commit per iteration.** gnhf's default, no-mistakes enforces it. Fine-grained history = easy revert.
