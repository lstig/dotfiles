# agents package

Stow package for AI coding-agent customizations. Installs symlinks under
`~/.pi/agent/` (Pi) and `~/.claude/` (Claude Code).

## Structure

```
.pi/agent/
├── AGENTS.md       # global Pi instructions
├── extensions/     # local Pi extensions (see docs/extensions.md)
├── skills/         # local Pi skills (see docs/skills.md)
├── prompts/        # local prompt templates (see docs/prompt-templates.md)
└── themes/         # local Pi themes (see docs/themes.md)

.claude/
├── CLAUDE.md       # global Claude Code instructions
├── agents/         # Claude Code subagents
└── skills/         # Claude Code skills (vendored and locally-authored)
```

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
