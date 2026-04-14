# Philosophy

The research foundations and guiding principles the `agentex-audit` skill applies. Load this file when you need to ground a specific recommendation in a thought-leader quote or research finding.

---

## The three DevEx dimensions (Forsgren / Storey / Noda, 2023)

From *DevEx: What Actually Drives Productivity* (Forsgren, Storey, Noda, Greiler, Houck — ACM Queue, 2023). The paper identifies three sociotechnical dimensions that directly drive developer productivity. These are the **primary lens** for the audit:

### Feedback loops

**Principle:** *Agents cannot learn they are wrong faster than the slowest feedback loop in their environment.*

> "Fast feedback loops allow developers to complete their work quickly with minimal friction. Slow feedback loops interrupt the development process, leading to frustration and delays as developers wait or decide to switch tasks."
> — Forsgren et al., ACM Queue 2023

Auditable signals: CI duration, test suite speed, linter/type-checker speed, hot reload, code review SLA. A slow CI isn't just unpleasant — it forces agents to batch changes, which produces larger diffs, which produce more review overhead, which slows the next loop. The damage compounds.

### Cognitive load

**Principle:** *Every file an agent must read to make one change is a tax on every future session.*

> "Developers who report a high degree of understanding of their codebase feel 42% more productive than those with low understanding."
> — Forsgren et al., ACM Queue 2023

This is the single most cited statistic in DevEx research, and it maps directly onto AgentEx: an agent with no CODEMAP, no AGENTS.md, and a 660-line monolith must reconstruct the codebase from scratch *every session*. Cognitive load is primary — if you can only fix one thing, fix this.

### Flow state

**Principle:** *If the agent has to ask the human, flow has already broken.*

Agents don't literally experience flow, but the repo either supports autonomous iteration or it doesn't. A missing `.env.example`, an undocumented startup script, or a hardcoded IP is an interruption point — every interruption forces the agent to escalate to the human, and the cost of that context switch is high for both parties.

---

## DORA: lead time is the key metric

**Principle:** *Measure throughput and stability together; optimize for lead time.*

> "Lead Time — the total time between the request from the business to the functionality deployed and available in production to the customer — is the key metric."
> — Gene Kim, *The DevOps Handbook*

> "In order to maximize flow, we need to make work visible, reduce our batch sizes and intervals of work, build in quality by preventing defects from being passed to downstream work centers."
> — Gene Kim, *The Three Ways of DevOps*

The four DORA metrics (deployment frequency, lead time for changes, change failure rate, time to restore) are the outcomes. The DevEx dimensions above are the leading indicators. When auditing, cite DORA for *why* the improvement matters at the organizational level; cite DevEx for *what* to actually change in the repo.

---

## Humble: bring the pain forward

**Principle:** *If a task hurts, automate it; if it hurts to automate, automate it anyway — the pain compounds if you don't.*

> "If it hurts, do it more frequently, and bring the pain forward."
> — Jez Humble, *Continuous Delivery*

This is the single most generative principle in DevOps thinking. Applied to AgentEx: the fact that agents *routinely hit* a rough edge (hardcoded IPs, monolithic files, missing test DB, `bd close` warnings) is itself the signal. The audit should surface lived friction — anything an agent stumbled on during the session that generated the audit is high-value to fix, regardless of abstract severity.

Tag such findings with `[lived]` in the report so the user can see which recommendations came from actual pain and which came from the catalog.

---

## SPACE: never trust a single metric

**Principle:** *Productivity cannot be reduced to one number. Audits that score on a single 0-10 scale lie.*

> "It's tempting to use a single metric to measure productivity, but this approach is misleading. Productivity is multidimensional, and a single metric obscures trade-offs."
> — Forsgren, Storey, Maddila, Zimmermann, Houck, Butler, *The SPACE of Developer Productivity*, ACM Queue 2021

SPACE stands for Satisfaction, Performance, Activity, Communication, Collaboration, Efficiency. The takeaway for our audit: use narrative maturity bands (*early / developing / solid / advanced*), not numerical scores. A 7/10 with no context is meaningless; "solid on feedback loops, early on observability" is actionable.

---

## Willison: Red/Green TDD as an agent lever

**Principle:** *Write the failing test first; let the agent make it pass. Tests are context, not just verification.*

> "The central challenge of agentic engineering is that the cost to churn out initial working code has dropped to almost nothing... Agentic Engineering represents professional software engineers using coding agents to improve and accelerate their work by amplifying their existing expertise."
> — Simon Willison, *Agentic Engineering Patterns*

