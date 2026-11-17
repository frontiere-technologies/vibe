# Changelog of the vibe template

What each version of the template changes, newest first. Each version has a heading `## <version> — <YYYY-MM-DD>` and a list of changes. A project started from an older version brings a change in by hand, if it wants it.

## 0.2.0 — 2026-11-17

- **Shorter setup.** The guide has steps 0–4: the steps that added project skills, kept or removed the reviewer agents, configured the MCP servers, and set permissions and ignored files are gone, and *Verify the setup* is step 4. This replaces the *Permissions*, *Hygiene* (the gitleaks pre-commit hook) and *Reviewer agents* notes of 0.1.0 that pointed to steps 5 and 7; the reviewer agents still ship in `.agents/agents/`, and `.editorconfig` stays.
- **Leaner guide.** `vibe/README.md` drops *The four parts of the environment*, *Which steps apply*, *Setup run by the AI coding CLI* (and its `Setup step` commit convention), the optional tools, *Shared and personal files* and *Troubleshooting*, and speaks of AI coding CLIs in general rather than of Claude Code only. *Symlinks on Windows* covers every CLI's links to `.agents/` with one command. Step 1 keeps only the commands to create the repository and the Windows symlink warning: it no longer lists the adaptations (README, copyright line, removing `vibe/tutorial/`), which replaces the *Licence* and *Tutorial* notes of 0.1.0. Step 2 recommends Superpowers, points to its own documentation instead of describing its skills, and names AI Hero, BMAD Method, Spec Kit and Get Shit Done as alternatives.
- **Superpowers not preconfigured.** `.claude/settings.json` is no longer shipped: the template recommends Superpowers but does not enable it, which replaces the *Permissions* note of 0.1.0.
- **Consistent documentation.** The guide, the second-brain pages and the tutorial no longer contradict each other: `log.md` records only ingests, filed queries and lints; `overview.md` is revised at ingest when a source changes the synthesis; reviewer agents only report, and the session that runs them saves the report; `SCHEMA.md` lists the same formats as `second-brain.md` and names the markitdown output `<name>.md`.

## 0.1.0 — 2026-11-15

- **Licence.** `LICENSE` is the MIT licence; the setup asks for the project's copyright holder and rewrites the copyright line, and a project may replace the file with any other licence. The notices of the third-party files (the `wiki-*` skills, the second-brain schema, the reviewer agents) are in `.agents/THIRD_PARTY_NOTICES.md`, which stays.
- **Second brain.** `docs/second-brain/SCHEMA.md` has a format for entity pages and one for concept pages, and source pages record where the document came from (`origin:`).
- **`AGENTS.md`.** It holds only the project's rules: the explanations for the template's user moved to step 3 of the guide. New sections *Git workflow*, *Language* and *Definition of done*, each with a default. `docs/README.md` maps the `docs/` folder. The guide names the Superpowers version it was verified with (7.0.0) and no longer has a *To be evaluated* list.
- **Code layout.** `sources/` stays the default code layout. Step 1 of the guide says how a project of another kind replaces it.
- **Tutorial.** Step 1 removes `vibe/tutorial/` by default; the guide links to the lessons in the template repository.
- **Superpowers folder.** The template does not ship `docs/superpowers/`: Superpowers, the recommended workflow, creates it with the project's own specs and plans, and a project that does without Superpowers never has it.
- **Permissions.** `.claude/settings.json` ships with the Superpowers plugin setting only. Step 7 of the guide shows the recommended `deny` rules (secret files, `docs/second-brain/raw/`) and the `allow` list a project adds.
- **Hygiene.** An `.editorconfig`. The guide describes an optional local gitleaks pre-commit hook for secrets.
- **Reviewer agents.** `.agents/agents/` ships `code-reviewer`, `architect-reviewer` and `ui-ux-tester`; step 5 keeps or removes them instead of downloading them.
