# ARVIN FINAL RELEASE VALIDATION REPORT

**Date:** 2026-10-13  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Base checkpoint:** `ee73adbc61c4baea82caeb9932969fd293922162` (`main` at report creation)  
**Release decision:** **NO-GO**  
**Purpose:** Validate the existing system and record evidence. This report does not authorize new feature work, merge, or release.

## 1. Evidence rules

- PASS means the stated evidence exists for the exact named commit and the tested scope.
- FAIL means repository inspection or a test demonstrates the criterion is not met.
- BLOCKED means required physical-device evidence, exact-head validation, integration, or owner acceptance is missing.
- Emulator Device Smoke is not physical-device acceptance.
- Evidence for one commit does not validate a different commit.
- No release decision may be upgraded while any required gate is FAIL or BLOCKED.

## 2. Verified automated evidence

### Candidate PR #2663 — visual distinction only

PR: https://github.com/mobinpda-lab/Arvin-clean/pull/2663  
Tested head: `c3b95d0781ec03f07d43379c4087f427667cb250`  
Base: `ee73adbc61c4baea82caeb9932969fd293922162`  
PR status at inspection: OPEN, unmerged, mergeable=true.

- Build run: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38361448901
  - Analyze: PASS
  - Test shards 0–5: PASS
  - Debug APK: PASS
  - Release APK: PASS
- Device Smoke run: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38361448950
  - Home: PASS
  - Quick Entry: PASS
  - SQL Persistence: PASS
  - SQL Migration: PASS
  - People: PASS
  - Backup/Restore: PASS

**Scope limitation:** these checks validate the visual-only PR head and emulator/device-smoke lanes. They do not prove physical-phone acceptance, the complete Calendar Provider contract, multiple Task-level reminders, or the current release candidate. PR #2663 remains unmerged.

## 3. Source inspection findings

### Follow-up and reminder data model

Inspected on `main` at report creation:

- `lib/models/task.dart`, blob `3becbe89ffd378d8bdf19300211e76ba392760b0`
- `lib/services/follow_up_calendar_projection.dart`, blob `b26524cb8a3587e88f4436b0032c42cde055df01`
- `lib/services/calendar_outbound_sync_service.dart`, blob `5844ed0d1c4b78e07aba4a74adf764a9bcd2bc7e`
- `lib/services/system_calendar_bridge.dart`, blob `d68c2ac5f5af256b5855b7fa7a292034fdbaa227`
- `test/follow_up_reminder_model_test.dart`, blob `2d232e913812e5dc6b8ff724bc9ca8dd11c5c290`

Observed facts:

1. `Task.reminderDate` is singular on the current main model.
2. Each `FollowUp` stores separate nullable `nextFollowUp` and `reminderDate` fields. Their JSON serialization/deserialization preserves the two fields independently in the tested model envelope.
3. `FollowUpCalendarProjection` projects explicit FollowUp reminders and Task reminders. It explicitly does **not** project a follow-up schedule/history date when no independent reminder is configured.
4. The projection does not read `FollowUp.nextFollowUp` and does not project the legacy Task `followUpDate`.
5. The same projected reminder list is passed to `CalendarOutboundSyncService.sync` from the main save flow. Therefore, on this inspected path, `nextFollowUp` alone does not enter outbound Calendar sync. This is source-level evidence only; physical-provider behavior still requires acceptance testing.
6. The existing model test proves JSON round-trip for one FollowUp reminder and independent `nextFollowUp`; it does not prove notification delivery on a real phone or support for multiple Task-level reminders.
7. The current `SystemCalendarBridge` allows canonical reminder/due/follow-up ID families to be provider-sync eligible, but this eligibility alone is not proof of correct end-to-end provider behavior.

## 4. Release gate matrix

| Gate | Status | Evidence / remaining condition |
|---|---|---|
| Build | **PASS (scoped)** | Run 38361448901, exact PR #2663 head `c3b95d0...`; not a release-wide sign-off. |
| Automated tests | **PASS (scoped)** | Analyze and shards 0–5 passed on the same PR head. |
| Six Device Smoke lanes | **PASS (emulator scope)** | Run 38361448950; all six lanes passed on `c3b95d0...`. |
| Real Device Acceptance | **BLOCKED** | No recorded physical-device model, OS, installed app version, candidate SHA, date, screenshots, or device logs. |
| Task / Quick Entry / edit / Checklist | **BLOCKED for physical acceptance** | Emulator smoke passed, but the required nine-scenario installed-phone walkthrough and evidence bundle are not recorded. |
| Follow-up contract | **FAIL — internal Calendar fallback** | Source inspection shows `nextFollowUp` is not projected when no Reminder exists. This conflicts with the final owner contract requiring internal Calendar to show the Follow-up Action when no Reminder exists. |
| No notification from `nextFollowUp` alone | **PASS at source-path level; runtime BLOCKED** | Current projection omits follow-up-only schedule from the list passed to outbound sync. Real notification behavior and regression tests are still required. |
| Reminder notification delivery | **BLOCKED** | No physical-device notification receipt, reschedule, cancellation, reboot/restart, or Task-parent integrity evidence. |
| Internal Calendar Reminder display | **PARTIAL / BLOCKED** | Explicit Reminder projections exist, but full owner contract and end-to-end behavior have not been accepted on a physical device. |
| External Calendar CREATE → UPDATE → no duplicate | **BLOCKED** | No exact-candidate Calendar Provider Acceptance result or physical-provider event-ID/count evidence is recorded for this report. |
| Multiple Task-level reminders | **BLOCKED** | PR #2655 remains open/unmerged and GitHub reports `mergeable=false`. The current main Task model still has one `Task.reminderDate`. |
| Multiple-reminder data/backup/restore | **BLOCKED** | Two independently editable/deletable Task reminders, stable IDs, legacy compatibility, JSON/SQL/backup/restore round-trip, and notification/calendar identity are not proven on a reconciled exact head. |
| Backup/Restore | **PASS (smoke only); full acceptance BLOCKED** | Device Smoke backup/restore lane passed; real-phone backup file restore, task/history integrity, and Calendar-link integrity remain unverified. |
| UX mobile / Persian RTL | **BLOCKED** | Automated compact-viewport widget coverage exists, but no recorded physical-device screenshot review for Quick Entry, Roll Box, full Task form, Calendar, filters, Project, Category, Tag, date/time, chips, clipping, or RTL has been accepted. |
| Documentation | **PASS for this report draft** | This report is recorded in the repository proposal. Overall release handover and explicit owner approval remain outstanding. |

