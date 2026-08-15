# Arvin — Wave 1 Progress — 2026-08-15

## هدف
PROVE BEFORE REFACTOR: اثبات قرارداد داده، Migration و Recurrence قبل از هر Refactor تولیدی.

## وضعیت فعلی
- Branch: `wave1/task-contract-proof`
- Base: `main` at `ac3934607acd400e4663e332d4c93ff5c10e0068`
- Production architecture is not being refactored in this Wave.
- Migration tests are being expanded before switching Home from the legacy path.

## تغییرات این Wave
- تست‌های قرارداد Unified Item/Migration در PR #95 اضافه شده‌اند.
- `RecurrenceFrequency` به `weekly` توسعه داده شد.
- Weekly recurrence با `interval` پشتیبانی می‌شود: هر interval برابر ۷ روز است.
- تست Serialization/Deserialization و محاسبه next occurrence برای weekly اضافه شد.
- برنامه Recurring Tasks با قرارداد واقعی فعلی هم‌راستا شد.

## Guardrails
- کلید Storage `arvin.tasks` تغییر نمی‌کند.
- داده Legacy حذف یا بازنویسی نمی‌شود.
- مدل یا Repository موازی جدید ایجاد نمی‌شود.
- `ArvinTask` و `TaskRepository` تا اثبات کامل Migration حذف نمی‌شوند.
- قبل از Merge باید Test، Analyze و CI واقعی بررسی شوند.

## موارد نیازمند Cross-Review
- سازگاری افزودن `weekly` با Roadmap و رفتار مورد انتظار محصول.
- بررسی مرزهای Monthly/Yearly recurrence قبل از توسعه بیشتر.
- تأیید نهایی Migration Contract قبل از Wave 2.

## Gate
Wave 1: `IN PROGRESS`
Migration/Architecture Refactor: `BLOCKED UNTIL PROOF`
Recurrence weekly slice: `IMPLEMENTED — PENDING TEST/CI VALIDATION`
