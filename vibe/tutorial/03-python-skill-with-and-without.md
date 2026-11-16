# 03 — A Python skill, with and without

**Time:** about 20 minutes · **Needs:** setup steps 0–1, `git`, `python3` (3.11 or later to run the second version) · **Result:** the same small program built twice from the same prompt, once without and once with the `python-pro` skill, and a rule-by-rule comparison of the two

A skill is a folder of instructions the agent loads when a task matches its description. [Jeffallan's skills collection](https://github.com/Jeffallan/claude-skills), listed in the Resources of [`../README.md`](../README.md), has one for Python: [`python-pro`](https://github.com/Jeffallan/claude-skills/tree/main/skills/python-pro). This lesson shows what it actually changes. You read its rules, give the agent one prompt for a tiny program, build it without the skill, install the skill, build it again from the same prompt, and check both results against the skill's rules.

Prompts to type into the CLI are in quotes; shell commands are in code blocks. The agent writes different code on every run, so your two versions will not match the ones below line for line. What should repeat is the kind of difference.

The skill is installed only on the lesson's throwaway branch and thrown away with it: this template does not ship it in `.agents/skills/`. Start on a throwaway branch (see [the tutorial's README](README.md#run-each-lesson-on-a-throwaway-branch)):

```bash
git switch -c tutorial/03
```

---

## Step 1 — Read the skill's rules

A skill is plain Markdown: read it before you install it, as you would read a dependency's licence. `python-pro` (version 1.1.0 at the time of writing) is a `SKILL.md` plus five reference files the agent loads only when the task needs them:

| File | Loaded when the task is about |
|---|---|
| `SKILL.md` | always: workflow, rules, examples, what to deliver |
| `references/type-system.md` | type hints, mypy, generics, `Protocol` |
| `references/async-patterns.md` | `async`/`await`, `asyncio`, task groups |
| `references/standard-library.md` | `pathlib`, dataclasses, `functools`, `itertools`, logging |
| `references/testing.md` | pytest, fixtures, mocking, `parametrize`, coverage |
| `references/packaging.md` | `pyproject.toml`, Poetry, project layout, CI |

The rules that matter are in `SKILL.md`. Its target is **Python 3.11+**, and its workflow ends with a validation step: run `mypy --strict`, `black` and `ruff`, and fix and re-run until they are clean.

**Must do**

- type hints for all function signatures and class attributes
- PEP 8, formatted with `black`
- comprehensive docstrings, Google style
- tests with pytest, coverage above 90%
- `X | None` instead of `Optional[X]`
- `async`/`await` for I/O-bound operations
- dataclasses instead of hand-written `__init__` methods
- context managers for resources

**Must not do**

- leave public APIs without type annotations
- use mutable default arguments
- mix sync and async code improperly
- ignore mypy errors in strict mode
- use bare `except:`
- hardcode secrets or configuration
- use deprecated stdlib modules (`pathlib`, not `os.path`)

**Deliver**: the module with full type hints, a pytest test file with fixtures, confirmation that `mypy --strict` passes, and a short explanation of the patterns used.

The reference files add detail, not new rules: a strict mypy configuration, a `src/` project layout with `pyproject.toml`, `pytest --cov … --cov-fail-under=90`, `ruff` with bugbear and pyupgrade rules.

Note what this means for a project: the skill's definition of done needs five third-party tools (pytest, pytest-cov, mypy, black, ruff). This template's `AGENTS.md` says to ask before adding any dependency, and lesson 01 sets a stack of Python 3.9+ with the standard library only. Keep that in mind for step 6.

## Step 2 — Pick a program and write one prompt

A program small enough to read in one go, with a little of everything the rules talk about: a function, a command-line option, a file to read, errors to handle.

The prompt, used for both builds:

> "Write a small Python command-line program, wordfreq.py, that reads a text file and prints the N most frequent words with their counts. N is an option and defaults to 10. Words are case-insensitive and punctuation is ignored. Keep it small: a few dozen lines."

It says nothing about types, tests or tools on purpose: those are what the skill should add.

If Superpowers is installed, it may start a brainstorming session on this prompt. Answer "skip the design, just write it" in both builds, so that the skill is the only difference.

## Step 3 — Build it without the skill

Check that no Python skill is installed (`ls .claude/skills/` shows only the `wiki-*` skills), start a new session from the repository root and type the prompt.

When it is done, move the result aside so that the second build starts from the same empty folder:

```bash
mkdir -p scratch/without && mv wordfreq.py scratch/without/
```

**What we got** — one file, 42 lines, and a note saying it had not been run:

```python
#!/usr/bin/env python3
"""Print the N most frequent words in a text file."""

import argparse
import re
import sys
from collections import Counter

# A word is a run of letters/digits, optionally joined by apostrophes ("don't").
WORD_RE = re.compile(r"[^\W_]+(?:'[^\W_]+)*")


def positive_int(value):
    n = int(value)
    if n < 1:
        raise argparse.ArgumentTypeError("must be a positive integer")
    return n


def count_words(text):
    return Counter(WORD_RE.findall(text.lower()))


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("file", help="text file to read")
    parser.add_argument("-n", "--top", type=positive_int, default=10,
                        help="number of words to show (default: 10)")
    args = parser.parse_args(argv)

    try:
        with open(args.file, encoding="utf-8") as f:
            counts = count_words(f.read())
    except (OSError, UnicodeDecodeError) as e:
        sys.exit(f"wordfreq: cannot read {args.file}: {e}")

    for word, count in counts.most_common(args.top):
        print(f"{count:7d}  {word}")


if __name__ == "__main__":
    main()
```

Clean, idiomatic, standard library only, and it runs on the `python3` macOS ships (3.9). No type hints, no function docstrings, no tests.

## Step 4 — Install the skill

Skills live in `.agents/skills/`; `.claude/skills` is a symlink to that folder, so Claude Code sees whatever you put there (Codex, Antigravity and OpenCode read `.agents/skills/` directly). Copy only the one skill you want from the collection:

```bash
git clone --depth 1 https://github.com/Jeffallan/claude-skills.git /tmp/claude-skills
cp -R /tmp/claude-skills/skills/python-pro .agents/skills/
rm -rf /tmp/claude-skills
ls .claude/skills/
```

**Expect:** `python-pro` next to the `wiki-*` skills.

The collection is also a Claude Code plugin (`/plugin marketplace add jeffallan/claude-skills`, then `/plugin install fullstack-dev-skills@fullstack-dev-skills`), but that installs the whole collection, more than 60 skills, and for Claude Code only. Copying one folder into `.agents/skills/` keeps the change visible in the repository and shared by every CLI.

## Step 5 — Build it again with the skill

Skills are discovered when a session starts, so start a **new** session and type the same prompt.

**Check:** the agent should say it is using `python-pro` and read `SKILL.md`. A skill loads when the task matches its description, and "write a small Python program" does not always count as a match. If the skill does not load, run the same prompt again with the skill named in front (`/python-pro Write a small Python command-line program, …`; `$python-pro …` in Codex). The request is unchanged: you only make sure the skill is read.

Then move the result aside as well:

```bash
mkdir -p scratch/with && mv wordfreq.py test_wordfreq.py pyproject.toml scratch/with/
```

**What we got** — the agent read `SKILL.md`, `references/standard-library.md` and `references/testing.md`, skipped the others as not relevant, and wrote three files. `wordfreq.py`, 80 lines:

```python
"""Print the most frequent words in a text file."""

import argparse
import re
import sys
from collections import Counter
from collections.abc import Sequence
from pathlib import Path

_APOSTROPHES = str.maketrans("", "", "'’")
_WORD = re.compile(r"[^\W_]+")


def count_words(text: str) -> Counter[str]:
    """Count words case-insensitively, ignoring punctuation.

    Args:
        text: The text to analyse.

    Returns:
        A counter mapping each lower-cased word to its number of occurrences.
    """
    return Counter(_WORD.findall(text.casefold().translate(_APOSTROPHES)))


def positive_int(value: str) -> int:
    """Parse a command-line value as an integer greater than zero.

    Args:
        value: The raw command-line value.

    Returns:
        The parsed integer.

    Raises:
        argparse.ArgumentTypeError: If the value is zero or negative.
    """
    number = int(value)
    if number < 1:
        raise argparse.ArgumentTypeError(f"must be at least 1, got {value}")
    return number


def main(argv: Sequence[str] | None = None) -> int:
    """Run the command line program.

    Args:
        argv: Command-line arguments; defaults to ``sys.argv[1:]``.

    Returns:
        The process exit code: 0 on success, 1 if the file cannot be read.
    """
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("file", type=Path, help="text file to read (UTF-8)")
    parser.add_argument(
        "-n",
        "--top",
        type=positive_int,
        default=10,
        metavar="N",
        help="number of words to print (default: 10)",
    )
    args = parser.parse_args(argv)
    path: Path = args.file
    top: int = args.top
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as exc:
        print(f"wordfreq: {exc}", file=sys.stderr)
        return 1
    except UnicodeDecodeError:
        print(f"wordfreq: {path}: not valid UTF-8 text", file=sys.stderr)
        return 1
    for word, count in count_words(text).most_common(top):
        print(f"{count:>7} {word}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

<details>
<summary><code>test_wordfreq.py</code> (68 lines, pytest) and <code>pyproject.toml</code> (12 lines)</summary>

```python
"""Tests for wordfreq."""

from collections import Counter
from pathlib import Path

import pytest

from wordfreq import count_words, main


@pytest.fixture
def sample(tmp_path: Path) -> Path:
    path = tmp_path / "sample.txt"
    path.write_text("The cat; the DOG! The cat's toy, a dog.\n", encoding="utf-8")
    return path


@pytest.mark.parametrize(
    "text,expected",
    [
        ("Hello, hello HELLO!", {"hello": 3}),
        ("don't stop — don’t", {"dont": 2, "stop": 1}),
        ("snake_case 42", {"snake": 1, "case": 1, "42": 1}),
        ("Café CAFÉ", {"café": 2}),
        ("", {}),
    ],
    ids=["case", "apostrophes", "underscore_digits", "unicode", "empty"],
)
def test_count_words(text: str, expected: dict[str, int]) -> None:
    assert count_words(text) == Counter(expected)


def test_main_default_top(sample: Path, capsys: pytest.CaptureFixture[str]) -> None:
    assert main([str(sample)]) == 0
    rows = [line.split() for line in capsys.readouterr().out.splitlines()]
    assert rows == [
        ["3", "the"],
        ["2", "dog"],
        ["1", "cat"],
        ["1", "cats"],
        ["1", "toy"],
        ["1", "a"],
    ]


def test_main_top_option(sample: Path, capsys: pytest.CaptureFixture[str]) -> None:
    assert main([str(sample), "-n", "2"]) == 0
    rows = [line.split() for line in capsys.readouterr().out.splitlines()]
    assert rows == [["3", "the"], ["2", "dog"]]


@pytest.mark.parametrize("value", ["0", "-1", "abc"])
def test_main_rejects_invalid_top(sample: Path, value: str) -> None:
    with pytest.raises(SystemExit) as exc_info:
        main([str(sample), "--top", value])
    assert exc_info.value.code == 2


def test_main_missing_file(tmp_path: Path, capsys: pytest.CaptureFixture[str]) -> None:
    assert main([str(tmp_path / "missing.txt")]) == 1
    assert capsys.readouterr().err.startswith("wordfreq: ")


def test_main_invalid_utf8(tmp_path: Path, capsys: pytest.CaptureFixture[str]) -> None:
    path = tmp_path / "binary.txt"
    path.write_bytes(b"\xff\xfe\xfa")
    assert main([str(path)]) == 1
    assert "not valid UTF-8" in capsys.readouterr().err
```

```toml
[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.black]
target-version = ["py311"]

[tool.ruff]
target-version = "py311"
```

</details>

The agent's notes said it had run nothing, listed the commands to run (`mypy --strict`, `black --check`, `ruff check`, `pytest --cov=wordfreq`), and pointed out two things itself: it wrote a test file although the prompt did not ask for one, because the skill asks for it; and the program is 80 lines, more than "a few dozen", mostly because of the docstrings (about 45 lines without them).

## Step 6 — Run both and check them against the rules

Write a sample text:

```bash
printf "The cat sat on the mat. The dog didn't sit on the mat:\nthe dog sat on the cat's bed! Don't ask the cat, ask the DOG.\n" > scratch/sample.txt
```

Run both versions with Python 3.11 or later (here `python3.12`), then the second one with the `python3` macOS ships (3.9):

```bash
python3.12 scratch/without/wordfreq.py scratch/sample.txt -n 5
python3.12 scratch/with/wordfreq.py scratch/sample.txt -n 5
/usr/bin/python3 scratch/with/wordfreq.py scratch/sample.txt
```

**What we got** (run from inside each folder, so the paths are short):

| Case | Without the skill | With the skill |
|---|---|---|
| `sample.txt -n 5` | `8  the` · `3  on` · `3  dog` · `2  cat` · `2  sat`, exit 0 | same counts, one space less between count and word, exit 0 |
| `missing.txt` | `wordfreq: cannot read missing.txt: [Errno 2] No such file or directory: 'missing.txt'`, exit 1 | `wordfreq: [Errno 2] No such file or directory: 'missing.txt'`, exit 1 |
| `-n 0` | `error: argument -n/--top: must be a positive integer`, exit 2 | `error: argument -n/--top: must be at least 1, got 0`, exit 2 |
| contractions (`-n 12`, last lines) | `didn't`, `cat's`, `don't` | `didnt`, `cats`, `dont` |
| Python 3.9.6 (macOS) | works | `TypeError: unsupported operand type(s) for \|: 'types.GenericAlias' and 'NoneType'` at `def main(argv: Sequence[str] \| None = None)` |

The contractions row is not the skill's doing: the prompt did not say what to do with apostrophes, and the two runs chose differently. Expect some differences like this between any two runs; only the ones that map to a rule below are the skill's effect. The Python 3.9 row is the skill's doing: it targets 3.11+, and `X | None` in a signature fails on older versions.

Then the checks, with the standard library only:

```bash
python3 -m py_compile scratch/without/wordfreq.py scratch/with/wordfreq.py scratch/with/test_wordfreq.py
(cd scratch/with && python3 -m unittest test_wordfreq)
```

**What we got:** all three files compile, even with Python 3.9 (the `|` in the annotation fails only when the function is defined, at run time); the test run fails before any test with `ModuleNotFoundError: No module named 'pytest'`. The skill's tests need pytest, and plain `unittest` cannot run them.

To check the rules that can be read from the code (type hints, docstrings, mutable defaults, bare `except`, `Optional`, `os.path`, line length), a few lines of `ast` are enough. Save them as `scratch/check_rules.py`:

<details>
<summary><code>check_rules.py</code> (standard library only)</summary>

```python
"""Check the python-pro rules that can be read from the source."""
import ast, sys
from pathlib import Path

for name in sys.argv[1:]:
    src = Path(name).read_text(encoding="utf-8")
    tree = ast.parse(src)
    funcs = [n for n in ast.walk(tree) if isinstance(n, (ast.FunctionDef, ast.AsyncFunctionDef))]
    untyped = [f.name for f in funcs if f.returns is None or any(a.annotation is None for a in f.args.args + f.args.kwonlyargs)]
    nodoc = [f.name for f in funcs if ast.get_docstring(f) is None]
    google = [f.name for f in funcs if (d := ast.get_docstring(f)) and ("Args:" in d or "Returns:" in d)]
    mutable_defaults = [f.name for f in funcs for d in f.args.defaults + f.args.kw_defaults if isinstance(d, (ast.List, ast.Dict, ast.Set))]
    bare_except = sum(1 for n in ast.walk(tree) if isinstance(n, ast.ExceptHandler) and n.type is None)
    long_lines = [i for i, line in enumerate(src.splitlines(), 1) if len(line) > 88]
    print(f"## {name}: {len(src.splitlines())} lines")
    print(f"  missing type hints: {untyped or 'none'}")
    print(f"  missing docstrings: {nodoc or 'none'}")
    print(f"  Google-style docstrings: {google or 'none'}")
    print(f"  mutable defaults: {mutable_defaults or 'none'}; bare except: {bare_except}; "
          f"Optional[: {'Optional[' in src}; os.path: {'os.path' in src}")
    print(f"  lines over 88 chars: {long_lines or 'none'}")
```

</details>

```bash
python3 scratch/check_rules.py scratch/without/wordfreq.py scratch/with/wordfreq.py scratch/with/test_wordfreq.py
```

**What we got:**

```text
## scratch/without/wordfreq.py: 42 lines
  missing type hints: ['positive_int', 'count_words', 'main']
  missing docstrings: ['positive_int', 'count_words', 'main']
  Google-style docstrings: none
  mutable defaults: none; bare except: 0; Optional[: False; os.path: False
  lines over 88 chars: none
## scratch/with/wordfreq.py: 80 lines
  missing type hints: none
  missing docstrings: none
  Google-style docstrings: ['count_words', 'positive_int', 'main']
  mutable defaults: none; bare except: 0; Optional[: False; os.path: False
  lines over 88 chars: none
## scratch/with/test_wordfreq.py: 68 lines
  missing type hints: none
  missing docstrings: ['sample', 'test_count_words', 'test_main_default_top', 'test_main_top_option', 'test_main_rejects_invalid_top', 'test_main_missing_file', 'test_main_invalid_utf8']
  Google-style docstrings: none
  mutable defaults: none; bare except: 0; Optional[: False; os.path: False
  lines over 88 chars: none
```

The five `count_words` cases in the skill's test file can still be checked without pytest, by calling the function directly: all five give the expected counts, and so does the sample used by the `main` tests.

mypy, black, ruff and coverage are third-party tools. When we wrote this lesson we chose not to install them (standard library only), so the rows that need them were judged by reading the code and are marked as such. If your project approves those tools, run them and replace the judgement with the output.

### The comparison

✅ meets the rule · ❌ breaks it · ⚠️ partly, or not verified · ➖ does not apply to this program

| Rule from `SKILL.md` | Without the skill | With the skill | How we checked |
|---|---|---|---|
| Type hints on all function signatures | ❌ 0 of 3 functions | ✅ 3 of 3, and all 7 test functions | `check_rules.py` |
| `X \| None`, not `Optional[X]` | ➖ no hints at all | ✅ `Sequence[str] \| None` | reading |
| Google-style docstrings | ❌ module docstring only | ✅ every function in the module; none on the tests | `check_rules.py` |
| PEP 8 with `black` formatting | ❌ the wrapped `add_argument(…, help=…)` call is not how black formats it | ✅ looks black-formatted | reading (black not run) |
| pytest tests, coverage above 90% | ❌ no tests | ⚠️ a pytest file with a fixture and `parametrize`; its cases check out by hand, but pytest and coverage were not run | by hand (pytest not run) |
| `mypy --strict` clean | ❌ untyped functions are errors in strict mode | ⚠️ probably, and configured in `pyproject.toml`, but not confirmed | reading (mypy not run) |
| `ruff` clean | ⚠️ not run | ⚠️ not run, configured | — |
| Dataclasses over hand-written `__init__` | ➖ no classes | ➖ no classes | reading |
| Context managers for resources | ✅ `with open(...)` | ✅ `Path.read_text` opens and closes the file itself | reading |
| `async` for I/O-bound operations | ➖ one small file read | ➖ same: the skill did not force async where it adds nothing | reading |
| No mutable default arguments | ✅ | ✅ | `check_rules.py` |
| No bare `except:` | ✅ | ✅ | `check_rules.py` |
| No hardcoded secrets or configuration | ✅ | ✅ | reading |
| `pathlib`, not `os.path` | ⚠️ no `os.path`, but a plain `open()` on a string | ✅ `Path` throughout | reading |
| Python 3.11+ | ➖ no target; runs on 3.9 | ✅ targets 3.11; does **not** run on macOS's 3.9 | run |
| Deliver module, tests, mypy confirmation, explanation | ⚠️ module and notes | ⚠️ module, tests, config and notes; no mypy confirmation, because it could not run commands | reading |

---

## What you have seen

| | Without the skill | With the skill |
|---|---|---|
| Files | 1 (42 lines) | 3 (80 + 68 + 12 lines) |
| Types and docs | none | full type hints, Google-style docstrings |
| Tests | none | pytest, fixture, parametrized cases, error paths |
| Tool configuration | none | mypy strict, black, ruff in `pyproject.toml` |
| Runs with plain `python3` | yes, 3.9 included | only on 3.11+; its tests need pytest |
| Behaviour | correct | correct, with a cleaner exit code from `main()` |

The skill did what it says: from a prompt that never mentioned them, the agent wrote typed, documented and tested code and set up the tools to check it. Every rule we could check without third-party tools was met, and the rules that do not fit a 40-line script (async, dataclasses) were sensibly left out rather than forced in.

The price is in its assumptions: Python 3.11+, pytest, mypy, black and ruff, and roughly twice the code. Its tests do not even run in a project that uses only the standard library. A skill is someone else's conventions, and it does not read your `AGENTS.md` before it applies them. So before you install one:

- read its rules, as in step 1, and compare them with your *Stack*, *Conventions* and *Testing* sections
- where they disagree, decide in `AGENTS.md`: approve the tools the skill needs, or write down which of its rules do not apply here
- or don't install it, and copy the rules you like into `AGENTS.md` (type hints, docstrings, no bare `except`, `pathlib`), where every agent and every CLI reads them

### How the results above were produced

Both builds ran with Claude Opus 5.5 as fresh Claude Code agents started from this repository, so both saw its `AGENTS.md`. Each worked in its own empty folder, with the `.agents/skills/` and `.claude/skills` layout described above, and could write files but not run commands, so that every check above was run afterwards in the same way for both. In the second build `python-pro` was copied into `.agents/skills/`, and the agent loaded it by reading `SKILL.md` and the reference files it chose. The skill is version 1.1.0, from commit `67c1961` of the collection. The runs and the checks used Python 3.12.13, plus the macOS `python3` 3.9.6 for the last row of the first table.

## Throw it away

The lesson's branch holds the skill and the two builds: commit them there, so nothing follows you back, then delete the branch:

```bash
git add -A && git commit -m "Lesson 03: python-pro with and without"
git switch -
git branch -D tutorial/03
```

`ls .claude/skills/` should list only the `wiki-*` skills again.

**Next:** lesson 04 (planned) — reviewing code and UI with the reviewer agents.
