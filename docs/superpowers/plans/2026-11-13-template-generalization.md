# Template Generalization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the vibe repository into a template that gives each project only what it needs, checks itself mechanically, sets itself up through a skill, and can be updated in projects already created from it.

**Architecture:** Plain files only. A bash check script (with its own bash test script) is the single source of mechanical checks, used by the guide, the setup skill and CI. Two new Agent Skills (`vibe-setup`, `vibe-update`) drive setup and updates from `vibe/README.md` and a `.vibe-template` manifest. Documentation changes move template explanations out of `AGENTS.md` into the guide. The check script comes first (Task 1), unlike the spec's order, so that every later task can verify itself with it.

**Tech Stack:** Markdown, bash (bash 3.2-compatible), git, GitHub Actions, gitleaks (container image), Agent Skills (`SKILL.md`).

**Spec:** `docs/superpowers/specs/2026-11-13-template-generalization-design.md`

## Global Constraints

- Bash must run on macOS bash 3.2, Linux and Git Bash: no associative arrays, no `mapfile`, no `sed -i` without a portable form, no GNU-only flags; quote every path.
- Only bash and git are required to run the checks; the wiki needs no script.
- Every file stays usable by any AI coding CLI (no Claude-only instructions outside `.claude/` and `CLAUDE.md`).
- Documentation, skills, specs and plans in English.
- `docs/second-brain/wiki/sources/` keeps its name; only the code root `sources/` becomes `src/`.
- `AGENTS.md` must end under 70 lines, with no sentence addressed to the template's user.
- No push, remote tag or GitHub issue without the developer's explicit go-ahead in chat.
- Commit messages: imperative subject, body that says why, ending with the attribution line the session gives.

## Review Focus

- A Windows checkout where `.claude/skills` is a text file instead of a symlink: `check-setup.sh` must report `FAIL symlinks` with a pointer to *Symlinks on Windows*, not pass. (Test in Task 1.)
- A repository path containing spaces: every check must still work. (Test in Task 1.)
- Markdown links with `#anchors`, links to folders, and link-like text inside fenced code blocks: no false `FAIL links`. (Test in Task 1.)
- A committed template such as `src/api/.env.test.example`: must not be reported as a tracked secret. (Test in Task 1.)
- `vibe-update` on a project that edited an owned file: the edit must surface as a merge conflict, never be silently overwritten. (Check in Task 10.)

---

### Task 1: Mechanical setup checks

**Files:**
- Create: `vibe/scripts/check-setup.sh`
- Create: `vibe/scripts/tests/check-setup.test.sh`
- Modify: `vibe/README.md` (step 8 and *Troubleshooting*)

**Interfaces:**
- Produces: `bash vibe/scripts/check-setup.sh [repo-root]` → one line per check, `PASS <check>` or `FAIL <check>: <reason>`; exit 0 if all pass, 1 otherwise. Check names, exactly: `symlinks`, `imports`, `gitignore`, `no-secrets-tracked`, `skills`, `links`. Outside a git repository: `FAIL repo: not a git repository`, exit 1.

- [ ] **Step 1: Write the failing test script**

`vibe/scripts/tests/check-setup.test.sh` clones the current repository's `HEAD` into a temp dir whose path contains a space (`"$tmp/repo copy"`) once per case, mutates it, runs the check, and asserts exit code and output. Cases:

| Case | Mutation | Expect |
|---|---|---|
| `pristine` | none | exit 0, no `FAIL` line |
| `symlink-as-file` | replace `.claude/skills` with a file containing `../.agents/skills` | exit 1, line starts `FAIL symlinks:` and mentions `Symlinks on Windows` |
| `missing-import` | `CLAUDE.md` emptied | exit 1, `FAIL imports:` |
| `env-ignored-template` | commit `src/api/.env.test.example` | exit 0 |
| `env-tracked` | `git add -f .env` and commit | exit 1, `FAIL no-secrets-tracked:` naming `.env` |
| `broken-link` | append `[x](does-not-exist.md)` to `README.md`, commit | exit 1, `FAIL links:` naming `README.md` and `does-not-exist.md` |
| `link-in-fence-and-anchor` | append a fenced block containing `[x](nope.md)` and a line `[y](vibe/README.md#troubleshooting)`, commit | exit 0 |
| `not-a-repo` | run against an empty temp dir | exit 1, `FAIL repo: not a git repository` |

The script prints `ok <case>` / `not ok <case>: <why>` and exits 1 if any case failed.

