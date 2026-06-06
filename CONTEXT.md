# Dotfiles

Personal dotfiles and AI coding-agent customizations, installed via GNU Stow.
The terms below disambiguate words this repo overloads (agent, skill, package)
and capture concepts unique to how it's organized (vendored skill, stowed vs
real file).

## Language

### Agents

**Agent**:
An interactive coding-CLI that loads global configuration from this repo.
Currently Pi and Claude Code; the list is open-ended.
_Avoid_: Bot, assistant, AI

**Subagent**:
A specialized Claude Code agent defined under `agents/.claude/agents/` and
invoked from a parent Claude Code session. Claude-specific; Pi has no
equivalent.
_Avoid_: Helper agent, child agent

### Skills

**Skill**:
A reusable Agent capability described by a `SKILL.md` file in a dedicated
directory. Loaded by Pi from `agents/.pi/agent/skills/` and by Claude Code
from `agents/.claude/skills/`.
_Avoid_: Plugin, command, macro

**Vendored skill**:
A Skill copied from an upstream repo (typically `mattpocock/skills`),
tracked with `source:`, `source-rev:`, and `source-author:` frontmatter
and a `skill:`-prefixed `name:`. Synced via the `sync-upstream-skills`
skill.
_Avoid_: Upstream skill, imported skill, third-party skill

**Locally-authored skill**:
A Skill written from scratch in this repo, with no `source:` frontmatter
and no `skill:` name prefix.
_Avoid_: Custom skill, own skill, in-house skill

### Stow layout

**Stow package**:
A top-level directory in this repo (e.g. `agents/`, `git/`, `nvim/`,
`terminal/`, `zsh/`) whose contents mirror a path layout under `$HOME`
and are installed as symlinks by `stow`.
_Avoid_: Package (ambiguous with npm/brew/pip), module, bundle

**Stowed file**:
A file in `$HOME` that is a symlink back to its canonical path inside
this repo. Editing happens at the canonical path.
_Avoid_: Linked file, managed file

**Real file**:
A file in `$HOME` (typically under `~/.pi/agent/` or `~/.claude/`) that
is not a symlink and is not tracked by this repo. Used for
machine-mutated state.
_Avoid_: Local file, untracked file

**Machine-mutated state**:
Content written by an Agent at runtime (e.g. `settings.json`,
`sessions/`, `history.jsonl`, `.credentials.json`, `cache/`, `projects/`).
Must live as Real files, never as Stowed files.
_Avoid_: Runtime state, transient state, agent state

### Instructions hierarchy

**Global instructions**:
An `AGENTS.md` or `CLAUDE.md` file installed via Stow into the Agent's
home directory (`~/.pi/agent/AGENTS.md`, `~/.claude/CLAUDE.md`). Loaded
at the start of every Agent session regardless of the working directory.
_Avoid_: System prompt, base prompt, default instructions

**Project instructions**:
An `AGENTS.md` or `CLAUDE.md` file at the root of a specific repository.
Loaded only when the Agent is operating inside that repo. This repo's
own root `AGENTS.md` and `CLAUDE.md` are project instructions that
govern maintenance of the repo itself.
_Avoid_: Local instructions, repo instructions

### Upstream sync

**Sync**:
The act of pulling upstream changes into Vendored skills via the
`sync-upstream-skills` skill. Surfaces hunks where local has changed
since the last recorded `source-rev:` as conflicts to resolve;
otherwise applies upstream wholesale.
_Avoid_: Update, refresh, pull

**Source frontmatter**:
The `source:`, `source-rev:`, and `source-author:` fields preserved
in every Vendored skill's `SKILL.md`. `source:` and `source-author:`
identify the upstream; `source-rev:` is the merge base for the next
Sync. Local-wins on conflict — see
[ADR 0001](docs/adr/0001-skill-frontmatter-overrides.md).
