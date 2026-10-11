# Arvin — Clean Project

نرم‌افزار مدیریت کارها و پیگیری‌ها برای اندروید، ساخته‌شده با Flutter.

این Repository کاملاً جدید است و نسخه‌های قبلی مبنای آن نیستند.

## پایه‌های پروژه
- مدیریت کارها و پیگیری‌ها
- عنوان خودکار از سطر اول توضیحات با امکان اصلاح
- تاریخ پیگیری، شامل تاریخ‌های گذشته
- تگ‌ها
- انتخاب چندتایی و عملیات گروهی
- بایگانی و سطل زباله
- تنظیم عملکرد Swipe چپ و راست
- پنل تنظیمات قابل مخفی شدن
- Backup/Restore
- آماده‌سازی برای اتصال Dropbox

## Project Governance and Architecture
- [Master Execution Command](docs/constitution/ARVIN_MASTER_EXECUTION_COMMAND.md) — canonical project rules
- [Current Project Status](docs/status/ARVIN_STATUS.md) — evidence-based snapshot and blockers
- [Decision Log](docs/decisions/ARVIN_DECISION_LOG.md) — accepted principles and implementation status
- [Evidence Map](docs/testing/ARVIN_EVIDENCE_MAP.md) — feature paths, tests and acceptance evidence
- [Task Architecture](docs/architecture/TASK_ARCHITECTURE.md)
- [Calendar Architecture](docs/architecture/CALENDAR_ARCHITECTURE.md)
- [Data Model](docs/architecture/DATA_MODEL.md)
- [Existing Execution Protocol](docs/ARVIN_MASTER_EXECUTION_PROTOCOL.md)
- [Accepted Project / Category / Tag ADR](docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md)

## Build
```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```
