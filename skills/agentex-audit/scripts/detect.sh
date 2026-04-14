#!/usr/bin/env bash
# detect.sh — fast file-presence probe for the agentex-audit skill.
#
# Usage: bash detect.sh [repo-root]
#
# Stat-checks ~65 paths commonly associated with AgentEx/DevEx best
# practices and prints a compact YAML-ish report to stdout. Exits 0
# on success.
#
# This script is an *additive fast path* — it replaces the file-presence
# probes in Step 1 detection but not the Read of actual file contents.
# After running this, the skill should still Read the small root-level
# docs (README, AGENTS.md, CLAUDE.md, CODEMAP.md) to understand content.
#
# Dependencies: Bash + coreutils only.

set -u

ROOT="${1:-.}"
if [[ ! -d "$ROOT" ]]; then
    echo "error: $ROOT is not a directory" >&2
    exit 1
fi

cd "$ROOT" || exit 1

# Helpers -------------------------------------------------------------

# present_file <label> <path>
#   Emits "<label>: present (<wc-l> lines, <size> bytes)" or "<label>: absent"
present_file() {
    local label="$1"
    local path="$2"
    if [[ -f "$path" ]]; then
        local lines size
        lines=$(wc -l < "$path" 2>/dev/null || echo "?")
        size=$(wc -c < "$path" 2>/dev/null || echo "?")
        echo "${label}: present (${lines} lines, ${size} bytes, path=${path})"
    else
        echo "${label}: absent"
    fi
}

# present_dir <label> <path>
#   Emits "<label>: present (<n> entries)" or "<label>: absent"
present_dir() {
    local label="$1"
    local path="$2"
    if [[ -d "$path" ]]; then
        local count
        count=$(find "$path" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')
        echo "${label}: present (${count} entries, path=${path})"
    else
        echo "${label}: absent"
    fi
}

# first_existing <label> <path1> <path2> ...
#   Emits the first path that exists, or "<label>: absent"
first_existing() {
    local label="$1"
    shift
    for p in "$@"; do
        if [[ -e "$p" ]]; then
            echo "${label}: present (path=${p})"
            return
        fi
    done
    echo "${label}: absent"
}

# Report --------------------------------------------------------------

echo "# agentex-audit detect.sh report"
echo "# repo_root: $(pwd)"
echo "# generated: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo

echo "## 1. Context & documentation"
present_file "agents_md"            "AGENTS.md"
present_file "claude_md"            "CLAUDE.md"
first_existing "copilot_instructions" ".github/copilot-instructions.md"
first_existing "readme"             "README.md" "README.rst" "README.txt" "README"
present_file "codemap_md"           "CODEMAP.md"
present_file "contributing_md"      "CONTRIBUTING.md"
present_file "llms_txt"             "llms.txt"
present_file "llms_full_txt"        "llms-full.txt"
first_existing "adr_dir"            "docs/adr" "docs/decisions" "doc/adr"
present_dir  "docs_dir"             "docs"
present_file "devcontainer_json"    ".devcontainer/devcontainer.json"
present_file "runbook_md"           "RUNBOOK.md"
echo

echo "## 2. Feedback loops"
first_existing "test_dir"           "tests" "test" "spec" "__tests__"
first_existing "test_runner_config" \
    "pytest.ini" "pyproject.toml" "jest.config.js" "jest.config.ts" \
    "vitest.config.js" "vitest.config.ts" "karma.conf.js"
first_existing "linter_config" \
    ".eslintrc" ".eslintrc.js" ".eslintrc.json" ".eslintrc.yml" \
    "eslint.config.js" "ruff.toml" ".rubocop.yml" ".golangci.yml" \
    "rustfmt.toml" "clippy.toml"
first_existing "type_checker_config" \
    "tsconfig.json" "mypy.ini" "pyrightconfig.json" "pyproject.toml"
present_file "precommit_config"     ".pre-commit-config.yaml"
present_dir  "ci_github_workflows"  ".github/workflows"
present_file "ci_gitlab"            ".gitlab-ci.yml"
present_file "ci_jenkins"           "Jenkinsfile"
first_existing "examples_dir"       "examples" "samples" "example"
echo

echo "## 3. Tool access & scaffolding"
first_existing "mcp_json"           ".mcp.json" ".claude/.mcp.json"
present_file "claude_settings"      ".claude/settings.json"
present_file "claude_settings_local" ".claude/settings.local.json"
present_dir  "claude_hooks"         ".claude/hooks"
present_dir  "claude_skills"        ".claude/skills"
present_dir  "claude_agents"        ".claude/agents"
present_dir  "claude_commands"      ".claude/commands"
present_file "makefile"             "Makefile"
present_file "justfile"             "justfile"
first_existing "startup_script"     "startup.sh" "scripts/dev.sh" "scripts/start.sh" "bin/dev"
present_file "stop_script"          "stop.sh"
echo

echo "## 4. Guardrails & safety"
present_file "gitignore"            ".gitignore"
present_file "env_example"          ".env.example"
first_existing "aiignore" ".aiignore" ".cursorignore" ".windsurfignore"
# Check that .env is gitignored
if [[ -f ".gitignore" ]] && grep -qE '(^|/)\.env($|/)' .gitignore; then
    echo "gitignore_excludes_env: true"
else
    echo "gitignore_excludes_env: false"
fi
first_existing "dockerfile"         "Dockerfile" "Containerfile"
present_file "docker_compose"       "docker-compose.yml"
echo

echo "## 5. Code architecture & navigability"
first_existing "package_manifest" \
    "pyproject.toml" "package.json" "Cargo.toml" "go.mod" "Gemfile" \
    "pom.xml" "build.gradle" "mix.exs"
first_existing "lock_file" \
    "uv.lock" "poetry.lock" "requirements.txt" "package-lock.json" \
    "pnpm-lock.yaml" "yarn.lock" "Cargo.lock" "go.sum" "Gemfile.lock"
first_existing "monorepo_marker" \
    "pnpm-workspace.yaml" "turbo.json" "nx.json" "lerna.json" \
    "rush.json" "go.work"

# Biggest source files — a cognitive-load signal
echo "## largest source files (top 5):"
find . \
    -type f \
    \( -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" \
       -o -name "*.jsx" -o -name "*.go" -o -name "*.rs" -o -name "*.rb" \
       -o -name "*.java" -o -name "*.kt" \) \
    -not -path "*/node_modules/*" \
    -not -path "*/.venv/*" \
    -not -path "*/venv/*" \
    -not -path "*/.git/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*" \
    -not -path "*/target/*" \
    -exec wc -l {} + 2>/dev/null \
    | sort -rn | head -6 | tail -5 \
    | awk '{ printf "  - %s (%s lines)\n", $2, $1 }'
echo

echo "## 6. Observability & evals"
first_existing "evals_dir" "evals" "eval" "tests/evals"
first_existing "prompts_dir" "prompts" "src/prompts"
echo

echo "# end of report"
