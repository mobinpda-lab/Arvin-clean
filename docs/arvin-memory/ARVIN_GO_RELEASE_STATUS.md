# ARVIN GO Release Status — Reality Check

Updated: 2026-10-13 (latest evidence observed around 16:22 UTC)
Working PR: [#2666](https://github.com/mobinPda-lab/Arvin-clean/pull/2666)
Current observed PR head: `41583a72062a69f8fb30e229239198458f8bc2af`
PR state: **OPEN, NOT MERGED**. Release decision: **NO-GO**.

> This report separates verified terminal results from jobs that are still running and from product gaps that are not proven closed. A successful subset is not a release pass. CI run links below are the runs associated with the observed head; any new commit makes these results stale for final release sign-off unless rerun against that exact SHA.

## Executive reality check

- **Analyzer:** PASS on this head's Build run.
- **Automated tests:** FAIL. Two test shards have terminal failures; two more shards were still running at the last observation.
- **APK builds:** Debug and Release jobs were still building; no terminal build/verification/upload result was available.
- **Calendar Provider Acceptance:** still running; no terminal acceptance result available.
- **Device Smoke:** partial pass only. Home and Quick Capture passed; SQL migration and SQL persistence were running; People and Backup/Restore were queued. This is emulator CI evidence, not physical-device sign-off.
- **Product completeness:** Person directory backup/restore and person-based reporting remain open P1 issues (#2682 and #2683). Legacy reminder title compatibility remains an unresolved contract conflict.
- **Decision:** do not merge or publish.

## Exact-head workflow evidence

| Workflow | Run | Observed state | What the evidence actually says |
|---|---|---|---|
| Arvin Build | [38429467799](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38429467799) | In progress at last poll | Analyze passed; test-0 and test-1 passed; test-2 and test-3 failed; test-4 and test-5 were still running; Debug and Release APK jobs were still building. |
| Calendar Provider Acceptance | [38429467851](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38429467851) | In progress | Android Calendar Provider acceptance step was running; publish-evidence step had not run yet. No pass can be claimed. |
| Device Smoke | [38429467818](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38429467818) | In progress | `quick-capture` and `home` passed; `sql-persistence` and `sql-migration` were in progress; `people` and `backup-restore` were queued. |

### Build failures captured from job logs

**test-2 — 236 passed, 3 failed** ([run details](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38429467799)):

1. `test/task_editor_dialog_test.dart`: “new Task keeps checklist disabled until explicitly enabled” — expected key `task-editor-checklist-block` exactly once; found zero.
2. `test/task_editor_dialog_test.dart`: “disabling a checklist preserves its rows and re-enabling restores them” — expected no checklist-block widget while disabled; found one.
3. `test/settings_page_test.dart`: “settings exposes date, swipe, projects and canonical backup controls” — expected key `all-day-reminder-time-setting` exactly once; found zero.

These are UI contract/layout failures, not evidence that the assertions should be removed. Inspect the actual widget visibility and test setup, then fix implementation or the intended contract without weakening checks.

**test-3 — 116 passed, 1 failed** ([run details](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38429467799)):

- `test/follow_up_office_page_test.dart`: “waiting filter uses only each task latest follow-up result” — expected exactly two matches for “کار پاسخ‌گرفته”; found one at line 303. Resolve the discrepancy against the accepted semantics: the waiting list should be based on the latest canonical Follow-up, and structured Person association must not be replaced by a legacy boolean or unassociated result.

**test-0 and test-1:** terminal success in this run.  
**test-4 and test-5:** in progress at last observation; their final outcomes are unknown.  
**Analyze:** terminal success.  
**Debug/Release APK:** no terminal outcome observed; do not describe either APK as built, verified, or uploaded yet.

## Product and data-integrity gate matrix

| Gate | Current status | Reality / required evidence |
|---|---|---|
| Canonical Task source of truth | 🟡 In progress | PR describes canonical Task envelope and reminder collection; require full exact-head regression plus persistence/migration evidence. |
| Quick Add and Full Form | 🟡 In progress | Must create/edit the same Task, without duplicate models or stores; Home/Quick Capture smoke alone does not prove full-form equivalence. |
| Checklist | 🔴 Failing | Two exact-head UI tests fail on checklist widget visibility/key behavior. |
| Follow-up history | 🟡 In progress | Preserve append/edit history by stable ID; exact-head test suite is not green. |
| Follow-up-enabled flag removal | 🟡 In progress | User-facing flag is intended to be removed; legacy field may remain for compatibility only and must not drive active decisions. Audit all reads/writes. |
| Waiting for response | 🔴 Failing | Latest-result widget test fails (2 expected, 1 found); resolve using canonical Follow-up semantics and Person links. |
| Person directory | 🔴 Incomplete | P1 [#2682](https://github.com/mobinPda-lab/Arvin-clean/issues/2682): standalone Person records are not proven to survive portable backup/restore. Device People lane was queued at last poll. |
| Person association | 🟡 In progress | People references have contract tests, but association to Task/Follow-up/waiting/report must be validated end-to-end. |
| Multiple reminders | 🟡 In progress | Model/projection fixes and reminder tests exist; overall test/build/device acceptance is not green. |
| All-day reminder notification time | 🟡 In progress | Policy is 09:00 local by default and configurable in Settings. Exact-head settings test cannot find `all-day-reminder-time-setting`; user-visible control is not validated. |
| Legacy reminder migration/title | 🔴 Contract conflict | Current code preserves legacy Calendar title/fingerprint (`یادآوری: <Task>`), while the latest GO command expects `<Task> — یادآور ۱`. Decide and test an explicit migration that preserves stable external Calendar identity; do not change title/identity blindly. |
| Calendar projection/sync | 🟡 In progress | Provider acceptance is still running. Stable event identity, inbound edit/delete, sibling reminder isolation and no duplicate events still need terminal exact-head evidence. |
| Reports and Person filter | 🔴 Incomplete | P1 [#2683](https://github.com/mobinPda-lab/Arvin-clean/issues/2683): report rows/filter are not proven to include Task, each Follow-up, linked Person(s), waiting status and next action. |
| Backup/restore | 🔴 Not accepted | Device lane is queued; portable settings/reminder behavior may have unit coverage, but Person-directory integrity and real restore evidence remain open. |
| SQL migration/persistence | 🟡 In progress | Both device lanes were running; no terminal pass yet. |
| Device smoke | 🟡 Partial | Home and Quick Capture passed in emulator CI; that is not whole-app acceptance and not physical-device validation. |
| Physical-device evidence | 🔴 Missing | No verified device/model/app-version evidence package with screenshots and acceptance outcomes is recorded. |
| Handover docs | 🟡 In progress | Final release notes, install guide, user guide, known issues, architecture summary and evidence report must reflect final verified behavior and limitations. |

## Required architecture and safety invariants

1. Task remains the sole source of truth; do not add a parallel Task/reminder store.
2. Category is Group; Quick Add and Full Form represent the same Task; Checklist belongs to that Task.
3. Repeat is a Task capability and must not create duplicate Tasks.
4. Calendar is a projection, not the owner of Task or Follow-up data.
5. `nextFollowUp` is a next-action/review time; it must not by itself create a notification or external Calendar event. `FollowUp.reminderDate` and `nextFollowUp` remain independent.
6. A Task may have zero, one, or many Follow-ups and independently zero, one, or many Reminders. Removing one Reminder must not delete the Task, Follow-ups, or sibling Reminders.
7. Waiting-for-response must link one or more Person IDs; do not treat an unassociated boolean as sufficient.
8. Person deletion must not delete Tasks or Follow-ups. Backup/restore must preserve Person records and relationships.
9. Migration must be idempotent, preserve legacy history, avoid duplicates/data loss, and never convert `nextFollowUp` into a Reminder.
10. Do not remove/relax assertions just to make CI green. Do not force-push or blindly merge diverged PRs.

## Ordered next actions

1. Fix the two checklist visibility/key failures by inspecting the actual editor layout/state and its intended enabled/disabled contract.
2. Fix the Settings all-day notification-time control/test mismatch and confirm the saved preference is applied by both alarm planning and background delivery.
3. Diagnose the waiting-list test with its fixtures and chronological latest-Follow-up selection; retain the rule that an older waiting result does not override a newer resolved result.
4. Poll test-4/test-5, Debug/Release APK, Calendar Provider Acceptance and all Device Smoke lanes to terminal states. Record the exact result and commit SHA.
5. Complete P1 issues #2682 (Person backup/restore) and #2683 (Person-based reports); add end-to-end tests to existing systems rather than new parallel architecture.
6. Reconcile child PR #2681 and parent PR #2666 carefully; do not merge conflicting PR #2679 independently.
7. Resolve the legacy reminder title request through an explicit migration/compatibility plan preserving Calendar event identity.
8. After fixes, rerun the entire required gate set on the exact final SHA, then capture physical-device evidence and prepare handover documents.

## Evidence policy

A successful analyzer, one passing test shard, an APK build, or a subset of smoke tests is not a release pass. Release can move to GO only when all required exact-head checks are terminal and green, migration and backup/restore integrity are demonstrated, Calendar synchronization and device acceptance pass, open P1 gaps are closed, and the evidence/handover package is complete.

## Previous snapshot

The earlier snapshot in this file referenced head `4b7d5e3d454d0e1204ed6702e5643c78be83eac5` and Build run `38428476972`. Those results are historical and must not be used as evidence for the current head `41583a72062a69f8fb30e229239198458f8bc2af`.
