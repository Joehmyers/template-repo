# /spec command

Invoke the spec-writer skill to write a new feature specification.

## Usage

```
/spec <feature-name>
```

## Steps

1. Read `.claude/skills/spec-writer/SKILL.md`.
2. Interview the user following the skill's steps.
3. Write the spec to `docs/specs/<feature-name>/spec.md`.
4. Ask the user to review before proceeding to implementation.
