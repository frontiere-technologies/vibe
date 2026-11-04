<!--
Template for a repository's AI instructions file.

Copy it to the repo root as `AGENTS.md` — the canonical file — then give every other CLI
a one-line file that imports it, so no content is ever duplicated:

    CLAUDE.md   ->  @AGENTS.md
    GEMINI.md   ->  @AGENTS.md

(see the config-dir table in `vibe/README.md` for which file each CLI reads).

Then fill in the `<placeholders>` and delete this comment.

The "Commands" and "Stack" sections are project-specific: replace them.
All other sections are project-independent conventions: keep them as they are.
Keep this file short — it is loaded on every interaction.
-->

# AGENTS.md

Read also the ./README.md file.

## Layout

- `sources/` — code and operations: `microservices/`, `libraries/`, `devops/`, `tests/` (e2e). See `sources/README.md` for what goes where.
- `docs/second-brain/` — knowledge base: source documents (`raw/`), the wiki (`wiki/`) and saved reports (`reports/`)

`docs/second-brain/wiki/sources/` holds summaries of source documents, not code.

## Commands

```bash
# From <path/to/the/app>, e.g. sources/microservices/<service>
<dev command>          # e.g. npm run dev
<build command>        # e.g. npm run build
<lint command>         # e.g. npm run lint
<unit test command>    # e.g. npm run test

# <E2E or integration tests, and the runner they must use>, e.g. from sources/tests/e2e: uv run pytest
```

## Stack

`<one-line summary of the tech stack, so the assistant does not have to infer it from the manifest>`

`<any dependency whose presence or absence is surprising, and the variables that do NOT need configuring>`

## Using the second brain

When a task needs project or domain context (designing, coding, reviewing, answering questions):
1. Read `docs/second-brain/wiki/index.md` to find the relevant pages
2. Read only those pages, following their `[[wikilinks]]` as needed (`[[Name]]` is the file `Name.md` under `docs/second-brain/wiki/`)
3. Mention which wiki pages you relied on

Do not modify anything under `docs/second-brain/` while doing other work unless the user asks. If the wiki looks wrong or is missing something, tell the user.

Wiki maintenance requests — `ingest <file>`, `query: <question>`, `health`, `lint`, or the same in plain words — follow `docs/second-brain/SCHEMA.md`. Read that file first; it is not loaded automatically. The same workflows are Agent Skills in `.agents/skills/` (`wiki-ingest`, `wiki-query`, `wiki-health`, `wiki-lint`).

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
