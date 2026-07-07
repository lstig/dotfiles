---
name: vendor-skills
description: Vendor third-party skills into the agents stow package using the skills.sh CLI. Use when the user wants to add, update, remove, or prune a vendored skill, or refresh vendored skills from upstream.
argument-hint: "add|update|remove|prune [args]"
---

# vendor-skills

Manages the skills vendored into the `agents` stow package at
`agents/.agents/skills/`, using the [skills.sh](https://skills.sh) CLI
(`npx skills`) for the fetch. The list of vendored skills lives in
[`skills.txt`](./skills.txt) — one `<owner/repo> <skill-name>` per line — which
is the source of truth, since the CLI keeps no lockfile.

Skills float to upstream **latest**; there is no revision pinning. Vendored
skills are not edited in place — change them upstream, then `update`. Skills the
author owns (`pr`, `shipit`, `task-notes`, `task-work`) live in
[`lstig/agents`](https://github.com/lstig/agents); edit there, then `update`.

## Run the script

```bash
.agents/skills/vendor-skills/scripts/skills.sh <command> [args]
```

| Command | Effect |
|---|---|
| `add <owner/repo> <skill>` | Record the skill in `skills.txt` and vendor it. |
| `update [skill...]` | Re-fetch every tracked skill (or just the named ones) from upstream. |
| `remove <skill>` | Delete the vendored skill and drop its `skills.txt` entry. |
| `prune` | Delete any vendored skill not tracked in `skills.txt`. |
| `list` | Print the tracked skills. |

Every mutating command re-stows the `agents` package so `$HOME` symlinks stay
current. Run `/reload` (or restart the Agent) afterward to pick up changes.

## Internal skills

Private skills that have no upstream (e.g. `deploy-fleet-app`) carry
`metadata: internal: true` in their `SKILL.md` frontmatter. They are **not**
listed in `skills.txt`; the script never fetches them and `prune` leaves them
alone. Mark a new private skill the same way to protect it.

## Notes

- Requires `node`/`npx` (for the CLI), `rsync`, and `stow`.
- The CLI is invoked with `--copy` into a temp dir, then synced into the
  vendored tree, so nothing depends on the CLI's own symlink layout — stow owns
  the symlinks.
- `add`/`update` fetch upstream's `SKILL.md` verbatim; no provenance frontmatter
  is written (unlike the retired `add-upstream-skill`/`sync-upstream-skills`).
