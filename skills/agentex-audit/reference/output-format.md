# Output format

The report template the `agentex-audit` skill renders at Step 5. Load this file only when you reach Step 5; do not load it earlier.

The format is modeled on the gold-standard manual audit this skill emulates — tiered, narrative, `[lived]`-tagged, with per-tier verification and a token-efficiency table.

---

## Report template

```markdown
# AgentEx & DevEx Audit — <repo-name>

*Generated YYYY-MM-DD by the `agentex-audit` skill.*

## Headline

- **Overall AgentEx maturity:** <early | developing | solid | advanced>
- **Top friction:** <one sentence — the biggest agent-pain>
- **Highest-leverage fix:** <one sentence — points at a specific Tier 1 item>

## Context

<2-4 sentences: what the repo is, its stack, its monorepo shape,
its agent-adoption stage. Do NOT restate the README — this is the
auditor's read, not the README's pitch.>

## What's working well (keep)

- <3-7 bullets — signals that are already correct and should NOT regress>
- <Each bullet is one line; cite the file or config that shows the signal>
- <This section is NOT filler: it prevents recommendations from accidentally
  undoing good patterns.>

## Findings

<Numbered friction points, each 2-6 lines. Mark items the auditor
*literally hit* during the audit with [lived]. Each finding ties to
one or more DevEx dimensions or AgentEx categories.>

1. **<Finding title>** [AgentEx | DevEx | AgentEx+DevEx] [lived?]
   <2-4 sentences describing the friction with specific file paths
   and line numbers. Cite the tokens-per-session cost where possible.>

2. **<Finding title>** ...

<~6-12 findings is the sweet spot. Fewer means the audit is thin;
more means the signal is getting lost in the noise.>

## Recommendations

Ordered by (agent-pain-reduction × cheapness-to-implement). Pick from the top.

### Tier 1 — Quick wins (< 30 min each, unblock every future session)

**1.1 <Title>** [AgentEx | DevEx | AgentEx+DevEx]
- **What:** <one-sentence concrete action>
- **Why:** <ties to feedback loops / cognitive load / flow state;
  cite token or time cost where possible>
- **How:** <exact file paths, edits, template references, commands>
- **Verify:** <observable test — "run X, expect Y">

**1.2 <Title>** ...

### Tier 2 — High-value (hours, cuts token waste / cognitive load)

**2.1 <Title>** ...

### Tier 3 — Strategic (days, architectural improvements)

**3.1 <Title>** ...

### Tier 4 — Not recommended right now

- **<Thing the repo conspicuously lacks>** — explicit rationale for why
  adding it *now* would be premature scaffolding. Examples: full CI when
  tests run locally in <10s; Alembic migrations when the schema is still
  churning weekly; observability stack for a prototype.

## Token-efficiency quick wins

If you only do the *cheapest* items in Tier 1, the token savings per
future agent session are roughly:

| Change | Tokens saved per session (est.) | Why |
|---|---|---|
| <fix 1> | 2-5k | <why> |
| <fix 2> | 1-3k | <why> |
| ... | ... | ... |

**Total realistic saving per future feature session: ~X-Yk tokens.**

## Critical files referenced

- `<absolute path>` — <what should change>
- `<absolute path>` — <what should change>
- *(new)* `<absolute path>` — <what should be created>

## Verification plan

Concrete checks after each tier:

**After Tier 1:**
1. <Observable check>
2. <Observable check>

**After Tier 2:**
1. <Observable check>
2. <Observable check>

**After Tier 3:**
1. <Observable check>

**How to sanity-check the "reduced flail" goal:**
<Time or token-count the next feature handed to an agent against a
pre-audit baseline. A well-executed Tier 1 + Tier 2 should cut total
tokens by ~20-30% for comparable-scope features.>
```

---

## Worked example

A hypothetical Python/FastAPI service named `bookshelf`, early-stage, one engineer plus one Claude Code agent.

