# Arvin Current Code Audit Checklist — 2026-09-14

## Purpose

این سند مرحله بازرسی بین قرارداد نهایی آروین و پیاده‌سازی واقعی Flutter را کنترل می‌کند.

هدف: رسیدن به محصول واقعی قابل اجرا، نه صرفاً تطبیق ظاهری.

## Audit Order

1. Models and persistence
2. Services and repositories
3. Pages/screens
4. Widgets and components
5. Tests
6. Android runtime verification

## Core Data Preservation

بررسی الزامی:

- Task
- FollowUp
- Project
- Category
- Label
- Notebook
- Archive
- Trash
- Reminder
- Recurrence

قاعده:

هیچ UI جدیدی نباید ذخیره‌سازی موازی ایجاد کند.

## UI Convergence Checklist

### Home

- [ ] Header مطابق قرارداد نهایی
- [ ] Search
- [ ] Four grouping modes
- [ ] Real data grouping
- [ ] No legacy statistics regression

### Quick Entry

- [ ] Keyboard behavior
- [ ] Repeated task creation
- [ ] Draft preservation
- [ ] Duplicate prevention

### Task Detail / FollowUp

- [ ] Timeline preservation
- [ ] Append follow-up behavior
- [ ] Independent due date/reminder

### Notebook

- [ ] Simple note
- [ ] Checklist
- [ ] Persistence after restart

### Calendar

- [ ] Jalali calendar
- [ ] Data connection with tasks
- [ ] Separate event types

## Evidence Required

هر قابلیت فقط زمانی Complete محسوب می‌شود که:

- کد وجود داشته باشد
- داده واقعی متصل باشد
- تست شود
- روی Android واقعی بررسی شود
- نتیجه ثبت شود

## Status Values

- Documented
- Implemented
- Tested
- Android Verified
- Released
