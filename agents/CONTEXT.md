# agents package

Stow package for AI coding-agent customizations.
Installs symlinks under `~/.agents/` (canonical, agent-agnostic), `~/.pi/agent/` (Pi), and `~/.claude/` (Claude Code).

## Structure

```
.agents/
└── skills/         # canonical skills home (shared across agents)

.pi/agent/
├── AGENTS.md       # global Pi instructions
├── extensions/     # local Pi extensions (see docs/extensions.md)
├── skills -> ../../.agents/skills    # symlink to canonical skills
├── prompts/        # local prompt templates (see docs/prompt-templates.md)
└── themes/         # local Pi themes (see docs/themes.md)

.claude/
├── CLAUDE.md       # global Claude Code instructions
├── agents/         # Claude Code subagents
└── skills -> ../.agents/skills       # symlink to canonical skills
```

Skills live exactly once at `.agents/skills/`.
Per-agent skill directories (`.claude/skills`, `.pi/agent/skills`) are relative symlinks into that canonical tree, so every agent sees the same skill set.
When a new agent tool is added, point its skills directory at `.agents/skills/` the same way.

Pi reference docs ship inside the installed `@earendil-works/pi-coding-agent`
package.

## Notes

- `settings.json`, `.credentials.json`, `sessions/`, `projects/`,
  `history.jsonl`, `cache/`, `plugins/`, `daemon*`, and similar
  Machine-mutated state files under `~/.pi/agent/` and `~/.claude/` must
  stay as Real files, not symlinks; they are not tracked here.
- Vendored skills carry `source:`, `source-rev:`, and `source-author:`
  frontmatter and a `skill:`-prefixed `name:`. Reconcile them with
  upstream via the `sync-upstream-skills` skill.
