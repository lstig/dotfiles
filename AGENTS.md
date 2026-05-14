# Agent instructions: dotfiles repo

This repository is the source of truth for personal dotfiles and pi agent
customizations. Files here are installed into `$HOME` via [GNU Stow](https://www.gnu.org/software/stow/).

## Ground rules

- **Edit here, not in `$HOME`.** Anything under `~/.pi/agent/` that is stowed is
  a symlink back into this repo. Treat the repo path as canonical.
- **Preserve the stow layout.** Each top-level directory (e.g. `pi/`) is a stow
  package; its contents must mirror the target layout under `$HOME`. For
  example, `pi/.pi/agent/AGENTS.md` installs to `~/.pi/agent/AGENTS.md`.
- **Do not commit machine-mutated state.** `settings.json`, `auth.json`,
  `sessions/`, and similar files are written by pi at runtime. They live in
  `~/.pi/agent/` as real files, not symlinks, and must not be added to this
  repo.
- **Stable line endings, no secrets.** Never commit API keys, tokens, or auth
  blobs. If a tool's config file mixes secrets with shareable config, split it
  or template it.

## Layout reminder

```
pi/.pi/agent/
├── AGENTS.md      # global pi instructions (installed to ~/.pi/agent/AGENTS.md)
├── extensions/    # see docs/extensions.md
├── skills/        # see docs/skills.md
├── prompts/       # see docs/prompt-templates.md
└── themes/        # see docs/themes.md
```

Pi docs are inside the installed `@earendil-works/pi-coding-agent` package. When
adding a new extension/skill/prompt/theme, read the corresponding doc first and
follow its cross-references.

## Workflow

1. Make the edit inside this repo.
2. If a new file or directory was added, re-stow: `stow -v -R -t "$HOME" pi`.
3. If you changed `AGENTS.md`, extensions, skills, or settings that pi already
   loaded, run `/reload` (or restart pi) so changes take effect.
4. Commit with a short, scoped message (e.g. `pi: add brave-search skill`).

## Adding a new stow package

- Create `dotfiles/<name>/` and recreate the home-relative path inside it.
- Document it in `README.md`.
- Verify with `stow -nv -t "$HOME" <name>` (dry run) before stowing for real.
