# Vibe Coding — Environment Setup Guide

This guide walks through setting up a development environment for vibe coding, where an AI coding CLI writes most of the code inside rules and knowledge that live in the repository. It applies to any project started from this template and to any AI coding CLI (Claude Code, OpenAI Codex, Google Antigravity, OpenCode, GitHub Copilot CLI, Gemini CLI, …), with Claude Code and the Superpowers plugin as the reference setup; where the other CLIs differ, the guide says so.

How the project's knowledge base is used is described in [second-brain.md](second-brain.md). Once the environment is set up, the [tutorial](tutorial/README.md) shows it at work, hands-on.

![Vibe coding overview: roles, AI coding tools, agents, skills, MCP servers and LLMs](vibe-coding-overview.jpg)

---

## The four parts of the environment

The agent is free to write code, within four boundaries. Each one has a fixed place in the repository:

| Part | What it holds | Where it lives |
|---|---|---|
| **Knowledge** | What the project is about: domain, decisions, source documents | `docs/second-brain/` — a wiki the agent writes and keeps up to date |
| **Rules** | Stack, commands, layout, conventions, approved libraries, test policy, boundaries | `AGENTS.md` — read by the agent on every interaction |
| **Workflow** | How a change is made: design, plan, isolated branch, test-first build, review, finish | The Superpowers plugin; specs and plans saved in `docs/superpowers/` |
| **Tools** | Specialised abilities: skills, subagents (reviewers), MCP servers | `.agents/skills/`, `.agents/agents/`, the MCP configuration |

All of it is committed to Git: the environment is part of the project, not of one developer's machine, so every developer and every CLI works the same way. Only personal settings and secrets stay out (see [Shared and personal files](#shared-and-personal-files)).

---

## Which steps apply

| Situation | Steps |
|---|---|
| A new project started from this template | all of them, 0 to 8 |
| A developer joining a project already started from this template | 0, 2 and 8. Steps 1 and 3–7 are already in the repository, to be cloned and checked |
| A second AI coding CLI added to the project | 0 for the new CLI, the *Other CLIs* notes of steps 2 and 4–7, then 8 |
| A first trial of the approach | 0–2, then the [tutorial](tutorial/README.md) on a throwaway branch |

## Setup checklist

0. [ ] Install the prerequisites: `git`, `gh`, an AI coding CLI
1. [ ] Bootstrap the repository from this template
2. [ ] Install the Superpowers workflow plugin
3. [ ] Fill in the instructions file (`AGENTS.md`)
4. [ ] Add the project skills
5. [ ] Add the project agents (subagents)
6. [ ] Configure the MCP servers
7. [ ] Set permissions and ignore local files
8. [ ] Verify the setup

## Setup run by the AI coding CLI

The steps can be followed by hand, or run by the AI coding CLI itself: it reads this guide, runs the commands, and asks the developer for every decision. Only what the CLI cannot do on its own stays with the developer.

Before the CLI can take over, the developer installs `git` and one AI coding CLI and logs in to it (a CLI cannot install itself), then clones the template and starts the CLI in it:

```bash
git clone https://github.com/frontiere-technologies/vibe.git my-project
cd my-project
claude      # or: codex, gemini, opencode, …
```

The setup starts with one prompt:

> "Run the setup from `vibe/README.md`, step by step. Ask me whenever you need to decide something, and stop when an action of mine is needed."

The prompt works in any language, for example in Italian: *"Esegui il setup partendo da `vibe/README.md`, passo per passo. Fammi le domande quando devi decidere qualcosa, e fermati quando serve un'azione mia."*

What happens next:

- **Questions.** The CLI asks for every decision, one at a time: a fresh Git history or not, the licence, the layout of `sources/`, the sections of `AGENTS.md` (stack, commands, approved libraries, tests, boundaries), which skills, agents and MCP servers to add.
- **Pauses for the developer.** The CLI stops for what only the developer can do: the interactive logins (`gh auth login`), the tokens of the MCP servers (set as environment variables, never written to a file), and the restart after step 2, because plugins and skills are loaded only when a session starts.
- **Commits.** Each step ends with a commit, so the work done so far is safe and a new session can see where the setup stands.
- **Resuming.** After the restart, or in any later session, the setup continues with: *"Continue the setup from `vibe/README.md`: check which steps are already done and go on from there."*
- **Final checks.** The checks of step 8 that ask the CLI what it loaded are meaningful only in a new session, started after the last commit.

