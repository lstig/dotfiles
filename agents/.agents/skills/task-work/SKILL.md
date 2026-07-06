---
name: task-work
description: Drive work from a Joplin task note, one checklist item at a time.
argument-hint: "note id, note title, or a description of new work"
disable-model-invocation: true
---

Work a task while keeping its Joplin task note the single source of truth.
The note format and update mechanics live in the `task-create` skill — read it first and follow its update conventions for every note change.

1. **Resolve the note.**
   If the arguments name an existing note, find it (`search_notes` with `notebook:Agents type:todo iscompleted:0 <keywords>`) and `read_note` it.
   Otherwise invoke `task-create` for the described work.
   Done when you hold the note id and its full body.

2. **Orient.**
   Switch to the note's working directory, check out its working branch if one is recorded, and read the whole log — it is a record of what already happened, not a suggestion.
   Done when you can state which unchecked item is next and why.

3. **Work the loop.**
   Take the topmost unchecked item and finish it completely.
   Before starting the next item, update the note: check the item off and log what happened.
   If the work surfaces new tasks, add them to the checklist instead of doing them silently.
   If you get blocked (user input needed, outage, missing access), block the note per `task-create`'s conventions, then poll: periodically re-read the note and re-check the blocker.
   A changed `updated_time` while you were idle means the user edited the note — read the response under `**Response:**` (a ticked option, or text on the freeform line).
   Resume once the user has responded or the blocker has cleared on its own; unblock the note before touching the next item.
   When you think the work is finished, re-read the note and review the whole checklist: confirm every item is genuinely complete, checked off, and has a matching log entry — an update lost to a tool failure looks identical to one you never made.
   Done when that review finds no unchecked items and no gaps.

4. **Close out.**
   Add links for any artifacts produced (PRs, commits, docs), close the task per `task-create`'s conventions, and tell the user what changed and what to do next.
