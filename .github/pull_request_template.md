<!--
Keep this short. The point is to link the change to the reasoning behind it,
so a reviewer — human or agent — does not have to reconstruct it from the diff.
Delete any section that does not apply.
-->

## What changed

<!-- One or two sentences, active voice. What does this do that the repo did not do before? -->

## Why

<!-- The problem this solves. Link the spec, plan, or ADR that carries the full reasoning. -->

- Spec: <!-- docs/specs/<feature>/spec.md, or "none — small, self-contained change" -->
- Plan: <!-- docs/plans/<feature>.md, or "none — one-sentence diff" -->
- ADR: <!-- docs/decisions/NNNN-<title>.md, if this makes a hard-to-reverse choice -->

## Verification

<!-- Paste the result of the command below, or say why it does not apply. -->

```
ops/check.sh
```

## Checklist

- [ ] `ops/check.sh` passes locally
- [ ] Prose follows [`docs/style-guide.md`](../docs/style-guide.md)
- [ ] No `.env`, secrets, or build artifacts committed
- [ ] Any architecturally significant choice is recorded as an ADR, and no
      `Accepted` ADR is silently contradicted
