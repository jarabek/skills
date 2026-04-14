# Signal catalog

The auditable signals the `agentex-audit` skill checks against. Loaded at Step 3 of the audit procedure. Each signal is tagged with its primary lens (`[AgentEx]`, `[DevEx]`, or `[AgentEx+DevEx]`), a severity, and a fix template where applicable.

Signal statuses: **PRESENT** (configured and meaningful), **PARTIAL** (present but incomplete or stale), **MISSING** (absent), **N/A** (not applicable for this repo type/stage).

Severity levels:
- **critical** — agents cannot work productively without it
- **high** — sizable token waste / flail per session
- **medium** — noticeable friction
- **low** — quality-of-life

---

## 1. Context & documentation

### 1.1 `AGENTS.md` exists and is comprehensive — `[AgentEx]` — critical
**What to check:** root `AGENTS.md`. Count sections. GitHub's analysis of 2,500+ top repos found top-tier AGENTS.md covers six areas: build/test commands, project structure, code style, git workflow, testing expectations, agent accessibility.
**Present means:** agents onboard in one file read.
**Absent means:** every new agent session starts with generic guessing — easily 5–10k tokens of exploration before the first useful edit.
**Fix template:** `templates/AGENTS.md.tmpl`
**Citation:** GitHub Blog, "How to write a great agents.md: lessons from 2,500 repositories" (2025).

### 1.2 `CLAUDE.md` exists and is concise — `[AgentEx]` — high
**What to check:** root `CLAUDE.md`; `wc -l` should be < 200. It should NOT duplicate AGENTS.md content. It should point to `AGENTS.md`
**Present means:** Claude Code auto-loads it on session start.
**Absent means:** Claude starts with no project conventions. If present but > 200 lines: every session pays a tax on context.
**Fix template:** `templates/CLAUDE.md.tmpl`
**Citation:** Claude Code docs, "Best Practices" — keep CLAUDE.md under 200 lines.

### 1.3 `CODEMAP.md` or equivalent orientation doc — `[AgentEx+DevEx]` — high
**What to check:** a root-level doc that answers "where does X live?" with a directory tree, a "where to add X" table, and an endpoint/feature index.
**Present means:** agents skip the grep/read loop on first contact with a module.
**Absent means:** 2–5k tokens wasted per feature session on "where is the portfolio code?" exploration.
**Fix template:** `templates/CODEMAP.md.tmpl`

### 1.4 `README.md` non-trivial and includes setup + usage — `[DevEx]` — high
**What to check:** > 200 chars, mentions install/setup and at least one example usage.
**Present means:** humans can onboard without a chat.
**Absent means:** cognitive load spikes for every newcomer (human or agent).

### 1.5 `.github/copilot-instructions.md` — `[AgentEx]` — low
**What to check:** file presence.
**Present means:** GitHub Copilot users get project-specific instructions.
**Absent means:** Copilot users fall back to generic behavior (not a blocker if AGENTS.md exists).

### 1.6 `llms.txt` at repo root — `[AgentEx]` — low
**What to check:** `llms.txt` or `llms-full.txt` at root per the llmstxt.org standard.
**Present means:** external agents discovering the repo get a structured index of documentation.
**Absent means:** mostly a miss for public libraries with external docs; irrelevant for internal services.

### 1.7 Architecture Decision Records (ADRs) — `[AgentEx+DevEx]` — medium
**What to check:** `docs/adr/`, `docs/decisions/`, or similar directory with dated ADR files.
**Present means:** agents can cite *why* an architectural decision was made, not just *what* it is.
**Absent means:** agents revert or second-guess intentional design choices.

### 1.8 Runbooks or operational guides — `[DevEx]` — medium
**What to check:** `RUNBOOK.md`, `docs/runbooks/`, or similar.
**Present means:** on-call and agents both have a recipe for common tasks.
**Absent means:** tribal knowledge, repeated investigation.

