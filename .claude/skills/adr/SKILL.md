---
description: Record an Architecture Decision Record (ADR) in docs/decisions/ — the durable why behind a significant, hard-to-reverse choice. Use when a change picks a database, protocol, cloud provider, framework, or boundary, or when someone asks to document a decision, its rationale, or the alternatives considered.
argument-hint: [short-title]
---

# Record an architecture decision

Decision: `$ARGUMENTS`

An ADR captures **why** a hard-to-reverse choice was the right answer at the time,
which constraints applied, and what was rejected. A commit message records what
changed; an ADR records why nobody should quietly change it back.

## Steps

1. **Confirm it is architecturally significant** — costly to change, or reversing
   it would need coordination, migration, or risk management. If it is trivial or
   already covered by a linter or convention, say so and write nothing. A log
   full of small decisions hides the load-bearing ones.
2. **Read `docs/decisions/README.md`** and the most recent ADRs, so the new record
   is consistent and does not silently contradict an `Accepted` decision.
3. **Copy the template.** `docs/decisions/adr-template.md` →
   `docs/decisions/NNNN-$ARGUMENTS.md`, using the next zero-padded number.
4. **Fill in the frontmatter and every section.** One decision per record, a page
   or two. Always list the real alternatives that were on the table — "we just
   picked it" is not a rationale, and the alternatives are what a future reader
   needs in order to reopen the question honestly. Follow `docs/style-guide.md`:
   an ADR is read years later by someone who was not there, so define every term
   of art on first use and state consequences as concrete outcomes.
5. **Add a row** to the index table in `docs/decisions/README.md`.
6. **If this supersedes a past decision:** set the old record's `status` to
   `superseded by ADR-NNNN` and its `superseded-by` field, and set `supersedes` on
   the new record. Never rewrite the accepted body of the old ADR — each record
   was true on the day it was written, and the chain tells the story.
7. **Open it in a pull request** and review it like code.
