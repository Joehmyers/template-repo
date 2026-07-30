# template-repo

A template repository structured for agent-driven development. Instructions live
in a tool-agnostic `AGENTS.md`, so it works with Claude Code, Cursor, Copilot,
Codex, Aider, and other [AGENTS.md](https://agents.md)-aware tools — not just one.
Clone, fill in the `<fill-in>` placeholders in `AGENTS.md`, and start building.

---

## Repository layout

```
my-project/
├── AGENTS.md                 # Agent context (tool-agnostic) — auto-loaded every session (committed)
├── CLAUDE.md                 # Thin pointer that imports AGENTS.md for Claude Code (committed)
├── AGENTS.local.md           # Personal overrides — gitignored, never commit
├── README.md                 # This file — human-oriented overview
├── .gitignore
├── .claude/
│   ├── settings.json         # Team permissions and hooks (committed)
│   ├── settings.local.json   # Personal overrides (gitignored)
│   ├── rules/                # Path-scoped modular instructions
│   │   └── testing.md        # Example: test-file rules
│   ├── skills/               # On-demand domain knowledge (loaded when relevant)
│   │   └── spec-writer/      # Example: spec-writing workflow
│   ├── agents/               # Specialized subagent definitions
│   │   └── code-reviewer.md  # Example: adversarial diff reviewer
│   └── commands/             # Custom slash commands
│       ├── spec.md           # /spec — start a new feature spec
│       ├── plan.md           # /plan — write an implementation plan
│       └── adr.md            # /adr — record an architecture decision
├── docs/
│   ├── specs/                # Feature specs — the "what/why"
│   │   └── SPEC_TEMPLATE.md  # Copy this when writing a new spec
│   ├── plans/                # Implementation plans — the "how"
│   │   └── PLAN_TEMPLATE.md  # Copy this when writing a new plan
│   ├── decisions/            # Decision log — Architecture Decision Records (the durable "why")
│   │   ├── README.md         # Index table + how to write an ADR
│   │   ├── adr-template.md   # Copy this when recording a new decision
│   │   └── 0001-record-architecture-decisions.md  # Bootstrap ADR
│   ├── diagrams/             # Architecture diagrams (Mermaid, rendered by GitHub)
│   │   └── system-diagram.md # System diagram — graph + timeline views (placeholder)
│   └── style-guide.md        # Writing style — plain English, Orwell's rules, defined terms
├── wrangler.jsonc            # Cloudflare wrangler config — R2 bucket binding (bucket = repo name)
├── src/                      # Product source code
├── tests/                    # Test suite
└── ops/                      # Infrastructure and deployment scripts
    ├── create-bucket.sh      # Create the project's R2 bucket via wrangler
    └── fetch-data.sh         # Sync R2 bucket data into ./data (S3-compatible)
```

---

## Getting started

1. **Clone** this template and rename the project.
2. **Edit `AGENTS.md`** — fill in the `<fill-in>` sections for your build, test, and lint commands.
   (`CLAUDE.md` just imports it, so there is nothing to edit there.)
3. **Add your source code** to `src/` and tests to `tests/`.
4. **Cloud storage (optional)** — storage is assumed to be [Cloudflare R2](https://developers.cloudflare.com/r2/),
   and the bucket is named after the repository.
   - **Create the bucket** with [wrangler](https://developers.cloudflare.com/workers/wrangler/):
     run `wrangler login`, then `ops/create-bucket.sh` (creates a bucket named after the repo).
     The R2 binding is pre-wired in `wrangler.jsonc`.
   - **Fetch data** — copy `.env.example` to `.env`, fill in your Cloudflare R2
     credentials, and run `ops/fetch-data.sh` to sync the bucket into `./data/` (gitignored).
   - Anything created in `./assets/` (gitignored) is pushed back to the bucket automatically
     at the end of each Claude Code turn — so created assets are accessible from anywhere
     (manual push: `ops/push-assets.sh`).
5. **Start your agent** (e.g. `claude` from the project root) — it loads `AGENTS.md` automatically.

---

## Recommended workflow (explore → plan → code → commit)

| Step | What to do |
|------|-----------|
| **Explore** | Enter plan mode (`Shift+Tab`); ask Claude to read relevant files |
| **Plan** | Use `/plan <feature>` to write an implementation plan to `docs/plans/` |
| **Implement** | Exit plan mode; Claude codes against the plan and runs tests |
| **Commit** | Claude commits with a descriptive message |

For larger features, start with `/spec <feature>` to write a spec first.

> **One-sentence diff?** Skip the plan. **Touching > 4 files or unclear scope?** Write a spec.

When a change makes a significant, hard-to-reverse choice, record it in the
**decision log** with `/adr <title>` — see [`docs/decisions/`](docs/decisions/).
These Architecture Decision Records give both humans and agents the durable *why*
behind the code, so past decisions aren't silently contradicted.

---

## Key files to edit first

| File | Purpose |
|------|---------|
| `AGENTS.md` | Fill in build/test/lint commands, code style, gotchas (the canonical instructions) |
| `.claude/settings.json` | Configure permissions and hooks for your toolchain |
| `docs/specs/SPEC_TEMPLATE.md` | Copy and fill for each new feature spec |
| `docs/plans/PLAN_TEMPLATE.md` | Copy and fill for each implementation plan |
| `docs/decisions/adr-template.md` | Copy and fill to record each significant decision |

---

## Resources

- [AGENTS.md](https://agents.md) — the open, tool-agnostic instruction-file standard
- [Architecture Decision Records](https://adr.github.io/) — ADR/MADR formats and tooling
- [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Claude Code best practices](https://www.anthropic.com/engineering/claude-code-best-practices)