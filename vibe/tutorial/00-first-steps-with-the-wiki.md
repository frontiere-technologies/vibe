# 00 — First steps with the wiki

**Time:** about 10 minutes · **Needs:** setup steps 0–1 · **Result:** a tiny wiki built from a one-page text, and an answer to a question about it

The smallest possible lesson: give the agent a short text, let it turn it into wiki pages, and ask it a question. No code, no rules, no Superpowers. The text is [`examples/release-process.md`](examples/release-process.md): how a fictional team ships a change to its service, in fifteen lines.

Start on a throwaway branch (see [the tutorial's README](README.md#run-each-lesson-on-a-throwaway-branch)):

```bash
git switch -c tutorial/00
```

---

## Step 1 — Add the text

Copy the text into the second brain:

```bash
mkdir -p docs/second-brain/raw/examples
cp vibe/tutorial/examples/release-process.md docs/second-brain/raw/examples/
```

## Step 2 — Ingest it

Start the CLI from the repository root:

> `/wiki-ingest docs/second-brain/raw/examples/release-process.md`

**Expect:** within a minute, a summary page in `docs/second-brain/wiki/sources/`, a few pages in `entities/` (the team, the service, the people) and `concepts/` (the release process, the deploy rules), and `index.md` and `log.md` updated.

**Look at:** open `docs/second-brain/wiki/index.md`, then one entity page. Fifteen lines of text became linked pages that any later session reads instead of the original.

## Step 3 — Ask

> "query: can Sara deploy her change to production on Friday, if the CI is green?"

**Expect:** no, with the reason (no production deploys on Friday, and only after staging) and the wiki pages it used.

**Try:** ask something the text does not say, e.g. "query: which database does orders-api use?". A good answer says the wiki does not know, instead of inventing it.

---

## Throw it away

Commit what the lesson created, so it lives only on the tutorial branch (uncommitted files would follow you back to your branch), then delete the branch:

```bash
git add -A && git commit -m "Lesson 00: ingest the release process"
git switch -
git branch -D tutorial/00
```

`git status` should now show a clean tree, and `docs/second-brain/wiki/` is back as it was.

**Next:** [lesson 01](01-from-document-to-code.md) — the same steps on a real document, then rules in `AGENTS.md` and tested code.
