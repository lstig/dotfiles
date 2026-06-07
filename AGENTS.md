# Agent instructions: dotfiles repo

This repository is the source of truth for personal dotfiles and Agent customizations.
Files here are installed into `$HOME` via [GNU Stow](https://www.gnu.org/software/stow/).
See [`CONTEXT.md`](./CONTEXT.md) for the vocabulary (Agent, Skill, Stow package, Global instructions, Sync, etc.).

## Scope

These are the **project instructions** for maintaining this repo.
The files under `agents/.pi/agent/` and `agents/.claude/` (instructions, skills, subagents, extensions, prompts, themes) are **payloads**: they get stowed into `$HOME` and govern Agent behavior in *other* projects.
When working in this repo, treat those payloads as content to manage, not as guidance to follow.

## Ground rules

- **Edit here, not in `$HOME`.** Stowed files under `~/.pi/agent/` or `~/.claude/` are symlinks back into this repo.
  Treat the repo path as canonical.
- **Preserve the stow layout.** Each top-level directory (e.g. `agents/`) is a Stow package; its contents must mirror the target layout under `$HOME`.
  For example, `agents/.pi/agent/AGENTS.md` installs to `~/.pi/agent/AGENTS.md` and `agents/.claude/CLAUDE.md` installs to `~/.claude/CLAUDE.md`.
- **Do not commit Machine-mutated state.** `settings.json`, `auth.json`, `sessions/`, and similar files are written by Agents at runtime.
  They live in `~/.pi/agent/` and `~/.claude/` as Real files, not symlinks, and must not be added to this repo.
- **Stable line endings, no secrets.** Never commit API keys, tokens, or auth blobs.
  If a tool's config file mixes secrets with shareable config, split it or template it.

## Layout reminder

Each Stow package has its own `CONTEXT.md` documenting its structure; start there when editing inside one.
The top-level [`README.md`](./README.md) lists the packages and the per-package `CONTEXT.md` files cover the internals (e.g. [`agents/CONTEXT.md`](./agents/CONTEXT.md) for the Pi + Claude Code payloads).

When adding a new Pi extension/skill/prompt/theme, read the corresponding doc inside the installed `@earendil-works/pi-coding-agent` package first and follow its cross-references.

## Workflow

1. Make the edit inside this repo.
2. If a new file or directory was added, re-stow: `stow -v -R -t "$HOME" agents`.
3. If you changed Global instructions, extensions, skills, or settings that an Agent already loaded, run `/reload` (or restart the Agent) so changes take effect.
4. Commit with a short, conventional commit, scoped to the package (e.g. `feat(agents): add brave-search skill`).

## Adding a new stow package

- Create `dotfiles/<name>/` and recreate the home-relative path inside it.
- Add `<name>/CONTEXT.md` describing the package structure and `<name>/.stow-local-ignore` containing `CONTEXT\.md` so the CONTEXT file isn't symlinked into `$HOME`.
- Document the package in `README.md`.
- Verify with `stow -nv -t "$HOME" <name>` (dry run) before stowing for real.

The `stow-pkg` skill scaffolds these steps for you.
