# Vibe Coding — Environment Setup Guide

This guide sets up a vibe-coding environment: an AI coding CLI writes most of the code, inside rules and knowledge kept in the repository. It works with any AI coding CLI (Claude Code, OpenAI Codex, Google Antigravity, OpenCode, GitHub Copilot CLI, Gemini CLI, …).

How the project's knowledge base is used is described in [second-brain.md](second-brain.md). Once the environment is set up, the [tutorial](https://github.com/frontiere-technologies/vibe/tree/development/vibe/tutorial) in the template repository shows it at work, hands-on.

![Vibe coding overview: roles, AI coding tools, agents, skills, MCP servers and LLMs](vibe-coding-overview.jpg)

## Setup checklist

0. [ ] Install the prerequisites: `git`, `gh`, an AI coding CLI
1. [ ] Bootstrap the repository from this template
2. [ ] Install the Superpowers workflow plugin (recommended)
3. [ ] Fill in the instructions file (`AGENTS.md`)
4. [ ] Verify the setup

## 0. Install the prerequisites

This step installs the tools every developer needs:

- `git`, and `gh` (the GitHub CLI) for pull requests, logged in with `gh auth login`
- at least one AI coding CLI, installed from its official page and logged in:

| CLI | Install and docs | Config dir | Instructions file | Skills | Agents (subagents) | MCP servers |
|---|---|---|---|---|---|---|
| Claude Code | [claude.ai/code](https://claude.ai/code) | `.claude/` | `CLAUDE.md` (→ `@AGENTS.md`) | `.claude/skills/` (symlink to `.agents/skills/`) | `.claude/agents/` (symlink to `.agents/agents/`) | `.mcp.json` |
| OpenAI Codex | [github.com/openai/codex](https://github.com/openai/codex) | `.codex/` | `AGENTS.md` | `.agents/skills/` | `.codex/agents/<name>.toml` (TOML: `name`, `description`, `developer_instructions`), converted from `.agents/agents/` | `config.toml`, `[mcp_servers]` tables |
| Google Antigravity (`agy`) | [antigravity.google](https://antigravity.google) | `.agents/` | `AGENTS.md` | `.agents/skills/` | check its docs | check its docs |
| OpenCode | [opencode.ai](https://opencode.ai) | `.opencode/` | `AGENTS.md` | `.agents/skills/` | `.opencode/agents/` (symlink to `.agents/agents/`; needs `mode: subagent`) | `opencode.json`, `mcp` key |
| GitHub Copilot CLI | [github.com/github/copilot-cli](https://github.com/github/copilot-cli) | `.github/` | `AGENTS.md` or `COPILOT-INSTRUCTIONS.md` | own folder — check its docs | `.github/agents/<name>.agent.md` — check its docs | check its docs |
| Gemini CLI | [github.com/google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli) | `.gemini/` | `GEMINI.md` (→ `@AGENTS.md`) | own folder — check its docs | `.gemini/agents/<name>.md` (Markdown + YAML, `name` required) | `.gemini/settings.json`, `mcpServers` key |

The CLIs change often: where a cell and the tool's docs disagree, the docs win, and the table should be updated.

The login uses a personal or organisation account: a subscription login, or an API key kept in the shell or the system keychain. Keys are never stored in a file of the repository.

A quick check of what is installed:

```bash
git --version && gh auth status
<cli> --version         # claude, codex, agy, opencode, copilot, gemini, …
```

## 1. Bootstrap the repository

This repository is a [GitHub template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template). A new project gets its own repository from it, with a fresh history:

```bash
gh repo create my-project --template frontiere-technologies/vibe --private --clone
cd my-project
```

On GitHub, the same is **Use this template → Create a new repository** on the template's page.

Outside GitHub, or with `git` alone, the template is cloned and given a fresh history by hand:

```bash
git clone https://github.com/frontiere-technologies/vibe.git my-project
cd my-project
rm -rf .git && git init && git add -A && git commit -m "Start the project from the vibe template"
git remote add origin <url-of-the-empty-repository>
git push -u origin HEAD
```

### Symlinks on Windows

The CLIs' skills and agents folders (`.claude/skills`, `.claude/agents`, `.opencode/agents`, …) are symlinks to `.agents/`. On Windows, Git creates them only with Developer Mode enabled and `core.symlinks=true`; otherwise each one becomes a small text file and the CLI sees no skills or agents. Enable Developer Mode, then clone with `git clone -c core.symlinks=true <url>`, or fix an existing clone from Git Bash:

```bash
git config core.symlinks true
git ls-files -s | awk '$1 == "120000" { print $4 }' | xargs git checkout --
```

## 2. Install the Superpowers workflow plugin

[Superpowers](https://github.com/obra/superpowers) is the recommended workflow for every non-trivial change: design before code, a plan, tests before code, review. It is not required, and the template does not preconfigure it: the rest of the template works without it. To install it, follow the [Superpowers documentation](https://github.com/obra/superpowers), which covers the CLIs it supports. Superpowers saves its specs and plans in `docs/superpowers/`, which is committed.

A project that does without Superpowers can use another harness, such as [AI Hero](https://www.aihero.dev/), the [BMAD Method](https://github.com/bmad-code-org/bmad-method), [Spec Kit](https://github.com/github/spec-kit) or [Get Shit Done](https://github.com/gsd-build/get-shit-done), or the team's own written process covering the same ground, and records the choice in `AGENTS.md` (*Git workflow* and *Definition of done*).

## 3. Fill in the instructions file (`AGENTS.md`)

`AGENTS.md` at the repository root is the single instructions file. Every CLI reads it at startup, directly or through a one-line import (`CLAUDE.md` and `GEMINI.md` contain only `@AGENTS.md`). Its content is never copied into another instructions file: two copies drift apart.

Its sections:

| Section | Content | In a new project |
|---|---|---|
| Pointer to `README.md` | So the project overview is not duplicated | already there |
| **Layout** | Where knowledge and code live (`docs/`, `sources/`) | already there; updated if the code folders change |
| **Commands** | Install, run, build, lint, format, test, and from which folder | filled in |
| **Stack** | Languages and versions, frameworks, runtime, in one or two lines | filled in |
| **Conventions** | Architectural layers and allowed dependencies, patterns, naming, the allow-list of approved ("certified") libraries; nothing outside it is added without asking | filled in |
| **Testing** | Required kinds of test, where they live, what is written test-first | filled in |
| **Git workflow** | Branches, commit message format, when the agent may push | the default is kept or replaced |
| **Language** | The language of code, documentation, wiki and commit messages, and of the conversation | the default is kept or replaced |
| **Definition of done** | The checks a change must pass before it counts as done | the default is kept or replaced |
| **Boundaries** | Files, folders and systems the agent must not change, or only after asking (generated code, applied migrations, vendored code, CI/CD, production configuration) | project rules added; the two rules already there stay |
| **Using the second brain** | How the wiki is used, and where its maintenance rules are | kept as it is |
| **Commit AI-tooling folders to Git** | Which AI folders are committed | kept as it is |

Some principles for filling it in:

- **Each section starts as *Not defined yet*.** A section that has a safe default keeps it until the project replaces it.
- **What is known now is written now.** A section that cannot be filled in yet stays *Not defined yet*, and the agent follows the safe default written there, for example "run the existing tests before declaring a change done".
- **Rules are written so that a test or a reviewer can check them.** "Breakpoints at 600 and 1200 px; every screen tested at three widths" can be checked; "make it responsive" cannot.
- **Approved libraries form an allow-list.** Anything not on it becomes a question for the developer, not a choice for the agent: this is what keeps a request like "make it elegant" from turning into five new dependencies.
- **The file stays short.** It is loaded on every interaction. Rules needed only for some work go in files read on demand, as the template does with the second-brain rules in `docs/second-brain/SCHEMA.md`.
- **Rules for one part of the code live next to it.** A service or app with rules of its own gets an `AGENTS.md` in its folder; those rules add to the root file and win where they are more specific.
- **When the agent breaks a rule, the rule is fixed, not only the code.** A rule the agent ignored was not clear enough: it is sharpened, committed, and tried again in a new session.

`AGENTS.md` is committed after every change: the agent works from the committed file, and the worktrees of the workflow start from the last commit.

## 4. Verify the setup

These checks run from the repository root after the previous steps; each one that passes ticks the setup checklist.

1. **Symlinks.** The CLI's skills and agents folders (see the table in step 0, for example `.claude/skills/` and `.claude/agents/`) list `wiki-health`, `wiki-ingest`, `wiki-lint` and `wiki-query`, and `architect-reviewer`, `code-reviewer` and `ui-ux-tester`. If a folder shows as a file instead, see *Symlinks on Windows* in step 1.
2. **GitHub CLI.** `gh auth status` reports a logged-in account.
3. **Instructions file.** In the AI coding CLI, the question *"Which instructions file did you load, and which sections are still Not defined yet?"* gets an answer that comes from `AGENTS.md`, directly or through `CLAUDE.md`/`GEMINI.md`.
4. **Rules applied.** The question *"Which libraries may you add to this project?"* gets the allow-list of `AGENTS.md` back, or the answer that there is none yet.
5. **Skills.** The question *"Which skills are available?"* lists the four `wiki-*` skills and, when Superpowers is installed, its skills (`brainstorming`, `writing-plans`, `test-driven-development`, …). In CLIs with slash commands, typing `/` shows them.
6. **Second brain.** `/wiki-health` (in Codex `$wiki-health`; in any CLI just `health`) reports, on a new repository, an empty wiki with no errors.
7. **Agents.** The CLI's list of subagents includes `code-reviewer`, `architect-reviewer` and `ui-ux-tester`.
8. **MCP servers** (if the project has any). The CLI's MCP command (for example `claude mcp list`) shows each server of the project's MCP configuration (see the table in step 0) as connected.
9. **Nothing personal committed.** `git status` is clean, and `git ls-files | grep -E 'settings\.local|(^|/)\.env($|\.)' | grep -vE '\.(example|template)$'` prints nothing.

## Working in the environment

![Vibe coding workflow: reviews and ideas become markdown action items, then go through pre-processing and the Superpowers cycle](vibe-coding-workflow.jpg)

Once the environment is set up, the work follows a loop:

1. **Collecting the work.** Ideas, bugs and review findings become Markdown items with checkboxes (`- [ ]`), in an issue or in `docs/`.
2. **Preparing complex requests.** A large or vague request is first refined in an AI chat, so the agent starts from a clear prompt.
3. **The workflow cycle.** Design, plan, implementation with tests, review, finish, with Superpowers or the harness chosen in step 2. Debugging, when needed, happens inside the same cycle.
4. **Feeding the knowledge back.** New source documents go into `docs/second-brain/raw/` and are ingested; decisions worth keeping become wiki pages.
5. **Retrospective.** From time to time, the way the agent worked is reviewed, and the lessons learned become rules in `AGENTS.md`, so the next session starts better.

### Quality reviews

As the code grows, the reviewer agents in `.agents/agents/` are run on it, each as a subagent rather than inline, so that it reviews with a fresh context. The agents only read and report; the session that ran them saves each report:

- `code-reviewer` → `docs/reviews/<YYYY-MM-DD>-code-reviewer.md`
- `architect-reviewer` → `docs/reviews/<YYYY-MM-DD>-architect-reviewer.md`
- `ui-ux-tester`, if the project has a UI → `docs/reviews/<YYYY-MM-DD>-ui-ux-tester.md`

The findings are new work items: they go back to the first point of the loop.

## Keeping the environment up to date

- **CLIs and plugins** change often: they are updated every few weeks, followed by the checks of step 4.
- **Skills and agents** copied from collections do not update by themselves: an update is a deliberate change, with the diff read before it is committed.
- **`AGENTS.md`** grows with the project: a section is filled in as soon as it stops being *Not defined yet*, and every retrospective can add a rule.
- **The template itself** changes over time; [`CHANGELOG.md`](CHANGELOG.md) lists what each version changes. A project brings in the changes it wants by hand.

## Resources

- Superpowers plugin: https://github.com/obra/superpowers
- AI Hero (an alternative to Superpowers): https://www.aihero.dev/
- BMAD Method (an alternative to Superpowers): https://github.com/bmad-code-org/bmad-method
- Spec Kit (an alternative to Superpowers): https://github.com/github/spec-kit
- Get Shit Done (an alternative to Superpowers): https://github.com/gsd-build/get-shit-done
- Agent Skills standard: https://agentskills.io
- Anthropic official skills: https://github.com/anthropics/skills
- Jeffallan's skills collection: https://github.com/Jeffallan/claude-skills
- VoltAgent subagents collection: https://github.com/VoltAgent/awesome-claude-code-subagents/tree/main/categories (single agents are copied; the collection is not installed as a whole)
- Awesome Claude (menu of extensions): https://awesomeclaude.ai
- MCP server registries: https://registry.modelcontextprotocol.io/, https://mcpservers.com/
