========================================================
ARVIN MASTER EXECUTION COMMAND
Version 3.0
========================================================

نام پروژه:
آروین (ARVIN)

هدف:
این سند بالاترین فرمان اجرایی، معماری و مدیریتی پروژه آروین است.

تمام توسعه‌ها، اصلاحات، طراحی‌ها، تصمیم‌های معماری،
تغییرات UI/UX، تغییرات دیتابیس، Automation، AI Agentها،
و فعالیت‌های توسعه‌دهندگان باید از این فرمان پیروی کنند.

هیچ تغییر مهمی خارج از این چارچوب معتبر نیست.

========================================================
SECTION 1 — PROJECT AUTHORITY
========================================================

GitHub حافظه رسمی پروژه آروین است.

گفتگو، حافظه شخصی، پیشنهاد شفاهی یا تصمیم ثبت‌نشده
مرجع رسمی پروژه محسوب نمی‌شود.

هر تصمیم مهم باید در GitHub ثبت شود:

- Decision
- Reason
- Impact
- Implementation
- Evidence
- Status


========================================================
SECTION 2 — EXECUTION GATE
========================================================

هیچ تغییر، Feature، اصلاح یا بازطراحی قبل از عبور
از مراحل زیر مجاز نیست.


مرحله 1:
REALITY CHECK

ابتدا وضعیت واقعی بررسی شود:

- Repository فعلی
- آخرین Commit
- Branch
- Issue
- Pull Request
- Documentation
- Existing Code
- Existing Tests
- Current Architecture


--------------------------------------------------------

مرحله 2:
EXISTING SYSTEM CHECK

قبل از ساخت هر چیز بررسی شود:

آیا قابلیت مشابه وجود دارد؟

آیا مشکل با اصلاح موجود حل می‌شود؟

ساخت موارد زیر بدون بررسی ممنوع است:

- Entity جدید
- Service جدید
- Database جدید
- Workflow جدید
- Architecture جدید


اصل:

FIX EXISTING

NOT REBUILD


--------------------------------------------------------

مرحله 3:
ARCHITECTURE CHECK

هر تغییر باید بررسی شود:

آیا با معماری اصلی آروین هماهنگ است؟


--------------------------------------------------------

مرحله 4:
DECISION RECORD

اگر تغییر روی معماری، داده یا رفتار اصلی اثر دارد:

قبل از اجرا Decision ثبت شود.


--------------------------------------------------------

مرحله 5:
IMPLEMENTATION

پس از تأیید مراحل بالا:

تغییر اجرا شود.


--------------------------------------------------------

مرحله 6:
VALIDATION

پس از اجرا:

- Test
- Build
- Integration Validation
- Device Validation
- Data Validation

انجام شود.


--------------------------------------------------------

مرحله 7:
EVIDENCE

هیچ کاری Done نیست مگر اینکه Evidence داشته باشد.


========================================================
SECTION 3 — ARVIN PRODUCT IDENTITY
========================================================

آروین یک Todo ساده نیست.

آروین:

Personal Work Management System

است.


هویت اصلی:

Task

+

Time

+

Organization

+

Follow-up

+

Trust


========================================================
SECTION 4 — CORE PRINCIPLE
========================================================

Task تنها منبع حقیقت آروین است.


تمام بخش‌ها باید از Task تغذیه شوند:


Task

 |
 |-- Home
 |-- Calendar
 |-- Search
 |-- Notification
 |-- Report
 |-- Backup


ساخت سیستم موازی برای مدیریت کار ممنوع است.


========================================================
SECTION 5 — TASK MODEL
========================================================

Task هسته اصلی آروین است.


Task شامل:

- Title
- Description
- Date
- Time
- Project
- Category
- Tags
- Priority
- Checklist
- Repeat
- Tracking
- Follow-up
- Next Action
- History
- Calendar Link


هر قابلیت جدید باید مشخص کند
چگونه به Task متصل می‌شود.


========================================================
SECTION 6 — PROJECT / CATEGORY / TAG
========================================================


Project:

حوزه اصلی کار.


Category:

در آروین:

Category = Group


دو مفهوم مستقل Group و Category ممنوع است.


Tag:

برچسب آزاد و چندگانه.


رابطه:

Task

N:M

Tag


========================================================
SECTION 7 — QUICK ADD
========================================================

Quick Add و فرم کامل یک Task هستند.


مسیر:

Quick Add

↓

Task

↓

Full Detail


ساخت Task دوم ممنوع است.


========================================================
SECTION 8 — CHECKLIST
========================================================

Checklist بخشی از Task است.


ممنوع:

- Checklist مستقل
- Checklist App جدا
- Storage مستقل


مدل:

Task

↓

Checklist Definition

↓

Checklist Execution State


در Repeat:

هر Occurrence وضعیت مستقل دارد.


