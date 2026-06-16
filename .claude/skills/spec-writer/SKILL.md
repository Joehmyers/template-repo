# Spec-writing skill

Use this skill when asked to write a feature specification.

## Steps

1. **Interview the user** — ask clarifying questions until you can answer:
   - What problem does this solve, and for whom?
   - What are the acceptance criteria (observable behavior)?
   - What is explicitly out of scope?
   - What is the end-to-end verification step?

2. **Write the spec** to `docs/specs/<feature>/spec.md` using the template below.

3. **Stop and ask for review** before writing any code.

## Spec template

```markdown
# Spec: <Feature name>

## Problem
<One paragraph: what problem this solves and why it matters.>

## Scope
### In scope
- <Bullet list of what this change covers.>

### Out of scope
- <Bullet list of what this change does NOT cover.>

## Requirements
1. <Numbered, testable requirements.>
2. ...

## Interfaces / files involved
- `src/<file>` — <what changes>
- `tests/<file>` — <what tests are added>

## Acceptance criteria
- [ ] <Observable behavior that proves the feature works.>
- [ ] ...

## End-to-end verification
<Step-by-step instructions a human or agent can follow to confirm the feature works end-to-end.>
```
