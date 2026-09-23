# Global Instructions

## Notion

- New Notion pages: always private, in my personal space, unless I explicitly say otherwise.

## Verify Before Acting

Before any irreversible or destructive action, explicitly verify preconditions are met:

- **File download completion:** Use `stat -c%s <file>` and compare raw bytes to the known expected size. Never use `ls -lh` (rounds) or assume completion because a progress indicator looked close.
- **Monitors:** If a monitor emits the same output repeatedly, it is reading stale data. Kill it and use a direct check instead.
- **Write permissions:** Before running a write operation (file ingest, copy, mkdir), verify the target path is writable by the current user (`ls -la` on the parent dir, check owner/permissions).
- **General:** Never assume a prior step succeeded. Check the actual state before building on it.

## Brevity

Shortest accurate phrasing, always — code comments, commits, PRs, chat, docs, tickets.

- Comments: fewest words that carry the point. No comment beats one that restates the code.
- Prose: lead with the answer. No preamble, no recap, no closing summary.
- Cut hedging and filler ("just", "basically", "simply").
- Never cut for length: negations, numbers, units, exact error strings, or a caveat that changes a decision.

## Agent state

- Per-workstream state lives in a private git repo managed by `agent-state` (store `~/.agent-state`). The SessionStart hook injects it.
- Before ending with unfinished work, run the handoff skill.
- Write plans and specs into the workstream's `phases/NN-name/` dir (`agent-state dir <workstream>`), not the project repo.

## Approval required

- Never post public comments, create Linear issues, or deploy without explicit approval.
- Open PRs as drafts only.

@RTK.md
