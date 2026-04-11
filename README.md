# skills

A collection of Claude skills. Each skill is a self-contained directory under `skills/` containing a `SKILL.md` plus any bundled reference docs, templates, or helper scripts the skill progressively discloses.

## Installing a skill

Claude Code loads skills from two locations:

- **User-global:** `~/.claude/skills/<skill-name>/` — available in every session on that machine.
- **Per-project:** `.claude/skills/<skill-name>/` inside a repo — available only when Claude is running in that repo.

To install a skill from this repository, copy its directory into one of those locations:

```bash
# user-global install
cp -r skills/agentex-audit ~/.claude/skills/

# per-project install (run from the target repo root)
mkdir -p .claude/skills
cp -r /path/to/skills/skills/agentex-audit .claude/skills/
```

Claude picks up the skill on the next session start. Invoke it by asking Claude to do what the skill's `description` field advertises (e.g. "audit this repo for agent experience") or with an explicit `/<skill-name>` slash command if your harness supports it.

## Skills in this repo

| Skill | What it does |
|---|---|
| [`agentex-audit`](./skills/agentex-audit/) | Audits any repo for AgentEx (AI-agent ergonomics) and DevEx best practices. Produces a tiered, actionable recommendation report modeled on Forsgren/Humble/Kim DevEx research and emerging AgentEx patterns (AGENTS.md, CLAUDE.md, MCP, guardrails, feedback loops). |

## Authoring a new skill

See [CONTRIBUTING.md](./CONTRIBUTING.md) for conventions (directory layout, `SKILL.md` frontmatter, progressive disclosure patterns, bundled scripts and templates).
