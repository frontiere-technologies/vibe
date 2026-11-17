# Wiki Log

Append-only chronological record of the operations that change or review the wiki: `ingest`, `query` (only when the answer is filed as a synthesis page) and `lint`. `health` is not logged.

Format: `## [YYYY-MM-DD] <operation> | <title>`

Parse recent entries: `grep "^## \[" docs/second-brain/wiki/log.md | tail -10`

---
