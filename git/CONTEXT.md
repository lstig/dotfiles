# git package

Stow package for git configuration. Installs `~/.gitconfig` and
`~/.config/git/`.

## Structure

```
.gitconfig                  # main git config (user, signing, includes)
.config/git/
├── ignore                  # global .gitignore
├── allowed_signers         # SSH signing allowed signers
├── github                  # GitHub-specific email (includeIf)
├── gitlab                  # GitLab-specific email (includeIf)
├── codeberg                # Codeberg-specific email (includeIf)
└── local                   # self-hosted Gitea email (includeIf)
```

The per-forge files are sourced via `includeIf gitdir:` directives in
`.gitconfig` so each remote uses the correct identity.