### 1.9 `.devcontainer/devcontainer.json` — `[AgentEx+DevEx]` — medium
**What to check:** file exists and references a base image plus install steps.
**Present means:** reproducible environment; agents in sandboxed harnesses get identical tooling.
**Absent means:** "works on my machine" drift between human and agent environments.

### 1.10 Tech stack and versions documented — `[AgentEx+DevEx]` — medium
**What to check:** README or AGENTS.md lists the major stack (Python 3.12, Node 20, Postgres 16, etc.).
**Present means:** agents pick correct idioms and APIs on the first try.
**Absent means:** agents guess, sometimes wrongly.

### 1.11 "Where to add X" table — `[AgentEx]` — medium
**What to check:** AGENTS.md or CODEMAP.md contains an explicit table mapping task → file path.
**Present means:** cognitive load ≈ 0 for common feature work.
**Absent means:** see 1.3.

---

## 2. Feedback loops for agents

### 2.1 Test directory and runner configured — `[AgentEx+DevEx]` — critical
**What to check:** `tests/`, `test/`, `spec/`, `__tests__/` directory AND a runner config (`pytest.ini`, `jest.config.js`, `vitest.config.ts`, `go test`, `cargo test`).
**Present means:** agents have a concrete "did this break anything?" signal.
**Absent means:** agents have no independent verification — they must rely on the human to catch regressions.

### 2.2 Test command documented — `[AgentEx]` — critical
**What to check:** AGENTS.md or CLAUDE.md contains the literal command (e.g. `` `npm test` `` or `` `.venv/bin/pytest tests/` ``) wrapped in backticks.
**Present means:** agents run the correct command on the first try.
**Absent means:** agents guess, or worse, skip tests entirely.
**Citation:** GitHub's 2,500-repo analysis — exact commands in backticks is a top-tier marker.

### 2.3 Test suite runs in < 30 seconds (or "fast lane" documented) — `[AgentEx+DevEx]` — high
**What to check:** `time` the documented test command against a trivial change, or check CI logs for wall-clock. If slow, check for a documented fast lane (`pytest tests/unit/`, `npm run test:unit`).
**Present means:** agents can run tests mid-task without breaking flow.
**Absent means:** agents either skip tests or lose context while waiting. Forsgren: "slow feedback loops interrupt the development process."

### 2.4 Linter/formatter configured — `[AgentEx+DevEx]` — high
**What to check:** `.eslintrc*`, `ruff.toml`/`[tool.ruff]` in pyproject, `.rubocop.yml`, `rustfmt.toml`, `gofmt` implied.
**Present means:** agents get fast, cheap style feedback.
**Absent means:** endless nitpick cycles in code review.

### 2.5 Type checker configured — `[AgentEx]` — high
**What to check:** `tsconfig.json`, `mypy.ini`/`[tool.mypy]`, Go/Rust type systems inherent.
**Present means:** agents catch whole classes of bugs before running tests.
**Absent means:** agents ship type-unsafe code that dies in production.

### 2.6 Pre-commit hooks configured — `[AgentEx+DevEx]` — high
**What to check:** `.pre-commit-config.yaml`, Husky setup in `package.json`, or `.git/hooks/` scripts.
**Present means:** agents can't accidentally commit broken code.
**Fix template:** `templates/precommit-config.yaml.tmpl`

### 2.7 CI pipeline exists and runs on every push — `[DevEx]` — high
**What to check:** `.github/workflows/*.yml`, `.gitlab-ci.yml`, `Jenkinsfile`. Trigger is `push` or `pull_request`, not manual.
**Present means:** final safety net.
**Absent means:** regressions land silently.

### 2.8 CI wall-clock < 10 minutes — `[DevEx]` — medium
**What to check:** CI workflow log durations. If unavailable, infer from number of jobs/steps.
**Present means:** agents get feedback within one coffee break.
**Absent means:** batching, context loss, skipped feedback cycles.

### 2.9 Tests are deterministic — `[AgentEx]` — high
**What to check:** grep tests for `sleep`, `time.sleep`, `setTimeout` without mocking, network calls without mocking, hardcoded dates/IPs.
**Present means:** agents trust test results.
**Absent means:** flaky tests train agents to ignore failures.

