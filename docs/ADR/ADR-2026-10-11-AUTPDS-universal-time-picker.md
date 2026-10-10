# ADR-2026-10-11 — Universal Arvin Time Picker

- **Status:** Accepted product/UX direction; implementation pending
- **Date:** 2026-10-11
- **Owner issue:** [#2589](https://github.com/mobinpda-lab/Arvin-clean/issues/2589)
- **Related contracts:** [#1934](https://github.com/mobinpda-lab/Arvin-clean/issues/1934), [#1851](https://github.com/mobinpda-lab/Arvin-clean/issues/1851)

## Context
Arvin has multiple direct calls to the platform time picker across task capture/edit, follow-up, backup scheduling, reports, and Home filters. This creates inconsistent titles, localization, minute granularity, and visual behavior. Existing canonical date/time data and scheduling services must remain the only source of truth.

## Decision
Arvin will converge on one reusable, public-facing component contract: **Universal Arvin Time Picker (UATP)**. All user-facing time-selection entry points must call this component. Time display should reuse the shared formatting contract where practical. No parallel model, storage, repository, or scheduling engine may be introduced to support the picker.

The standard dialog is contextual, Persian-first, RTL, 24-hour, dial-first, and includes a manual keyboard path:
1. Contextual title, such as «زمان انجام کار» or «زمان یادآوری».
2. Prominent selected value, primary #4A4CAB with white text.
3. Circular dial: hour stage, then minute stage.
4. Manual exact-time entry option.
5. Explicit «لغو» and «ذخیره» actions.

The hour dial uses two clearly distinguished rings for hours 1–12 and 13–24, without AM/PM. The minute dial defaults to 5-minute steps from 00 through 55. Manual entry permits exact minute values. Persian digits are the default visible representation.

## Date/time boundary
UATP handles **time only**. Date selection remains the responsibility of the existing Date Picker. Calendar surfaces may display a date and time together but must not create a separate time-selection experience.

## Scope
Audit and migrate time entry points for Create Task, Edit Task, Task Detail, Reminder, Repeat, Occurrence, Follow-up, Calendar, Notification, Schedule, date/time forms, report filters, and backup schedule settings. Some areas may only display a time rather than select it; document the distinction and use consistent formatting.

## Compatibility and guardrails
- Keep existing canonical DateTime/TimeOfDay semantics and persistence paths.
- Preserve existing values during edit and date-only changes.
- Cancel must not mutate the caller's value; Save returns the chosen time to the caller.
- Repeat occurrences, reminders, follow-ups, calendar links/events, report filters, and backup/restore must retain their intended time values.
- No direct edits to main; use Issue → Branch → PR.
- The older #1934 Roll Box contract remains applicable to surrounding form entry points; for time itself, this ADR supersedes any wording that implies a Roll Box/dropdown replaces the required circular dial.
- Do not claim full rollout until source audit, automated validation, visual evidence, and real-device acceptance are complete.

## Acceptance evidence
Required evidence is tracked in [#2589](https://github.com/mobinpda-lab/Arvin-clean/issues/2589). At decision-record creation, the implementation PR, screenshots, exact-head validation, and physical-device evidence are **pending**. This ADR records the decision; it is not proof that the component has shipped.
