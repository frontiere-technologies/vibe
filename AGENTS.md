# AGENTS.md

This repository holds project code and a **second brain**: a wiki of project knowledge maintained by coding agents. This file is the canonical instructions file for every AI coding assistant; tool-specific files (`CLAUDE.md`, `GEMINI.md`, …) only import it.

Read also the ./README.md file.

A folder of the code can add its own `AGENTS.md`; its rules add to this file and win where they are more specific.

## Layout

- `docs/second-brain/` — knowledge base: source documents (`raw/`), the wiki (`wiki/`) and saved reports (`reports/`). `docs/second-brain/wiki/sources/` holds summaries of source documents, not code.
- `docs/` — other project documents (see `docs/README.md`).
- Code folders: not defined yet (chosen at setup from the presets in [`vibe/layouts.md`](vibe/layouts.md)).

## Commands

Not defined yet: there is no code yet.

## Stack

Not defined yet (see Commands).

## Conventions

Not defined yet. Do not add a dependency outside the approved libraries, once listed here, without asking the user.

## Testing

Not defined yet. Until it is defined: run the existing tests and linters before declaring a change done, and report failures as they are.

## Git workflow

Not defined yet. Until it is defined: one branch per change, from the default branch; commit subject in the imperative, with a body that says why; no push without the developer's approval.

## Language

Not defined yet. Until it is defined: code, documentation, wiki and commit messages in English; conversation in the developer's language.

## Definition of done

Not defined yet. Until it is defined: the existing tests and linters pass, and the result has been shown, not claimed.

## Boundaries

Not defined yet. Always, in every project:

- Never commit secrets: commit only templates (`*.example`, `.env.template`) and keep real values in ignored files.
- Do not change other projects or shared infrastructure from this repository.

## Using the second brain

When a task needs project or domain context (designing, coding, reviewing, answering questions):
1. Read `docs/second-brain/wiki/index.md` to find the relevant pages
2. Read only those pages, following their `[[wikilinks]]` as needed (`[[Name]]` is the file `Name.md` under `docs/second-brain/wiki/`)
3. Mention which wiki pages you relied on

Do not modify anything under `docs/second-brain/` while doing other work unless the user asks. If the wiki looks wrong or is missing something, tell the user.

Wiki maintenance requests — `ingest <file>`, `query: <question>`, `health`, `lint`, or the same in plain words — follow `docs/second-brain/SCHEMA.md`. Read that file first; it is not loaded automatically. The same workflows are Agent Skills in `.agents/skills/` (`wiki-ingest`, `wiki-query`, `wiki-health`, `wiki-lint`). Codex, Antigravity and OpenCode read that folder directly; `.claude/skills` is a symlink to it for Claude Code. In Claude Code and Antigravity they are slash commands (`/wiki-ingest`, …); in Codex mention them with `$wiki-ingest`.

## Commit AI-tooling folders to Git

Folders that AI workflow plugins create under `docs/` (e.g. `docs/superpowers/` when Superpowers is used, containing plans and other workflow artifacts) must be committed to Git, not left untracked or gitignored. They are part of the project's traceable history of AI-assisted work.

The same applies to `.agents/skills/` and `.agents/agents/` (the shared skills and agent definitions), to the `skills` and `agents` symlinks inside `.claude/`, and to the equivalent folders inside any other AI coding CLI's config directory (`.github/`, `.codex/`, `.gemini/`, `.opencode/`, etc. — the config-dir table in `vibe/README.md` lists them, when that folder is present). These contain the agent and skill definitions the project standardizes on and must be tracked so every contributor and every AI assistant gets the same setup.
