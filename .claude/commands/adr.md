# /adr command

Record an Architecture Decision Record (ADR) in the decision log at
`docs/decisions/`. Use this when a change makes a significant, hard-to-reverse
choice whose rationale should outlive the pull request.

## Usage

```
/adr <short-title>
```

## Steps

1. First confirm the decision is **architecturally significant** — costly to
   change, or reversing it would need coordination, migration, or risk
   management. If it is trivial or already covered by a linter/convention, stop
   and say so instead of writing a record.
2. Read `docs/decisions/README.md` and the most recent ADRs so the new record is
   consistent and does not silently contradict an `Accepted` decision.
3. Copy `docs/decisions/adr-template.md` to
   `docs/decisions/NNNN-<short-title>.md`, using the next zero-padded number.
4. Fill in the YAML frontmatter and every section. Keep it to a page or two — one
   decision per record. Always list the real alternatives that were considered.
5. Add a row to the index table in `docs/decisions/README.md`.
6. If this decision changes a past one, set the old ADR's `status` to
   `superseded by ADR-NNNN`, set `superseded-by`, and set `supersedes` on the new
   record. Never rewrite the accepted body of the old ADR.
7. Open it in a pull request and review it like code.
