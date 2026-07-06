---
name: task-create
description: Create a Joplin task note — the durable record of one task (description, working directory, checklist, log, links). Use when the user wants a Joplin note tracking a task, or when another skill needs to create or update a task note.
---

A task note is a Joplin to-do holding the true state of one task.
Anyone — or any fresh agent — reading only the note must be able to resume the work.

## Creating a task note

1. Search for an existing open note for the same work: `search_notes` with `notebook:Agents type:todo iscompleted:0 <keywords>`.
   If one exists, update it per the conventions below instead of creating a duplicate.
2. Get the `Agents` notebook id from `list_notebooks`; create it with `create_notebook` if missing.
3. Allocate the task number.
   Search `notebook:Agents` with **no** `iscompleted` filter (completed tasks keep their numbers so none is ever reused), read every title's leading `[NNNN]`, take the highest, add one, and zero-pad to four digits.
   Start at `[0001]` when the notebook has no numbered notes yet.
4. Create the note with `create_note`: `is_todo: true`, title `[NNNN] <short imperative title>`, body from the template below.
   The checklist must cover all work known at creation time, as concrete verifiable items, each uniquely worded (exact-match updates depend on it).

Done when the note exists in `Agents` **as a to-do** (it appears under `type:todo` in `search_notes` — if not, the `is_todo` flag was dropped; fix it before proceeding) and you have reported its number, id, and title back to the caller.

## Body template

    ## Task

    One or two sentences: what the work is and what "done" means.

    **Working directory:** `/absolute/path`

    **Working branch:** `branch-name`

    ## Checklist

    - [ ] First concrete item
    - [ ] Second concrete item

    ## Links

    - [Descriptive title](https://example.com)

    ## Log

    - 2026-07-05 14:02 — Created task note.

`## Log` stays the last section so entries land there with plain `append`.

Omit the working-branch line when the directory is not a git repository.

## Update conventions

All updates go through `update_note` partial ops; never rewrite the full body.

- **Log an event:** `append` one line, `- <YYYY-MM-DD HH:MM> — <what happened and the outcome>`.
  Get the timestamp from `date '+%Y-%m-%d %H:%M'`.
- **Check off an item:** `replace_text` with find `- [ ] <exact item>`, replace `- [x] <exact item>`.
- **Add a line to a section:** `replace_text` on the *next* section's heading, replacing it with the new line, a blank line, then the heading — headings are the only guaranteed-unique anchors.
- **Block the task:** insert `🛑` after the `[NNNN]` prefix so the title reads `[NNNN] 🛑 <title>`, and `prepend` a blocked section:

      ## 🛑 Blocked — <YYYY-MM-DD HH:MM>

      <the question for the user, or the outage being waited on>

      **Response:**

      - [ ] <option 1>
      - [ ] <option 2>
      - [ ] Other: <type here>

  When the answers are enumerable, offer them as checkboxes for the user to tick — always with an `Other:` freeform line last.
  Skip the checkboxes and leave only the freeform line when options don't fit the question (or it's an outage, not a question).
- **Unblock the task:** restore the title, log the user's response or the resolution, and remove the whole blocked section with `replace_text` (replace with nothing).
- **Close the task:** when every checklist item is checked, set `todo_completed: true` and append a final log entry with the outcome.
