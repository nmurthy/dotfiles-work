---
name: handoff
description: >
  Save portable session state before ending or switching machines/agents. Rewrites the
  workstream's STATE.md, appends DECISIONS.md, ticks ROADMAP.md, writes the phase SUMMARY.md,
  then commits and syncs the private state repo via the `agent-state` CLI. Use for /handoff,
  "save state", "wrap up", "hand off", or before closing a session with unfinished work.
---

# Handoff

State lives outside the project repo in a private git repo (the store: `$AGENT_STATE_DIR`, default `~/.agent-state`), one directory per workstream. `agent-state dir` prints this project's directory in the store. The next session on any machine or agent is started from STATE.md alone, so write it for a reader with zero context.

## Steps

1. Pull first: `agent-state sync`. If it reports a conflict, stop and resolve it before writing anything (see Conflicts).
2. Find the workstream: `agent-state ws`. If it exits 1 (branch not mapped):
   - Continuing an existing workstream on a new branch: `agent-state map <name>` (names in `$(agent-state dir)/INDEX.md`).
   - New work: `agent-state init <name>` (lowercase, `a-z0-9._-`). Ask the user for the name if unclear.
3. `D=$(agent-state dir "$(agent-state ws)")`, then update files in `$D`:
   - **STATE.md**: rewrite the body. Keep it under ~60 lines. Update frontmatter `updated` (`date -u +%Y-%m-%dT%H:%M:%SZ`), `host` (`hostname -s`), and `status` (`active|paused|done`). Keep `branches`.
     - Goal: one or two lines.
     - Current phase: `NN-name`, one line on where it stands.
     - Done (recent): outcomes, not activity. Drop items older than the current phase.
     - Next: concrete first action for the next session.
     - Open questions, Blockers: only live ones.
     - Resume notes: branch, commit, uncommitted work, running jobs/PIDs, PR/issue/external IDs, anything a text file can't restore.
   - **DECISIONS.md**: append only, never edit old entries. One `## YYYY-MM-DD: <decision>` heading plus `Why:` per decision made this session.
   - **ROADMAP.md**: tick finished phases, add or reorder upcoming ones.
   - **phases/NN-name/SUMMARY.md**: what the phase produced, evidence (tests, commits), leftovers. Plans and specs for a phase go in `phases/NN-name/PLAN.md`.
4. `agent-state index && agent-state commit "<workstream>: <one-line summary>"`.
5. `agent-state sync` to push. "no remote; local only" is fine. If push fails (network blocked, sandbox), leave the local commit and tell the user.
6. Report: workstream, commit hash, sync result, and the Next line.

## Rules

- Conclusions go in these files, not only in chat.
- Never put secrets, tokens, or raw logs in state files. Link or name the artifact instead.
- Keep markdown plain: headings, bullets, checkboxes, code.

## Conflicts

`sync` stops mid-rebase and lists conflicted files. Resolve in the store dir: STATE.md takes the newer content (merge both machines' facts if both matter), DECISIONS.md keeps every entry from both sides. Then `git -C <store> add -A && git -C <store> rebase --continue`, rerun `agent-state sync`.
