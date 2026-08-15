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

## Current UI gate
- Reminder label with a smaller time beside it.
- All-day reminders must not display a fabricated time.
- Reminder quick actions: complete, snooze, edit, convert to Task.
- Recurring quick actions include Resume From Today.
- Top-right two-line menu opens by tap.
