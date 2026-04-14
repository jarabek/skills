#!/usr/bin/env bash
# detect-stack.sh — classifier for the agentex-audit skill.
#
# Usage: bash detect-stack.sh [repo-root]
#
# Classifies the repo on four axes and prints a compact report:
#   - language: the dominant language(s)
#   - application_type: library | service | cli | webapp | data | infra | unknown
#   - monorepo: true | false (with detected marker)
#   - agent_adoption_stage: none | basic | advanced
#
# Separable from detect.sh so "what kind of repo is this?" can be
# answered without running the full signal probe.
#
# Dependencies: Bash + coreutils only.

set -u

ROOT="${1:-.}"
if [[ ! -d "$ROOT" ]]; then
    echo "error: $ROOT is not a directory" >&2
    exit 1
fi

cd "$ROOT" || exit 1

# --- Language detection -----------------------------------------------

lang=""
if [[ -f "pyproject.toml" || -f "setup.py" || -f "requirements.txt" ]]; then
    lang="${lang}python,"
fi
if [[ -f "package.json" ]]; then
    if [[ -f "tsconfig.json" ]]; then
        lang="${lang}typescript,"
    else
        lang="${lang}javascript,"
    fi
fi
if [[ -f "go.mod" ]]; then
    lang="${lang}go,"
fi
if [[ -f "Cargo.toml" ]]; then
    lang="${lang}rust,"
fi
if [[ -f "Gemfile" ]]; then
    lang="${lang}ruby,"
fi
if [[ -f "pom.xml" || -f "build.gradle" || -f "build.gradle.kts" ]]; then
    lang="${lang}jvm,"
fi
if [[ -f "mix.exs" ]]; then
    lang="${lang}elixir,"
fi
lang="${lang%,}"  # strip trailing comma
if [[ -z "$lang" ]]; then
    lang="unknown"
fi

# --- Application type detection ---------------------------------------

app_type="unknown"

# Service / webapp heuristics
if grep -qs -E 'fastapi|flask|django|express|koa|fastify|gin|actix|rocket|axum|sinatra|rails|phoenix' \
        pyproject.toml package.json go.mod Cargo.toml Gemfile mix.exs requirements.txt requirements/*.txt 2>/dev/null; then
    app_type="service"
fi

# Webapp — has a frontend build tool
if [[ -f "package.json" ]] && grep -qs -E '"vite"|"next"|"remix"|"astro"|"svelte"|"nuxt"|"gatsby"' package.json 2>/dev/null; then
    if [[ "$app_type" == "service" ]]; then
        app_type="webapp+service"
    else
        app_type="webapp"
    fi
fi

# Library hints — has a published package manifest but no obvious app entry
if [[ "$app_type" == "unknown" ]]; then
    if [[ -f "pyproject.toml" ]] && grep -qs -E '\[project\]|\[tool.poetry\]' pyproject.toml 2>/dev/null \
       && [[ ! -f "main.py" && ! -d "app" && ! -d "api" ]]; then
        app_type="library"
    elif [[ -f "package.json" ]] && ! grep -qs '"start"' package.json 2>/dev/null; then
        app_type="library"
    fi
fi

# CLI hints
if [[ "$app_type" == "unknown" ]]; then
    if grep -qs -E 'click|typer|argparse|clap|cobra|commander' \
            pyproject.toml package.json Cargo.toml go.mod 2>/dev/null; then
        app_type="cli"
    fi
fi

# Infra hints
if [[ "$app_type" == "unknown" ]] && { [[ -f "main.tf" ]] || [[ -d "terraform" ]] || [[ -f "Pulumi.yaml" ]] || [[ -d "ansible" ]]; }; then
    app_type="infra"
fi

# --- Monorepo detection -----------------------------------------------

monorepo="false"
monorepo_marker=""
for marker in pnpm-workspace.yaml turbo.json nx.json lerna.json rush.json go.work; do
    if [[ -f "$marker" ]]; then
        monorepo="true"
        monorepo_marker="$marker"
        break
    fi
done

# Fallback: multiple package.jsons or pyproject.tomls under packages/ or apps/
if [[ "$monorepo" == "false" ]]; then
    count=$(find packages apps 2>/dev/null -maxdepth 2 -name "package.json" -o -name "pyproject.toml" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" -gt 1 ]]; then
        monorepo="true"
        monorepo_marker="multi-package (${count} nested manifests)"
    fi
fi

# --- Agent adoption stage ---------------------------------------------

stage="none"
if [[ -f "AGENTS.md" || -f "CLAUDE.md" ]]; then
    stage="basic"
fi
if [[ -d ".claude/hooks" || -d ".claude/skills" || -d ".claude/agents" || -d ".claude/commands" ]]; then
    stage="advanced"
fi

# --- Emit report ------------------------------------------------------

echo "# agentex-audit detect-stack.sh report"
echo "repo_root: $(pwd)"
echo "language: ${lang}"
echo "application_type: ${app_type}"
echo "monorepo: ${monorepo}"
if [[ -n "$monorepo_marker" ]]; then
    echo "monorepo_marker: ${monorepo_marker}"
fi
echo "agent_adoption_stage: ${stage}"