### 2.10 Runnable examples — `[AgentEx]` — medium
**What to check:** `examples/`, `samples/`, or quickstart in README with copy-paste-runnable code.
**Present means:** agents verify their understanding before writing code.
**Absent means:** more exploration, more flail.

### 2.11 Custom error messages optimized for agents — `[AgentEx]` — low
**What to check:** custom linter/test errors include fix hints, not just diagnostics.
**Present means:** agents self-correct without human intervention.
**Citation:** Spotify Engineering, "Feedback loops for background coding agents" — custom linter messages optimized for LLM consumption.

---

## 3. Tool access & scaffolding

### 3.1 `.mcp.json` with ≥1 MCP server — `[AgentEx]` — medium
**What to check:** file exists at root or in `.claude/`; contains at least one `mcpServers` entry.
**Present means:** agents can reach external tools (GitHub, DBs, docs) without shell workarounds.
**Absent means:** agents fall back to Bash and invent URLs.

### 3.2 `.claude/settings.json` or `.claude/settings.local.json` — `[AgentEx]` — medium
**What to check:** file exists; contains `permissions` or `hooks` config.
**Present means:** agent permissions are intentional, not ambient.
**Absent means:** either everything is permitted or everything prompts — both are friction.

### 3.3 `.claude/hooks/` directory — `[AgentEx]` — low
**What to check:** directory exists with at least one executable hook script.
**Present means:** repo-specific automation fires automatically (lint on edit, format on save).
**Absent means:** missed automation opportunities.

### 3.4 `.claude/skills/` directory — `[AgentEx]` — low
**What to check:** directory exists with at least one `SKILL.md`.
**Present means:** repo-specific skills (e.g. "deploy-preview", "run-migrations") are co-located.
**Absent means:** tribal operational knowledge.

### 3.5 `.claude/agents/` for subagents — `[AgentEx]` — low
**What to check:** directory exists with subagent definitions.
**Present means:** specialized subagents (test-runner, code-reviewer) are reusable.
**Absent means:** every session re-invents the prompt.

### 3.6 `.claude/commands/` for slash commands — `[AgentEx]` — low
**What to check:** directory exists with markdown command files.
**Present means:** common workflows are one keystroke.
**Absent means:** repeated typing, repeated mistakes.

### 3.7 Makefile or justfile with phony targets — `[AgentEx+DevEx]` — high
**What to check:** `Makefile` or `justfile` exists with targets like `test`, `build`, `lint`, `check`.
**Present means:** agents discover the task graph in one file.
**Absent means:** agents scroll README, package.json scripts, Dockerfile, and CI config looking for the right incantation.

### 3.8 Idempotent startup script — `[AgentEx+DevEx]` — medium
**What to check:** `startup.sh`, `./scripts/dev.sh`, `docker-compose up` or other documented command. Running twice should not error.
**Present means:** agents can spin the dev environment up without reading docs.
**Absent means:** agents ask the human to start the dev server.

### 3.9 `stop.sh` or documented shutdown — `[DevEx]` — low
**What to check:** `stop.sh` or documented kill command. Otherwise agents `fuser -k PORT/tcp`.
**Present means:** clean teardown without port leaks.

### 3.10 CLI tools documented — `[AgentEx]` — low
**What to check:** AGENTS.md mentions which external CLIs are expected (`gh`, `aws`, `kubectl`, `docker`).
**Present means:** agents don't invent commands for tools the harness lacks.

---

## 4. Guardrails & safety

### 4.1 `.gitignore` excludes secrets — `[AgentEx+DevEx]` — critical
**What to check:** `.gitignore` contains `.env`, `.env.local`, `secrets/`, `*.pem`, `*.key`.
**Present means:** agents can't accidentally commit credentials.
**Absent means:** one bad session away from a leak.

### 4.2 `.env.example` exists and is complete — `[AgentEx+DevEx]` — high
**What to check:** `.env.example` exists; every env var referenced in code has an entry with a comment.
**Present means:** agents know exactly which env vars to set and why.
**Absent means:** agents guess env var names or hardcode fallbacks.
**Fix template:** `templates/env.example.tmpl`

