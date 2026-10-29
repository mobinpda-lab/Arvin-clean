# سند مرجع جامع محصول آروین — نسخه 1.4 (همساز با قرارداد قطعی)
- Governing Issue: #823
- Release Status: BLOCKED — RELEASE: NO-GO

## Changelog from v1.4
- Governing Issue changed to #823
- System Default font prohibited; Vazirmatn inside APK only
- Home updated to 6 fixed sections
- Task List Swipe: configurable with "ثبت پیگیری"
- Calendar Swipe settings added
- Delete lifecycle: soft-delete to Trash + hard-delete
- Device Calendar: idempotent + isolated + failure-safe
- Purge: "Next Follow-up" and "followUpEnabled" completely removed

## 0) Non-Negotiables
1. Font: Vazirmatn only (System Default forbidden).
2. Purged Concepts: Next Follow-up & followUpEnabled must be removed from schema, models, UI, APIs, tests.
3. Core Concepts: Task, Due Date, Reminder, Follow-up Record (independent, no merging).
4. Follow-up Record: Past actual actions only with valid completedAt.
5. Calendar: Local Arvin Calendar (auto) & Device Calendar (optional, isolated, idempotent).
6. Release Status: BLOCKED — RELEASE: NO-GO.

## 1) Core Definition & Principles
Arvin is a Persian-first tool for tasks, reminders, follow-ups, internal calendar, and data recovery.
Verification rule: Every PASS must link to SHA + Run + Evidence.

## 2) Typography
- Font: Vazirmatn bundled in APK.
- Typography weights: Title 700, Card/Task Title 600, Controls 500, Regular/Calendar 400.
- Applied everywhere including PDF export (embedded font).

## 3) Conceptual Model
- Task: Core item with independent DueDate, Reminder, Recurrence, Checklist, Follow-up Records.
- Due Date: All-day has no real time; 00:00 display only, never triggers timed alarms/sync.
- Follow-up Record: Past actions only. Future is handled exclusively via Reminders.
- Reminder: Multiple & independent per task.

## 4) Forms & UI
- Quick Entry: Simple, no checklist, no legacy flags.
- Task Details: Manage Checklist, Reminders, and Follow-up Record history.

## 5) Home Structure (6 Fixed Sections)
1. Overdue (عقب‌افتاده)
2. Today (امروز)
3. Today's Reminders (یادآورهای امروز)
4. Actual Follow-ups (پیگیری‌های واقعی)
5. No Date (بدون تاریخ)
6. Completed (انجام‌شده - collapsed at bottom)

## 6) Gestures & Lifecycle
- Task List Swipe: Configurable right/left dropdowns including "ثبت پیگیری" (opens form only).
- Calendar Swipe: Configurable (Edit, Delete, Transfer to Device Calendar).
- Delete: Soft-delete to Trash; Hard-delete for permanent removal.

## 7) Acceptance Gates
- Gate 1: Complete purge of Next Follow-up and followUpEnabled.
- Gate 2: Task Swipe dropdown includes "ثبت پیگیری".
- Gate 3: Calendar Swipe settings (Edit/Delete/Device Calendar).
- Gate 4: Device Calendar Sync (Idempotent, isolated, all-day != 00:00 timed).
- Gate 5: Vazirmatn PDF & UI typography audit.

**FINAL STATUS: BLOCKED — RELEASE: NO-GO**