```markdown
# AgentEx & DevEx Audit — bookshelf

*Generated 2026-04-11 by the `agentex-audit` skill.*

## Headline

- **Overall AgentEx maturity:** developing
- **Top friction:** No CODEMAP and a 540-line `api/main.py` mean agents
  re-read the monolith every session to find where to add a route.
- **Highest-leverage fix:** Add a 50-line `CODEMAP.md` with a
  "where to add X" table (Tier 1.1 below). Saves ~3k tokens per session.

## Context

`bookshelf` is a single-package FastAPI service (Python 3.12, SQLAlchemy,
Postgres) with a small test suite and no frontend. It has a README and a
minimal AGENTS.md but no CLAUDE.md, no `.claude/` tree, and no CI. The
agent-adoption stage is "early — user runs Claude Code locally but has no
repo-specific scaffolding."

## What's working well (keep)

- `pyproject.toml` with Ruff + Mypy configured — fast feedback on style
  and types.
- `tests/conftest.py` uses in-memory SQLite per test — proper isolation,
  deterministic.
- `.env.example` is complete and commented.
- `Makefile` with `make test`, `make lint`, `make run` — discoverable
  task graph in one file.
- `uv.lock` committed — reproducible installs.

## Findings

1. **No CODEMAP** [AgentEx] [lived]
   Finding where to add a new `/books/{id}/reviews` route required
   reading `api/main.py` (540 lines), `api/models.py` (220 lines), and
   grepping for "router" across the repo. ~4k tokens of exploration
   before the first useful edit.

2. **`api/main.py` is a 540-line monolith** [AgentEx+DevEx] [lived]
   All routes, middleware, scheduler setup, and Pydantic schemas in
   one file. Agents must scroll the whole file to avoid naming
   collisions. Straining already: there are two `from datetime import
   date` imports mid-file.

3. **AGENTS.md exists but is thin** [AgentEx]
   13 lines, covers "run tests" and "run server." Missing: project
   structure, code style, git workflow, testing expectations, and
   "where to add X." GitHub's 2,500-repo analysis calls these the
   six top-tier areas.

4. **No pre-commit hooks** [AgentEx+DevEx]
   Mypy and Ruff run only in `make lint`, never automatically. Two
   recent commits landed type errors that the agent didn't catch.

5. **No CI** [DevEx]
   No `.github/workflows/`. Currently relies on the human running
   `make test` manually before merging. Works at 1 engineer, breaks
   at 2.

6. **No `.claude/settings.json`** [AgentEx]
   Claude Code runs with ambient permissions. No explicit allow/deny
   list, no hooks, no skills.

7. **Hardcoded `localhost:5432` in `api/db.py`** [AgentEx+DevEx]
   Breaks in devcontainer and CI. Should read `DATABASE_URL`.

## Recommendations

Ordered by (agent-pain-reduction × cheapness-to-implement).

### Tier 1 — Quick wins

**1.1 Add `CODEMAP.md` at repo root** [AgentEx+DevEx]
- **What:** ~50-line orientation doc with directory tree, "where to add X"
  table, and endpoint index.
- **Why:** Finding #1 costs ~4k tokens per session. CODEMAP cuts that to
  ~200 tokens (one file read of a small doc).
- **How:** Scaffold from `templates/CODEMAP.md.tmpl`. Fill in the
  directory tree, add rows for "new route → `api/routers/<domain>.py`"
  (once 1.3 is done), "new model → `api/models/<domain>.py`", "new test
  → `tests/test_<domain>.py`". Link it from AGENTS.md as the first thing
  an agent should read.
- **Verify:** Ask a fresh Claude session "where do I add a new review
  route?" Expected: one-line answer from CODEMAP, no grep.

**1.2 Expand AGENTS.md to the six top-tier sections** [AgentEx]
- **What:** Add sections for project structure, code style, git workflow,
  testing expectations, and agent accessibility. Include the literal
  commands in backticks: `` `make test` ``, `` `make lint` ``,
  `` `uvicorn api.main:app --reload` ``.
- **Why:** Finding #3. Agents currently guess commands and conventions.
- **How:** Scaffold from `templates/AGENTS.md.tmpl`. Preserve the existing
  13 lines as the "project overview" section.
- **Verify:** `wc -l AGENTS.md` > 60 and all six sections present.

**1.3 Fix hardcoded DB host** [AgentEx+DevEx]
- **What:** Replace `"localhost:5432"` in `api/db.py:14` with
  `os.environ["DATABASE_URL"]`. Add `DATABASE_URL` to `.env.example`.
- **Why:** Finding #7. Breaks any environment that isn't the maintainer's
  laptop.
- **How:** One-line edit + `.env.example` update.
- **Verify:** Run the app in a container with `DATABASE_URL` set;
  unset it and expect a loud startup error, not a silent fallback.

**1.4 Add minimal `.claude/settings.json`** [AgentEx]
- **What:** Create `.claude/settings.json` with explicit `permissions.allow`
  for `make *`, `pytest`, `uv run`, `git status`/`git diff`.
- **Why:** Finding #6. Ambient permissions mean every new Bash command
  prompts — friction that breaks flow.
- **How:** ~15 lines of JSON.
- **Verify:** Start a fresh Claude session; run `make test`; expect no
  permission prompt.

### Tier 2 — High-value

**2.1 Split `api/main.py` into routers** [AgentEx+DevEx]
- **What:** Create `api/routers/` package with one file per domain
  (`books.py`, `reviews.py`, `users.py`, `health.py`). `api/main.py`
  becomes ~80 lines of app creation + `include_router` calls.
- **Why:** Finding #2. Typical feature work drops from reading 540 lines
  to reading ~100 lines. Estimated savings: 3-8k tokens per session.
- **How:** Standard FastAPI router pattern. Keep existing tests green
  (paths don't change).
- **Verify:** `wc -l api/main.py` < 100, each router < 200, full test
  suite green.

**2.2 Add pre-commit hooks** [AgentEx+DevEx]
- **What:** `.pre-commit-config.yaml` running Ruff, Mypy, and
  detect-secrets on commit.
- **Why:** Finding #4. Shifts feedback left; agents can't accidentally
  commit type errors.
- **How:** Scaffold from `templates/precommit-config.yaml.tmpl`.
  Install: `uv run pre-commit install`.
- **Verify:** Introduce a deliberate type error and try to commit;
  expect the hook to block.

**2.3 Add minimal CI** [DevEx]
- **What:** One `.github/workflows/ci.yml` that runs `make test` and
  `make lint` on push.
- **Why:** Finding #5. Cheap insurance. Scales past 1 engineer.
- **How:** 30-line workflow.
- **Verify:** Push a branch; expect the workflow to run and go green.

### Tier 3 — Strategic

**3.1 Add a devcontainer**
- **What:** `.devcontainer/devcontainer.json` pointing at a Python 3.12
  image with `uv` and the system deps pre-installed.
- **Why:** Makes agent sandboxes, Codespaces, and the maintainer's laptop
  identical.
- **How:** Standard Python devcontainer base + one post-create command
  (`uv sync`).
- **Verify:** "Reopen in Container" in VS Code gives a working shell
  where `make test` passes.

### Tier 4 — Not recommended right now

- **Alembic migrations.** Schema is churning weekly; `create_all()` at
  startup is fine. Add Alembic once the schema stabilizes — adding it
  now is pure overhead.
- **Observability stack (OTel, Prometheus, Grafana).** Too early.
  Structured logging with request IDs is enough at this stage.
- **Evals directory.** `bookshelf` has no LLM features yet. Irrelevant.

## Token-efficiency quick wins

| Change | Tokens saved per session (est.) | Why |
|---|---|---|
| CODEMAP.md | 2-5k | Agent skips "where does X live" grep/read |
| Split main.py into routers | 3-8k | Reads a 150-line router, not 540-line monolith |
| Expand AGENTS.md | 1-3k | No more command-guessing |
| Fix hardcoded DB host | 0-2k | Skips debugging container startup |

**Total realistic saving per future feature session: ~6-18k tokens.**
On a 200k context window that's 3-9% recovered every session.

## Critical files referenced

- `/bookshelf/AGENTS.md` — expand to six sections
- `/bookshelf/api/main.py:1-540` — split into routers
- `/bookshelf/api/db.py:14` — kill hardcoded host
- *(new)* `/bookshelf/CODEMAP.md`
- *(new)* `/bookshelf/api/routers/`
- *(new)* `/bookshelf/.claude/settings.json`
- *(new)* `/bookshelf/.pre-commit-config.yaml`
- *(new)* `/bookshelf/.github/workflows/ci.yml`

## Verification plan

**After Tier 1:**
1. Fresh Claude session in the repo: "where do I add a book review
   route?" → expect a one-line answer from CODEMAP.
2. `wc -l AGENTS.md` > 60.
3. App starts in a devcontainer with `DATABASE_URL` set.
4. `make test` in a fresh session runs without permission prompts.

**After Tier 2:**
1. `wc -l api/main.py` < 100; each router < 200.
2. Full test suite green (no regressions).
3. Deliberate type error blocks commit.
4. CI workflow runs green on push.

**After Tier 3:**
1. Devcontainer reopen → working shell → `make test` passes.

**How to sanity-check "reduced flail":**
Hand the next feature (e.g., "add book series support") to a fresh
Claude session; compare token count to the last comparable feature.
Well-executed Tier 1 + Tier 2 should cut total tokens ~20-30%.
```

---

## Notes on the example

- **Findings and recommendations are linked.** Each Tier item references a finding number. This keeps the narrative tight.
- **Tiers are ordered by ROI, not by severity.** Tier 1 is "cheap and high-impact," not "most critical." A critical-severity item that takes a week goes in Tier 3, not Tier 1.
- **Tier 4 is load-bearing.** Telling the user *not* to do something is valuable signal; it prevents them from chasing premature scaffolding.
- **Token-efficiency table is optional but recommended.** It makes the ROI case quantitative, which helps users prioritize among competing Tier 1 items.
- **`[lived]` tags only appear when the auditor literally hit the friction.** For a cold audit (no prior session), they may be absent — that's fine. When present, they carry extra weight.
