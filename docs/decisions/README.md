# Decisions

This folder holds the project's **decision records** — one short, immutable
Markdown file per significant, hard-to-reverse choice, capturing *why* it was
made. The format is Michael Nygard's
[Architecture Decision Record](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
pattern, simplified from [MADR](https://adr.github.io/madr/); here the records
are plain **decisions**, numbered `D-0001` and up.

A record holds one decision: the context that forced it, the alternatives that
were rejected, and the consequences. Records are **append-only** — when a
decision changes, write a *new* record that supersedes the old one (step 5
below). Each record was true on the day it was written, and the chain of
supersession tells the story of how the system evolved.

## Why this exists (especially for agents)

A commit message records *what* changed; a decision record explains *why* it was
the right answer at the time, which constraints applied, and what alternatives
were rejected. A human can compensate for missing rationale by asking a
colleague — an agent cannot. Without recorded rationale, an agent infers intent
from code patterns and will faithfully reproduce a convention without knowing
whether it is deliberate, deprecated, or accidental — producing plausible,
working, *inconsistent* code at speed.

This folder (the historical "why") and `AGENTS.md` (the active "what") are
complementary: a record says *"we chose Postgres because we needed transactional
consistency"*; an `AGENTS.md` rule says *"all data access goes through the
existing Postgres pool; never add a new database dependency without approval."*
One explains the past; the other governs the future.

## For agents

- **Before proposing an architectural change, read this index and any relevant
  record.**
- **Do not contradict an `Accepted` decision.** If it genuinely needs to change,
  supersede it (step 5 below) — never edit the accepted record.
- When retrieving decisions, **filter on `status`** so superseded/deprecated
  records never outrank the current one.

## Index

| ID | Title | Status | Date |
|----|-------|--------|------|
| [D-0001](D-0001-use-cloudflare-r2-for-project-storage.md) | Use Cloudflare R2 for project storage | Accepted | 2026-08-04 |

<!-- Add a row for every new record. Keep it sorted by number. -->

## Writing a new decision

1. Copy [`template.md`](template.md) to `D-NNNN-short-title.md`, where `NNNN` is
   the next zero-padded number.
2. Fill in the YAML frontmatter and sections. Keep it to a page or two — one
   decision per record.
3. Add a row to the index table above.
4. Open it in a pull request and review it like code; merge when the status is
   `accepted`.
5. To change a past decision, write a new record, set the old one's `status` to
   `superseded by D-NNNN` and its `superseded` field, and set `supersedes` on
   the new one.

Log only **architecturally significant** decisions — ones that are costly to
change or would need coordination, migration, or risk management to reverse.
Skip trivial, easily-reversed choices a linter or convention already covers.
