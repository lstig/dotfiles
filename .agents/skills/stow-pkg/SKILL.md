---
name: stow-pkg
description: Scaffold a new GNU Stow package in the dotfiles repo. Use when the user wants to add a new tool or config set (e.g., git, nvim, ssh) as a stow-managed dotfiles package.
---

# stow-pkg

Scaffolds a new GNU Stow package inside this dotfiles repo and verifies it can be stowed cleanly.

## Dotfiles repo layout

Each top-level directory is a stow package. Its contents mirror `$HOME`. For example:

```
git/
└── .gitconfig          → ~/.gitconfig
nvim/
└── .config/nvim/       → ~/.config/nvim/
```

## Steps

1. **Determine the package name and files** — ask the user if not provided. Common names: `git`, `nvim`, `ssh`, `tmux`, `starship`.

2. **Create the directory tree** inside the repo (resolve the repo root with `git rev-parse --show-toplevel`):
   ```bash
   DOTFILES=$(git rev-parse --show-toplevel)
   mkdir -p "$DOTFILES/<name>/<home-relative-path>"
   ```
   Mirror the exact path under `$HOME`. For `~/.config/foo/config.toml` use `<name>/.config/foo/config.toml`.

3. **Add a placeholder or real config** — either copy an existing file from `$HOME` or create a starter template, depending on what the user wants.

4. **Dry-run stow** to confirm no conflicts:
   ```bash
   stow -nv -t "$HOME" -d "$(git rev-parse --show-toplevel)" <name>
   ```
   If conflicts are reported, show them to the user and ask how to resolve before proceeding.

5. **Stow for real**:
   ```bash
   stow -v -R -t "$HOME" -d "$(git rev-parse --show-toplevel)" <name>
   ```

6. **Update `README.md`** — add the new package to the packages table.

7. **Stage and show the diff**; do not commit unless the user asks.

## Notes

- Never stow `~/.ssh/` private keys or `~/.gnupg/` secret material. Config-only files (e.g., `~/.ssh/config`) are fine.
- If the target file already exists in `$HOME` and is not a symlink, stow will conflict — surface this clearly.
- For XDG config paths (`~/.config/<tool>/`), use `<name>/.config/<tool>/` inside the package.
