---
name: agentex-audit
description: Audit a repository for AgentEx (AI-agent ergonomics) and DevEx best practices. Produces a tiered, actionable recommendation report ordered by (agent-pain-reduction × cheapness-to-implement). Use when the user asks to audit, review, assess, check, or score a repo for agent-readiness, agent-friendliness, AgentEx, DevEx, or developer experience, or asks how to make a repo better for Claude, Cursor, or other AI coding agents.
---

# agentex-audit

## When to use this skill

- The user asks to "audit", "review", "assess", "score", or "grade" a repo for agent-readiness, AgentEx, or DevEx.
- The user asks how to make a repo "better for Claude / Cursor / agents" or wants recommendations to reduce agent flail and token waste.
- The user onboards to a new repo and wants a quick health check before their agents start working in it.
- The user just finished a feature and wants to know what scaffolding gaps showed up.

## What this skill does

Produces a tiered, narrative audit report modeled on the three DevEx dimensions (Forsgren/Storey/Noda 2023: feedback loops, cognitive load, flow state) and a six-category AgentEx taxonomy (context & documentation, feedback loops for agents, tool access & scaffolding, guardrails & safety, code architecture, observability & evals). Each finding is an actionable recommendation with **What / Why / How / Verify** and is tagged `[AgentEx]`, `[DevEx]`, or `[AgentEx+DevEx]`. The report is *not* a pass/fail checklist.

## Philosophy (read before auditing)

Every recommendation must explain **why** it matters for agent productivity, not just whether a signal is present. Tie each finding to at least one of:

- **Feedback loops** — how fast do agents learn they are wrong? (CI, tests, type checkers, linters, clear errors)
- **Cognitive load** — how many files must an agent read to make one change? (Forsgren: "developers with high codebase understanding feel 42% more productive")
- **Flow state / tool access** — can an agent proceed autonomously, or must it ask the human? (MCP, hooks, scripts, devcontainer, env.example)

Humble's guiding principle applies: *if it hurts, do it more frequently, and bring the pain forward.* A slow test suite or a 660-line monolith is not just unpleasant — it is actively hostile to agent iteration.

For the full framework discussion and thought-leader citations, read `reference/philosophy.md` when you need to ground a specific recommendation.

## Audit procedure

### Step 1 — Detect repo shape (parallel, cheap)

Issue these in a single tool-call batch (Glob + Read of small files only):

- `Glob`: `AGENTS.md`, `CLAUDE.md`, `README*`, `.claude/**/*`, `.github/**/*.yml`, `.mcp.json`, `.aiignore`, `.env.example`, `.devcontainer/*`, `pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`, `Makefile`, `justfile`, `.pre-commit-config.yaml`, `pnpm-workspace.yaml`, `turbo.json`, `nx.json`, `lerna.json`, `docs/**/*.md`, `llms.txt`, `CODEMAP.md`
- `Read`: only the root-level small files surfaced above (README, AGENTS.md, CLAUDE.md, CODEMAP.md, main manifest).

**Fast path:** if `bash` is available and the repo has >200 files, run `bash skills/agentex-audit/scripts/detect.sh <repo-root>` instead — it stat-checks ~65 paths in ~1s and prints a compact report. The script is strictly additive; you still need to Read the content of key docs afterward.

### Step 2 — Classify the repo

Using the detection output, determine:

- **Language/stack**: Python, TypeScript, Go, Rust, mixed, other.
- **Monorepo vs single package**: look for `pnpm-workspace.yaml`, `turbo.json`, `nx.json`, `lerna.json`, multiple `package.json`/`pyproject.toml`, `/packages/` or `/apps/` directories.
- **Application type**: library, service, CLI, webapp, data pipeline, infra.
- **Agent-adoption stage**: none → `.claude/` exists → full `.claude/{hooks,skills,agents,commands}` tree.

These four axes change **which signals are in scope and how to weight them**. A pre-product-market-fit prototype should not be audited for a high maturity workflow; a mature service absolutely should.

### Step 3 — Walk the signal catalog

Read `reference/signals.md`. For each of the six AgentEx categories, walk the signals in order and record: **PRESENT / PARTIAL / MISSING / N/A**, plus a one-sentence observation. Do not write the report yet.

