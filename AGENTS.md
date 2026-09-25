# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.

## setup/mac.sh: never run it for real

`setup/mac.sh` installs Nix (via the Determinate installer) and runs a real `nix-darwin` system activation (`darwin-rebuild switch` / `sudo nix run ... switch`). Never execute it, the real Determinate installer, `darwin-rebuild switch`, `sudo nix run ...`, the Homebrew installer, or the nvm installer against a dev machine or CI host - these mutate the host permanently. All validation of this script must go through `tests/mac_setup_test.sh`, which runs the actual script with PATH masked to stub executables so nothing real is ever installed or activated.

## Fresh-machine single-pass contract

`setup/mac.sh` must bootstrap a brand-new Mac in one run, with no "run it again in a new shell" step. After the Determinate installer runs, the script sources the Nix daemon profile (`NIX_DAEMON_PROFILE`, defaults to `/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`) into the current shell so `nix` is usable immediately, then activates nix-darwin for the first time via `sudo <absolute nix path> --extra-experimental-features "nix-command flakes" run nix-darwin/master#darwin-rebuild -- switch --flake ...` (absolute path because `sudo` doesn't inherit the newly-sourced PATH). `NIX_DAEMON_PROFILE` and `DARWIN_REBUILD_BIN` are both overridable via environment variables (defaulting to the real canonical paths) specifically so tests can point them at a sandbox instead of the real filesystem. Any future edit to this bootstrap logic must preserve: single-pass success on a fresh machine, and the existing already-installed fast path (`$DARWIN_REBUILD_BIN switch`) staying untouched.

## Testing setup/mac.sh

Run `bash tests/mac_setup_test.sh`. It simulates a fresh Mac by copying the repo into a scratch fixture (placeholders pre-replaced), building stub `curl`/`sh`/`nix`/`darwin-rebuild`/`sudo`/`bash` executables that record invocations and fake just enough side effects (a profile script, a `nix` binary) for the script to progress, then running the real `setup/mac.sh` against that PATH-masked sandbox. It covers both the fresh-machine path (single-pass activation) and the already-installed fast path. It never touches the real network, Nix store, Homebrew, sudo, or system state. Set `DEBUG_KEEP_SANDBOX=1` to keep the scratch sandbox around for inspection after a failing run.

Each scenario sandboxes `HOME`, re-homes `NVM_DIR` under that temp root, and unsets inherited `BASH_ENV`/`ENV` before invoking `setup/mac.sh` (an inherited absolute `NVM_DIR` from hm-session-vars would otherwise leak stub writes).
Harness and stub writes call `assert_path_under_sandbox` / `guard_write_path` so a future leak through parent traversal, symlink escape, or another absolute write path fails the test instead of mutating the host.

## setup/agentic.sh: local inference layer ships no model weights

`setup/agentic.sh` provisions `pi` (npm global, the crew runtime Firstmate launches crewmate/worker sessions on, independent of Claude Code staying the primary session) and `llama-server` (`brew install llama.cpp`), then merges a `llamacpp` custom-provider entry into `~/.pi/agent/models.json` with `jq`. That provider entry is the only mechanism that gets `pi` talking to a local endpoint: `pi` ignores `OPENAI_BASE_URL` / `OPENAI_API_BASE`. The merge is idempotent (skips if the `llamacpp` key already exists) and falls back to printing the JSON block for a manual merge if `jq` is missing, matching the presence-check idiom the rest of the script uses.

The script deliberately does not download or reference a specific GGUF file: model weights are large, hardware-specific, personal-machine state. Pointing `llama-server` at one is left to the operator's own `ask-local`-style wrapper, documented in `docs/LEARN-AGENTIC.md` as personal tooling (like the doctrine layer) rather than something this repo ships. Firstmate's session backend (`herdr`) and crew-dispatch routing (`config/crew-dispatch.json`) live inside the firstmate repo, not this one; this repo only documents the values this stack expects, in `README.md` ("Crew runtime and local inference", "Firstmate crew routing") and `docs/LEARN-AGENTIC.md`.

Unlike `setup/mac.sh`, `setup/agentic.sh` has no dedicated test harness: its own docstring already documents it as safe to run standalone and re-run (idempotent presence checks, no system-level Nix/nix-darwin activation).