Willison's three named patterns:
1. **Red/Green TDD** — test first guides agent code generation; the test *is* the spec.
2. **Templates** — reduce variation so agents don't reinvent conventions.
3. **Hoarding** — document domain expertise explicitly so agents inherit it.

All three map to auditable signals: deterministic test suite, templates directory, AGENTS.md quality.

---

## Osmani: the 70% problem

**Principle:** *Agents get you to 70%. The last 30% requires real engineering discipline. The repo must support both halves.*

> "The final 30% — the part that makes software production-ready, maintainable, and robust — still requires real engineering knowledge. AI-assisted engineering is a more structured approach that combines the creativity of vibe coding with the rigor of traditional engineering practices."
> — Addy Osmani, *Beyond Vibe Coding*

Implication for the audit: don't just reward repos that *let agents ship fast*; reward repos that *let agents ship safely*. Pre-commit hooks, type checkers, strict test isolation, and guardrails aren't speed bumps — they are the 30% that turns vibe-coded features into production code.

---

## Husain: evals, not vibes

**Principle:** *For AI-product repos, manual trace analysis precedes eval-writing. Read 100 real conversations before measuring anything.*

> "Starting with error analysis by manually reviewing real user traces to uncover upstream issues and patterns before writing evals... Following a 4-step eval process that starts by manually labeling 100+ AI conversations."
> — Hamel Husain, *LLM Evals: Everything You Need to Know*

When auditing AI-product repos, look for evidence that the team has read their own traces. `evals/` without a corresponding `evals/traces/` or trace-review habit is premature optimization — the eval is only as good as the error analysis behind it.

---

## Spotify: the feedback loop *is* the product

**Principle:** *For agent-assisted engineering, the feedback loop is not support infrastructure — it is the primary deliverable.*

> "The feedback loop is the product, not the agent. Agentic systems require feedback loops that connect incident detection, diagnosis, and design refinement."
> — Spotify Engineering, *Feedback Loops for Background Coding Agents*

Concrete pattern from Spotify: **custom linter messages optimized for LLM consumption** — error messages should include explicit self-correction instructions, not just diagnostics. Audit for this in any repo that runs background agents unsupervised.

---

## Claude Code docs: context is the scarce resource

**Principle:** *Every file an agent reads without using is a waste. The audit must itself be context-efficient.*

> "Claude's context window is the most important resource to manage. Most best practices are based on one constraint: Claude's context window fills up fast, and performance degrades as it fills."
> — Claude Code Best Practices

Three concrete rules the docs emphasize, all of which the audit applies to itself:
1. **Give Claude ways to verify work** (tests, screenshots, expected outputs).
2. **Explore first, then plan, then code** — separate research from execution.
3. **Keep CLAUDE.md under 200 lines**; start small and grow based on actual mistakes.

The audit's hard cap of ~30 file reads is a direct application of this principle. If the audit itself *needs* more reads, that failure is a Tier 1 finding in the target repo.

---

## The "pit of success" principle

**Principle:** *The right thing must be the easiest thing. Agents fall down the slope of least resistance.*

> "Customers should simply fall into winning practices by using a platform... leading developers to write great, high performance code such that developers just fall into doing the right thing."

Applied to AgentEx: if the agent's shortest path to "done" routes through a monolith, it will edit the monolith. If the shortest path to running tests is through an undocumented command, it will skip the tests. Design the repo so the right thing is also the cheapest thing.

---

## Summary: principles → audit rules

| Principle | Audit behavior |
|---|---|
| Cognitive load is primary (Forsgren) | Tier 1 almost always includes a doc/orientation finding |
| Bring the pain forward (Humble) | Tag `[lived]` friction; surface even "small" annoyances |
| Never a single score (SPACE) | Use narrative maturity bands, not 0-10 |
| Lead time is the key metric (Kim) | Prefer feedback-loop fixes over one-off checklist items |
| Red/Green + Templates + Hoarding (Willison) | Reward deterministic tests, templates/, AGENTS.md depth |
| 70% problem (Osmani) | Weight guardrails and type-safety; don't just reward speed |
| Read 100 traces first (Husain) | For AI repos, audit whether traces are saved and reviewed |
| Feedback loop = product (Spotify) | Reward LLM-optimized error messages |
| Context is scarce (Claude Code) | Self-cap at ~30 file reads; treat your own flail as a finding |
| Pit of success | Ask: "is the right thing also the cheapest thing here?" |
