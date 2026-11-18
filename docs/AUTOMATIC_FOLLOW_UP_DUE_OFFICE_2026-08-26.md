# Automatic FollowUp — Due Office Slice

Date: 2026-08-26

## Goal
Expose the merged automatic-follow-up due-candidate contract in the existing Follow-up Office without adding a scheduler, notification engine, storage key, repository, or parallel model.

## Delivery
- `FollowUpOfficePage` now loads canonical `Task` objects beside its existing tolerant legacy rows.
- A new `فقط پیگیری‌های موعدرسیده` action projects due work through `AutomaticFollowUpService`.
- Only the chronologically latest FollowUp can qualify.
- A newer FollowUp without `nextFollowUp` suppresses an older schedule.
- Future schedules are excluded until due.
- Completed, archived, and trashed Tasks are excluded by the canonical service.
- Due rows remain editable through the existing `FollowUpRepository` flow.
- No persistence mutation is performed by the automatic projection.

## Regression coverage
`test/follow_up_office_page_test.dart` verifies that the due filter:
- shows a genuinely due latest FollowUp;
- hides an older due schedule superseded by newer history;
- hides future schedules;
- hides completed Tasks.

## Scope guard
This is the first real user-facing surface for roadmap feature #2 `FollowUp خودکار`. It does not claim background scheduling or notification delivery. Existing `Task.followUps`, `nextFollowUp`, `FollowUpRepository`, and `arvin.tasks` remain the canonical path.

## Gate
Merge only after exact-head `Arvin Build` and `Arvin Parallel Wave` are green. After merge, require post-merge main validation before promoting the official scorecard beyond the evidence earned by this UI slice.

Refs #180 #92 #153.
