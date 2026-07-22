---
status: "accepted"
date: 2026-07-21
decision-makers: []
consulted: []
informed: []
tags: [process, documentation]
supersedes: []
superseded-by: null
---

# 0001. Record architecture decisions

## Context and problem statement

We make architecturally significant decisions on this project — choices that are
costly to change and whose rationale would otherwise live only in people's heads,
chat threads, and pull-request comments. When that rationale is lost, new
contributors (human and agent alike) can only blindly accept a past decision or
blindly change it. AI coding agents are especially affected: they infer intent
from code patterns and will faithfully reproduce a convention without knowing
whether it is deliberate, deprecated, or accidental.

How should we record these decisions so the reasoning survives staff turnover,
onboarding, and being read back into an agent's context window?

## Considered options

- **Architecture Decision Records (ADRs)** stored as Markdown in the repo.
- An external wiki or documentation site.
- Nothing formal — rely on commit messages, chat history, and institutional memory.

## Decision

We will use **Architecture Decision Records**, as described by
[Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions),
using the lightweight [MADR](https://adr.github.io/madr/) format.

- ADRs live in `docs/decisions/` as numbered, immutable Markdown files
  (`NNNN-short-title.md`).
- Each record uses the YAML frontmatter and sections in
  [`adr-template.md`](adr-template.md).
- Accepted records are append-only: to change a decision, we write a new ADR that
  supersedes the old one rather than editing history.
- `docs/decisions/README.md` holds an index table, and `AGENTS.md` points agents
  at the log before they propose architectural changes.

## Consequences

- **Good:** rationale is durable, versioned alongside the code, reviewable in
  pull requests, and retrievable by both humans and coding agents.
- **Good:** settled questions stop being re-litigated; the log shows *when* it is
  safe to revisit a decision.
- **Trade-offs:** writing a record takes a few minutes, and the log must be kept
  in the PR workflow to avoid going stale.
- **Follow-ups:** log only load-bearing decisions — avoid documenting trivial or
  purely cosmetic choices that a linter or convention already covers.
