---
name: add-upstream-skill
description: Vendor a new upstream skill from a GitHub URL into agents/.claude/skills/, writing source/source-rev/source-author frontmatter so sync-upstream-skills can track it. Use when the user wants to add, import, or vendor a new skill from an upstream repo.
argument-hint: "GitHub tree URL of the upstream skill"
---

# add-upstream-skill

Vendors a new skill from upstream into the `agents` stow package, with
frontmatter set up so [sync-upstream-skills](../sync-upstream-skills/SKILL.md)
can track it on future syncs.

## Run the script

```bash
.agents/skills/add-upstream-skill/scripts/add.sh <github-tree-url>
```

Example:

```bash
.agents/skills/add-upstream-skill/scripts/add.sh \
  https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me
```

The script:

1. Parses the URL — only `https://github.com/<owner>/<repo>/tree/<branch>/<path>` is supported.
2. Clones or refreshes the source repo in the shared sync cache.
3. Copies the skill directory to `agents/.claude/skills/<skill-name>/`.
4. Rewrites `SKILL.md` frontmatter:
   - `name:` ← upstream value, or the directory basename if upstream omits it
   - `source:` ← input URL
   - `source-rev:` ← upstream HEAD SHA at clone time
   - `source-author:` ← owner's GitHub display name (falls back to login if `gh` is unavailable)

The script aborts if the upstream path has no `SKILL.md`, or if the destination directory already exists. To re-vendor, remove the destination first.

## After adding

1. Re-stow so the new skill is symlinked into `$HOME`:
   ```bash
   stow -v -R -t "$HOME" -d "$(git rev-parse --show-toplevel)" agents
   ```
2. Review the vendored content — trim anything that doesn't fit. Future upstream changes will surface as conflicts via `sync-upstream-skills`.
3. Commit when satisfied.
