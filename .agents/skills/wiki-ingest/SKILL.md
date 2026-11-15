---
name: wiki-ingest
description: Ingest a source document into the LLM Wiki in docs/second-brain. Use when the user says "ingest <file>" or asks to add a document from docs/second-brain/raw/ to the wiki.
---

Ingest a source document into the LLM Wiki.

First read docs/second-brain/SCHEMA.md — it defines the wiki's layout, page formats, naming conventions and workflows, and is not loaded automatically.

Input: the path to a file in docs/second-brain/raw/ given by the user, e.g. `docs/second-brain/raw/articles/my-article.md`. If no path was given, ask for one.

Follow the Ingest Workflow defined in docs/second-brain/SCHEMA.md exactly:
1. Read the source file at the given path (convert it first if it is a binary format, as SCHEMA.md describes)
2. Read docs/second-brain/wiki/index.md and docs/second-brain/wiki/overview.md for current context
3. Write docs/second-brain/wiki/sources/<slug>.md (source page format per SCHEMA.md); fill `origin` from the document or the user's words, never guessing (use "unknown" otherwise)
4. Update docs/second-brain/wiki/index.md — add the new entry under Sources
5. Update docs/second-brain/wiki/overview.md — revise synthesis if warranted
6. Create/update entity pages (docs/second-brain/wiki/entities/) for key people, companies, projects (Entity Page Format per SCHEMA.md)
7. Create/update concept pages (docs/second-brain/wiki/concepts/) for key ideas and frameworks (Concept Page Format per SCHEMA.md)
8. Flag any contradictions with existing wiki content
9. Append to docs/second-brain/wiki/log.md: ## [today's date] ingest | <Title>
10. Post-ingest validation: check that every [[wikilink]] in the new and updated pages points to an existing page, and that every new page is listed in index.md; fix what is missing

Never modify files in docs/second-brain/raw/: they are immutable.

After completing all writes, summarize: what was added, which pages were created or updated, any contradictions found, and the result of the validation.

---

Provenance: adapted from the wiki workflows of https://github.com/SamurAIGPT/llm-wiki-agent, Copyright (c) 2023 SamurAIGPT, MIT License (full text in `.agents/skills/THIRD_PARTY_NOTICES.md`). This note is not an instruction.
