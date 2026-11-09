# 01 — From a document to tested code

**Time:** about 30 minutes · **Needs:** setup steps 0–2, `python3` · **Result:** a small Python library, written by the agent from knowledge it extracted itself, inside rules you wrote

You will ingest the NASA Systems Engineering Handbook, ask the wiki about Technology Readiness Levels (TRL), then have the agent build a tiny TRL calculator. The calculator is not the point: the point is watching where the agent takes its knowledge from, and whether it respects your constraints.

Prompts to type into the CLI are in quotes; shell commands are in code blocks. Exact wiki page names and wording will differ from run to run.

---

## Step 1 — Give the agent some knowledge

Copy the sample source into the second brain:

```bash
mkdir -p docs/second-brain/raw/examples
cp vibe/tutorial/examples/nasa_systems_engineering_handbook_0.pdf docs/second-brain/raw/examples/
```

Start the CLI from the repository root and ingest it:

> `/wiki-ingest docs/second-brain/raw/examples/nasa_systems_engineering_handbook_0.pdf`

The PDF has 297 pages, so this takes a few minutes. Then check the result:

> `/wiki-health`

**Expect:** a summary page in `docs/second-brain/wiki/sources/`, a few dozen pages in `entities/` and `concepts/` (one of them on TRL), `index.md` and `log.md` updated, and a health report with no errors.

**Look at:** open `docs/second-brain/wiki/index.md` and one concept page. This is now the project's memory: any later session reads it instead of the 297-page PDF.

## Step 2 — Ask the wiki

> "query: what are the nine TRL levels, and what has to be demonstrated to reach TRL 6?"

**Expect:** an answer built from wiki pages, with the pages it used cited by name. The answer should mention a model or prototype demonstrated in a relevant environment for TRL 6.

**Try:** ask something the handbook does not cover, e.g. "query: what is the TRL of the James Webb telescope mirror?". A good answer says the wiki does not know, instead of inventing it.

## Step 3 — Set the rules

Open `AGENTS.md` and replace the *Not defined yet* lines of four sections with these rules:

```markdown
## Commands

- Run the tests: `python3 -m unittest discover -s sources/libraries -t sources/libraries`

## Stack

Python 3.9+ (the version macOS ships), standard library only.

## Conventions

- Library code lives in `sources/libraries/<name>/`, one package per library, with its tests in `sources/libraries/<name>/tests/`. Both folders have an `__init__.py`.
- Pure functions, type hints everywhere, no I/O in library code.
- Approved libraries: the Python standard library. Nothing else.

## Testing

- Unit tests with `unittest`, written before the code they test (red, then green).
- A change is done only when every test passes.
```

**Why:** this is the part that turns vibe coding into controlled coding. The agent reads `AGENTS.md` on every interaction, so these rules apply to everything that follows, without repeating them in each prompt.

## Step 4 — Ask for a plan, not for code

> "Using the wiki, write a plan in docs/plans/trl-calculator-plan.md for a small library `trl` that: lists the nine TRL levels with their definitions; turns the answers to a yes/no questionnaire into a TRL (questions go from TRL 9 down to TRL 2, the first yes gives the TRL, all no gives TRL 1, missing answers give no result); and tells whether a TRL meets a target. Don't write code yet."

**Expect:** a Markdown plan with a summary first and one unchecked item per task, in the format `- [ ] ID=..., Severity=..., Complexity=..., Priority=..., Estimate=..., Title=..., Fix description=...` — that format comes from the *Tasks as checkboxes* rule in `AGENTS.md`, not from your prompt.

**Check:** the TRL definitions in the plan should match the wiki, and the agent should say which wiki pages it used. Edit the plan by hand if you disagree with anything: it is the contract for the next step.

## Step 5 — Implement test-first

> "Implement docs/plans/trl-calculator-plan.md item by item, test-first. Tick each item when it is done and tested."

With Superpowers installed, the agent may start its own workflow (plan, worktree, TDD); let it run, and answer its questions.

**Expect:**

- `sources/libraries/trl/` with the code and `sources/libraries/trl/tests/` with the tests
- tests written before the code — the agent should show them failing first
- each plan item ticked as `- [✅]` as soon as it is done, not all at the end

Run the tests yourself:

```bash
python3 -m unittest discover -s sources/libraries -t sources/libraries
```

**Check:** the output must say `Ran N tests` with N greater than zero. `Ran 0 tests … OK` means `unittest` found nothing, usually because an `__init__.py` is missing: a green result that proves nothing, and a good thing to point out to the agent.

## Step 6 — Test the boundaries

Now ask for something that breaks a rule:

> "Add a function that plots the TRL distribution of a list of components as a bar chart with matplotlib."

**Expect:** matplotlib is not an approved library, so the agent should stop and ask before adding it, or propose a standard-library alternative (for example a text bar chart). If it just installs matplotlib, the rule was not clear enough: make the *Conventions* wording stronger and try again in a new session.

This is the habit to keep: when the agent breaks a rule, fix the rule, not only the code.

---

## What you have seen

| Practice | Where it lives | What it gave you |
|---|---|---|
| Project knowledge | `docs/second-brain/` | Answers grounded in a source, with citations |
| Technical constraints | `AGENTS.md` | Stack, layout, approved libraries, test policy applied without repeating them |
| Plans as checklists | `docs/plans/` | A reviewable contract before code, and visible progress |
| Tests as definition of done | `sources/libraries/trl/tests/` | Proof the code does what the plan says |

To reset and run the lesson again on a fresh copy, start from setup step 0, path A.

**Next:** lesson 02 (planned) — reviewing this code with the reviewer agents.