Categories (details in `reference/signals.md`):

1. **Context & documentation** — AGENTS.md, CLAUDE.md, README quality, CODEMAP, ADRs, llms.txt, devcontainer
2. **Feedback loops for agents** — CI, test runner, test speed, linter, type checker, pre-commit, runnable examples
3. **Tool access & scaffolding** — .mcp.json, .claude/settings.json, hooks, skills, agents, commands, task runner
4. **Guardrails & safety** — .aiignore, .gitignore sanity, .env.example, secret scanning, branch protection, "don't touch" boundaries
5. **Code architecture & navigability** — entry points, file sizes, modular structure, naming consistency, lock files
6. **Observability & evals** — structured logging, trace IDs, eval framework, golden outputs

### Step 4 — Tier the findings

Every gap becomes a recommendation. Assign each to one tier, ordered within the tier by cheapness:

- **Tier 1 — Quick wins** (<30 min, unblocks every future session)
- **Tier 2 — High-value** (hours, cuts token waste / cognitive load substantially)
- **Tier 3 — Strategic** (days, architectural improvements)
- **Tier 4 — Not recommended right now** (explicit deprioritization — premature scaffolding is itself a DevEx tax)

Order by **(agent-pain-reduction × cheapness-to-implement)**. Tier 4 is load-bearing: telling the user *not* to do something (yet) is as valuable as telling them what to do.

### Step 5 — Render the report

Use the template in `reference/output-format.md`. Each recommendation MUST include **What / Why / How / Verify**. Tag each with `[AgentEx]`, `[DevEx]`, or `[AgentEx+DevEx]`. Interleave — do not separate into two reports; ~70% of signals overlap.

**Save destination:**
1. If `docs/` exists → write to `docs/agentex-audit-YYYY-MM.md`
2. Else if `.claude/` exists → write to `.claude/audits/agentex-audit-YYYY-MM.md`
3. Else → stream to the conversation and ask where to save

**Always** also print a 5–10 line headline summary to the conversation (overall maturity band, top friction, highest-leverage Tier 1 item) so the human sees the punch line even when the full report is written to disk.

## Context-efficiency rules

- **Hard cap: ~30 file Reads total.** If the repo genuinely demands more to understand, *that is itself a Tier 1 finding* ("codebase lacks CODEMAP/orientation — agents must read N files to make one change").
- Never `cat` whole source files. Use Grep for content probes and `wc -l` via Bash for size probes.
- Read only: root-level config/docs, `.claude/*`, `.github/*`, `docs/*`, manifests, and small files surfaced by Step 1.
- **Do not re-read files already loaded in Step 1.**
- Progressive disclosure: load `reference/signals.md` only at Step 3, `reference/philosophy.md` only when citing a reason in a recommendation, `reference/output-format.md` only at Step 5, templates only on user consent.

## Monorepo handling

If Step 2 detected a monorepo, run the audit **once** at the repo root, then a lightweight pass per top-level package. Workspace-wide findings go under a `## Workspace-wide` section; per-package findings go under `### <package-name>` subsections. Do not duplicate the signal report per package.

## Templates

When a recommendation says "create AGENTS.md" or "create CODEMAP.md", offer to scaffold from the matching file in `templates/`. **Do NOT auto-write templates — ask first.** Templates are intentionally generic; customize to the repo's stack and domain before writing.

## Anti-patterns (do NOT do these)

- **Do not produce a pass/fail checklist.** Produce a tiered narrative.
- **Do not recommend Alembic / full CI / observability boilerplate for pre-PMF repos.** Premature scaffolding is itself a DevEx tax. Put those items in Tier 4 with an explicit rationale.
- **Do not copy the full signal catalog into the output.** The output is the *recommendations*, not the inspection log.
- **Do not write findings to disk silently.** If the destination is ambiguous, ask.
- **Do not re-read files already loaded during detection.**
- **Do not score on a 0–10 scale.** Use narrative maturity bands: *early / developing / solid / advanced*.
- **Do not separate AgentEx and DevEx into two sections.** Interleave with tags — the overlap is ~70%.
