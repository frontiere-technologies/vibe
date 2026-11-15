# Generalising the vibe template — design

**Status:** proposed · **Date:** 2026-11-13 · **Branch it starts from:** `development` at `38cc35d`

## Intent

This repository is the starting point for every new vibe-coding project at Frontiere: a new project is created from it, fills in its rules, and lets an AI coding CLI build inside them. Today it works as a starting point, but it still behaves like a single project that happens to be copied:

- once a project is created, it never hears from the template again;
- every project inherits things it does not need (the tutorial, a service-based folder layout, a licence clause about third-party code);
- the safety and consistency rules exist only as prose that the agent may or may not follow, and the setup is a long guide that each developer (or agent) interprets anew.

The goal of this work is a template that a team can start from in minutes, that carries only what every project needs, that checks itself mechanically, and that can be updated in projects already created from it.

The developer skipped the brainstorming questions and asked to start from the analysis of 2026-11-13. Every decision below that the developer did not state is marked **(my call)**: they are the points to check when reading.

## Already done (not part of this work)

Commit `38cc35d` on `development`:

- full `.gitignore` and Claude Code deny rules (secret files, `docs/second-brain/raw/`);
- wiki skills aligned with `docs/second-brain/SCHEMA.md`; off-topic second-brain content replaced;
- full NASA PDF removed from the tutorial (linked instead);
- the setup guide creates projects with `gh repo create --template`.

Outside the repository: `frontiere-technologies/vibe` is marked as a GitHub template; `development` is its only and default branch.

## Goals

1. **Only what every project needs.** A project created from the template contains no tutorial, no example data and no code folders it did not choose.
2. **Rules that are checked, not only written.** The setup's mechanical checks, the secret rules and the documentation links are verified by a script, locally and in CI.
3. **A short, project-only `AGENTS.md`.** It holds the project's rules and placeholders for them, nothing that explains the template.
4. **A repeatable setup.** The setup is a skill every CLI can run the same way, with the guide as its reference.
5. **Updatable projects.** A project knows which template version it came from and can pull later template changes in a controlled way.
6. **A free licence choice.** A project chooses its own licence; third-party notices travel with the code they cover.

## Non-goals

- Shrinking the Git history or the guide's images (the developer chose to keep the original images; old blobs stay in history).
- Pinning Superpowers to a version mechanically: Claude Code has no project-level version pin. The guide states the version it was verified with.
- Converting agents for every CLI (Codex TOML, Copilot `.agent.md`): the guide's existing per-CLI notes stay as they are.
- A web site, a generator CLI or any runtime service for the template.
- Moving the tutorial to its own repository (see *Tutorial* below for why).

## Anti-goals

The work fails, even if every task is done, if:

- the template stops working without extra installs: bash and git stay the only requirements for the checks, and the wiki keeps needing no script at all;
- the template becomes Claude-only: everything keeps working through `AGENTS.md` and `.agents/` for the other CLIs;
- `AGENTS.md` grows: it must end shorter than it is today (70 lines);
- starting a project takes more decisions than today: new choices are asked by the setup skill with a default;
- the update procedure can overwrite a project's own changes without showing them first.

## Constraints

- Plain files only: Markdown, YAML/JSON configuration, and POSIX-leaning bash that runs on macOS's bash 3.2, Linux, and Git Bash on Windows (no associative arrays, no `mapfile`, no GNU-only flags).
- Documentation, skills, specs and plans in English; conversation with the developer in their language.
- Every file the template owns stays usable by any AI coding CLI (see the CLI table in `vibe/README.md`, step 0).
- Outward actions — pushing, tagging on the remote, creating GitHub issues — happen only after the developer confirms them.
- The wiki folder `docs/second-brain/wiki/sources/` keeps its name; only the code root is renamed (see *Layout presets*).

## Design

### 1. Licence and third-party notices

- `LICENSE` at the root becomes the template's own MIT licence, copyright Mario Stefanutti only. A project replaces it with any licence.
- New `.agents/skills/THIRD_PARTY_NOTICES.md`: the MIT text with the SamurAIGPT copyright for the `wiki-*` skills and the second-brain schema, plus a section for every other third-party file added later (the reviewer agents, see 8).
- The provenance line of each `wiki-*` skill points to that file instead of `LICENSE`.
- Step 1 of the guide no longer asks to keep the SamurAIGPT line in `LICENSE`; it says the notices file stays.

### 2. Second brain completion

- `SCHEMA.md` gains an **Entity Page Format** and a **Concept Page Format** (frontmatter plus sections: for entities *Role*, *Facts*, *Relationships*, *Mentioned in*; for concepts *Definition*, *How it works here*, *Related*, *Mentioned in*). Section names are left to the builder; each format ends with a *Connections*-style list of `[[wikilinks]]`.
- The ingest workflow gains a step: add a row to the table in `docs/second-brain/raw/README.md` (file, origin if known, ingest date). The `wiki-ingest` skill gets the same step. **(my call: keep the table and fill it automatically, rather than drop it, because it records provenance.)**