- [ ] **Step 2: Run it to verify it fails**

Run: `bash vibe/scripts/tests/check-setup.test.sh`
Expected: every case `not ok` (the check script does not exist), exit 1.

- [ ] **Step 3: Implement `vibe/scripts/check-setup.sh`**

One function per check. `links`: list tracked `*.md` with `git ls-files`, strip fenced blocks with `awk` (toggle on lines starting with three backticks), extract `](target)` with `grep -o`, drop `http:`, `https:`, `mailto:` and pure `#anchor` targets, cut `#…` from the rest, resolve relative to the file's folder, test with `[ -e ]`. `gitignore`: `git check-ignore -q --no-index` on `.env`, `.env.local`, `.claude/settings.local.json` (must be ignored) and `.env.example`, `.env.template` (must not). `symlinks`: `[ -L ]` plus `readlink` equal to the expected target; for `.opencode/agents` and `.gemini/agents` only if they exist.

- [ ] **Step 4: Run the tests and the check on the repository**

Run: `bash vibe/scripts/tests/check-setup.test.sh && bash vibe/scripts/check-setup.sh`
Expected: eight `ok` lines; then six `PASS` lines, exit 0.

- [ ] **Step 5: Point step 8 of the guide at the script**

In `vibe/README.md` step 8, checks 1 (symlinks) and 9 (nothing personal committed) become "run `bash vibe/scripts/check-setup.sh`; every line says PASS". The questions to the CLI (checks 3–7) stay. Add a *Troubleshooting* row: `FAIL links` → a document links to a moved or deleted file.

- [ ] **Step 6: Commit**

```bash
git add vibe/scripts vibe/README.md
git commit -m "Add a setup check script with its tests"
```

---

### Task 2: Licence and third-party notices

**Files:**
- Create: `.agents/skills/THIRD_PARTY_NOTICES.md`
- Modify: `LICENSE`, `.agents/skills/wiki-{ingest,query,health,lint}/SKILL.md` (provenance line), `vibe/README.md` (step 1, `LICENSE` bullet)

- [ ] **Step 1: Create the notices file** with a section *LLM Wiki Agent* (origin `https://github.com/SamurAIGPT/llm-wiki-agent`, what was derived: the `wiki-*` skills and `docs/second-brain/SCHEMA.md`, the full MIT text with `Copyright (c) 2023 SamurAIGPT`).
- [ ] **Step 2: Make `LICENSE` the template's own MIT licence** — remove the SamurAIGPT line, keep `Copyright (c) 2026 Mario Stefanutti`.
- [ ] **Step 3: Repoint the four provenance lines** to `.agents/skills/THIRD_PARTY_NOTICES.md` instead of "this repository's `LICENSE`".
- [ ] **Step 4: Rewrite the `LICENSE` bullet of step 1**: the project replaces `LICENSE` with any licence; `.agents/skills/THIRD_PARTY_NOTICES.md` stays with the skills.
- [ ] **Step 5: Verify**

Run: `grep -rn "SamurAIGPT" --exclude-dir=.git . | grep -v THIRD_PARTY_NOTICES` and `bash vibe/scripts/check-setup.sh`
Expected: only the four provenance lines (each naming `THIRD_PARTY_NOTICES.md`); all checks PASS.

- [ ] **Step 6: Commit** — `git commit -m "Move third-party notices next to the skills they cover"`

---

### Task 3: Second-brain page formats and source provenance

**Files:**
- Modify: `docs/second-brain/SCHEMA.md`, `.agents/skills/wiki-ingest/SKILL.md`, `docs/second-brain/raw/README.md`

- [ ] **Step 1: Add *Entity Page Format* and *Concept Page Format* to `SCHEMA.md`**, after *Source Page Format*: the common frontmatter (`type: entity` / `type: concept`, `sources`, `last_updated`) and sections — entities: *Role*, *Facts*, *Relationships*, *Mentioned in*; concepts: *Definition*, *How it works here*, *Related*, *Mentioned in*. Steps 6–7 of the ingest workflow refer to them.
- [ ] **Step 2: Add an ingest step** after step 9 in `SCHEMA.md` and in `wiki-ingest`: add a row `| <file> | <origin, or "unknown"> | <ingest date> |` to the table in `docs/second-brain/raw/README.md`. Renumber the validation step to 11.
- [ ] **Step 3: Give the table in `raw/README.md` its third column** `Ingested`, and say the ingest fills it.
- [ ] **Step 4: Verify**