========================================================
SECTION 9 — REPEAT
========================================================

Repeat سیستم مستقل نیست.

Repeat قابلیت Task است.


مدل:


Task

↓

Repeat Definition

↓

Occurrence

↓

Execution State

↓

History


قوانین:

- گذشته Immutable است.
- آینده قابل تغییر است.
- تغییر Repeat نباید تاریخچه گذشته را خراب کند.
- ساخت Task کپی برای هر تکرار ممنوع است.


========================================================
SECTION 10 — TRACKING & FOLLOW-UP
========================================================

Tracking یکی از قابلیت‌های هویتی آروین است.


Tracking یعنی:

کاری که انجام شده اما هنوز نیازمند توجه است.


Follow-up یعنی:

اقدام بعدی برای رساندن کار به نتیجه.


مدل:


Task

↓

Tracking State

↓

Follow-up

↓

Next Action


Tracking نباید تبدیل به CRM مستقل شود.


========================================================
SECTION 11 — CALENDAR
========================================================

Calendar مالک Task نیست.


Task مالک اصلی است.


مدل:


Task

↓

Calendar Projection

↓

External Event


هر Event باید با:

- Task ID
- External Calendar ID
- External Event ID

مدیریت شود.


ساخت Event تکراری ممنوع است.


========================================================
SECTION 12 — HOME
========================================================

Home یک Dashboard آماری نیست.


Home مرکز مدیریت روزانه است.


چهار محور اصلی:


1- Time

2- Project

3- Category

4- Tag


Home نباید:

- Storage مستقل داشته باشد.
- Task مستقل بسازد.


========================================================
SECTION 13 — SEARCH & REPORT
========================================================

Search باید روی Task کار کند.


Search نباید منبع داده باشد.


Report از:

- Task
- Occurrence
- History

استخراج می‌شود.


Storage مستقل Report ممنوع است.


========================================================
SECTION 14 — DATA SAFETY
========================================================

Backup باید کل جهان Task را حفظ کند:


- Task
- Relations
- Checklist
- Repeat
- Tracking
- Follow-up
- History
- Calendar Links


Restore باید Integrity را حفظ کند.


قبل از Migration:

- Backup
- Rollback Plan
- Restore Test

الزامی است.


========================================================
SECTION 15 — AI / DEVELOPER RULE
========================================================

هیچ AI یا Developer اجازه ندارد:


- معماری موازی بسازد.
- Entity جدید بدون بررسی ایجاد کند.
- تصمیم معماری ثبت‌نشده اجرا کند.
- قابلیت موجود را دوباره بسازد.
- بدون Evidence اعلام Done کند.


فرآیند اجباری:


Analyze

↓

Compare

↓

Recommend

↓

Approve

↓

Implement

↓

Validate


========================================================
SECTION 16 — RELEASE GATE
========================================================

آروین فقط زمانی آماده انتشار است که:


CORE:

✓ Task

✓ Time

✓ Project

✓ Category

✓ Tag

✓ Checklist

✓ Repeat

✓ Tracking

✓ Follow-up

✓ Calendar


DATA:

✓ Backup

✓ Restore

✓ Migration

✓ Integrity


QUALITY:

✓ Build

✓ Test

✓ Device Validation

✓ Evidence


========================================================
SECTION 17 — GOLDEN FLOW
========================================================


Create Task

↓

Set Date/Time

↓

Assign Project

↓

Assign Category

↓

Add Tags

↓

Add Checklist

↓

Enable Repeat

↓

Set Follow-up

↓

Open Calendar

↓

Sync

↓

Edit Same Task

↓

Update Same Event

↓

Complete Occurrence

↓

Backup

↓

Restore

↓

Verify Integrity


========================================================
FINAL RULE
========================================================

قبل از هر تغییر:

بررسی کن.

قبل از ساخت:

جستجو کن.

قبل از تصمیم:

ثبت کن.

قبل از انتشار:

اثبات کن.


هدف نهایی:

ساخت یک سیستم مدیریت کار، زمان و پیگیری
که قابل اعتماد، پایدار و قابل توسعه باشد.


END OF ARVIN MASTER EXECUTION COMMAND
========================================================

---

## Related canonical records
- [Current project status](../status/ARVIN_STATUS.md)
- [Decision log](../decisions/ARVIN_DECISION_LOG.md)
- [Evidence map](../testing/ARVIN_EVIDENCE_MAP.md)
- [Task architecture](../architecture/TASK_ARCHITECTURE.md)
- [Calendar architecture](../architecture/CALENDAR_ARCHITECTURE.md)
- [Data model](../architecture/DATA_MODEL.md)
- [Existing execution protocol](../ARVIN_MASTER_EXECUTION_PROTOCOL.md)
- [Accepted Project / Category / Tag ADR](../ADR/ADR-2026-10-10-PCTADP-project-category-tag.md)
