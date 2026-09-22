---
status: "accepted"
date: 2026-09-22
decider: [joehmyers]
tags: [agents, research, plugins, claude-code]
supersedes: []
superseded: null
---

# D-0003. Ship deep research as a project-scoped plugin

## Context

The template already has `/research`, a skill that splits a question into
sub-questions and gives each one to a subagent inside the current session. It
suits a question you can scope in one go. It does not suit a question that
needs a source list built first, read by several specialists who disagree with
each other, and then synthesised: one session cannot hold that much reading,
and the skill has no way to run the specialists as separate sessions.

The `deep-research` plugin does exactly that job and is already written. (A
*plugin* here is a bundle of skills and subagent definitions that Claude Code
installs and versions in one step, from a *marketplace*, a catalogue of them
hosted in a git repository.) It runs a Haiku scout to build the source list,
three to five Sonnet specialists to read and cross-check, and an Opus agent to
check coverage and write the report, and it commits the report to
`docs/research/`, the folder this repository already keeps evidence in.

So the question is not whether to build such a pipeline; it is whether the
template carries someone else's, and at which scope. Every repository created
from this template inherits the answer.

Note that D-0002 governs the format of skills a project *publishes*. This
record is about a tool the project *consumes*, so the two do not overlap.

## Options

- **Point at it in the README and let each person install it.** No repository
  change; anyone who wants deep research runs two commands first.
- **Install at user scope** (`~/.claude/settings.json`), so it follows the
  person across every repository they open.
- **Install at project scope** (`.claude/settings.json`, committed), so it
  follows the repository to everyone who clones it.
- **Copy the plugin's skills and subagents into `.claude/` as our own files.**
  Full control, no dependency, and we own every future fix.

## Decision

We will install `deep-research@claude-community` at project scope and commit
the result, and enable agent teams in the same file.

- `.claude/settings.json` names the community marketplace under
  `extraKnownMarketplaces`, enables the plugin under `enabledPlugins`, and sets
  `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to `"1"` under `env`. All three are
  committed, so a clone needs no setup step.
- The plugin is invoked as `/deep-research:research --mode={web,repo,structured}`
  and checked with `/deep-research:setup`. Claude Code namespaces plugin skills
  by plugin name, so the template's own `/research` keeps its name.
- `/research` stays. It is the cheaper tool and the right first reach; the
  plugin is for questions that earn a bigger spend.

## Consequences

- **Benefits:** every project spun from the template has repository-aware deep
  research on the first session, with the plugin's source and pinned version
  recorded in git rather than in someone's machine.
- **Benefits:** reports land in `docs/research/`, which `/decision` and `/spec`
  already read, so the evidence chain is unchanged.
- **Benefits:** reversing this is one command,
  `claude plugin uninstall deep-research@claude-community --scope project`,
  which edits the same committed file.
- **Costs:** a third-party dependency in every downstream project. The
  marketplace pins the plugin to a commit, but nobody here reviews what a
  future pin contains.
- **Costs:** about 1,900 tokens are added to every session in the repository
  before anything is run, and each teammate the pipeline spawns is a separate
  Claude session with its own context window.
- **Costs:** agent teams is experimental and off by default upstream. While it
  is on, any subagent Claude names starts as a teammate, so a team can form in
  ordinary work nobody framed as team work. Setting the value to `"0"` turns
  that off and stops the plugin working.
- **Costs:** the plugin is Claude Code only. A contributor using another
  AGENTS.md-aware tool gets nothing from it and falls back to `/research`.
- **Costs:** two file-naming conventions now share `docs/research/`. The plugin
  writes `YYYY-MM-DD-<topic-slug>.md` plus a paper trail under `archive/`;
  `/research` writes `<topic>.md`.
- **Known rough edges:** plugin 1.3.1 lags Claude Code 2.1.278 in two places.
  It still instructs `TeamCreate` and `TeamDelete`, tools removed in v2.1.178,
  where spawning a named subagent now creates the teammate instead, so those
  steps fail and Claude has to work around them. And `/deep-research:setup`
  tests for `commands/{web,repo,structured}.md`, which 1.3.1 replaced with one
  `research.md` plus a `--mode` flag, so its own health check reports every
  pipeline missing while all three work. Both were checked against the
  installed 1.3.1 tree on 2026-09-22.
