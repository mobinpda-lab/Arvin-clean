# Arvin — Development Rules

## Permanent project rules
1. Before every code change, audit the current architecture and existing implementation to prevent duplication or regressions.
2. Prefer extending the existing Unified Item/Task foundation; do not create parallel models, repositories, or storage without explicit architectural justification.
3. UI is a first-class priority. Keep RTL-first, calm hierarchy, minimal visual noise, and ChatGPT-inspired interaction patterns (inspiration only, no pixel copying).
4. Reminder, FollowUp, Recurring, Calendar, Voice, Notifications, and Widget work must converge on the same Item foundation.
5. Use a branch/PR for production code changes whenever practical; do not knowingly leave broken code on `main`.
6. Validate with Analyze → Test → Build/Workflow before merging. Never call a workflow green based only on missing/empty status data.
7. Historical workflow runs must be distinguished from the current branch/commit before diagnosing failures.
8. Preserve backward compatibility for existing persisted data unless a migration is explicitly designed and tested.
9. Every meaningful change must be documented in GitHub project documentation with its rationale, scope, validation state, and follow-up.
10. After every response in the project conversation, report compact progress: overall %, UI/UX %, CI state, blocker/current lane, and next action.
11. Parallel work is encouraged, but shared foundations must be audited first to avoid conflicting implementations.
12. Speed up independent validation and documentation where safe, but correctness and architectural consistency always outrank speed.
13. **UI visual fidelity is a protected product requirement.** No AI, developer, refactor, migration, dependency change, or automated tool may intentionally or incidentally change the approved Arvin visual language, layout hierarchy, RTL behavior, typography, spacing, colors, component shapes, navigation pattern, Reminder presentation, or other accepted UI details unless the change is explicitly approved as a UI redesign/change and documented before implementation.
14. **Before any non-UI change, perform a UI regression check.** If a change can affect rendering, theme, fonts, assets, navigation, screen dimensions, localization/RTL, Android behavior, notifications, widgets, or persisted UI state, the approved UI contract must be re-checked before and after the change.
15. **The agreed Reminder/Lock-Screen concept is a canonical UI reference.** The Reminder presentation previously agreed with the product owner must be preserved: `یادآور` with a smaller time beside it, the reminder title below, expandable details/actions, no fabricated time for all-day reminders, and Lock Screen/widget behavior consistent with the approved concept. This reference is a guardrail, not a license to redesign the UI.
16. **«بسم الله الرحمن الرحیم» is an inseparable project principle.** It is part of the project's identity and must remain present in the project documentation/context and must not be removed or treated as disposable metadata during future development or AI handoffs.
17. Never replace an approved visual contract merely because another UI looks newer, simpler, or more fashionable. Improvements must be additive, evidence-based, and explicitly reconciled with the canonical Arvin UI before coding.
18. Every AI handoff or new development session must treat this document and the current UI/visual audit as mandatory context and must check them before making changes.

## Current UI gate
- Reminder label with a smaller time beside it.
- All-day reminders must not display a fabricated time.
- Reminder quick actions: complete, snooze, edit, convert to Task.
- Recurring quick actions include Resume From Today.
- Top-right two-line menu opens by tap.
- RTL-first Persian presentation and the approved Arvin visual hierarchy must remain stable.