Run: `grep -n "Entity Page Format\|Concept Page Format\|raw/README.md" docs/second-brain/SCHEMA.md .agents/skills/wiki-ingest/SKILL.md && bash vibe/scripts/check-setup.sh`
Expected: both formats and the new step present in `SCHEMA.md`, the step present in the skill; all checks PASS.

- [ ] **Step 5: Commit** — `git commit -m "Add entity and concept page formats and record ingested sources"`

---

### Task 4: A project-only `AGENTS.md`, a map of `docs/`, guide housekeeping

**Files:**
- Modify: `AGENTS.md`, `vibe/README.md` (steps 2 and 3, *To be evaluated*)
- Create: `docs/README.md`

- [ ] **Step 1: Move template explanations out of `AGENTS.md`** into the table and principles of step 3 of the guide: the *Fill in per project* paragraph, the alternative-layouts paragraph, the italic description under each section. Each section keeps `Not defined yet.` and, where present today, its safe default.
- [ ] **Step 2: Add the sections *Git workflow*, *Language*, *Definition of done*** with the defaults from the spec (section 3), and add them to the step 3 table in the guide.
- [ ] **Step 3: Reduce *Layout*** to `docs/second-brain/`, `docs/` (see `docs/README.md`) and `Code folders: not defined yet (chosen at setup, see vibe/layouts.md).`
- [ ] **Step 4: Create `docs/README.md`**: one line each for `superpowers/specs/`, `superpowers/plans/`, `reviews/`, `second-brain/`; everything committed.
- [ ] **Step 5: Guide housekeeping** — step 2 says "Verified with Superpowers 7.0.0"; remove *To be evaluated* from the guide and keep its three items for Step 7.
- [ ] **Step 6: Verify**

Run: `wc -l < AGENTS.md; grep -c "Fill in per project\|For other kinds of project" AGENTS.md; bash vibe/scripts/check-setup.sh`
Expected: a number below 70; `0`; all checks PASS.

- [ ] **Step 7: Propose the GitHub issue** — show the developer the issue title ("Evaluate: frontend-design, code-review, code-simplifier, claude-mem, context7") and body with the three items; create it with `gh issue create` only on their yes.
- [ ] **Step 8: Commit** — `git commit -m "Keep AGENTS.md to project rules and map the docs folder"`

---

### Task 5: Layout presets and the `src/` root

**Files:**
- Create: `vibe/layouts.md`
- Delete: `sources/` (README and `.gitkeep` files)
- Modify: `AGENTS.md` (*Layout*), `README.md` (*Project structure*), `vibe/README.md` (step 1), `vibe/tutorial/01-from-document-to-code.md`, `vibe/tutorial/02-from-document-to-web-app.md`

**Interfaces:**
- Produces: preset names `services`, `single-app`, `library`, `data`, each with a *Folders* list and an *AGENTS.md Layout lines* block, used by `vibe-setup` (Task 9).

- [ ] **Step 1: Write `vibe/layouts.md`**: the four presets of the spec (section 4). `services` reuses the text of `sources/README.md` with `src/` paths and says the setup copies its description to `src/README.md`.
- [ ] **Step 2: `git rm -r sources`.**
- [ ] **Step 3: Step 1 of the guide asks for the preset** and points to `vibe/layouts.md`; the root `README.md` lists `src/` as an example adapted at setup.
- [ ] **Step 4: Rename code paths in the lessons** — every `sources/libraries`, `sources/microservices` and `sources/tests` in `vibe/tutorial/` becomes `src/…`; the lessons' `AGENTS.md` snippets say where code lives, so the agent creates the folders.
- [ ] **Step 5: Verify**

Run: `grep -rn "sources/\(libraries\|microservices\|devops\|tests\|README\)" --exclude-dir=.git . ; git ls-files sources | wc -l; bash vibe/scripts/check-setup.sh`
Expected: no grep output; `0`; all checks PASS. (`wiki/sources/` mentions are expected to remain and are not matched.)

- [ ] **Step 6: Commit** — `git commit -m "Replace the fixed code layout with presets chosen at setup"`

---

### Task 6: The tutorial stays in the template, not in projects

**Files:**
- Modify: `vibe/README.md` (intro, step 1, *Which steps apply*), `vibe/second-brain.md`, `vibe/tutorial/README.md`

