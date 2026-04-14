# Contributing a skill

Skills in this repo follow a small set of conventions so Claude Code (and other agent harnesses) can load them consistently and so authors can compose them with minimal ceremony.

## Directory layout

```
skills/
  <skill-name>/              # kebab-case, matches the `name` field in SKILL.md
    SKILL.md                 # required — entry point
    reference/               # optional — progressive-disclosure docs
      *.md
    templates/               # optional — files the skill can scaffold
      *.tmpl
    scripts/                 # optional — helper scripts invoked by the skill
      *.sh
```

Flat `skills/<name>/` — no category subdirectories. Nested categories make skills harder to find and duplicate what the `description` field already expresses.

## `SKILL.md` conventions

### Frontmatter (required)

```yaml
---
name: my-skill
description: One-to-three sentences that describe what the skill does AND list trigger synonyms ("audit", "review", "assess") so Claude's skill matcher fires on varied user phrasing.
---
```

Only `name` and `description` are required. They are the two fields Claude Code's skill loader reads reliably. `description` is the skill's *trigger surface* — pack it with synonyms and explicit use cases. It is the single highest-leverage line in the file.

### Body length

Target **≤ 200 lines** for the body. The body is loaded into context on every skill invocation; long bodies waste tokens. Put detailed reference material in `reference/` and instruct Claude when to load it.

### Body structure (recommended)

```markdown
# <skill-name>

## When to use this skill
<bullets: explicit user intents that should activate it>

## What this skill does
<one paragraph: the concrete deliverable>

## Procedure
<ordered steps — the actual instructions Claude follows>

## Anti-patterns
<things the skill must NOT do, stated explicitly>
```

Not all skills need every section, but every skill should at minimum answer *when to use it*, *what it produces*, and *how to produce it*.

## Progressive disclosure

Large reference docs and templates live under `reference/` and `templates/` and are only loaded when the procedure explicitly instructs Claude to read them. Reference them by relative path:

```markdown
For the full signal catalog, read `reference/signals.md`. Do this AFTER
step 1 detection, not before.
```

Explicit "read this file now" instructions are more portable than `@path/to/file` syntax, which is not universally supported across harnesses.

## Bundled scripts

Put helper scripts under `scripts/`. Prefer pure Bash + coreutils so the skill runs in any environment. Mark scripts executable (`chmod +x`). Scripts should exit 0 on success and print compact, parseable output (YAML-ish key/value or JSON) that Claude can read into context cheaply.

Scripts are *optional fast paths* — the skill should also work without them for harnesses without Bash access.

## Templates

Put scaffold files under `templates/` with a `.tmpl` suffix. Templates should be generic (no repo-specific paths) and small (< 200 lines). The skill must offer templates before writing them — never auto-create files without user consent.

## Testing a skill

At minimum, before opening a PR:

1. `wc -l skills/<name>/SKILL.md` — body should be < 200 lines.
2. Frontmatter parses as valid YAML.
3. Any referenced `reference/`, `templates/`, or `scripts/` path exists.
4. Executable scripts have `+x` and exit 0 on a trivial input.
5. Manually invoke the skill in a fresh Claude session against a real repo and sanity-check the output.

## Naming

- **kebab-case** directory and `name` field (e.g. `agentex-audit`, not `agentex_audit` or `AgentexAudit`).
- Verb-noun or noun-noun phrases that describe the deliverable, not the implementation (`agentex-audit`, not `repo-scanner`).
- Avoid generic names (`helper`, `tools`, `utils`).
