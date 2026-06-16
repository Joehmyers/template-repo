# CLAUDE.md

Agent context for this repository. Auto-loaded at the start of every Claude Code session.
Keep this file under ~200 lines. Include only what Claude cannot infer from reading the code.

---

## Commands

```bash
# Install dependencies
<fill-in>

# Build
<fill-in>

# Run tests
<fill-in>

# Lint / format
<fill-in>

# Run locally
<fill-in>
```

---

## Architecture

- `src/`   — product source code
- `tests/` — test suite (the agent's verification target)
- `docs/specs/` — feature specs (what/why)
- `docs/plans/` — implementation plans (how/steps)
- `ops/`   — infrastructure and deployment scripts
- `.claude/` — Claude Code configuration (committed to git)

---

## Code style

<!-- Document rules that differ from language defaults, e.g.:
- Use 2-space indentation (not 4)
- Prefer named exports over default exports
- All public functions must have docstrings
-->

---

## Testing

<!-- Describe the test runner and any non-obvious conventions, e.g.:
- Tests live alongside source in __tests__/ subdirectories
- Run a single test file: `<command> <file>`
- Integration tests require a running database; see ops/README.md
- IMPORTANT: Never mock internal modules — test them directly
-->

---

## Repo etiquette

- Branch naming: `<your-username>/<short-description>` (e.g., `alice/add-login`)
- Commit style: imperative mood, present tense (`add feature`, not `added feature`)
- Open a PR for every change, even solo work — it creates a review artifact
- YOU MUST run tests and lint before pushing
- NEVER commit `.env`, secrets, or generated build artifacts

---

## Architecture decisions

<!-- Document non-obvious decisions, e.g.:
- We use X over Y because Z
- Module boundaries are enforced by ... (tool/rule)
- Auth uses JWT with 15-min expiry; refresh tokens stored in httpOnly cookies
-->

---

## Environment / gotchas

<!-- Document required env vars and non-obvious setup, e.g.:
- Requires `FOO_API_KEY` in `.env` (copy `.env.example`)
- Port 5432 must be free; run `docker compose up db` before integration tests
- The build assumes Node ≥ 20; check `.nvmrc`
-->

---

## Planning workflow

For any change touching more than one file:
1. **Explore** — read relevant files in plan mode (no edits)
2. **Plan** — write a plan to `docs/plans/<feature>.md`
3. **Implement** — code against the plan, run tests after each step
4. **Commit** — descriptive commit message, reference the plan file

For larger features, start with a spec in `docs/specs/<feature>/spec.md` first.
One-sentence diff? Skip the plan.

---

## Personal overrides

Add your personal notes, local commands, and machine-specific settings to `CLAUDE.local.md`
(gitignored). They are auto-loaded alongside this file.