The same prompt works for a developer joining an existing project: the CLI finds steps 1 and 3–7 already in the repository and only checks them.

---

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

Optional tools:

- [`markitdown`](https://github.com/microsoft/markitdown) (`pip install 'markitdown[all]'`), to ingest `.docx`, `.pptx`, `.xlsx` and other binary files into the second brain (see `docs/second-brain/SCHEMA.md`)
- [`uv`](https://docs.astral.sh/uv/), if the project has Python code; Python is then run through `uv run …` rather than by calling `python`/`pip` directly

A quick check of what is installed:

```bash
git --version && gh auth status
claude --version        # or: codex --version, gemini --version, opencode --version, …
```

---

## 1. Bootstrap the repository

A new project starts as a clone of this template:

```bash
git clone https://github.com/frontiere-technologies/vibe.git my-project
cd my-project
rm -rf .git && git init    # optional: start with a fresh history
```

The clone is ready to use: the second brain is empty, `AGENTS.md` has its project sections still to fill in, and there is no sample code or data. What still describes the template rather than the project is then adapted:

- the root `README.md` — a skeleton for the project's README, whose sections are filled in
- `LICENSE` — replaced with the project's licence, keeping the SamurAIGPT copyright line and the MIT text (in the same file or a separate one): the `wiki-*` skills and the second brain derive from MIT-licensed work, and the licence's only condition is that this notice stays with every copy (see the provenance note at the end of each skill)
- `sources/` — the service-based layout is kept or replaced with the project's own folders (see *Layout* in `AGENTS.md`)

The `vibe/` folder stays: this guide, the [second brain guide](second-brain.md) and the [tutorial](tutorial/README.md) remain part of the project. Tutorial lessons run only on a throwaway branch, never on the branch the project is built on (see the tutorial's README).

The starting point is committed before the agent changes anything, so every later change can be compared with it:

```bash
git add -A && git commit -m "Start the project from the vibe template"
```

### Symlinks on Windows

`.claude/skills` and `.claude/agents` are symlinks to `.agents/skills` and `.agents/agents`. On Windows, Git creates real symlinks only with `core.symlinks=true` and Developer Mode enabled (or administrator rights). Otherwise it checks each symlink out as a small text file containing its target (`../.agents/skills`), and Claude Code sees neither the skills nor the agents.

The fix is to enable Developer Mode, then run from Git Bash:

```bash
git config core.symlinks true
rm .claude/skills .claude/agents && git checkout -- .claude/skills .claude/agents
```

The same applies to any other symlink added later, such as `.opencode/agents`. For new clones, `git clone -c core.symlinks=true <url>` creates the symlinks directly.

---

## 2. Install the Superpowers workflow plugin

[Superpowers](https://github.com/obra/superpowers) provides the workflow used for every non-trivial change: design before code, and tests before code.

In Claude Code, the plugin is enabled for the project in `.claude/settings.json`, which is committed:

```json
{
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true
  }
}
```

The template already contains this file, so Claude Code offers to install the plugin when the project is first opened. In a repository without the file, `claude plugin install superpowers@claude-plugins-official --scope project` writes it, and the file is then committed.

**Other CLIs:** Superpowers has ports for some of them, installed as described in their READMEs. Without a port, the same steps can be followed as a written process, asking the agent for each one by name.

The workflow has one skill per step:

1. `brainstorming` — questions one at a time, until the idea is a design document the developer approves; no code before that
2. `using-git-worktrees` — the work moves to its own branch, in a separate worktree
3. `writing-plans` — the design becomes small tasks with exact files, tests and commands
4. `subagent-driven-development` or `executing-plans` — the tasks are built one by one, with a review after each one or in batches
5. `test-driven-development` — for every task: failing test, then code, then passing test, then commit
6. `requesting-code-review` — the work is reviewed against the plan before going on
7. `finishing-a-development-branch` — the tests run again, then the branch is merged, opened as a pull request, or kept

This sequence is the default for features and bug fixes; it is skipped only for truly trivial changes, such as a typo or a version bump.

---

## 3. Fill in the instructions file (`AGENTS.md`)

`AGENTS.md` at the repository root is the single instructions file. Every CLI reads it at startup, directly or through a one-line import (`CLAUDE.md` and `GEMINI.md` contain only `@AGENTS.md`). Its content is never copied into another instructions file: two copies drift apart.

Its sections:

| Section | Content | In a new project |
|---|---|---|
| Pointer to `README.md` | So the project overview is not duplicated | already there |
| **Layout** | Where knowledge and code live (`sources/` for service-based systems, see `sources/README.md`; other folders for other kinds of project) | the code part is filled in |
| **Commands** | Install, run, build, lint, format, test, and from which folder | filled in |
| **Stack** | Languages and versions, frameworks, runtime, in one or two lines | filled in |
| **Conventions** | Architectural layers and allowed dependencies, patterns, naming, the allow-list of approved libraries | filled in |
| **Testing** | Required kinds of test, where they live, what is written test-first, the checks a change must pass | filled in |
| **Boundaries** | What the agent must not touch, or only after asking | project rules added; the two rules already there stay |
| **Using the second brain** | How the wiki is used, and where its maintenance rules are | kept as it is |
| **Commit AI-tooling folders to Git** | Which AI folders are committed | kept as it is |

Some principles for filling it in:

- **What is known now is written now.** A section that cannot be filled in yet stays *Not defined yet*, and the agent follows the safe default written there, for example "run the existing tests before declaring a change done".
- **Rules are written so that a test or a reviewer can check them.** "Breakpoints at 600 and 1200 px; every screen tested at three widths" can be checked; "make it responsive" cannot.
- **Approved libraries form an allow-list.** Anything not on it becomes a question for the developer, not a choice for the agent: this is what keeps a request like "make it elegant" from turning into five new dependencies.
- **The file stays short.** It is loaded on every interaction. Rules needed only for some work go in files read on demand, as the template does with the second-brain rules in `docs/second-brain/SCHEMA.md`.
- **Rules for one part of the code live next to it.** A service or app with rules of its own gets an `AGENTS.md` in its folder; those rules add to the root file and win where they are more specific.
- **When the agent breaks a rule, the rule is fixed, not only the code.** A rule the agent ignored was not clear enough: it is sharpened, committed, and tried again in a new session.

`AGENTS.md` is committed after every change: the agent works from the committed file, and Superpowers' worktrees start from the last commit.

---

## 4. Add the project skills

A skill is a folder with a `SKILL.md`: instructions, and optionally scripts and references, that the agent loads only when a task needs them. Project skills live in `.agents/skills/<name>/SKILL.md`, the [Agent Skills](https://agentskills.io) folder read by Codex, Antigravity and OpenCode. Claude Code reads the same files through the `.claude/skills` symlink, so each skill is written once.

Part of the template:

- `wiki-ingest`, `wiki-query`, `wiki-health`, `wiki-lint` — maintain and query the second brain in `docs/second-brain/`

Further skills depend on the project's stack and kind of work, for example:

| Need | Skill | Source |
|---|---|---|
| Python | `python-pro` (type hints, async, pytest, mypy strict, black and ruff) | [Jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills/tree/main/skills/python-pro) |
| Flutter | `flutter-expert` | [Jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills/tree/main/skills) |
| Web front ends | `webapp-testing` (checks the UI in a real browser with Playwright) | [anthropics/skills](https://github.com/anthropics/skills/tree/main/skills/webapp-testing) |
| Other stacks | the collections | [anthropics/skills](https://github.com/anthropics/skills), [Jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills) |

A skill is added by copying its whole folder (`SKILL.md` and everything next to it, licence included) into `.agents/skills/`, then read and committed. A skill is a set of instructions the agent will follow, so it is read before being committed, like code.

**Other CLIs:** Copilot CLI and Gemini CLI use their own folders (see the table in step 0); they are pointed at the same files where they allow it, or the files are copied.

---

## 5. Add the project agents (subagents)

A subagent is a specialised assistant the main agent hands a task to. It has its own instructions and starts with a clean context, so it can, for example, review code without the bias of having written it.

**One folder for the agents.** Agent definitions live in `.agents/agents/<name>.md`, next to `.agents/skills/`: one Markdown file per agent, with a YAML frontmatter and the instructions as its body. Each CLI reads them from its own folder (see the *Agents* column in step 0), which is a symlink to `.agents/agents/` wherever the format allows it:

- Claude Code reads `.claude/agents`, a symlink already in the template
- OpenCode reads `.opencode/agents`, a symlink created when OpenCode is used:

```bash
mkdir -p .opencode && ln -s ../.agents/agents .opencode/agents
```

Unlike `.agents/skills/`, which the CLIs read as a standard, `.agents/agents/` is a convention of this template, held together by the symlinks.

**A frontmatter the CLIs share.** The CLIs agree on the Markdown body, not on the frontmatter: tool names, permissions and models differ from one CLI to the next. A shared definition therefore keeps only the fields they have in common:

```markdown
---
name: code-reviewer
description: Reviews code changes for correctness, security and maintainability. Use after a feature or a fix is implemented.
mode: subagent
---

You are a senior code reviewer. …
```

`name` and `description` tell every CLI what the agent is and when to use it; `mode: subagent` is needed by OpenCode. Without `tools` and `model`, each CLI gives the agent its default tools and model. The price is that the tools of an agent cannot be restricted in the shared file: a reviewer that must only read says so in its instructions.

**The recommended reviewers.** The recommended set is the three reviewers of the [quality reviews](#quality-reviews): `code-reviewer`, `architect-reviewer`, and `ui-ux-tester` for projects with a UI. Their reference definitions are in the [VoltAgent subagents collection](https://github.com/VoltAgent/awesome-claude-code-subagents/tree/main/categories), in Claude Code's format. The download is pinned to a commit rather than `main`, so it is clear what was installed and nothing changes underneath:

```bash
REF=main    # replace with a commit SHA of the collection
BASE=https://raw.githubusercontent.com/VoltAgent/awesome-claude-code-subagents/$REF/categories/04-quality-security
mkdir -p .agents/agents
for agent in code-reviewer architect-reviewer ui-ux-tester; do
  curl -fsSL "$BASE/$agent.md" -o ".agents/agents/$agent.md"
done
```

Each definition is then reduced to the shared frontmatter (`tools` and `model` removed, `mode: subagent` added), and read before it is committed: what does not apply to the project is removed from its instructions.

**Other CLIs:**

- Codex reads TOML files from `.codex/agents/`, so it cannot share the Markdown files. Each definition gets a converted copy, `.codex/agents/<name>.toml`, with `name`, `description`, and the Markdown body as `developer_instructions`. The Markdown file stays the source: the copy is regenerated whenever it changes, and an AI coding CLI can do the conversion.
- Gemini CLI reads Markdown files from `.gemini/agents/`. A `.gemini/agents` symlink to `.agents/agents` should work, but it has not been tried with the shared frontmatter: `/agents` in Gemini CLI shows whether the agents are loaded.
- GitHub Copilot uses `.agent.md` files in `.github/agents/`; check its docs.

Only the agents the project actually uses are added, one file each; a whole collection is never installed.

---

## 6. Configure the MCP servers

MCP servers give the agent access to external systems: GitHub issues and pull requests, up-to-date library documentation, databases, browsers, mail, calendars, documents. A server is added only when the project needs it: each one is more context for the agent and more access to keep under control.

In Claude Code, the project's servers are in `.mcp.json` at the repository root, committed so the whole team gets them. The file is created with the first server, by hand or with `claude mcp add --scope project …`:

```json
{
  "mcpServers": {
    "example": {
      "command": "npx",
      "args": ["-y", "example-mcp-server"],
      "env": { "EXAMPLE_TOKEN": "${EXAMPLE_TOKEN}" }
    }
  }
}
```

- **No secrets in the file.** It refers to environment variables (`${EXAMPLE_TOKEN}`), set in the shell or in an ignored `.env`.
- **Project and personal servers are kept apart.** Servers the whole team needs go in the project file; servers only one developer uses (their mail, their calendar) go in that developer's user configuration.
- **Only trusted servers.** A server runs code on the developer's machine and can act on the systems it reaches: official servers from the vendor of the system are preferred.

Servers can be found in the [MCP registry](https://registry.modelcontextprotocol.io/) and on [mcpservers.com](https://mcpservers.com/).

**Other CLIs:** each one has its own file and format (see the *MCP servers* column in step 0). The same servers are configured in every CLI the team uses.

---

## 7. Set permissions and ignore local files

The agent runs commands on the developer's machine. This step decides what it may do without asking, and keeps personal and generated files out of Git.

**Permissions.** In Claude Code, the project's rules are in `.claude/settings.json`, next to the plugin setting. The commands the agent runs all the time (tests, linters) are allowed, so it does not stop to ask, and reading secrets is denied:

```json
{
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true
  },
  "permissions": {
    "allow": ["Bash(python3 -m unittest:*)", "Bash(flutter test:*)"],
    "deny": ["Read(./.env)", "Read(./.env.*)"]
  }
}
```

The allowed commands are those of the *Commands* section of `AGENTS.md`. Personal preferences go in `.claude/settings.local.json`, which is not committed. The agent is not run with all permission checks turned off on a developer's own machine; fully unattended runs belong in a container or a disposable cloud environment.

**Other CLIs:** they have equivalent approval and sandbox modes, described in their docs.

**Ignored files.** `.gitignore` lists the local files the AI tools create:

```gitignore
# AI coding tools: personal settings and local worktrees
.claude/settings.local.json
.claude/worktrees/
.worktrees/

# secrets
.env
.env.*
!.env.template
!.env.example
```

Both `.gitignore` and `.claude/settings.json` are committed.

---

## 8. Verify the setup

These checks run from the repository root after the previous steps; each one that passes ticks the setup checklist.

1. **Symlinks.** `ls .claude/skills/` lists `wiki-health`, `wiki-ingest`, `wiki-lint`, `wiki-query` and the skills added in step 4; `ls .claude/agents/` lists the agents added in step 5. If either fails, or shows a file instead of a folder, see *Symlinks on Windows* in step 1.
2. **GitHub CLI.** `gh auth status` reports a logged-in account.
3. **Instructions file.** In the AI coding CLI, the question *"Which instructions file did you load, and which sections are still Not defined yet?"* gets an answer that comes from `AGENTS.md`, directly or through `CLAUDE.md`/`GEMINI.md`.
4. **Rules applied.** The question *"Which libraries may you add to this project?"* gets the allow-list of `AGENTS.md` back, or the answer that there is none yet.
5. **Skills and Superpowers.** The question *"Which skills are available?"* lists the four `wiki-*` skills, the skills of step 4 and the Superpowers skills (`brainstorming`, `writing-plans`, `test-driven-development`, …). In Claude Code, typing `/` shows them as slash commands.
6. **Second brain.** `/wiki-health` (in Codex `$wiki-health`; in any CLI just `health`) reports, on a new repository, an empty wiki with no errors.
7. **Agents** (if added in step 5). The CLI's list of subagents includes `code-reviewer`, `architect-reviewer` and `ui-ux-tester`.
8. **MCP servers** (if configured in step 6). In Claude Code, `claude mcp list` shows each server of `.mcp.json` as connected; other CLIs have an equivalent command.
9. **Nothing personal committed.** `git status` is clean, and `git ls-files | grep -E 'settings.local|\.env$'` prints nothing.

---

## Working in the environment

![Vibe coding workflow: reviews and ideas become markdown action items, then go through pre-processing and the Superpowers cycle](vibe-coding-workflow.jpg)

Once the environment is set up, the work follows a loop:

1. **Collecting the work.** Ideas, bugs and review findings become Markdown items with checkboxes (`- [ ]`), in an issue or in `docs/`.
2. **Preparing complex requests.** A large or vague request is first refined in an AI chat, so the agent starts from a clear prompt.
3. **The Superpowers cycle.** Brainstorming, plan, implementation with tests, review, finish (step 2). Debugging, when needed, happens inside the same cycle.
4. **Feeding the knowledge back.** New source documents go into `docs/second-brain/raw/` and are ingested; decisions worth keeping become wiki pages.
5. **Retrospective.** From time to time, the way the agent worked is reviewed, and the lessons learned become rules in `AGENTS.md`, so the next session starts better.

### Quality reviews

As the code grows, the reviewers of step 5 are run on it, each as a subagent rather than inline, so that it reviews with a fresh context. Each review is saved:

- `code-reviewer` → `docs/reviews/<YYYY-MM-DD>-code-reviewer.md`
- `architect-reviewer` → `docs/reviews/<YYYY-MM-DD>-architect-reviewer.md`
- `ui-ux-tester` → `docs/reviews/<YYYY-MM-DD>-ui-ux-tester.md`

The findings are new work items: they go back to the first point of the loop.

---

## Shared and personal files

| Committed (shared by the team) | Not committed (personal or generated) |
|---|---|
| `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, nested `AGENTS.md` files | `.claude/settings.local.json` and the other CLIs' personal settings |
| `.claude/settings.json` (plugins, permissions) | user configuration (`~/.claude/`, `~/.codex/`, …) |
| `.agents/skills/` and `.agents/agents/`, with their symlinks (`.claude/skills`, `.claude/agents`, `.opencode/agents`, …) | credentials and API keys, `.env` files |
| converted agent copies (`.codex/agents/`) | worktrees (`.claude/worktrees/`, `.worktrees/`) |
| `.mcp.json` and the other CLIs' project MCP files, without secrets | build output and dependency folders |
| `docs/second-brain/`, `docs/superpowers/`, `docs/reviews/` | |

The rule behind the left column is in `AGENTS.md` (*Commit AI-tooling folders to Git*): the agent and skill definitions, the specs and the plans are the traceable history of the AI-assisted work.

---

## Keeping the environment up to date

- **CLIs and plugins** change often: they are updated every few weeks, followed by the checks of step 8.
- **Skills and agents** copied from collections do not update by themselves: an update is a deliberate change, with the diff read before it is committed.
- **`AGENTS.md`** grows with the project: a section is filled in as soon as it stops being *Not defined yet*, and every retrospective can add a rule.
- **This guide** belongs to the project, not to the template: when the team's setup changes, the guide changes with it.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| The CLI does not see the `wiki-*` skills or the agents | `.claude/skills` or `.claude/agents` is a text file instead of a symlink (Windows) | *Symlinks on Windows* in step 1 |
| The agent ignores a rule | the rule is vague, or the session started before it was written | sharpen the rule, commit it, start a new session |
| Superpowers' worktree does not have the latest changes | the worktree starts from the last commit | commit before starting a change |
| Tests are green but prove nothing (`Ran 0 tests`) | the test runner found no tests (a missing `__init__.py`, a wrong path) | check the test count in the output, and point it out to the agent |
| The agent adds a library that is not approved | the allow-list is missing or not clear | make *Conventions* in `AGENTS.md` say "Nothing else" explicitly |
| An MCP server does not connect | an environment variable is missing, or the server is not installed | `claude mcp list` (or the CLI's equivalent), then check the server's variables |

---

## Resources

- Superpowers plugin: https://github.com/obra/superpowers
- Agent Skills standard: https://agentskills.io
- Anthropic official skills: https://github.com/anthropics/skills
- Jeffallan's skills collection: https://github.com/Jeffallan/claude-skills
- VoltAgent subagents collection: https://github.com/VoltAgent/awesome-claude-code-subagents/tree/main/categories (single agents are copied; the collection is not installed as a whole)
- Awesome Claude (menu of extensions): https://awesomeclaude.ai
- MCP server registries: https://registry.modelcontextprotocol.io/, https://mcpservers.com/

## To be evaluated

- claude-plugins-official: frontend-design, code-review, code-simplifier
- https://github.com/thedotmack/claude-mem — persistent memory across sessions
- https://context7.com/ — up-to-date library documentation for Claude, Codex, Cursor and other agents