- [ ] **Step 1: Make every link to the tutorial from outside `vibe/tutorial/` absolute**: `https://github.com/frontiere-technologies/vibe/tree/development/vibe/tutorial` (and `/blob/development/...` for single files).
- [ ] **Step 2: Step 1 of the guide removes the tutorial by default**: `git rm -r vibe/tutorial` in a new project, kept only on the developer's choice. *Which steps apply*, row "A first trial": create a throwaway repository from the template and follow the lessons there.
- [ ] **Step 3: The tutorial's README** says lessons run in a throwaway repository created from the template (or on a throwaway branch of the template itself).
- [ ] **Step 4: Verify the removal leaves no broken link**

Run: `tmp=$(mktemp -d) && git clone -q . "$tmp/p" && git -C "$tmp/p" rm -rq vibe/tutorial && git -C "$tmp/p" -c user.name=t -c user.email=t@t commit -qm t && bash vibe/scripts/check-setup.sh "$tmp/p"`
Expected: all checks PASS.

- [ ] **Step 5: Commit** — `git commit -m "Remove the tutorial from new projects by default"`

---

### Task 7: CI and repository hygiene

**Files:**
- Create: `.github/workflows/vibe-checks.yml`, `.github/pull_request_template.md`, `.github/ISSUE_TEMPLATE/work-item.md`, `.editorconfig`
- Modify: `vibe/README.md` (step 7: optional gitleaks pre-commit hook; *Shared and personal files*)

- [ ] **Step 1: Workflow** — triggers `push` and `pull_request`; one job on `ubuntu-latest`: `actions/checkout` with `fetch-depth: 0`, `bash vibe/scripts/check-setup.sh`, `bash vibe/scripts/tests/check-setup.test.sh`, then gitleaks from `ghcr.io/gitleaks/gitleaks:<exact latest v8 tag>` scanning the full history (check the subcommand with `--help` of that version). Pin `actions/checkout` to a full commit SHA with the version in a comment.
- [ ] **Step 2: PR template** (*What*, *Why*, *How it was verified*, *Follow-ups* as `- [ ]`) and **issue template** `work-item.md` (front matter `name`, `about`; body: context, then `- [ ]` items).
- [ ] **Step 3: `.editorconfig`** — `root = true`; `[*]` utf-8, lf, final newline, trim trailing whitespace, `indent_style = space`, `indent_size = 2`; `[*.md]` `trim_trailing_whitespace = false`.
- [ ] **Step 4: Verify locally** — `bash vibe/scripts/check-setup.sh`; if `actionlint` is installed, `actionlint .github/workflows/vibe-checks.yml`; if Docker is available, run the same gitleaks command as the workflow.
Expected: all PASS; no actionlint errors; gitleaks `no leaks found`.
- [ ] **Step 5: Commit** — `git commit -m "Run the setup checks and a secret scan in CI"`. The workflow is proven on GitHub only after the push (Task 11).

---

### Task 8: Reviewer agents shipped with the template

**Files:**
- Create: `.agents/agents/code-reviewer.md`, `.agents/agents/architect-reviewer.md`, `.agents/agents/ui-ux-tester.md`
- Delete: `.agents/agents/.gitkeep`
- Modify: `.agents/skills/THIRD_PARTY_NOTICES.md`, `vibe/README.md` (step 5, step 8 check 7)

- [ ] **Step 1: Download at a pinned SHA** — take the latest commit SHA of `VoltAgent/awesome-claude-code-subagents` (`gh api repos/VoltAgent/awesome-claude-code-subagents/commits/main --jq .sha`) and use the guide's existing loop with `REF=<sha>`. Read the repository's licence file.
- [ ] **Step 2: Reduce each file** to `name`, `description`, `mode: subagent`; read it whole; remove instructions that assume a stack, tools or MCP servers the template does not have.
- [ ] **Step 3: Add a *VoltAgent subagents* section** to the notices file: repository, SHA, licence text.
- [ ] **Step 4: Rewrite step 5 of the guide**: the three reviewers are already in `.agents/agents/`; keep or remove (remove `ui-ux-tester` without a UI); updating them is a deliberate download at a new SHA, with the diff read.
- [ ] **Step 5: Verify** — `head -5 .agents/agents/*.md` shows only the three keys; `ls .claude/agents/` lists the three files; `bash vibe/scripts/check-setup.sh` all PASS.
- [ ] **Step 6: Commit** — `git commit -m "Ship the three reviewer agents, pinned to a known commit"`

---

### Task 9: `vibe-setup` skill

**Files:**
- Create: `.agents/skills/vibe-setup/SKILL.md`
- Modify: `vibe/README.md` (*Setup run by the AI coding CLI*, step 4 list of template skills), `AGENTS.md` only if a pointer is needed (keep under 70 lines)

