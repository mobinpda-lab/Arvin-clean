# Arvin-clean — Live AI Handoff
## Primary Rule
The single active operating authority is `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0. This file is a compact handoff aid, not a competing governance document.
## Start Here
1. Read the canonical v49.0 standard.
2. Check live GitHub access, `main`, working ref, recent commits, open PRs and exact CI results.
3. Read current-state and relevant architecture/feature records.
4. Inspect real code when implementation behavior is involved.
5. Identify the nearest real gap and avoid duplicate work.
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