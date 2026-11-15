---
name: vibe-check-setup
description: Run the mechanical checks of the vibe setup (symlinks, AGENTS.md imports, ignore rules, tracked secrets, skills, Markdown links) and explain each failure. Use when the user says "check the setup", "verify the setup", at step 8 of vibe/README.md, or after the vibe-setup or vibe-update skills change the repository.
---

Check that the repository still follows the setup of `vibe/README.md`.

## Run

From the repository root, with bash:

```bash
bash .agents/skills/vibe-check-setup/scripts/check-setup.sh
```

It needs only bash, git and POSIX tools (bash 3.2 on macOS, Linux, Git Bash on Windows). It prints one line per check, `PASS <check>` or `FAIL <check>: <reason>`, and exits 1 if any check failed. CI runs the same script (`.github/workflows/vibe-checks.yml`).

| Check | What it verifies |
|---|---|
| `symlinks` | `.claude/skills` and `.claude/agents` (and `.opencode/agents`, `.gemini/agents` when present) are symlinks into `.agents/` |
| `imports` | `AGENTS.md` exists; `CLAUDE.md` and `GEMINI.md` import it with `@AGENTS.md` |
| `gitignore` | `.env`, `.env.local` and `.claude/settings.local.json` are ignored; `.env.example` and `.env.template` are not |
| `no-secrets-tracked` | no `.env*` file (other than `*.example`, `*.template`) and no `settings.local.json` is tracked |
| `skills` | the four `wiki-*` skills exist; every skill folder has a `SKILL.md` whose front matter has a `name` equal to the folder and a `description` |
| `links` | every relative link in the tracked Markdown files points to a file that exists (links in code blocks and inline code are skipped) |

## Report

- Report every line as it is. Never call the setup fine while a `FAIL` line is there.
- For each `FAIL`, say what the reason means and how to fix it, using *Troubleshooting* in `vibe/README.md` (for `symlinks`, *Symlinks on Windows* in step 1). Fix it only on the developer's yes.
- The script cannot see what the AI coding CLI loaded (instructions file, skills, agents, MCP servers): those are the questions of step 8 of the guide, and they count only in a session started after the last commit.

## Change the checks

The script and its tests are in `scripts/`. After a change to the script, run its tests too:

```bash
bash .agents/skills/vibe-check-setup/scripts/tests/check-setup.test.sh
```

They clone the repository at `HEAD` into a temporary folder and break it one way per case, so commit first: uncommitted changes are not in the clone.