## 5. Required real-device acceptance record

**Current status: BLOCKED — no physical-device evidence supplied/recorded.**

Do not fill these fields with assumptions:

- Device model: **NOT RECORDED**
- Android version: **NOT RECORDED**
- Installed app version/build: **NOT RECORDED**
- Tested commit SHA: **NOT RECORDED**
- Test date/time: **NOT RECORDED**
- Screenshots/log bundle: **NOT RECORDED**

Required scenarios, each with PASS or FAIL plus screenshot/log and notes:

1. Create Task
2. Quick Entry
3. Edit Task
4. Checklist
5. Follow-up
6. Reminder notification
7. Internal and external Calendar
8. Backup
9. Restore

A CI artifact or emulator lane must not be substituted for this record.

## 6. Follow-up and Reminder contract tests still required

Use a canonical Task titled «تماس با مشتری» with `nextFollowUp` set to Tuesday 10:00 and no Reminder:

- Internal Arvin Calendar displays the Follow-up Action.
- Reports/filters can use the follow-up field independently.
- No OS notification is created.
- No external Calendar event is created.

Then explicitly add a Reminder for Tuesday 09:55:

- Notification is delivered at the configured time.
- The Reminder retains its parent Task identity.
- Removing the Reminder leaves the Task and Follow-up intact.
- Editing/removing `nextFollowUp` does not alter the Reminder.
- Repeated sync updates the linked external event rather than creating a duplicate.

**Important implementation boundary:** internal Calendar fallback must not be implemented by blindly adding `nextFollowUp` to the shared outbound-sync projection. Internal display and outbound provider eligibility need distinct, tested rules so a follow-up-only schedule cannot leak into external Calendar or OS notifications.

## 7. Multiple Reminder merge gate

PR #2655: https://github.com/mobinpda-lab/Arvin-clean/pull/2655

Recorded state at inspection: OPEN, unmerged, `mergeable=false`; feature head `cc35194d84d6c2fdf52d566723be0d6343e93c6b`. Existing status comments report 58 commits ahead, 2 behind, and no exact-head PR-triggered checks for that SHA at the last poll.

Required before merge:

1. Reconcile the branch using a real Git merge/rebase workflow; no force update or synthetic tree merge.
2. Review conflicts and the complete changed-file list, especially Task model, Calendar, notification scheduling, and backup/restore.
3. Run Analyze, every test shard, Debug/Release builds, Calendar Provider Acceptance, and all six Device Smoke lanes on one exact reconciled SHA.
4. Validate two distinct stable Reminder IDs on one Task; independent edit/delete; preserved Follow-up and Task; JSON/SQL/backup/restore compatibility; notification rescheduling/cancellation; and Calendar CREATE → UPDATE without duplicates.
5. Merge only after all checks are green and the diff is reviewed.

No merge is authorized by this report.

## 8. Mobile UX acceptance

On a small physical viewport, inspect Quick Entry, both independent Roll Boxes, Full Task Form, Calendar, filters, Project, Category, Tag, date/time controls, and chips.

- Record screenshots for every reproduced issue.
- Prefer wrapping, controlled font sizing, horizontal chip scrolling, and full values in detail views.
- Do not delete, truncate from storage, or silently drop user-entered data to fix layout.
- Current status: **BLOCKED** until screenshot-based acceptance is recorded.

## 9. Known blockers and next actions

1. **P0 — Internal Calendar contract gap:** implement and test internal-only fallback for `nextFollowUp` when no Reminder exists, without making that projection eligible for external sync or notifications.
2. **P0 — Physical-device acceptance:** install one exact release APK on a real phone and record all required metadata, nine scenarios, screenshots, and logs.
3. **P0 — Calendar provider acceptance:** verify create once, update the same event ID, repeat-sync no-op, import-origin protection, and backup/restore identity.
4. **P0 — Reminder runtime validation:** confirm actual delivery and independent edit/delete behavior on-device.
5. **P1 — Multiple reminders:** safely reconcile PR #2655 and run its full exact-head validation suite before merge.
6. **P1 — Mobile UX:** record compact Persian RTL screenshots and fix only demonstrated display defects while preserving data.
7. Re-run final gate review against one exact release candidate SHA after all changes are merged and tested.

## 10. Final release decision

**STATUS = NO-GO**

Reason: the automated Build, test shards, and six emulator Device Smoke lanes are green for the scoped visual PR head, but that head is not merged; physical-device acceptance is missing; source inspection finds the required internal Calendar `nextFollowUp` fallback absent; Calendar Provider Acceptance is not evidenced for the release candidate; and multiple Task-level reminders remain blocked behind non-mergeable PR #2655.

This report deliberately does not mark the product GO FOR RELEASE. Upgrade to GO only after every release gate has PASS evidence on the exact final candidate and the owner approves release.
