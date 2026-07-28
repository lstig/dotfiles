# agents package

Stow package for AI coding-agent customizations.
Installs symlinks under `~/.agents/` (canonical, agent-agnostic), `~/.pi/agent/` (Pi), and `~/.claude/` (Claude Code).

## Structure

```
.agents/
├── AGENTS.md       # canonical global instructions (shared across agents)
└── skills/         # canonical skills home (shared across agents)

.pi/agent/
├── AGENTS.md -> ../../.agents/AGENTS.md  # symlink to canonical instructions
├── extensions/     # local Pi extensions (see docs/extensions.md)
├── skills -> ../../.agents/skills        # symlink to canonical skills
├── prompts/        # local prompt templates (see docs/prompt-templates.md)
└── themes/         # local Pi themes (see docs/themes.md)

.claude/
├── CLAUDE.md -> ../.agents/AGENTS.md     # symlink to canonical instructions
├── agents/         # Claude Code subagents
└── skills -> ../.agents/skills           # symlink to canonical skills
```

Global instructions and skills each live exactly once, under `.agents/`.
The per-agent copies (`.pi/agent/AGENTS.md`, `.claude/CLAUDE.md`, `.claude/skills`, `.pi/agent/skills`) are relative symlinks into that canonical tree, so every agent sees the same instructions and the same skill set.
When a new agent tool is added, point its instructions file and skills directory at `.agents/` the same way.
Keep the canonical instructions agent-agnostic: harness-specific guidance belongs in that harness's own system prompt (for Claude Code, `zsh/.config/zsh/custom/plugins/claude/SYSTEM.md`), not here.

Pi reference docs ship inside the installed `@earendil-works/pi-coding-agent`
package.

## Notes

- `settings.json`, `.credentials.json`, `sessions/`, `projects/`,
  `history.jsonl`, `cache/`, `plugins/`, `daemon*`, and similar
  Machine-mutated state files under `~/.pi/agent/` and `~/.claude/` must
  stay as Real files, not symlinks; they are not tracked here.
- Vendored skills are listed in `.agents/skills/vendor-skills/skills.txt`
  and managed by the `vendor-skills` skill (the `skills.sh` CLI): add,
  update, remove, or prune from that manifest. They float to upstream
  latest and are not edited in place.
- This includes the author's own shareable skills, vendored from
  [`lstig/agents`](https://github.com/lstig/agents) the same way as
  third-party ones. Edit those in that repo, then run `skills.sh update`
  to pull the changes in — don't edit the vendored copies here.
- Private skills with no upstream (e.g. `deploy-fleet-app`) carry
  `metadata: internal: true`, are absent from `skills.txt`, and are edited
  in place; the tooling never fetches or prunes them.
