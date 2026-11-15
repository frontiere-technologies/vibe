#!/usr/bin/env bash
# Mechanical checks of the vibe setup (step 8 of vibe/README.md).
# Usage: bash .agents/skills/vibe-check-setup/scripts/check-setup.sh [repo-root]
# Prints "PASS <check>" or "FAIL <check>: <reason>" per check.
# Exit 0 if every check passes, 1 otherwise.
# Needs only bash, git and POSIX tools; works on bash 3.2 (macOS), Linux, Git Bash.

failures=0

# report <check> <problem>: empty problem means PASS.
report() {
  if [ -z "$2" ]; then
    echo "PASS $1"
  else
    echo "FAIL $1: $2"
    failures=$((failures + 1))
  fi
}

# add_problem <text>: append to the problem list of the running check.
add_problem() {
  if [ -z "$problems" ]; then problems=$1; else problems="$problems; $1"; fi
}

check_symlinks() {
  local problems="" link target
  # path:expected-target; the last two only matter if the folder exists.
  for pair in \
    ".claude/skills:../.agents/skills" \
    ".claude/agents:../.agents/agents" \
    ".opencode/agents:../.agents/agents" \
    ".gemini/agents:../.agents/agents"; do
    link=${pair%%:*}
    target=${pair#*:}
    case "$link" in
      .opencode/*|.gemini/*) [ -e "$link" ] || [ -L "$link" ] || continue ;;
    esac
    if [ ! -L "$link" ]; then
      add_problem "$link is not a symlink (expected -> $target)"
    elif [ "$(readlink "$link")" != "$target" ]; then
      add_problem "$link points to $(readlink "$link"), expected $target"
    fi
  done
  if [ -n "$problems" ]; then
    add_problem "see Symlinks on Windows in step 1 of vibe/README.md"
  fi
  report symlinks "$problems"
}

check_imports() {
  local problems="" f
  [ -f AGENTS.md ] || add_problem "AGENTS.md is missing"
  for f in CLAUDE.md GEMINI.md; do
    if [ ! -f "$f" ]; then
      add_problem "$f is missing"
    elif ! grep -q '^@AGENTS\.md[[:space:]]*$' "$f"; then
      add_problem "$f does not import @AGENTS.md"
    fi
  done
  report imports "$problems"
}

check_gitignore() {
  local problems="" f
  for f in .env .env.local .claude/settings.local.json; do
    git check-ignore -q --no-index -- "$f" || add_problem "$f is not ignored"
  done
  for f in .env.example .env.template; do
    if git check-ignore -q --no-index -- "$f"; then add_problem "$f is ignored but must be committable"; fi
  done
  report gitignore "$problems"
}

check_no_secrets_tracked() {
  local problems="" f base
  while IFS= read -r f; do
    base=${f##*/}
    case "$base" in
      *.example|*.template) ;;
      .env|.env.*) add_problem "$f is tracked" ;;
      settings.local.json) add_problem "$f is tracked" ;;
    esac
  done <<EOF
$(git -c core.quotePath=false ls-files)
EOF
  report no-secrets-tracked "$problems"
}

check_skills() {
  local problems="" dir name
  # The four wiki skills are required, whatever else is in the folder.
  for name in wiki-ingest wiki-query wiki-health wiki-lint; do
    [ -f ".agents/skills/$name/SKILL.md" ] || add_problem "$name/SKILL.md is missing"
  done
  for dir in .agents/skills/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    if [ ! -f "$dir/SKILL.md" ]; then
      add_problem "$name has no SKILL.md"
      continue
    fi
    # Front matter: first line ---, then key: value lines up to the closing ---.
    if [ "$(sed -n '1p' "$dir/SKILL.md")" != "---" ]; then
      add_problem "$name/SKILL.md has no front matter"
      continue
    fi
    if ! awk 'NR==1{next} /^---[[:space:]]*$/{exit} {print}' "$dir/SKILL.md" | grep -q "^name:[[:space:]]*$name[[:space:]]*\$"; then
      add_problem "$name/SKILL.md: name does not match the folder"
    fi
    if ! awk 'NR==1{next} /^---[[:space:]]*$/{exit} {print}' "$dir/SKILL.md" | grep -q '^description:[[:space:]]*[^[:space:]]'; then
      add_problem "$name/SKILL.md: description is missing"
    fi
  done
  report skills "$problems"
}

check_links() {
  local problems="" file dir target path
  while IFS= read -r file; do
    [ -f "$file" ] || continue
    dir=$(dirname "$file")
    # Drop fenced blocks and inline code spans, then list the ](target) parts.
    while IFS= read -r target; do
      target=${target#](}
      target=${target%)}
      case "$target" in
        http:*|https:*|mailto:*|\#*|"") continue ;;
      esac
      target=${target%%#*}
      [ -n "$target" ] || continue
      target=$(printf '%s' "$target" | sed 's/%20/ /g')
      case "$target" in
        /*) path=".$target" ;;
        *) path="$dir/$target" ;;
      esac
      [ -e "$path" ] || add_problem "$file links to missing $target"
    done <<EOF
$(awk '/^[[:space:]]*```/ { fence = !fence; next } !fence { gsub(/`[^`]*`/, ""); print }' "$file" | grep -o '\]([^)]*)')
EOF
  done <<EOF
$(git -c core.quotePath=false ls-files '*.md')
EOF
  report links "$problems"
}

main() {
  local root=${1:-.} top
  if ! top=$(git -C "$root" rev-parse --show-toplevel 2>/dev/null); then
    echo "FAIL repo: not a git repository"
    exit 1
  fi
  cd "$top" || exit 1
  check_symlinks
  check_imports
  check_gitignore
  check_no_secrets_tracked
  check_skills
  check_links
  [ "$failures" -eq 0 ]
}

main "$@"
