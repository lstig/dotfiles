# ADR 0002: Canonical skills location and the .gitignore allowlist invariant

Status: Accepted
Date: 2026-06-29

> **Update (2026-07-06):** The vendoring tooling named below
> (`add-upstream-skill`, `sync-upstream-skills`) has been retired in favour
> of the `vendor-skills` skill (`skills.sh`), which writes directly to the
> real `agents/.agents/skills/` tree rather than through the `.claude/skills`
> symlink. The decision — canonical location plus the `.gitignore` allowlist
> invariant — is unchanged and still binding.

## Context

All skills — vendored and locally authored — live in
`agents/.agents/skills/`. That is the real directory. The paths
`agents/.claude/skills` and `agents/.pi/agent/skills` are **symlinks**
into it, so the Claude Code and Pi harnesses both load the same payloads
from one source of truth.

Git stores those two entries as symlink objects and never traverses
them. Every actual `SKILL.md` and bundled file is therefore tracked under
its real path, `agents/.agents/skills/...`.

The repo's `.gitignore` uses a denylist-then-allowlist pattern:
`agents/**/*` ignores the whole package, then `!`-prefixed lines
re-include specific subtrees. It originally allowlisted only the symlink
paths (`!agents/.claude/skills/**/*` and
`!agents/.pi/agent/skills/**/*`), not the real `.agents/skills` tree.

The consequence was a silent trap. The vendoring tools of the time
(`add-upstream-skill` and `sync-upstream-skills`, since retired) wrote to
`.claude/skills/`, and the files landed in `.agents/skills/` through the
symlink — a path nothing allowlisted, so git ignored them. The
already-tracked skills had been force-added at some point, which masked
the gap until a fresh sync added `grilling`, `domain-modeling`, and
`codebase-design` and they failed to appear in `git status`.

## Decision

`agents/.agents/skills/` is the canonical location for all skills. The
`.claude/skills` and `.pi/agent/skills` entries are symlinks into it and
must stay symlinks — do not replace them with real directories, as that
duplicates content and breaks the single source of truth.

`.gitignore` **must allowlist the real tree**, not the symlinks:

```
!agents/.agents
!agents/.agents/skills
!agents/.agents/skills/**/*
```

The symlink allowlist entries are harmless but effectively dead (git
won't traverse a symlink). The `.agents/skills` allowlist is what
actually makes skill content trackable.

## Consequences

- New skills are committable with a normal `git add` — no `git add -f`,
  and no surprise when committing what the vendoring tooling produced.
- Tooling may assume anything written under `.agents/skills/` is
  trackable. `skills.sh` writes there directly, so the original
  write-through-symlink trap can no longer recur.
- A skill added outside `.agents/skills/` (for example under a new
  harness directory) will be silently ignored until a matching allowlist
  entry exists. A `git check-ignore` guard in `skills.sh` would catch
  this class of failure at write time; it is a known, unimplemented
  follow-up rather than part of this decision.
