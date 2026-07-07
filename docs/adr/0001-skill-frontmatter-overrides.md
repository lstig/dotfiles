# ADR 0001: Local overrides in vendored SKILL.md frontmatter

Status: Superseded (2026-07-06)
Date: 2026-06-06

> **Superseded.** Vendoring moved to the `skills.sh` CLI (the `vendor-skills`
> skill). Skills are now tracked in `.agents/skills/vendor-skills/skills.txt`
> and float to upstream latest, so there is no 3-way merge and no
> `source:`/`source-rev:`/`source-author:` provenance frontmatter to reconcile.
> The decision below is retained for history only.

## Context

Skills under `agents/.claude/skills/` and `agents/.pi/agent/skills/` are
vendored from upstream repositories (mostly `mattpocock/skills`). The
`sync-upstream-skills` skill pulls upstream changes into them. By default
its rule is **"source wins on conflict unless an ADR covers the hunk."**

The provenance fields in the frontmatter of every vendored `SKILL.md` are
added by us and don't exist upstream, so they must be preserved on every
sync.

Vendored skills keep upstream's `name:` verbatim. An earlier revision of
this ADR prefixed `name:` with `skill:` to namespace vendored skills; that
prefix has been dropped — vendored and locally-authored skills now share a
flat namespace, and the `source:` field alone marks a skill as vendored.

## Decision

The following frontmatter fields are **local-wins** in any vendored
`SKILL.md`:

1. **`source:` and `source-author:` lines are added (and preserved).**
   Upstream `SKILL.md` files don't carry these — they can't, because
   upstream doesn't know it's a source. The sync script reads `source:`
   to discover which skills it owns; without it, the next sync won't find
   the skill at all. `source-author:` is kept for attribution.

2. **`source-rev:` is added (and preserved).** Written by the sync script
   after a clean run; gives the next sync a 3-way merge base.

The `name:` field follows upstream. Any other frontmatter field, and the
entire body of `SKILL.md`, follows the default rule (source wins on
conflict).

## Consequences

- When sync-upstream-skills surfaces a conflict whose only hunks are
  these provenance fields, the resolution is: keep local, take upstream
  for anything else, bump `source-rev:`.
- If upstream ever adds its own `source:` or `source-author:` value, this
  ADR still wins — we do not pull those fields from upstream.
- New vendored skills must follow this layout from the start: add
  `source:` and `source-author:` before the first sync, leaving `name:`
  as upstream sets it.
