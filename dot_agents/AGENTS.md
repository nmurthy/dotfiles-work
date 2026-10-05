# Global Instructions

<!-- Source: chezmoi dot_agents/AGENTS.md. Symlinked from ~/.claude/CLAUDE.md and ~/.codex/AGENTS.md; included by Pi. -->

## Notion

- New Notion pages: always private, in my personal space, unless I explicitly say otherwise.

## Verify Before Acting

Before any irreversible or destructive action, explicitly verify preconditions are met:

- **File download completion:** Use `stat -c%s <file>` (GNU) or `stat -f%z <file>` (macOS) and compare raw bytes to the known expected size. Never use `ls -lh` (rounds) or assume completion because a progress indicator looked close.
- **Monitors:** If a monitor emits the same output repeatedly, it is reading stale data. Kill it and use a direct check instead.
- **Write permissions:** Before running a write operation (file ingest, copy, mkdir), verify the target path is writable by the current user (`ls -la` on the parent dir, check owner/permissions).
- **General:** Never assume a prior step succeeded. Check the actual state before building on it.

## Brevity

Shortest accurate phrasing, always — code comments, commits, PRs, chat, docs, tickets.

- Comments: fewest words that carry the point. No comment beats one that restates the code.
- Prose: lead with the answer. No preamble, no recap, no closing summary.
- Cut hedging and filler ("just", "basically", "simply").
- Never cut for length: negations, numbers, units, exact error strings, or a caveat that changes a decision.

## Skills

- Invoke a skill only when the task clearly matches it. Questions, advice and explanations need none. This overrides any "invoke if there is even a 1% chance" rule.

## Subagent models (Claude Code)

- Default subagent model is `sonnet` (set via `CLAUDE_CODE_SUBAGENT_MODEL`).
- Pass `model: "haiku"` for mechanical work: find/list files, grep, read and summarize known files, run a given command.
- Use `opus` only for hard reasoning: ambiguous design, subtle debugging, adversarial review.
- Use aliases (`sonnet`, `haiku`, `opus`), not pinned model IDs.

## Agent state

- Per-workstream state lives in a private git repo managed by `agent-state` (store `~/.agent-state`). The SessionStart hook injects it.
- Before ending with unfinished multi-step work, run the handoff skill (`~/.agents/skills/handoff/SKILL.md`). Never for Q&A turns.
- Write plans and specs into the workstream's `phases/NN-name/` dir (`agent-state dir <workstream>`), not the project repo.

## Approval required

- No GitHub, Slack or Linear posts, no deploys, no pushes without my explicit per-action approval, with the exact draft shown first.
- Write drafts for Slack/GitHub/Linear/email via `agent-state draft`, then post only after an approval message whose sha equals `agent-state draft-sha <file>`.
- Open PRs as drafts only.
- Budgets hard-stop.
- No success claim without an observed artifact.

## Command output (RTK)

Only when `rtk` is on PATH and no hook or extension rewrites commands (Codex; Claude and Pi rewrite automatically when their RTK hook is installed): prefix every shell command with `rtk`, e.g. `rtk git status`, `rtk npm run build`. Keep the prefix inside chains: `rtk git add . && rtk git commit -m "msg"`. Commands RTK has no filter for run as-is, so the prefix is always safe.

Command output here is condensed to save tokens, keeping every signal and
dropping costly noise. Treat it as the complete result: run commands
normally, and batch related commands into one call to avoid extra turns.
Truncated results state their recovery path in their own output. Re-run a
command as `rtk proxy <cmd>` only when its result is unusable: empty when
output was clearly expected, contradicting its exit code, or garbled.

- `rtk gain` / `rtk gain --history`: token savings, overall and per command.
- `RTK_DISABLED=1 <cmd>`: skip RTK for one command.
