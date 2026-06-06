# ADR 0001: Local overrides in vendored SKILL.md frontmatter

Status: Accepted
Date: 2026-06-06

## Context

Skills under `agents/.claude/skills/` and `agents/.pi/agent/skills/` are
vendored from upstream repositories (mostly `mattpocock/skills`). The
`sync-upstream-skills` skill pulls upstream changes into them. By default
its rule is **"source wins on conflict unless an ADR covers the hunk."**

Two passages in the frontmatter of every vendored `SKILL.md` differ from
upstream by design and must be preserved on every sync.

## Decision

The following frontmatter fields are **local-wins** in any vendored
`SKILL.md`:

1. **`name:` is prefixed with `skill:`**
   Upstream uses `name: foo`. Local uses `name: skill:foo`.
   Reason: the `skill:` namespace prevents collisions between vendored
   skills and locally-authored ones and makes the source obvious at the
   call site.

2. **`source:` and `source-author:` lines are added (and preserved).**
   Upstream `SKILL.md` files don't carry these — they can't, because
   upstream doesn't know it's a source. The sync script reads `source:`
   to discover which skills it owns; without it, the next sync won't find
   the skill at all. `source-author:` is kept for attribution.

3. **`source-rev:` is added (and preserved).** Written by the sync script
   after a clean run; gives the next sync a 3-way merge base.

Any other frontmatter field, and the entire body of `SKILL.md`, follows
the default rule (source wins on conflict).

## Consequences

- When sync-upstream-skills surfaces a conflict whose only hunks are
  these three fields, the resolution is: keep local, take upstream for
  anything else, bump `source-rev:`.
- If upstream ever adds its own `name:` rename, `source:`, or
  `source-author:` value, this ADR still wins — we do not pull those
  fields from upstream.
- New vendored skills must follow this layout from the start: rename
  `name:` to `skill:<name>`, add `source:` and `source-author:` before
  the first sync.
