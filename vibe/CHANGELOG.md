# Changelog of the vibe template

What each version of the template changes, newest first. Each version has a heading `## <version> — <YYYY-MM-DD>` and a list of changes. A project started from an older version brings a change in by hand, if it wants it.

## 0.1.0 — 2026-11-15

- **Licence.** `LICENSE` is the template's own MIT licence, which a project replaces with any licence. The notices of the third-party files (the `wiki-*` skills, the second-brain schema, the reviewer agents) are in `.agents/THIRD_PARTY_NOTICES.md`, which stays.
- **Second brain.** `docs/second-brain/SCHEMA.md` has a format for entity pages and one for concept pages, and source pages record where the document came from (`origin:`).
- **`AGENTS.md`.** It holds only the project's rules: the explanations for the template's user moved to step 3 of the guide. New sections *Git workflow*, *Language* and *Definition of done*, each with a default. `docs/README.md` maps the `docs/` folder. The guide names the Superpowers version it was verified with (7.0.0) and no longer has a *To be evaluated* list.
- **Code layout.** `sources/` stays the default code layout. Step 1 of the guide says how a project of another kind replaces it.
- **Tutorial.** Step 1 removes `vibe/tutorial/` by default; the guide links to the lessons in the template repository.
- **Superpowers folder.** The template does not ship `docs/superpowers/`: Superpowers, the recommended workflow, creates it with the project's own specs and plans, and a project that does without Superpowers never has it.
- **Hygiene.** An `.editorconfig`. The guide describes an optional local gitleaks pre-commit hook for secrets.
- **Reviewer agents.** `.agents/agents/` ships `code-reviewer`, `architect-reviewer` and `ui-ux-tester`; step 5 keeps or removes them instead of downloading them.
