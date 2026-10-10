# Component Contract — Universal Arvin Time Picker

**Name:** Universal Arvin Time Picker (UATP)  
**Status:** Required shared component contract; code implementation pending  
**Tracker:** [Issue #2589](https://github.com/mobinpda-lab/Arvin-clean/issues/2589)

## Responsibilities
UATP owns time-selection interaction only. It must not own task persistence, reminders, repeat rules, calendar synchronization, or backup storage.

## Required inputs
- contextTitle: required contextual Persian title from the caller.
- initialTime: current value for edit flows or the existing feature default for create flows.
- Optional presentation/localization configuration only where it is shared and justified; feature-specific forks are not permitted.

## Result contract
- On Save: return one validated time value (hour 0–23, minute 0–59) to the caller.
- On Cancel/dismiss: return no new value.
- Never persist directly from the component.
- Never mutate the passed initial value or caller state while the dialog is open.
- Keep date out of the result; caller retains its existing date and combines date/time using the canonical model and existing save path.

## Behavior
- Initial entry mode: circular dial.
- Hour selection: 24-hour inner/outer rings.
- Minute selection: 5-minute increments.
- Manual entry: exact minute values, with Persian/ASCII digit normalization and validation.
- Selected-time display: large and high contrast.
- Actions: «لغو» and «ذخیره».
- Locale/layout: Persian-first, RTL.
- Context title is supplied by caller and must describe the purpose of the time.

## Integration guidance
- Replace direct feature-level time-picker calls with UATP; do not wrap an existing picker in a new component and claim the custom interaction is implemented.
- Reuse existing canonical DateTime/TimeOfDay values and services.
- Reuse theme tokens and existing Persian digit formatting helpers after auditing them.
- Avoid a new package unless a verified technical constraint requires one.
- Add unit/widget tests at component level and regression tests at each migrated caller.
- Shared time display formatting should be centralized only after confirming there is no existing canonical formatter to reuse.

## Initial audit snapshot
Search against main SHA 72a2f4cc24df7a38eff9856ce403461615db5280 found direct platform picker calls in:
- lib/quick_capture_dialog.dart
- lib/task_editor_dialog.dart
- lib/follow_up_entry_page.dart
- lib/backup_schedule_page.dart
- lib/report_center_page.dart
- lib/main.dart (time-range filters)

This list is an initial, non-exhaustive search result. Audit TimePickerDialog, TimeOfDay, custom input widgets, and display formatting before deciding that the migration is complete.

## Implementation exit criteria
The contract is not considered implemented until a real shared widget/API exists, every intended call site is migrated, tests pass on the exact PR head, and real-device interaction evidence is attached to #2589.
