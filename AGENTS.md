# AGENTS.md

This repository holds application code and a **second brain**: a wiki of project knowledge maintained by coding agents. `CLAUDE.md` and `GEMINI.md` only import this file.

Read also the ./README.md file. For the vibe-coding environment setup (Superpowers, agents, skills, MCP), see `vibe/README.md`.

## Layout

- `sources/` — code and operations: `microservices/`, `libraries/`, `devops/`, `tests/` (e2e). See `sources/README.md` for what goes where.
- `docs/second-brain/` — knowledge base: source documents (`raw/`), the wiki (`wiki/`) and saved reports (`reports/`)

`docs/second-brain/wiki/sources/` holds summaries of source documents, not code.

## Commands

Not defined yet: there is no code in `sources/` yet.

## Stack

Not defined yet (see Commands).

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

Folders that the Superpowers plugin creates under `docs/` (e.g. `docs/superpowers/`, containing plans and other workflow artifacts) must be committed to Git, not left untracked or gitignored. They are part of the project's traceable history of AI-assisted work.

The same applies to `.agents/skills/` (the shared skills), to the `agents/` and `skills/` folders inside `.claude/`, and to the equivalent folders inside any other AI coding CLI's config directory (`.github/`, `.codex/`, `.gemini/`, etc. — see the config-dir table in `vibe/README.md`). These contain the agent and skill definitions the project standardizes on and must be tracked so every contributor and every AI assistant gets the same setup.
