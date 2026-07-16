# template-repo

A template repository structured for agent-driven development with Claude Code.
Clone, fill in the `<fill-in>` placeholders in `CLAUDE.md`, and start building.

---

## Repository layout

```
my-project/
├── CLAUDE.md                 # Agent context — auto-loaded every session (committed)
├── CLAUDE.local.md           # Personal overrides — gitignored, never commit
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
│       └── plan.md           # /plan — write an implementation plan
├── docs/
│   ├── specs/                # Feature specs — the "what/why"
│   │   └── SPEC_TEMPLATE.md  # Copy this when writing a new spec
│   ├── plans/                # Implementation plans — the "how"
│   │   └── PLAN_TEMPLATE.md  # Copy this when writing a new plan
│   └── diagrams/             # Architecture diagrams (Mermaid, rendered by GitHub)
│       └── system-diagram.md # System diagram — graph + timeline views (placeholder)
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
2. **Edit `CLAUDE.md`** — fill in the `<fill-in>` sections for your build, test, and lint commands.
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
5. **Start Claude Code** with `claude` from the project root.

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

---

## Key files to edit first

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Fill in build/test/lint commands, code style, gotchas |
| `.claude/settings.json` | Configure permissions and hooks for your toolchain |
| `docs/specs/SPEC_TEMPLATE.md` | Copy and fill for each new feature spec |
| `docs/plans/PLAN_TEMPLATE.md` | Copy and fill for each implementation plan |

---

## Resources

- [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Claude Code best practices](https://www.anthropic.com/engineering/claude-code-best-practices)