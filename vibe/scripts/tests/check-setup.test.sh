#!/usr/bin/env bash
# Tests for vibe/scripts/check-setup.sh.
# Clones the repository this script lives in (at HEAD) into a temp folder
# whose path contains a space, mutates the clone, and checks the verdict.
# Usage: bash vibe/scripts/tests/check-setup.test.sh

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
check="$here/../check-setup.sh"
root=$(git -C "$here" rev-parse --show-toplevel) || { echo "not a git repository: $here" >&2; exit 1; }
sha=$(git -C "$root" rev-parse HEAD)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

gitc() { git -c user.name=vibe-test -c user.email=vibe-test@example.invalid "$@"; }

failed=0
clone=""
out=""
code=0

fresh_clone() {
  rm -rf "$tmp/repo copy"
  clone="$tmp/repo copy"
  git clone -q --no-checkout "$root" "$clone" && git -C "$clone" checkout -q "$sha"
}

run_check() {
  out=$(bash "$check" "$1" 2>&1)
  code=$?
}

commit_all() {
  git -C "$clone" add -A && gitc -C "$clone" commit -q -m "test mutation"
}

# expect_result <case> <exit code> [<grep -F pattern>...]
# Every pattern must appear in the output; the pattern "!FAIL" means no FAIL line.
expect_result() {
  local name=$1 want=$2 why="" pat
  shift 2
  [ "$code" = "$want" ] || why="exit $code, expected $want"
  for pat in "$@"; do
    if [ "$pat" = "!FAIL" ]; then
      if printf '%s\n' "$out" | grep -q '^FAIL'; then why="$why; unexpected FAIL line"; fi
    else
      printf '%s\n' "$out" | grep -qF -- "$pat" || why="$why; missing '$pat'"
    fi
  done
  if [ -z "$why" ]; then
    echo "ok $name"
  else
    echo "not ok $name: ${why#; } | output: $(printf '%s' "$out" | tr '\n' '|')"
    failed=1
  fi
}

case_pristine() {
  fresh_clone && run_check "$clone"
  expect_result pristine 0 '!FAIL' 'PASS symlinks' 'PASS links'
}

case_symlink_as_file() {
  fresh_clone || return
  rm "$clone/.claude/skills" && printf '../.agents/skills' > "$clone/.claude/skills"
  run_check "$clone"
  expect_result symlink-as-file 1 'FAIL symlinks:' 'Symlinks on Windows'
}

case_missing_import() {
  fresh_clone || return
  : > "$clone/CLAUDE.md"
  run_check "$clone"
  expect_result missing-import 1 'FAIL imports:'
}

case_env_ignored_template() {
  fresh_clone || return
  mkdir -p "$clone/src/api" && echo "KEY=" > "$clone/src/api/.env.test.example"
  commit_all
  run_check "$clone"
  expect_result env-ignored-template 0 '!FAIL'
}

case_env_tracked() {
  fresh_clone || return
  echo "SECRET=1" > "$clone/.env"
  git -C "$clone" add -f .env && gitc -C "$clone" commit -q -m "track env"
  run_check "$clone"
  expect_result env-tracked 1 'FAIL no-secrets-tracked:' '.env'
}

case_env_tracked_non_ascii() {
  fresh_clone || return
  mkdir -p "$clone/café"
  echo "SECRET=1" > "$clone/café/.env"
  git -C "$clone" add -f "café/.env" && gitc -C "$clone" commit -q -m "track env in a non-ASCII folder"
  run_check "$clone"
  expect_result env-tracked-non-ascii 1 'FAIL no-secrets-tracked:' '.env'
}

case_broken_link() {
  fresh_clone || return
  printf '\n[x](does-not-exist.md)\n' >> "$clone/README.md"
  commit_all
  run_check "$clone"
  expect_result broken-link 1 'FAIL links:' 'README.md' 'does-not-exist.md'
}

case_link_in_fence_and_anchor() {
  fresh_clone || return
  {
    printf '\n```\n[x](nope.md)\n```\n\n'
    printf '[y](vibe/README.md#troubleshooting)\n'
  } >> "$clone/README.md"
  commit_all
  run_check "$clone"
  expect_result link-in-fence-and-anchor 0 '!FAIL'
}

case_link_in_inline_code() {
  fresh_clone || return
  printf '\n`[z](missing.md)`\n' >> "$clone/README.md"
  commit_all
  run_check "$clone"
  expect_result link-in-inline-code 0 '!FAIL'
}

case_missing_wiki_skill() {
  fresh_clone || return
  git -C "$clone" rm -q -r .agents/skills/wiki-lint && gitc -C "$clone" commit -q -m "remove wiki-lint"
  run_check "$clone"
  expect_result missing-wiki-skill 1 'FAIL skills:' 'wiki-lint'
}

case_not_a_repo() {
  rm -rf "$tmp/empty" && mkdir "$tmp/empty"
  run_check "$tmp/empty"
  expect_result not-a-repo 1 'FAIL repo: not a git repository'
}

case_pristine
case_symlink_as_file
case_missing_import
case_env_ignored_template
case_env_tracked
case_env_tracked_non_ascii
case_broken_link
case_link_in_fence_and_anchor
case_link_in_inline_code
case_missing_wiki_skill
case_not_a_repo

exit "$failed"
