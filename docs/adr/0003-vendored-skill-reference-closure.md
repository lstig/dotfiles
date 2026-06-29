# ADR 0003: Vendored skills must satisfy reference closure

Status: Accepted
Date: 2026-06-29

## Context

Upstream skills frequently delegate work to sibling skills. A skill body
can be as small as `Run the `/grilling` skill` or
`... using the `/domain-modeling` skill`. The referenced sibling is a
separate skill that must exist for the caller to function.

When `sync-upstream-skills` pulls such a body, a 3-way merge can succeed
cleanly while leaving the skill pointing at a sibling that isn't vendored
here. The merge reports success; the skill is broken at runtime.

This happened during the sync that prompted this ADR. Upstream rewrote
`grill-me`, `grill-with-docs`, and `improve-codebase-architecture` to
delegate to `/grilling`, `/domain-modeling`, and `/codebase-design` —
none of which were vendored. The sync reported a clean merge while all
three skills were left dangling.

Relatedly, upstream sometimes renames or removes a skill
(`write-a-skill` became `writing-great-skills`). The sync reports
`upstream path no longer exists` and skips it, leaving the local copy
pinned to a dead `source:` URL.

## Decision

A vendored skill must satisfy **reference closure**: every sibling skill
it invokes must itself be vendored under `agents/.agents/skills/`.

`sync.sh` enforces this advisorily. After merging, it emits a
`## Reference closure` report section flagging any `/x` reference with no
vendored skill directory. The heuristic: backtick-wrapped `/kebab`
tokens appearing on lines that mention "skill" or "session" (the
phrasing upstream uses to delegate), checked against the set of vendored
skill-directory basenames. It is report-only and does not change the
exit status.

Resolution when a reference is flagged:

- **Missing sibling** → vendor it with `add-upstream-skill` (its upstream
  URL is in the same source repo), then re-sync to confirm closure.
- **Stale reference** (upstream dropped the sibling) → edit the body to
  remove the call.

On an upstream **rename or removal**, adopt the successor: re-vendor
under the new name and delete the old skill. Do not maintain a local
fork under the old name — ADR 0001 keeps `name:` following upstream, so a
renamed-but-kept skill would conflict on every future sync.

## Consequences

- Vendoring one skill may pull in a tree of siblings. That is expected:
  the skills form a connected graph, and closure is the property that
  keeps the graph runnable.
- The check is a heuristic, not a parser. It can miss a reference phrased
  without "skill"/"session", and it does not scan bundled non-`SKILL.md`
  files. Treat a clean closure report as necessary, not sufficient.
- Following a rename changes the user-facing invocation name (for
  example `/write-a-skill` became `/writing-great-skills`). That churn is
  accepted in exchange for staying mergeable with upstream.
