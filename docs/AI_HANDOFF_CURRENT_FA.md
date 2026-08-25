# Arvin-clean — Live AI Handoff
## Primary Rule
The single active operating authority is `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0. This file is a compact handoff aid, not a competing governance document.

## Start Here
1. Read the canonical v49.0 standard.
2. Check live GitHub access, `main`, working refs, recent commits, open PRs and exact CI results.
3. Read this handoff file as the persistent continuation checkpoint.
4. Read current-state and relevant architecture/feature records.
5. Inspect real code when implementation behavior is involved.
6. Identify the nearest real gap and avoid duplicate work.

## Persistent GitHub Continuation Checkpoint
GitHub is the cross-conversation memory for execution. Every AI session that changes project state must leave enough evidence in GitHub for another session to resume without relying on chat memory.

Required protocol:
- Never treat an uncommitted or chat-only change as project state.
- Keep implementation work on named feature/fix/test branches and open a focused PR as soon as a coherent slice exists.
- PR title/body must state: purpose, scope guard, exact validation gate, and important invariants not changed.
- Commit code, tests and the relevant feature/status document together whenever practical.
- Before ending a work session, ensure the latest real work is pushed to GitHub and visible as either merged `main` state or an open PR/branch.
- For unfinished work, the open PR is the checkpoint: its Head SHA, CI state, remaining blocker and next action are authoritative.
- For completed work, squash/merge only after exact-head validation and review; then `main` becomes the checkpoint.
- Never claim CI from another SHA. Record or verify the exact Head SHA before merge.
- Do not force-update shared continuation branches unless an exceptional recovery is explicitly approved.
- After a merge, the next session must re-read `main` and open PRs before starting new work.
- When a feature document exists, update it when the implementation contract or completion state materially changes.
- Do not create a second competing handoff/source-of-truth document; keep this file compact and defer governance to v49.

Minimum resume algorithm for any new ChatGPT conversation:
`v49 → main SHA → open PRs/branches → exact-head CI → relevant docs → diff/code → nearest unfinished action`.

The user command «ادامه بده و اصل کار موازی هماهنگ سریع و تولید نرم‌افزار در چند ساعت به‌جای چند روز رو فراموش نکن» means execute that resume algorithm first, then continue independent lanes concurrently where safe.

## Product/Foundation Invariants
- Arvin is a Persian RTL Flutter application.
- Unified Item/Task is the shared product foundation; do not create a competing data system without approved architecture.
- FollowUp, Reminder, Calendar, Widget and other features must converge on shared foundations.
- Sync Engine is Foundation Core and no feature owns an independent Sync source of truth.
- Existing Calendar, Search, Backup/Dropbox and other foundations must be audited before extension.
- UI is protected: Persian RTL, approved hierarchy, Reminder contract and Lock Screen/widget expectations must not change without approval and validation.

## Parallel Delivery
Independent lanes should run concurrently. Shared foundation work must be coordinated. A blocked lane must not block unrelated lanes.

## Validation
`Analyze → Test → Build/Workflow → Evidence → Review → Merge` as applicable. Exact GitHub ref results are authoritative. Do not infer success from missing status.

## Communication
Management reports and AI answers must be short, simple, copyable, non-technical where possible, without unnecessary blank lines, and explicit about verified facts, blockers and next action.

## Continuation
The user command `ادامه` means audit live state and continue the nearest real unfinished task. It does not authorize guessing, duplication or unsafe change.

## Product Roadmap Areas
Task, Reminder, FollowUp, Jalali Calendar, Notification, Backup/Restore, Cloud/Dropbox, Google Calendar, PDF/Print, Security, Widget and Lock Screen remain roadmap areas subject to verified current state.

## Handoff Principle
Do not restart from conversation memory. Repository reality and the canonical v49.0 document control execution. Historical documents remain useful evidence and context but do not override current GitHub reality.
