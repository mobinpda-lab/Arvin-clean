# UX Specification — Universal Arvin Time Picker

**Status:** Shared implementation and first six caller migrations in PR #2591; device acceptance and full audit pending  
**Canonical tracker:** [Issue #2589](https://github.com/mobinpda-lab/Arvin-clean/issues/2589)  
**Architecture decision:** [ADR-2026-10-11](../ADR/ADR-2026-10-11-AUTPDS-universal-time-picker.md)

## User goal
Set or understand a time quickly and confidently, with no AM/PM ambiguity and without losing an existing time when editing a task.

## Dialog structure
1. **Contextual header.** Use the context supplied by the caller: «زمان انجام کار»، «زمان یادآوری»، «زمان شروع»، «زمان پایان»، «زمان پیگیری» or an equally clear phrase. Generic «انتخاب زمان» is a fallback only when no more precise context exists.
2. **Selected time.** Always show the current draft value in a large, high-contrast display, e.g. ۲۳:۰۰. Use primary blue #4A4CAB with white text.
3. **Circular selector.** Open in hour mode. Selecting an hour advances to minute mode. Selecting a minute updates the draft value.
4. **Manual entry.** A clearly discoverable alternative permits direct HH:mm entry, including minutes that are not multiples of five.
5. **Actions.** «لغو» discards draft changes; «ذخیره» confirms the chosen time and returns it to the invoking context.

## Hour stage
- Use 24-hour time; do not show AM/PM.
- Make 1–12 and 13–24 distinguishable as outer/inner ring values.
- Highlight the selected hour with a blue circle and use a blue hand/indicator with a central pivot.
- Keep the selected-time display synchronized with the draft selection.

## Minute stage
- Default dial targets: ۰۰, ۰۵, ۱۰, ۱۵, ۲۰, ۲۵, ۳۰, ۳۵, ۴۰, ۴۵, ۵۰, ۵۵.
- Use 5-minute increments for fast selection.
- Manual entry is the supported path for exact values between dial increments.
- Make the current selected minute and return-to-hour affordance obvious.

## Visual tokens
| Token | Value |
|---|---|
| Primary | #4A4CAB |
| Light primary | #E9EAFF |
| Background | #F8F8FB |
| Card | #FDFDFE |
| Main text | #232433 |
| Secondary text | #80829C |

Use rounded surfaces, subtle elevation, calm spacing, legible typography, and sufficient contrast. Do not let shadows or decoration compete with the selected time.

## RTL, localization, accessibility
- Dialog content is RTL for Persian.
- Persian digits are the default in visible values and labels; parse ASCII and Persian digits in manual entry.
- Ensure punctuation and HH:mm remain visually ordered in RTL.
- Use semantic labels for each selectable hour/minute and announce selected state to assistive technology.
- Preserve visible focus, keyboard navigation, and adequate touch targets.
- Validate on narrow screens and with larger text settings.

## Date separation
Do not place a date picker inside UATP. Existing date controls remain separate. A caller can show date and time together in a form or Calendar view, but the time dialog itself only edits hour/minute.

## Caller behavior
- Seed the picker with the current saved time when editing; use the caller's established default when creating.
- A date-only edit must not reset the time.
- Cancel returns no new value and must not write state.
- Save returns a validated time value; the caller remains responsible for updating the existing canonical record and scheduling path.
- Repeat rules share the same time contract across occurrences; do not create occurrence-specific picker variants.

## Validation checklist
- [ ] Create Task sets selected time.
- [ ] Edit Task displays and preserves existing time.
- [ ] Date-only edit preserves time.
- [ ] Repeat/Occurrence retain expected time.
- [ ] Reminder and Follow-up use contextual titles and preserve time.
- [ ] Calendar event time is correct and updating an event does not create a duplicate.
- [ ] Report filters and backup schedule settings use the same component.
- [ ] Cancel does not save; Save returns the draft.
- [ ] Persian digits, RTL layout, keyboard input, accessibility, and narrow screens are verified.
- [ ] Real-device evidence is attached to #2589.