### 4.3 `.aiignore` or tool-specific ignore — `[AgentEx]` — medium
**What to check:** `.aiignore`, `.cursorignore`, or equivalent. Should exclude `node_modules/`, `*.lock`, `dist/`, generated files, and any sensitive paths.
**Present means:** agents don't waste context on machine-generated files.
**Absent means:** agents read `package-lock.json`.

### 4.4 Pre-commit secret scanning — `[AgentEx+DevEx]` — high
**What to check:** `.pre-commit-config.yaml` includes `gitleaks`, `detect-secrets`, or similar.
**Present means:** credentials can't pass the pre-commit gate.

### 4.5 CI secret scanning — `[DevEx]` — medium
**What to check:** CI workflow includes a secret-scanning job, or GitHub Advanced Security is enabled (out of band).

### 4.6 Branch protection documented — `[DevEx]` — low
**What to check:** CONTRIBUTING.md or README mentions protected branches and required reviews.
**Present means:** agents can't force-push to main.
**Absent means:** relies on ambient GitHub config (non-auditable from the repo).

### 4.7 "Don't touch" boundaries documented — `[AgentEx]` — high
**What to check:** AGENTS.md has a section like "files agents should not modify" (generated code, migrations, vendored deps, legal notices).
**Present means:** agents stay out of landmine areas.
**Absent means:** agents routinely rewrite files that should be read-only.

### 4.8 Required env validation at boot — `[DevEx]` — medium
**What to check:** main entry point asserts required env vars before starting work (not deep in a handler).
**Present means:** missing config fails loudly at startup.
**Absent means:** cryptic NPE deep in a scheduler job.

### 4.9 Dangerous-command allowlist in `.claude/settings.json` — `[AgentEx]` — medium
**What to check:** `permissions.allow` and `permissions.deny` are explicit.
**Present means:** `rm -rf`, `git push --force`, DB drops require confirmation.

### 4.10 Backup/rollback story — `[DevEx]` — low
**What to check:** README or runbook documents how to roll back a deploy, restore a DB.
**Present means:** failures are recoverable.

---

## 5. Code architecture & navigability

### 5.1 Clear single entry point per app — `[AgentEx+DevEx]` — high
**What to check:** one obvious `main.py`, `index.ts`, `cmd/foo/main.go` per executable. Referenced in AGENTS.md.
**Present means:** agents start reading from the right file.
**Absent means:** agents guess from directory names.

