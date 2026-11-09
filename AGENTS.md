# AGENTS.md

This repository holds project code and a **second brain**: a wiki of project knowledge maintained by coding agents. This file is the canonical instructions file for every AI coding assistant; tool-specific files (`CLAUDE.md`, `GEMINI.md`, …) only import it.

Read also the ./README.md file.

The sections marked *Fill in per project* start as "Not defined yet" and are completed for each project. A folder of the code (e.g. a service) can add its own `AGENTS.md` with rules that apply only there; those rules add to this file and win where they are more specific.

## Vibe-coding setup (optional, recommended)

The recommended environment is described in `vibe/README.md`: the Superpowers plugin (SDD + TDD workflow), project agents and skills, and MCP servers. It is optional; when present, use it for any non-trivial change.

If the `vibe/` folder or the Superpowers plugin is missing, do not fail and do not invent the missing files: carry on without them, and once per session, before the first non-trivial change, recommend the user to set them up.

## Layout

*Fill in per project.* Always present:

- `docs/second-brain/` — knowledge base: source documents (`raw/`), the wiki (`wiki/`) and saved reports (`reports/`). `docs/second-brain/wiki/sources/` holds summaries of source documents, not code.
- `docs/` — other project documents (specs, plans, reviews, work in progress).

Code layout of this project:

- `sources/` — code and operations: `microservices/`, `libraries/`, `devops/`, `tests/` (e2e). See `sources/README.md` for what goes where.

The `sources/` layout fits service-based systems. For other kinds of project, replace the line above with the real folders, e.g. `app/` + `test/` for a single app or monolith, `lib/` + `test/` + `example/` for a published library, `notebooks/` + `data/` + `pipelines/` for data work, `infra/` + `modules/` for an infrastructure repository.

## Commands

*Fill in per project:* how to install, run, build, lint, format and test, and from which folder.

Not defined yet: there is no code yet.

## Stack

*Fill in per project:* languages and versions, frameworks, runtime and hosting, in one or two lines.

Not defined yet (see Commands).

## Conventions

*Fill in per project:* architectural rules (layers and allowed dependencies between them), patterns to use or avoid, naming and code style, and the allow-list of approved ("certified") libraries. Do not add a dependency outside the allow-list without asking the user.

Not defined yet.

## Testing

*Fill in per project:* which kinds of test are required (unit, integration, end-to-end), where they live, what must be written test-first, and the checks that must pass before a change counts as done.

Not defined yet. Until it is defined: run the existing tests and linters before declaring a change done, and report failures as they are.

## Boundaries

*Fill in per project:* files, folders and systems the agent must not change, or only change after asking (generated code, migrations already applied, vendored code, CI/CD, production configuration).

Always, in every project:

- Never commit secrets: commit only templates (`*.example`, `.env.template`) and keep real values in ignored files.
- Do not change other projects or shared infrastructure from this repository.

## Using the second brain

When a task needs project or domain context (designing, coding, reviewing, answering questions):
1. Read `docs/second-brain/wiki/index.md` to find the relevant pages
2. Read only those pages, following their `[[wikilinks]]` as needed (`[[Name]]` is the file `Name.md` under `docs/second-brain/wiki/`)
3. Mention which wiki pages you relied on

Do not modify anything under `docs/second-brain/` while doing other work unless the user asks. If the wiki looks wrong or is missing something, tell the user.

Wiki maintenance requests — `ingest <file>`, `query: <question>`, `health`, `lint`, or the same in plain words — follow `docs/second-brain/SCHEMA.md`. Read that file first; it is not loaded automatically. The same workflows are Agent Skills in `.agents/skills/` (`wiki-ingest`, `wiki-query`, `wiki-health`, `wiki-lint`). Codex, Antigravity and OpenCode read that folder directly; `.claude/skills` is a symlink to it for Claude Code. In Claude Code and Antigravity they are slash commands (`/wiki-ingest`, …); in Codex mention them with `$wiki-ingest`.

## Tasks as checkboxes

**Scope:** applies only to markdown files written under `./docs` (`docs/**/*.md`), except the second brain (`docs/second-brain/`), which follows `docs/second-brain/SCHEMA.md`. Markdown files outside `./docs` are exempt.

When generating a markdown file under `./docs` that lists actions, tasks, or items to address (reports, plans, reviews), always use unchecked checkboxes (`- [ ]`) per item, with a summary of findings/recommendations up front. Keep IDs and titles consistent across sections for traceability, e.g.:

- [ ] ID=CRIT-1, Severity=Critical, Complexity=Low, Priority=P0, Estimate=minutes, Title=Title A, Fix description=Description of the fix to be implemented for CRIT-1, updated as tasks are completed.
- [ ] ID=HIGH-1, Severity=High, Complexity=Low, Priority=P1, Estimate=hours, Title=Title C, Fix description=Description of the fix to be implemented for HIGH-1, updated as tasks are completed.

`Estimate` is one of `minutes`, `hours`, `days`, `weeks`, `months`: how long a vibe-coding system (Claude, ChatGPT, …) is expected to take to complete the item end to end, not how long a human developer would take. It is a different axis from `Complexity`, which describes the change itself: a mechanical rename across hundreds of files is Low complexity and still an `hours` estimate.

If the originating request came from a `.md` file under `./docs` with checkboxes, mark the corresponding checkbox `- [✅]` as soon as that work is done — regardless of whether it was done: via a workflow (like Superpowers implementation), a direct command, a bug fix, or delegated to a subagent. Do this per item, not in one batch at the end. Only mark items actually completed and tested.

## Commit AI-tooling folders to Git

Folders that AI workflow plugins create under `docs/` (e.g. `docs/superpowers/` when Superpowers is used, containing plans and other workflow artifacts) must be committed to Git, not left untracked or gitignored. They are part of the project's traceable history of AI-assisted work.

The same applies to `.agents/skills/` (the shared skills), to the `agents/` and `skills/` folders inside `.claude/`, and to the equivalent folders inside any other AI coding CLI's config directory (`.github/`, `.codex/`, `.gemini/`, `.opencode/`, etc. — the config-dir table in `vibe/README.md` lists them, when that folder is present). These contain the agent and skill definitions the project standardizes on and must be tracked so every contributor and every AI assistant gets the same setup.
