# Arvin Task Form — UX Contract

**Status:** Accepted direction; implementation audit in progress.  
**Authority:** [Issue #2593](https://github.com/mobinpda-lab/Arvin-clean/issues/2593) and [ADR](../ADR/ADR-2026-10-11-ARVIN-TASK-FORM.md).

## Core principles
- Simple First; Advanced When Needed.
- One canonical Create/Edit form and one Task identity/write path.
- Persian labels, full RTL, accessible touch targets, readable contrast and clear save/cancel feedback.
- Progressive disclosure may reduce visual density but must not remove approved capabilities.

## Information order
1. عنوان کار
2. توضیح کوتاه (اختیاری)
3. زمان انجام — Universal Arvin Time Picker
4. تاریخ انجام — Jalali date picker
5. تکرار
6. چک‌لیست
7. پروژه
8. دسته
9. برچسب‌ها
10. نوع پیگیری
11. جزئیات پیگیری (فقط برای «مهم و قابل پیگیری»)
12. یادداشت (اختیاری)
13. لغو / ذخیره

Reminder and any other already-supported fields remain available in an appropriate advanced section; this contract does not authorize removing them.

## Interaction rules
- Basic path should prioritize title, optional date/time, and save.
- Advanced controls should be discoverable, grouped and reversible.
- A newly created Project/Category/Tag is not implicitly assigned unless the user chooses it; selectors refresh immediately without closing the form.
- Cancel must not mutate the stored Task. Save validates and updates/creates only through the canonical path.
- Edit must preserve Task ID and unrelated field values.
- «چک‌لیست» is the only user-facing name for checklist. Do not call items «مرحله».
- Category and Group are one taxonomy concept. Tags remain separate.
- Repeat is a Task capability, not a separate Habit system.
- Tracking is a Task capability, not a new Tracking entity.
- Each recurring occurrence's checklist state must remain independent.
- Date shown to Persian users is Jalali; internal canonical persistence may remain Gregorian/ISO as existing contracts define.
- Time selection uses the shared Universal Arvin Time Picker; no alternate picker in this form.

## Required review surfaces
Create Task, Edit Task, Quick Entry → full form, Task Detail, Calendar create/edit entry points, Repeat, Reminder, Follow-up, Checklist, Search and Report. Align or record a justified contextual exception.

## Acceptance scenarios
- Simple Task; cancel then reopen without unintended mutation.
- Checklist add/edit/delete/reorder/toggle, persistence and progress.
- Repeat with independent checklist state per occurrence.
- Important-and-trackable Task with next action/history.
- Project + Category + multiple Tags, including immediate selector refresh.
- Jalali date and shared time picker, including narrow viewport and keyboard.
- Calendar projection and linked event behavior remain intact.
- Backup/Restore retains identity, metadata, recurrence, checklist state and links.
- RTL, scroll, keyboard, contrast, loading/error feedback.
- Visual comparison uses actual screenshots; do not substitute mockups or fabricated evidence for runtime screenshots.
