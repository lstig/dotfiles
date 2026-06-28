# dotfiles

Personal dotfiles and customizations, organized as [GNU Stow](https://www.gnu.org/software/stow/) packages.
Each top-level directory is a stow package whose contents mirror the target structure under `$HOME`.

See [`CONTEXT.md`](./CONTEXT.md) for the vocabulary used in this repo (Agent, Skill, Stow package, Global instructions, Sync, etc.) and [`AGENTS.md`](./AGENTS.md) for instructions when editing it with an Agent.

> [!WARNING]
> I don't recommend using these dotfiles verbatim since they contain configuration highly specific to my workflow.
> Having said that, I do hope they serve a good example or starting point for your own dotfiles.

## Layout

```
dotfiles/
├── README.md     # this file
├── AGENTS.md     # project instructions for this repo (symlinked as CLAUDE.md)
├── CONTEXT.md    # vocabulary used across the repo
├── docs/         # repo-wide docs (ADRs under docs/adr/)
├── agents/       # Stow package: AI coding-agent customizations
├── direnv/       # Stow package: direnv config (~/.config/direnv/)
├── forgejo-cli/  # Stow package: forgejo-cli config (~/.config/forgejo-cli/)
├── git/          # Stow package: git config, signing, per-forge identities
├── nvim/         # Stow package: Neovim config
├── terminal/     # Stow package: Ghostty + Starship config
└── zsh/          # Stow package: zsh config (XDG-based, modular conf.d/)
```

Each Stow package has its own `CONTEXT.md` describing its internal structure, excluded from stow installation via a per-package `.stow-local-ignore`.

`docs/adr/` holds Architecture Decision Records ("ADRs") for repo-wide decisions that affect more than one package or skill (e.g. how vendored-skill frontmatter is reconciled during sync).
Per-package decisions belong in the package's `CONTEXT.md` instead.

## Install

Prerequisite: `brew install stow` (or your platform's equivalent).

From the repo root:

```sh
# Install a package (creates symlinks under ~)
stow -v -t "$HOME" agents

# Remove (unstow)
stow -v -D -t "$HOME" agents

# Re-stow after changes
stow -v -R -t "$HOME" agents
```

If stow refuses because a Real file already exists at the target path (typically Machine-mutated state like `~/.pi/agent/settings.json` or `~/.claude/settings.json`), move that file aside and re-run.
Runtime state is deliberately left as Real files; only user-authored resources are stowed.
See [`CONTEXT.md`](./CONTEXT.md) for the distinction between Stowed and Real files.

## Adding a new package

1. Create a top-level directory named after the package (e.g. `zsh/`, `git/`).
2. Inside it, recreate the target paths relative to `$HOME` (e.g. `zsh/.zshrc`, `git/.config/git/config`).
3. Add a `CONTEXT.md` describing the package's structure and a `.stow-local-ignore` containing `CONTEXT\.md` so it's not symlinked.
4. Document the package in the Layout section above.
5. `stow -nv -t "$HOME" <package>` to dry-run, then drop `-n` to install.

The `stow-pkg` skill scaffolds steps 1-3 automatically.
