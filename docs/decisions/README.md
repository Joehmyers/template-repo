# Decision log

This is the project's **decision log** — the collection of
[Architecture Decision Records (ADRs)](https://adr.github.io/) that capture *why*
significant, hard-to-reverse choices were made.

An ADR is a short, **immutable** Markdown file. It records one decision, the
context that forced it, and the consequences of making it. When a decision
changes, you do **not** rewrite the old record — you write a *new* ADR that
supersedes it and link the two. Each record was true on the day it was written,
and the chain of supersession tells the story of how the system evolved.

## Why this exists (especially for agents)

A commit message records *what* changed; an ADR records *why* it was the right
answer at the time, which constraints applied, and what alternatives were
rejected. A human can compensate for missing rationale by asking a colleague — an
agent cannot. Without recorded rationale, an agent infers intent from code
patterns and will faithfully reproduce a convention without knowing whether it is
deliberate, deprecated, or accidental — producing plausible, working,
*inconsistent* code at speed.

The decision log (historical "why") and `AGENTS.md` (active "what") are
complementary: an ADR says *"we chose Postgres because we needed transactional
consistency"*; an `AGENTS.md` rule says *"all data access goes through the
existing Postgres pool; never add a new database dependency without approval."*
One explains the past; the other governs the future.

## For agents

- **Before proposing an architectural change, read this index and any relevant ADR.**
- **Do not contradict an `Accepted` decision.** If a decision genuinely needs to
  change, propose a *new* ADR that supersedes the old one rather than editing it.
- When retrieving decisions, **filter on `status`** so superseded/deprecated
  records never outrank the current one.

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | Accepted | 2026-07-21 |
| [0002](0002-use-cloudflare-r2-for-project-storage.md) | Use Cloudflare R2 for project storage | Accepted | 2026-08-04 |

<!-- Add a row for every new ADR. Keep it sorted by number. -->

## Writing a new ADR

1. Copy [`adr-template.md`](adr-template.md) to
   `NNNN-short-title.md`, where `NNNN` is the next zero-padded number.
2. Fill in the YAML frontmatter and sections. Keep it to a page or two — one
   decision per record.
3. Add a row to the index table above.
4. Open it in a pull request and review it like code; merge when the status is
   `accepted`.
5. To change a past decision, write a new ADR, set the old one's `status` to
   `superseded by ADR-NNNN`, and set the new one's `supersedes`.

The first record you write is that you'll use ADRs at all
([ADR 0001](0001-record-architecture-decisions.md)). Only log
**architecturally significant** decisions — ones that are costly to change or
would require coordination, migration, or risk management to reverse. Skip
trivial, easily-reversed choices already covered by a linter or a convention.