### 5.2 No file > 500 lines that agents edit regularly — `[AgentEx]` — critical
**What to check:** Bash `find ... -name '*.py' -o -name '*.ts' | xargs wc -l | sort -rn | head`. Flag any routinely-edited file > 500 lines.
**Present means:** one file ≈ one concept ≈ one mental load.
**Absent means:** 2–8k tokens wasted per feature reading a monolith (see stocked's `api/main.py` pre-split).

### 5.3 Modular package structure — `[AgentEx+DevEx]` — high
**What to check:** routers, handlers, models split per domain (not mixed in one file).
**Present means:** feature work touches 2–4 files, not 20.

### 5.4 Consistent naming conventions — `[AgentEx]` — medium
**What to check:** camelCase vs snake_case consistency within a language; consistent file naming.
**Present means:** agents predict file names correctly.
**Absent means:** name-collision bugs, rename churn.

### 5.5 Typed interfaces at module boundaries — `[AgentEx]` — high
**What to check:** function signatures have types (Python: type hints; TS: interfaces; Go/Rust: inherent).
**Present means:** type checker catches contract violations.
**Absent means:** runtime errors that agents can't reproduce locally.

### 5.6 Lock files present and committed — `[DevEx]` — critical
**What to check:** `package-lock.json`, `pnpm-lock.yaml`, `poetry.lock`, `uv.lock`, `Cargo.lock`, `go.sum`.
**Present means:** reproducible installs.
**Absent means:** "works on my machine" hell.

### 5.7 Hot reload / dev mode configured — `[DevEx]` — medium
**What to check:** `npm run dev`, `uvicorn --reload`, `cargo watch`, etc.
**Present means:** sub-second feedback on code changes.

### 5.8 No hardcoded local IPs or paths — `[AgentEx+DevEx]` — high
**What to check:** grep for `10.0.0.`, `192.168.`, `/home/`, `/Users/` in source.
**Present means:** code runs anywhere (including agent sandboxes).
**Absent means:** silent skips, broken tests on any other machine. (Classic stocked bug: hardcoded `10.0.0.182` in Playwright tests.)

### 5.9 Test fixtures isolated from dev DB — `[AgentEx+DevEx]` — high
**What to check:** integration/e2e tests use an isolated DB (in-memory SQLite or per-test schema), not the shared dev database.
**Present means:** tests are repeatable.
**Absent means:** accumulating test state, strict-mode selector violations, flakes.

### 5.10 Single source of truth for config — `[DevEx]` — medium
**What to check:** config reading is centralized in one module, not scattered.
**Present means:** agents know where to add a new setting.

### 5.11 No duplicate onboarding docs — `[AgentEx]` — medium
**What to check:** AGENTS.md and CLAUDE.md should not duplicate content. README should not restate AGENTS.md. CLAUDE.md should only contain Claude specific details, and otherwise point to AGENTS.md
**Present means:** one source of truth.
**Absent means:** stale drift, contradictory instructions, wasted context.

---

## 6. Observability & evals

### 6.1 Structured logging — `[DevEx]` — medium
**What to check:** logging library configured (`structlog`, `pino`, `zap`), not bare `print`/`console.log`.
**Present means:** production issues are traceable.

### 6.2 Trace IDs threaded through requests — `[DevEx]` — low
**What to check:** middleware adds a request-id; logs include it.

### 6.3 Trace logs readable by agents — `[AgentEx]` — low
**What to check:** recent request/error logs are saved to a known path (e.g. `.worktree/logs/`) that agents can tail.
**Present means:** agents can diagnose their own failures.

### 6.4 `claude-trace` or equivalent installed — `[AgentEx]` — low
**What to check:** mention in README/CONTRIBUTING of a tool that captures Claude Code session traces.

### 6.5 Eval directory — `[AgentEx]` — medium (for AI-product repos)
**What to check:** `evals/` directory with test cases for LLM features.
**Present means:** LLM regressions are caught.
**N/A:** for non-AI repos.
**Citation:** Hamel Husain — "Start with manual trace analysis of 100+ conversations before writing evals."

### 6.6 Evals runnable via task runner — `[AgentEx]` — medium (for AI-product repos)
**What to check:** `make evals` or `npm run evals` exists.

### 6.7 Golden outputs / regression fixtures — `[AgentEx]` — medium (for AI-product repos)
**What to check:** `evals/fixtures/` or snapshot tests.

### 6.8 Cost/token tracking — `[AgentEx]` — low (for AI-product repos)
**What to check:** logging of LLM calls includes token counts and cost estimates.

### 6.9 Prompt registry or single source of truth — `[AgentEx]` — medium (for AI-product repos)
**What to check:** prompts live in one directory (`prompts/` or `src/prompts/`), not scattered as string literals.

---

## Appendix: category weightings

When deciding what to put in Tier 1 vs Tier 2, use these rough weights:

| Category | Weight on agent-pain-reduction |
|---|---|
| Context & documentation | ★★★★★ (highest — cognitive load is the primary DevEx dimension per Forsgren 2023) |
| Feedback loops for agents | ★★★★★ (tight second — agents without feedback flail) |
| Code architecture & navigability | ★★★★ (monoliths are a token tax on every session) |
| Guardrails & safety | ★★★ (critical but often pre-existing) |
| Tool access & scaffolding | ★★★ (high ceiling but low floor — nice to have, not critical) |
| Observability & evals | ★★ (important for mature products, Tier 3-4 for early-stage) |
