# Agent instructions: dotfiles repo

This repository is the source of truth for personal dotfiles and AI agent
customizations. Files here are installed into `$HOME` via [GNU Stow](https://www.gnu.org/software/stow/).

## Ground rules

- **Edit here, not in `$HOME`.** Anything under `~/.pi/agent/` or `~/.claude/`
  that is stowed is a symlink back into this repo. Treat the repo path as
  canonical.
- **Preserve the stow layout.** Each top-level directory (e.g. `agents/`) is a
  stow package; its contents must mirror the target layout under `$HOME`. For
  example, `agents/.pi/agent/AGENTS.md` installs to `~/.pi/agent/AGENTS.md` and
  `agents/.claude/CLAUDE.md` installs to `~/.claude/CLAUDE.md`.
- **Do not commit machine-mutated state.** `settings.json`, `auth.json`,
  `sessions/`, and similar files are written by the agents at runtime. They
  live in `~/.pi/agent/` and `~/.claude/` as real files, not symlinks, and
  must not be added to this repo.
- **Stable line endings, no secrets.** Never commit API keys, tokens, or auth
  blobs. If a tool's config file mixes secrets with shareable config, split it
  or template it.

## Layout reminder

```
agents/
├── .pi/agent/
│   ├── AGENTS.md      # global pi instructions (installed to ~/.pi/agent/AGENTS.md)
│   ├── extensions/    # see docs/extensions.md
│   ├── skills/        # see docs/skills.md
│   ├── prompts/       # see docs/prompt-templates.md
│   └── themes/        # see docs/themes.md
└── .claude/
    ├── CLAUDE.md      # global Claude Code instructions (installed to ~/.claude/CLAUDE.md)
    ├── agents/        # custom subagents
    └── skills/        # user-level skills
```

Pi docs are inside the installed `@earendil-works/pi-coding-agent` package. When
adding a new extension/skill/prompt/theme, read the corresponding doc first and
follow its cross-references.

## Workflow

1. Make the edit inside this repo.
2. If a new file or directory was added, re-stow: `stow -v -R -t "$HOME" agents`.
3. If you changed agent instructions, extensions, skills, or settings that the
   agent already loaded, run `/reload` (or restart the agent) so changes take
   effect.
4. Commit with a short, scoped message (e.g. `agents: add brave-search skill`).

## Adding a new stow package

- Create `dotfiles/<name>/` and recreate the home-relative path inside it.
- Document it in `README.md`.
- Verify with `stow -nv -t "$HOME" <name>` (dry run) before stowing for real.
