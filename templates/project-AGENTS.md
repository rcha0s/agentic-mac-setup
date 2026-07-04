# AGENTS.md

> Template for a **project-level** `AGENTS.md`. Copy into any repo where you
> want Kun-style agentic workflows. `no-mistakes`, `firstmate`, and Claude
> Code all read this file.
>
> Global memory (`~/.claude/AGENTS.md`) provides doctrine that applies
> everywhere. **This** file covers project-specific facts: what the app is,
> how to run it, how to prove a change actually works end-to-end.
>
> **Delete this blockquote before committing.**

---

## What this project is

<!-- One sentence. Example:
"A Python FastAPI service that serves the security review chatbot
consumed by the security-scan-config repo's GitHub Actions."
-->

## Repo layout

<!-- Point out the 3-5 directories that matter. Not a `tree` dump. Example:
- `src/api/` — FastAPI routes and request/response schemas
- `src/rag/` — chunking, embedding, retrieval logic
- `src/eval/` — offline evaluation harness
- `tests/` — pytest, run with `make test`
- `deployments/` — Terraform for the AWS Lambda + API Gateway
-->

## How to run the app

<!-- The exact commands. Include env setup, dependencies, and where to point
your browser (if any). Example:

```
uv sync
uv run uvicorn src.api.main:app --reload --port 8000
```

Then hit http://localhost:8000/docs for the OpenAPI UI.
-->

## How to validate a change end-to-end

This is the section `no-mistakes` cares about most. The agent MUST prove
the change works by exercising the real app — not just running unit tests.

<!-- Example for a FastAPI service:

1. Boot the API locally: `uv run uvicorn src.api.main:app --port 8000`
2. Hit the endpoint(s) affected by the change:
   ```
   curl -X POST http://localhost:8000/review \
     -H "Content-Type: application/json" \
     -d @tests/fixtures/example_diff.json
   ```
3. Verify the response schema matches `docs/response_schema.json`.
4. If the change touches RAG, run `uv run python -m src.eval.smoke` and
   confirm the evaluation score is within 5% of the last commit's score.
5. If the change touches Terraform, `terraform plan -no-color` and paste
   the plan into the PR body.

Any of the above failing is a hard fail — do not open a PR.
-->

## Standard test suite

<!-- The commands `no-mistakes` will run in a fresh worktree. Example:

```
make lint        # ruff + mypy
make test        # pytest with 80% coverage gate
make eval-smoke  # 30-second offline eval
```
-->

## PR requirements

Before opening a PR, the change must have:

- [ ] All commands under "Standard test suite" pass
- [ ] E2E validation (above) executed successfully with output pasted or
      screenshotted in the PR body
- [ ] Conventional-commit-style commit messages (`feat:`, `fix:`, `refactor:`, …)
- [ ] No secrets or `.env` files staged
- [ ] Docstrings / README updated if public API changed

## Escalation policy

The agent auto-escalates to the human for:

- Product-facing behavioral changes (default responses, error messages,
  user-visible copy)
- Cost-affecting changes (LLM model choice, token budgets, batch sizes)
- Schema changes to public API contracts
- Security-relevant changes to auth, secrets, cert handling

Everything else the agent decides autonomously and documents in the PR.

## Ambient context

Present in every Claude Code session started from this repo:

- Open PRs and failing CI runs from `gh-axi`
- Ready-to-work backlog items from `tasks-axi` (reads `backlog.md` if present)
- Active browser tab from `chrome-devtools-axi` (if a debug session is running)

You don't need to paste PR links into prompts — the agent already sees them.

## Project-specific conventions

<!-- Anything a fresh agent would benefit from knowing that isn't obvious
from the code. Examples:

- We use `uv` for Python, not `poetry` or `pip`. Never generate a
  `requirements.txt` — modify `pyproject.toml` instead.
- Feature flags live in `src/config/flags.py`. Never hardcode
  environment-specific values elsewhere.
- Log lines follow `{"event": "...", "meta": {...}}` — structured JSON only.
- Never commit files under `data/` — those are gitignored fixtures pulled
  from S3 via `make fixtures`.
-->

## When the agent errs

Corrections to this file, not to the code:

- If Claude repeatedly forgets a convention, add it to the "Project-specific
  conventions" section.
- If the E2E validation is flaky or misses a class of bug, tighten the
  section above.
- If the escalation policy is too strict or too lax, revise it.

This file grows over time as an artifact of what your team has learned
about working with agents in this repo.

---

## Kun's doctrine (referenced)

Global memory (`~/.claude/AGENTS.md`) codifies the delegation/validation/
skills-caution/captain's-mindset rules. Everything above is
project-specific. If a project rule conflicts with a global rule,
**project wins** (more specific).
