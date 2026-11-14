# Changelog of the vibe template

What each version of the template changes for a project, newest first. A project records the version it came from in `.vibe-template`, and the `vibe-update` skill brings it to a later one (see *Keeping the environment up to date* in [the guide](README.md)).

Versions follow [semantic versioning](https://semver.org) and are tags `v<version>` of the template repository. Each version has a heading `## <version> — <YYYY-MM-DD>` and two lists: *Changes*, and *By hand*, what a project must do itself because an update does not do it.

## 0.1.0 — 2026-11-14

### Changes

- **Setup checks.** `vibe/scripts/check-setup.sh` checks the symlinks, the imports of `AGENTS.md`, the ignore rules, tracked secrets, the skills and the Markdown links, one `PASS` or `FAIL` line each; step 8 of the guide runs it first.
- **Licence.** `LICENSE` is the template's own MIT licence, which a project replaces with any licence. The notices of the third-party files (the `wiki-*` skills, the second-brain schema, the reviewer agents) are in `.agents/skills/THIRD_PARTY_NOTICES.md`, which stays.
- **Second brain.** `docs/second-brain/SCHEMA.md` has a format for entity pages and one for concept pages, and source pages record where the document came from (`origin:`).
- **`AGENTS.md`.** It holds only the project's rules: the explanations for the template's user moved to step 3 of the guide. New sections *Git workflow*, *Language* and *Definition of done*, each with a default. `docs/README.md` maps the `docs/` folder. The guide names the Superpowers version it was verified with (7.0.0) and no longer has a *To be evaluated* list.
- **Code layout.** The template ships no code folders. Step 1 asks for a preset of `vibe/layouts.md` (`services`, `single-app`, `library`, `data`) and creates only its folders. The code root of the `services` preset is `src/`, no longer `sources/`.
- **Tutorial.** Step 1 removes `vibe/tutorial/` by default; the guide links to the lessons in the template repository.
- **CI and hygiene.** `.github/workflows/vibe-checks.yml` runs the setup checks and a gitleaks secret scan on every push and pull request. New pull request and work-item templates in `.github/`, and an `.editorconfig`.
- **Reviewer agents.** `.agents/agents/` ships `code-reviewer`, `architect-reviewer` and `ui-ux-tester`; step 5 keeps or removes them instead of downloading them.
- **Setup skill.** `vibe-setup` runs the setup step by step, one decision at a time, with one commit per step.
- **Template updates.** `.vibe-template` records the template version a project came from and which files the template owns; the `vibe-update` skill brings later versions in. `vibe/` belongs to the template: project-specific setup notes go in `AGENTS.md` or the project's `README.md`.

### By hand

- **Projects created before 0.1.0.** They have no `.vibe-template`. Create it by hand: copy the template's file (`https://github.com/frontiere-technologies/vibe/blob/v0.1.0/.vibe-template`) to the root of the project, keeping `version: 0.1.0`. Use the `vibe-update` skill for later versions; it needs that file to start.
