# Arvin Task Creation — UX Contract

**Status:** Accepted direction; implementation audit in progress.  
**Authority:** [Issue #2593](https://github.com/mobinpda-lab/Arvin-clean/issues/2593), [ADR](../ADR/ADR-2026-10-11-ARVIN-TASK-FORM.md), [documentation PR #2594](https://github.com/mobinpda-lab/Arvin-clean/pull/2594).

## Core principles
- Simple First; Advanced When Needed.
- Two entry experiences, one canonical Task identity and one write path.
- Persian labels, full RTL, accessible touch targets, readable contrast and clear save/cancel feedback.
- Progressive disclosure may reduce visual density but must not remove approved capabilities.

## Quick Add — default fast path
Initial view:
- **عنوان کار** as the primary input, with importance control.
- Compact optional controls: **تاریخ**, **زمان**, **تکرار**, **یادآور**.
- A clear **«جزئیات بیشتر»** action leading into the Full Task Editor.
- A clear **«ثبت»** action for a simple Task.

Behavior:
- A simple save creates one canonical Task through the existing write path.
- «جزئیات بیشتر» transfers the current draft and identity to the existing `ArvinTaskEditorDialog`; it does not save a preliminary Task or create a second Task.
- Cancelling the Full Editor leaves the Quick Add draft intact and does not mutate stored Task data.
- Successful Full Editor save commits the canonical Task once; Quick Add clears only after confirmed success.
- Preserve supported multi-entry quick-capture behavior and existing validation/selector context.
- The exact visual density may adapt to viewport, but title and main action remain discoverable and controls must not clip.

## Full Task Editor — detailed path
1. عنوان کار
2. توضیح کوتاه (اختیاری)
3. تاریخ انجام — Jalali date picker
4. زمان انجام — Universal Arvin Time Picker
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
- Basic path prioritizes title, optional date/time, and save.
- Advanced controls are discoverable, grouped and reversible.
- A newly created Project/Category/Tag is not implicitly assigned unless the user chooses it; selectors refresh immediately without closing the form.
- Cancel must not mutate the stored Task. Save validates and persists through the canonical path.
- Edit must preserve Task ID and unrelated field values.
- Quick Add → Full Editor is one continuation, not a second create action. Same identity, no pre-save, no duplicate.
- «چک‌لیست» is the only user-facing name for checklist. Do not call items «مرحله».
- Category and Group are one taxonomy concept. Tags remain separate.
- Repeat is a Task capability, not a separate Habit system.
- Tracking is a Task capability, not a new Tracking entity.
- Each recurring occurrence's checklist state must remain independent.
- Date shown to Persian users is Jalali; internal canonical persistence may remain Gregorian/ISO as existing contracts define.
- Time selection uses the shared Universal Arvin Time Picker; no alternate picker in this form.

## Required review surfaces
Quick Add, Full Task Editor, Task Detail, Calendar create/edit entry points, Repeat, Reminder, Follow-up, Checklist, Search, Report and Backup/Restore. Align or record a justified contextual exception.

## Acceptance scenarios
- Quick Add simple Task → save exactly once.
- Quick Add → «جزئیات بیشتر» → edit → save the same draft once.
- Quick Add → Full Editor → cancel → draft preserved; stored Task unchanged.
- Quick Add repeated-entry mode remains functional.
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