### 3. `AGENTS.md` and `docs/`

- Everything in `AGENTS.md` that explains the template moves to step 3 of the guide: the "sections marked *Fill in per project*" paragraph, the list of alternative layouts, and each section's descriptive sentence. Each section keeps a one-line placeholder: `Not defined yet.` plus, where it exists today, the safe default.
- Three new sections, each a placeholder with a default **(my call)**:
  - **Git workflow** — default: one branch per change from the default branch; commit subject in the imperative, a body that says why; no push without the developer's approval.
  - **Language** — default: code, documentation, wiki and commit messages in English; conversation in the developer's language.
  - **Definition of done** — default: the existing tests and linters pass and the result has been shown, not claimed.
- *Layout* lists only `docs/second-brain/`, `docs/` and a placeholder for the code folders, filled in by the setup from the chosen preset.
- New `docs/README.md`: what lives in `docs/superpowers/specs/`, `docs/superpowers/plans/`, `docs/reviews/`, `docs/second-brain/`, and that all of it is committed.
- Target: `AGENTS.md` shorter than 70 lines, and no sentence in it that addresses the template's user rather than the agent.

### 4. Layout presets (and `sources/` → `src/`)

- The template ships **no code folders**. `sources/` and its `.gitkeep` files are removed.
- New `vibe/layouts.md` describes four presets: **services** (`src/microservices/`, `src/libraries/`, `src/devops/`, `src/tests/e2e/` — today's layout under a new root), **single app** (`app/`, `test/`), **library** (`lib/`, `test/`, `example/`), **data** (`notebooks/`, `data/`, `pipelines/`). For each preset: the folders, what goes in each, and the lines to put in *Layout* in `AGENTS.md`.
- The content of today's `sources/README.md` becomes the description of the services preset; the setup copies it to `src/README.md` when that preset is chosen.
- **(my call) Rename the code root from `sources/` to `src/`:** `src/` is the name tools and people expect, and it removes the clash with the wiki's `sources/` folder that `AGENTS.md` has to explain today.
- Step 1 of the guide asks for the preset; the setup creates only the chosen folders.
- The tutorial's lessons use `src/` paths (they create the folders they need).

### 5. Tutorial

**(my call)** The tutorial stays in the template repository, but not in projects:

- Step 1 of the setup removes `vibe/tutorial/` by default (`git rm -r vibe/tutorial`), and keeps it only if the developer wants to do the lessons in the project itself.
- Links from the guide and from `vibe/second-brain.md` to the tutorial become absolute URLs to the template repository, so they keep working after the removal.

Why not a separate repository, as first suggested: the lessons exercise the template itself (its `AGENTS.md`, skills and layout); a second repository would need to be kept in sync with every template change, which is the very problem goal 5 solves for projects. Trying the approach stays one command: create a throwaway repository from the template and follow the lessons there.

### 6. Mechanical checks

- New `vibe/scripts/check-setup.sh [repo-root]` (default: current directory). It prints one line per check, `PASS <check>` or `FAIL <check>: <reason>`, and exits 1 if any check failed, 0 otherwise. Checks:
  - **symlinks** — `.claude/skills` and `.claude/agents` are symlinks to `../.agents/skills` and `../.agents/agents`; `.opencode/agents` and `.gemini/agents`, if present, are symlinks to `../.agents/agents`.
  - **imports** — `CLAUDE.md` and `GEMINI.md` contain `@AGENTS.md`.
  - **gitignore** — `git check-ignore` reports `.env`, `.env.local` and `.claude/settings.local.json` as ignored, and `.env.example` and `.env.template` as not ignored.
  - **no-secrets-tracked** — no tracked file named `.env`, `.env.<anything>` (except `*.example` and `*.template`) or `settings.local.json`.
  - **skills** — `.agents/skills/wiki-{ingest,query,health,lint}/SKILL.md` exist.
  - **links** — every relative Markdown link `[text](path)` in tracked `.md` files, outside fenced code blocks, points to an existing file or folder (anchors are ignored, `http(s):`/`mailto:` links are skipped).
- A test script, `vibe/scripts/tests/check-setup.test.sh`, runs the check against a pristine local clone (expects exit 0) and against clones broken in one way each (expects exit 1 and the right `FAIL` line).
- Step 8 of the guide runs the script first; the questions to the CLI remain for what a script cannot see (what the CLI loaded).
- The `vibe-setup` skill (see 9) uses the script to find out which steps are already done.

### 7. CI and repository hygiene

- New `.github/workflows/vibe-checks.yml`, on push and pull request: runs `check-setup.sh` and its test script, then scans for secrets with gitleaks run from its official container image, pinned to an exact version. **(my call: the container, not the GitHub Action, because the Action needs a paid licence for organisation repositories.)**
- New `.github/pull_request_template.md` (what changed, why, how it was verified, a checkbox list for follow-ups) and `.github/ISSUE_TEMPLATE/work-item.md` (a work item as `- [ ]` checkboxes, as the guide's work loop describes).
- New `.editorconfig`: UTF-8, LF, final newline, trailing whitespace trimmed except in Markdown, 2-space indentation by default.
- The guide mentions an optional local pre-commit hook with gitleaks; the template does not install one.

### 8. Reviewer agents shipped with the template

- `.agents/agents/` ships `code-reviewer.md`, `architect-reviewer.md` and `ui-ux-tester.md`, downloaded from the VoltAgent collection at a pinned commit SHA, reduced to the shared frontmatter (`name`, `description`, `mode: subagent`), read, and trimmed of what does not apply to an unknown project.
- Their licence and origin (repository, SHA) go into `THIRD_PARTY_NOTICES.md`.
- Step 5 of the guide changes from "download" to "keep or remove": the setup removes `ui-ux-tester` for projects without a UI.

### 9. `vibe-setup` skill

- New `.agents/skills/vibe-setup/SKILL.md`, triggered by "run the setup", "set up the project", or the guide's prompt.
- It reads `vibe/README.md` as the reference, runs `check-setup.sh` and reads `git log` to find which steps are done, then goes on step by step: one decision at a time, each with a default; a commit at the end of each step; a stop for what only the developer can do (logins, tokens, the restart after step 2).
- Decisions it asks, in order: licence, layout preset, keep the tutorial or not, the `AGENTS.md` sections, skills, agents (UI or not), MCP servers.
- The prompt in the guide stays as the fallback for CLIs that do not load skills.

### 10. Template versioning and updates

- New `.vibe-template` at the root, plain `key: value` lines plus two lists:

  ```yaml
  repository: https://github.com/frontiere-technologies/vibe.git
  version: 0.1.0
  owned:        # replaced by updates (three-way merge)
    - .agents/skills/wiki-*/
    - .agents/skills/vibe-*/
    - .agents/skills/THIRD_PARTY_NOTICES.md
    - docs/second-brain/SCHEMA.md
    - vibe/
    - .github/workflows/vibe-checks.yml
  advisory:     # shown as a diff, applied only if the developer says so
    - AGENTS.md
    - .gitignore
    - .claude/settings.json
    - .agents/agents/
    - .editorconfig
  ```

- Releases of the template are tags `v<version>` (semantic versioning). `vibe/CHANGELOG.md` lists what each version changes and anything a project must do by hand.
- **(my call)** `vibe/` becomes template-owned: the guide's sentence "This guide belongs to the project" changes to say project-specific setup notes go in `AGENTS.md` or the project's `README.md`, so that updates can replace `vibe/`.
- New `.agents/skills/vibe-update/SKILL.md`: reads `.vibe-template`; fetches the recorded version's tag and the target tag (default: the latest) from `repository` into temporary refs; applies the diff of the `owned` paths between the two tags with a three-way merge (`git apply -3`); shows the diff of the `advisory` paths and applies each only on the developer's yes; shows `vibe/CHANGELOG.md` entries in between; updates `version`; runs `check-setup.sh`; and asks before committing. It never pushes.

### 11. Guide housekeeping

- The guide states the Superpowers version it was verified with (7.0.0) in step 2.
- The *To be evaluated* section leaves the guide; its three items become one GitHub issue in the template repository, created only after the developer confirms.

### 12. First release

- `vibe/CHANGELOG.md` gets the `0.1.0` entry, `.vibe-template` says `version: 0.1.0`, and the tag `v0.1.0` is created locally. Pushing `development` and the tag waits for the developer's go-ahead.

## Order

Each part is useful alone, but some depend on others:

1. Licence (1), second brain (2), `AGENTS.md` and `docs/` (3), guide housekeeping (11).
2. Layout presets (4), then tutorial (5): both rewrite the same guide steps and lesson paths.
3. Checks (6), then CI (7): CI runs the checks.
4. Agents (8), then the setup skill (9): the skill asks about them.
5. Versioning and updates (10), then the release (12): the release needs everything before it.

## Left to the builder

- Exact wording of every document, as long as it follows the existing style of the guide (short declarative sentences, tables for comparisons).
- Section names inside the entity and concept page formats.
- The exact gitleaks version (the latest stable v8 at implementation time) and its command syntax.
- The VoltAgent commit SHA (the latest at implementation time) and how much of each reviewer's instructions to trim.
- How `check-setup.sh` is split into functions.

## Done when

- A repository created with `gh repo create --template` and set up with the `vibe-setup` skill contains no tutorial (unless chosen), only the chosen code folders, a licence of the developer's choice, and passes `check-setup.sh`.
- `vibe-checks.yml` passes on `development`.
- `AGENTS.md` is under 70 lines and holds no template explanations.
- `vibe-update`, run in a throwaway project created from `v0.1.0` against a later local tag, applies an owned change, shows an advisory change, and leaves a project-modified owned file with a visible conflict instead of overwriting it.
