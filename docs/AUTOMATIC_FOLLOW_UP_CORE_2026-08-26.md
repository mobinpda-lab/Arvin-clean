# Automatic FollowUp core — 2026-08-26

## Scope
Start roadmap feature #2 `FollowUp خودکار` on the existing canonical FollowUp chain without creating a second model, repository, storage key, scheduler, or UI path.

## Canonical rule
- Source of truth remains `Task.followUps`.
- Only `Task.lastFollowUp` is authoritative for the next automatic follow-up.
- A task becomes a due candidate only when the latest FollowUp has `nextFollowUp <= now`.
- If a newer FollowUp has no `nextFollowUp`, it supersedes/cancels an older pending schedule.
- Completed, archived, and trashed Tasks are excluded.

## Implementation
`AutomaticFollowUpService` is a pure read-only projection. It returns immutable candidate value objects containing Task/FollowUp identifiers, title, and due time. It performs no persistence, notification scheduling, or mutation.

## Regression coverage
Focused tests cover:
- exact-now due schedule;
- future schedule exclusion;
- superseded older schedule;
- unordered FollowUp history;
- completed/archive/trash exclusion;
- deterministic due-time ordering.

## Guardrails
This slice intentionally does not introduce:
- a new FollowUp/Reminder model;
- a repository/database/storage key;
- background scheduler or notification trigger;
- Home/UI changes.

## Next delivery boundary
After this core passes exact-head CI and post-merge validation, the next slice may connect due candidates to the existing Reminder/notification foundation. Persistence/trigger/UI delivery is required before advancing beyond the core stage in the official scorecard.

Refs #180, #92, #153.
