# Universal Arvin Time Picker — Source Audit

**Baseline:** main at 72a2f4cc24df7a38eff9856ce403461615db5280  
**Tracker:** [#2589](https://github.com/mobinpda-lab/Arvin-clean/issues/2589)  
**Status:** Initial inventory only; audit is not complete.

## Search findings
Repository code search for showTimePicker, TimePicker, and TimeOfDay found these direct picker entry points on the baseline:

| File | Observed use | Initial classification | Migration status |
|---|---|---|---|
| lib/quick_capture_dialog.dart | _pickPersianTime, direct platform picker, dial mode | Quick Capture task time/reminder | Not migrated |
| lib/task_editor_dialog.dart | contextual helper calling direct platform picker | Task create/edit date-time fields | Not migrated |
| lib/follow_up_entry_page.dart | _pickClock, direct platform picker | Follow-up time | Not migrated |
| lib/backup_schedule_page.dart | _pickTime, direct platform picker | Automatic backup schedule time | Not migrated |
| lib/report_center_page.dart | _pickTime(bool from), direct platform picker | Report time range | Not migrated |
| lib/main.dart | pickFromTime and pickToTime | Home time-range filters | Not migrated |

## Audit gaps
This search is not exhaustive. Follow-up audit must search for:
- showTimePicker, TimePickerDialog, TimeOfDay, and direct CupertinoDatePicker/custom clock controls.
- DateTime fields that combine date and time but display time separately.
- Display-only time strings, notification/schedule formatting, calendar event editors, and occurrence-specific controls.
- Shared formatting and Persian digit utilities that should be reused rather than duplicated.
- Tests that depend on TimePickerDialog and must be updated to test the shared component.

## Architecture rule
Every direct time-picker entry point must be migrated to UATP or have a specific documented architectural exception. A Roll Box may launch UATP but may not become a second clock-selection implementation. Do not change persistence or scheduling semantics as part of visual migration.

## Evidence state
- Initial search inventory: recorded.
- Full repository audit: pending.
- Shared widget implementation: pending.
- Per-caller migration: pending.
- Automated exact-head validation: pending.
- Screenshot evidence: pending; none is claimed by this document.
- Real-device acceptance: pending.

## Exit criteria
Update this document with each discovered call site, its migration PR, test coverage, and any approved exception. Mark the audit complete only after a final search against the implementation PR's exact head and review of all remaining hits.
