# /plan command

Write an implementation plan for a feature, based on an existing spec or a user description.

## Usage

```
/plan <feature-name> [--spec docs/specs/<feature-name>/spec.md]
```

## Steps

1. If a spec exists at `docs/specs/<feature-name>/spec.md`, read it first.
2. Explore the relevant source files in plan mode (no edits).
3. Write the plan to `docs/plans/<feature-name>.md` using the template below.
4. Ask the user to review and approve before switching out of plan mode.

## Plan template

```markdown
# Plan: <Feature name>

Spec: [docs/specs/<feature>/spec.md](../specs/<feature>/spec.md) <!-- if applicable -->

## Overview
<One paragraph summarizing the approach.>

## Steps

- [ ] 1. <Concrete action — file to create/edit, function to add/change>
- [ ] 2. ...
- [ ] 3. Write / update tests for the above
- [ ] 4. Run test suite; fix failures
- [ ] 5. Commit with message: `<imperative summary>`

## Files changed
| File | Change |
|------|--------|
| `src/<file>` | <what changes> |
| `tests/<file>` | <what tests are added> |

## Verification
<Command(s) to run to confirm the feature works end-to-end.>
```
