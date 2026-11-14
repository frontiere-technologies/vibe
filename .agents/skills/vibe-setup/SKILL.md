---
name: vibe-setup
description: Run the setup of a new project started from the vibe template, step by step, asking one decision at a time. Use when the user says "run the setup", "set up the project", "continue the setup", or pastes the setup prompt of vibe/README.md.
---

Run the project setup described in `vibe/README.md`.

The guide is the only source for what each step contains: read `vibe/README.md` first, and follow the step you are on as written there. This skill does not repeat the steps; it only says how to run them.

## Find where the setup stands

1. For each step N, run `git log --oneline | grep "Setup step <N>:"`: the step is done when the commit exists. Step 0 changes no file; check it with its commands (`git --version`, `gh auth status`).
2. A step with no such commit (a repository set up by hand or before this convention, or a developer joining an existing project) is judged from the files instead: the files the guide says that step adds or changes (for step 1: `vibe/tutorial/` and `docs/superpowers/` removed or kept on purpose, a code layout from `vibe/layouts.md` present, *Layout* of `AGENTS.md` filled in; for step 3: sections no longer `Not defined yet.`). Ask the developer to confirm a step found done this way; do not redo it.
3. Run `bash vibe/scripts/check-setup.sh` as a cross-check and for step 8. A `FAIL` line is a problem to report, not a step to skip.
4. Say which steps are done and which comes next, then go on from there. A developer joining an existing project only confirms steps 1 and 3 to 7 and runs steps 0, 2 and 8.

## Run a step

- Ask one decision at a time. Offer the default and say it is the default; wait for the answer before the next question. Never batch questions.
- Do the step's work with the commands and files the guide names. Do not add a dependency, skill, agent or MCP server the developer did not accept.
- End every step 1 to 8 with one commit, subject `Setup step <N>: <what was done>`, body saying why. Check `git status` first, so a commit holds only that step's work. A step skipped by choice (no extra skills, no MCP servers) still gets the commit, with `--allow-empty` if nothing changed, and the subject or body says it was skipped.
- Never push, and never create a remote, tag or issue.

## Decisions, in order

| Decision | Guide step | Default |
|---|---|---|
| Licence of the project | 1 | MIT with the project's copyright holder and year: ask for the holder (no default name; suggest the git user or organisation as a hint) and rewrite the `Copyright (c)` line of `LICENSE`; another licence replaces the file |
| Layout preset: `services`, `single-app`, `library` or `data` (see `vibe/layouts.md`) | 1 | none: the developer must choose |
| Remove the template's tutorial and design history? (`git rm -r vibe/tutorial docs/superpowers`; one question for both) | 1 | yes, remove both |
| What the project does, for the root `README.md` (the *License* line follows the licence decision) | 1 | the *Fill in* text stays |
| The `AGENTS.md` sections to fill in (Commands, Stack, Conventions, Testing, and the others the guide lists) | 3 | a section that is not known yet stays `Not defined yet.` |
| Extra skills | 4 | none |
| Agents: does the project have a UI | 5 | keep all three reviewers; if there is no UI, remove `.agents/agents/ui-ux-tester.md` (files under `vibe/` are never edited: they belong to the template) |
| MCP servers | 6 | none |

The permissions and ignore rules of step 7 and the checks of step 8 follow the guide without a separate decision, except what step 7 asks about the project's own secret files.

Keep `AGENTS.md` short, with detail in files read on demand (see step 3 of the guide), and in the guide's style. Write only what the developer has said; do not invent stack, commands or libraries.

## Stop for the developer

Stop, say exactly what to do, and wait when the next action is one only the developer can do:

- an interactive login (`gh auth login` and the CLI's own login);
- a token or key: it is set as an environment variable by the developer, never typed into a file or into the chat;
- the restart after step 2, because plugins and skills load only when a session starts. Commit first, then tell the developer to start a new session and say "continue the setup";
- the checks of step 8 that ask the CLI what it loaded: they count only in a session started after the last commit.

## Finish

Run step 8, report each check as `PASS` or `FAIL` with the reason, and list what is left (sections still `Not defined yet.`, skipped steps). The prompt in the guide's *Setup run by the AI coding CLI* is the fallback for a CLI that does not load skills.
