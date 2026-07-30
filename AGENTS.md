# AGENTS.md

Agent context for this repository. This is the canonical, tool-agnostic
instruction file — auto-loaded at the start of every agent session (Claude Code,
Cursor, Copilot, Codex, Aider, Gemini CLI, and other [AGENTS.md](https://agents.md)-aware
tools). Claude Code reads it via a one-line `@AGENTS.md` import in `CLAUDE.md`.

Keep this file under ~200 lines. Include only what an agent cannot infer from
reading the code.

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

# Create the project's Cloudflare R2 bucket (wrangler; bucket = repo name)
ops/create-bucket.sh [bucket-name]

# Fetch project data from Cloudflare R2 into ./data (config via .env — see .env.example)
ops/fetch-data.sh [prefix]

# Push created assets from ./assets to Cloudflare R2 (runs automatically via Stop hook)
ops/push-assets.sh [prefix]
```

---

## Architecture

- `src/`   — product source code
- `tests/` — test suite (the agent's verification target)
- `docs/specs/` — feature specs (what/why)
- `docs/plans/` — implementation plans (how/steps)
- `docs/decisions/` — decision log: Architecture Decision Records (the durable *why*)
- `docs/diagrams/` — architecture diagrams (`system-diagram.md`: Mermaid graph + timeline views)
- `ops/`   — infrastructure and deployment scripts
- `.claude/` — Claude Code configuration (committed to git)

---

## Code style

---

## Writing style

All prose in this repo — docs, specs, plans, ADRs, commit messages, PR
descriptions, comments, error messages — follows `docs/style-guide.md`:
plain English, Orwell's rules, active voice, and every term of art defined on
first use. Apply Orwell's razor: if a simpler phrasing carries the same
meaning, the simpler phrasing is correct.

---

## Testing

---

## Repo etiquette

- Branch naming: `<your-username>/<short-description>` (e.g., `alice/add-login`)
- Commit style: imperative mood, present tense (`add feature`, not `added feature`)
- Open a PR for every change, even solo work — it creates a review artifact
- YOU MUST run tests and lint before pushing
- NEVER commit `.env`, secrets, or generated build artifacts

---

## Decision log

`docs/decisions/` holds the project's **Architecture Decision Records (ADRs)** —
short, immutable Markdown files that record *why* a significant, hard-to-reverse
choice was made. They are the historical "why"; this file is the active "what".

- **Before proposing an architectural change, consult `docs/decisions/README.md`
  and read any relevant ADR.** Do not contradict an `Accepted` decision.
- If a decision genuinely needs to change, propose a **new** ADR that supersedes
  the old one (copy `docs/decisions/adr-template.md`) — never rewrite an accepted
  record.
- Log only **architecturally significant** decisions (costly to change; would
  need coordination, migration, or risk management to reverse). Skip trivial,
  easily-reversed choices a linter or convention already covers.

---

## Architecture decisions

- **Cloud storage: Cloudflare R2.** The bucket is named after the repository
  (override with `R2_BUCKET`). Bucket lifecycle is managed with **wrangler**
  (`ops/create-bucket.sh` → `wrangler r2 bucket create <repo-name>`); the R2
  binding lives in `wrangler.jsonc`. Bulk data transfer uses the S3-compatible
  API (`ops/fetch-data.sh`) because wrangler has no recursive sync.

---

## Environment / gotchas

- Put created assets (generated files meant to outlive this machine) in `./assets/` (gitignored).
  A `Stop` hook in `.claude/settings.json` uploads them to Cloudflare R2 after each agent turn,
  so they are accessible from anywhere; retrieve them with `ops/fetch-data.sh assets`.
  Without R2 credentials in `.env` the hook is a silent no-op — nothing to configure on a fresh clone.
  Symlinks and secret-looking files (`.env*`, `*.pem`, `*.key`) are never uploaded.

---

## Planning workflow

For any change touching more than one file:
1. **Explore** — read relevant files in plan mode (no edits)
2. **Plan** — write a plan to `docs/plans/<feature>.md`
3. **Implement** — code against the plan, run tests after each step
4. **Commit** — descriptive commit message, reference the plan file

For larger features, start with a spec in `docs/specs/<feature>/spec.md` first.
One-sentence diff? Skip the plan.

When a change makes an architecturally significant decision, record it as an ADR
in `docs/decisions/` (copy `docs/decisions/adr-template.md`).

---

## Personal overrides

Add your personal notes, local commands, and machine-specific settings to
`AGENTS.local.md` (gitignored). They are auto-loaded alongside this file.
Claude Code users can equivalently use `CLAUDE.local.md`.