**Interfaces:**
- Consumes: `vibe/scripts/check-setup.sh` (Task 1), preset names from `vibe/layouts.md` (Task 5), the agents of Task 8.

- [ ] **Step 1: Write the skill** — frontmatter `name: vibe-setup`, a `description` that triggers on "run the setup", "set up the project", "continue the setup". Body: read `vibe/README.md` first; find done steps with `check-setup.sh` and `git log --oneline`; ask one decision at a time, each with a default, in this order: licence (default MIT), layout preset, keep the tutorial (default no), the `AGENTS.md` sections, extra skills, agents (UI or not), MCP servers; commit at the end of each step; stop for logins, tokens and the restart after step 2; never push.
- [ ] **Step 2: Update the guide** — the setup starts with `/vibe-setup` (Claude Code, Antigravity), `$vibe-setup` (Codex), or the existing prompt for other CLIs; step 4 lists `vibe-setup` among the template's skills.
- [ ] **Step 3: Verify in a throwaway clone** — `git clone -q . "$tmp/p"`, open a new CLI session in it, run `/vibe-setup`, answer with the defaults up to the end of step 1.
Expected: the tutorial removed, the chosen preset's folders and `src/README.md` created, `LICENSE` set, one commit per finished step, `check-setup.sh` all PASS.
- [ ] **Step 4: Commit** — `git commit -m "Add the vibe-setup skill"`

---

### Task 10: Template manifest and `vibe-update` skill

**Files:**
- Create: `.vibe-template`, `.agents/skills/vibe-update/SKILL.md`, `vibe/CHANGELOG.md`
- Modify: `vibe/README.md` (*Keeping the environment up to date*: the guide is template-owned; project notes go in `AGENTS.md` or `README.md`; how to run an update)

**Interfaces:**
- Produces: `.vibe-template` with keys `repository`, `version` and lists `owned`, `advisory`, exactly as in the spec (section 10); tags `v<version>`.

- [ ] **Step 1: Create `.vibe-template`** with `version: 0.1.0` and the lists from the spec, and `vibe/CHANGELOG.md` with an *Unreleased* section listing Tasks 1–10.
- [ ] **Step 2: Write the skill** — `name: vibe-update`. Procedure: read `.vibe-template`; `git fetch --no-tags <repository> "refs/tags/v<old>:refs/vibe/old" "refs/tags/v<new>:refs/vibe/new"` (new defaults to the highest `v*` tag from `git ls-remote --tags`); `git diff refs/vibe/old refs/vibe/new -- <owned paths> | git apply -3`; list conflicts and stop for the developer if any; for each advisory path show `git diff refs/vibe/old refs/vibe/new -- <path>` and apply only on yes; show the CHANGELOG entries between the versions; set `version`; run `check-setup.sh`; ask before committing; delete `refs/vibe/*`; never push.
- [ ] **Step 3: Verify with local tags** — in a scratch clone of the template: tag `v0.1.0`; create a project clone from it (fresh history); in the template clone change a line in `docs/second-brain/SCHEMA.md` and in `.gitignore`, commit, tag `v0.1.1`; in the project, edit the same `SCHEMA.md` line differently and commit; set `repository` to the scratch template path; run `/vibe-update`.
Expected: `SCHEMA.md` shows a conflict and nothing is overwritten; the `.gitignore` diff is shown and applied only on yes; `version: 0.1.1`; no commit without asking.
- [ ] **Step 4: Commit** — `git commit -m "Record the template version and add the vibe-update skill"`

---

### Task 11: Release 0.1.0

**Files:**
- Modify: `vibe/CHANGELOG.md`

- [ ] **Step 1: Rename *Unreleased* to `0.1.0 — <date>`** and add "Projects created before 0.1.0: create `.vibe-template` by hand with `version: 0.1.0`, then use `vibe-update` for later versions."
- [ ] **Step 2: Final check** — `bash vibe/scripts/tests/check-setup.test.sh && bash vibe/scripts/check-setup.sh`; `wc -l < AGENTS.md` below 70.
- [ ] **Step 3: Commit and tag locally** — `git commit -m "Release the vibe template 0.1.0"` and `git tag -a v0.1.0 -m "vibe template 0.1.0"`.
- [ ] **Step 4: Ask the developer** before `git push origin development v0.1.0`. After the push, check that `vibe-checks` passes on GitHub (`gh run list --workflow vibe-checks.yml --limit 1`).
