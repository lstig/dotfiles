# dotfiles

Personal dotfiles and customizations, organized as [GNU Stow](https://www.gnu.org/software/stow/)
packages. Each top-level directory is a stow package whose contents mirror the
target structure under `$HOME`.

> [!WARNING]
> I don't recommend using these dotfiles verbatim since they contain configuration highly specific to my workflow.
> Having said that, I do hope they serve a good example or starting point for your own dotfiles. 

## Layout

```
dotfiles/
├── AGENTS.md           # Instructions for the pi agent when working in THIS repo
├── README.md           # This file
├── pi/                 # Stow package for the `pi` coding agent
│   └── .pi/
│       └── agent/
│           ├── AGENTS.md     # Global instructions loaded by pi at startup
│           ├── extensions/   # Local pi extensions
│           ├── skills/       # Local pi skills
│           ├── prompts/      # Local prompt templates
│           └── themes/       # Local pi themes
├── git/                # Stow package for git configuration
│   ├── .gitconfig            # Main git config (user, signing, includes)
│   └── .config/
│       └── git/
│           ├── ignore        # Global .gitignore
│           ├── allowed_signers  # SSH signing allowed signers
│           ├── github        # GitHub-specific email (includeIf)
│           ├── gitlab        # GitLab-specific email (includeIf)
│           ├── codeberg      # Codeberg-specific email (includeIf)
│           └── local         # Self-hosted Gitea email (includeIf)
├── nvim/               # Stow package for Neovim configuration
│   └── .config/
│       └── nvim/
│           ├── init.lua        # Entry point
│           ├── lazy-lock.json  # lazy.nvim plugin lockfile
│           ├── lua/            # Lua config and plugin specs
│           └── after/          # ftplugin and after/plugin overrides
├── terminal/           # Stow package for terminal tools (Ghostty + Starship)
│   └── .config/
│       ├── ghostty/
│       │   └── config        # Ghostty terminal configuration
│       └── starship.toml     # Starship prompt configuration
└── zsh/                # Stow package for zsh configuration
    ├── .zshenv               # Sets ZDOTDIR to ~/.config/zsh
    └── .config/
        └── zsh/
            ├── .zshrc        # Main zsh config
            ├── conf.d/       # Modular config fragments (sourced in order)
            └── custom/       # Custom plugins and overrides
```

After stowing, the `pi/.pi/agent/...` tree is symlinked to `~/.pi/agent/...`,
which is where the pi agent looks for global configuration and resources.

## Install

Prerequisite: `brew install stow` (or your platform's equivalent).

From the repo root:

```sh
# Install the pi package (creates symlinks under ~)
stow -v -t "$HOME" pi

# Remove (unstow)
stow -v -D -t "$HOME" pi

# Re-stow after changes
stow -v -R -t "$HOME" pi
```

If stow refuses because a real file already exists at the target path (for
example `~/.pi/agent/settings.json`), move that file aside and re-run. We
deliberately do *not* stow `settings.json` because pi mutates it (e.g.
`lastChangelogVersion`); keep that as a real file in `~/.pi/agent/` and check in
only the resources you want under version control.

## Adding a new package

1. Create a top-level directory named after the package (e.g. `zsh/`, `git/`).
2. Inside it, recreate the target paths relative to `$HOME` (e.g. `zsh/.zshrc`, `git/.config/git/config`).
3. `stow -t "$HOME" <package>` to install.

## pi customizations

See [`pi/.pi/agent/AGENTS.md`](pi/.pi/agent/AGENTS.md) for the global agent
instructions, and the sibling `extensions/`, `skills/`, `prompts/`, and
`themes/` directories for resources. Reference docs:

- Extensions: `docs/extensions.md`
- Skills: `docs/skills.md`
- Prompt templates: `docs/prompt-templates.md`
- Themes: `docs/themes.md`
- Settings: `docs/settings.md`

(Docs ship inside the installed `@earendil-works/pi-coding-agent` package.)
