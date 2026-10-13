# ARVIN Calendar Projection Separation Decision

**Date:** 2026-10-13  
**Status:** Implementation submitted for validation; release gate remains NO-GO.

## Problem found in source inspection

The existing `FollowUpCalendarProjection.project` is used by both the internal calendar launcher and outbound Calendar sync. It projects explicit reminder dates and task calendar items, but it deliberately does not project `FollowUp.nextFollowUp`. Adding `nextFollowUp` to that shared projection would risk sending an action plan to an external calendar as if it were a notification.

## Decision

Keep two distinct projection paths:

1. **Reminder / existing calendar-item projection:** `FollowUpCalendarProjection`. It remains the input to `CalendarOutboundSyncService.sync`. Follow-up-only action dates are not added to this projection.
2. **Internal Follow-up Action projection:** `FollowUpInternalCalendarProjection`. Its only source is canonical `FollowUp.nextFollowUp`; its destination is the Arvin internal Calendar UI. It owns no persistence, scheduling, or provider sync.

The internal launcher combines these lists only for display. It does not pass internal follow-up action items to the outbound sync service or the notification scheduler. Internal action entries have stable UI identity `task-followup-action:<taskId>:<followUpId>` and a distinct Persian label/icon.

## Data path

```text
Canonical Task / FollowUp
  ├─ reminderDate ─ FollowUpCalendarProjection ─ Internal Calendar + eligible outbound sync
  └─ nextFollowUp ─ FollowUpInternalCalendarProjection ─ Internal Calendar only
                                      ├─ no OS notification
                                      └─ no external Calendar event
```

This change is read-only. It does not migrate, delete, normalize, or convert canonical Task/FollowUp data. Updating `nextFollowUp` does not modify `reminderDate`.

## Regression tests added

- Follow-up-only `nextFollowUp` appears in internal projection but not the reminder/outbound projection.
- Reminder and Follow-up remain distinct when both exist.
- Projection does not mutate canonical Task JSON.
- Updating `nextFollowUp` leaves `reminderDate` unchanged.

## Validation results

- Source inspection: **PASS** — outbound sync call sites still receive only `FollowUpCalendarProjection.project(...)`.
- Static analysis: **PASS** on exact PR head `227bcbcb99ad2d4919834cf1522fe9760ff641e3` (Build run 38364830290, Analyze job succeeded).
- Test shards 0–5 and Debug/Release APK: **IN PROGRESS** at the latest poll; no PASS is claimed yet.
- Six Device Smoke lanes: **IN PROGRESS / QUEUED** at the latest poll; no aggregate PASS is claimed yet.
- External provider create/update/no-duplicate behavior: **BLOCKED** pending Calendar Provider Acceptance.
- Physical device notification and calendar acceptance: **BLOCKED** pending a real-device evidence bundle.
- Multiple Task-level reminders: **BLOCKED** by the separate non-mergeable PR #2655; this change does not attempt to solve it.

## Release decision

**NO-GO.** This decision closes only the projection separation implementation after exact-head tests and review pass. It does not waive external Calendar, physical-device, multiple-reminder, backup/restore, or mobile UX release gates.


## Validation checkpoint update — 2026-10-13 (supersedes stale in-progress lines above)

- Exact queried PR head: `1628048eacfd20ecd73e7938fddb79a8306c6b8c`.
- Build workflow [38364976764](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38364976764): **SUCCESS**. Analyze, test shards 0–5, Debug APK and Release APK all completed successfully.
- Device Smoke workflow [38364976751](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38364976751): **SUCCESS**. All six emulator lanes passed: Home, Quick Capture, People, SQL Migration, SQL Persistence and Backup/Restore.
- Source boundary remains: internal Follow-up Action items are combined only for Arvin's internal calendar display; the existing outbound-sync call site continues to use the reminder/calendar projection, not the new internal-only projection.
- PR #2665 remains **OPEN and UNMERGED**. GitHub reports mergeable=true at this checkpoint. The validation above is automated CI/emulator evidence; it is not physical-device acceptance or Calendar Provider Acceptance.
- External provider CREATE → UPDATE same event/no duplicates, actual notification delivery/reschedule/cancel, real-device backup/restore link integrity, multi-reminder support, compact Persian RTL visual acceptance, and owner release approval remain **BLOCKED / NOT EVIDENCED**.
- Release remains **NO-GO**. Do not describe the feature as fully delivered until review and required provider/device acceptance are complete.

This checkpoint documents the successful runs on the queried head. Because updating this document creates a new commit, re-query workflows for the resulting PR head before using these results as exact-head validation for merge.
