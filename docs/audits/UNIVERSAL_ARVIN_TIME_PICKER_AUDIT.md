# Universal Arvin Time Picker — Source Audit

**Baseline:** main at 72a2f4cc24df7a38eff9856ce403461615db5280  
**Tracker:** [#2589](https://github.com/mobinpda-lab/Arvin-clean/issues/2589)  
**Status:** Expanded initial inventory; audit is not complete.

## Direct picker entry points

Repository code search for showTimePicker, TimePicker, and TimeOfDay found six direct picker-owning files on the baseline. The first migration wave is recorded in [PR #2591](https://github.com/mobinpda-lab/Arvin-clean/pull/2591); all six rows below are migrated on that branch. This is not the complete semantic audit.

| File | Observed use | Initial classification | Migration status |
|---|---|---|---|
| lib/quick_capture_dialog.dart | _pickPersianTime, direct platform picker, dial mode | Quick Capture task time/reminder | Migrated in #2591 |
| lib/task_editor_dialog.dart | contextual helper calling direct platform picker | Task create/edit date-time fields | Migrated in #2591 |
| lib/follow_up_entry_page.dart | _pickClock, direct platform picker | Follow-up time | Migrated in #2591 |
| lib/backup_schedule_page.dart | _pickTime, direct platform picker | Automatic backup schedule time | Migrated in #2591 |
| lib/report_center_page.dart | _pickTime(bool from), direct platform picker | Report time range | Not migrated |
| lib/main.dart | pickFromTime and pickToTime | Home time-range filters | Migrated in #2591 |

The same search found a test coupled to the platform TimePickerDialog: `test/quick_capture_dialog_test.dart`. PR #2591 updates it to assert the shared picker contract rather than the framework dialog type.

## Exact-head evidence

- Implementation PR: [#2591](https://github.com/mobinpda-lab/Arvin-clean/pull/2591)
- Head: `2b8ab84597e0a83527b41da61277822a1ec6296e`
- Analyze, test shards 0–5, Debug APK, Release APK: passed ([Build run](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38093948369)).
- Device Smoke: skipped by workflow policy; no device acceptance claimed.
- Remaining: full semantic audit, screenshots/visual review, and real-device validation.

## Time-display and formatting hotspots

A search for manually assembled HH:mm strings found repeated display formatting. These are **formatting hotspots**, not necessarily picker implementations; review each before deciding whether it belongs to the shared display formatter or remains a storage/export representation.

| File | Observed role | Initial action |
|---|---|---|
| lib/quick_capture_dialog.dart | Persian date + time label | Review/reuse shared formatter |
| lib/task_editor_dialog.dart | Task editor time label | Review/reuse shared formatter |
| lib/follow_up_entry_page.dart | Follow-up time label | Review/reuse shared formatter |
| lib/backup_schedule_page.dart | Backup schedule time and date-time labels | Review/reuse shared formatter |
| lib/report_center_page.dart | Report filter time labels | Review/reuse shared formatter |
| lib/main.dart | Calendar event and task time labels | Review/reuse shared formatter |
| lib/task_timeline_page.dart | Timeline date-time label | Review/reuse shared formatter |
| lib/task_next_action_page.dart | Next-action date-time label | Review/reuse shared formatter |
| lib/services/task_report_text_renderer.dart | Text report date-time output | Preserve report semantics; centralize if safe |
| lib/services/task_report_pdf_renderer.dart | PDF report date-time output | Preserve export semantics; centralize if safe |
| lib/services/home_follow_up_presentation_service.dart | Follow-up presentation | Review/reuse shared formatter |
| lib/work_agenda_page.dart | Agenda event time | Review/reuse shared formatter |
| lib/calendar_page.dart | Calendar time label | Review/reuse shared formatter |
| lib/follow_up_office_page.dart | Follow-up date-time label | Review/reuse shared formatter |
| lib/task_detail_page.dart | Task detail date/time | Review/reuse shared formatter |
| lib/task_recurrence_page.dart | Recurrence date-time label | Check Persian digit consistency |
| lib/notebook_page.dart | Timestamp display | Review whether in-scope user-facing time |
| lib/widgets/canonical_calendar_launcher.dart | Calendar event time | Review/reuse shared formatter |
| lib/backup_service.dart | Backup filename timestamp | Storage/export naming; likely exception, document explicitly |

Search results indicate Persian digit formatting is already available through PersianDateFormatter in many surfaces. Reuse the existing helper rather than creating a competing formatter. The audit has not yet inspected every occurrence or verified whether a single canonical display formatter already exists.

## Audit gaps

This remains a search-based inventory, not a complete semantic audit. Follow-up work must:
- Search all source and tests for showTimePicker, TimePickerDialog, TimeOfDay, direct CupertinoDatePicker/custom clock controls, and other clock-selection implementations.
- Inspect DateTime fields that combine date/time and all notification, calendar event, reminder, repeat/occurrence, follow-up, schedule, and report flows.
- Distinguish user-facing time selection, user-facing time display, internal calculations, and backup/export formats.
- Identify existing Persian digit/formatting helpers and avoid duplicating them.
- Update tests that depend on TimePickerDialog to test the shared component.
- Document each remaining exception with a reason and owner.

## Architecture rule

Every direct user-facing time-picker entry point must be migrated to UATP or have a specific documented architectural exception. A Roll Box may launch UATP but may not become a second clock-selection implementation. Do not change persistence or scheduling semantics as part of visual migration.

## Evidence state

- Direct-picker search: six source files found; not migrated.
- Display-formatting search: 19 source hotspots listed for review; semantic classification pending.
- Full repository audit: pending.
- Shared widget implementation: pending.
- Per-caller migration: pending.
- Automated exact-head validation: pending.
- Screenshot evidence: pending; none is claimed by this document.
- Real-device acceptance: pending.

## Exit criteria

Update this document with each discovered call site, its migration PR, test coverage, and any approved exception. Mark the audit complete only after a final search against the implementation PR's exact head and review of all remaining hits.
