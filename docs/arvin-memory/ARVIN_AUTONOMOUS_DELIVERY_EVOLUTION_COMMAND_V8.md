ARVIN AUTONOMOUS DELIVERY & EVOLUTION COMMAND
Version 8.0
PROJECT:
ARVIN (آروین)

MISSION:
هدایت خودکار پروژه آروین از وضعیت فعلی تا تحویل نهایی محصول، با حفظ معماری، جلوگیری از تکرار، ثبت دانش، اصلاح انحرافات و تکمیل مستمر.
این سند جایگزین تمام فرمان‌های اجرایی قبلی است.

========================================================
SECTION 1 — EXECUTION IDENTITY
این یک فرمان اجرایی است، نه سند توضیحی.
با اجرای این فرمان وارد حالت AUTONOMOUS EXECUTION MODE شو.
وظیفه: پروژه را جلو ببر، نه اینکه فقط تحلیل ارائه کنی.
در هر اجرا:
CHECK → UNDERSTAND → DECIDE → EXECUTE → VALIDATE → RECORD → CONTINUE

========================================================
SECTION 2 — CONTINUATION RULE
اگر این فرمان دوباره وارد گفتگو شد، شروع دوباره تحلیل پروژه، بازنویسی فرمان، توضیح دوباره معماری و تکرار کارهای انجام‌شده ممنوع است.
الزام: ادامه از آخرین وضعیت ثبت‌شده.
ابتدا بخوان: ARVIN_EXECUTION_STATE.md
سپس آخرین Completed Step را پیدا کن و ادامه بده.

========================================================
SECTION 3 — GITHUB AS PROJECT BRAIN
GitHub حافظه رسمی آروین است؛ فقط محل کد نیست.
GitHub شامل Source Code، Decisions، Progress، Problems، Solutions، Evidence، User Experience و Release History است.
هیچ دانش مهمی نباید فقط در Chat باقی بماند.

========================================================
SECTION 4 — FIRST ACTION RULE
قبل از هر تغییر، بررسی Repository، Branch، Latest Commit، Issues، Pull Requests، Documentation، Architecture، Existing Code، Existing Tests، CI/CD، Build Status، Release Status و Project Memory اجباری است.
بدون این بررسی هیچ تغییر انجام نشود.

========================================================
SECTION 5 — PROJECT MEMORY SYSTEM
ایجاد و نگهداری docs/arvin-memory/:
ARVIN_EXECUTION_STATE.md — Completed، In Progress، Blocked، Next Action، Current Bottleneck
ARVIN_DECISION_LOG.md — Problem، Decision، Reason، Impact، Status
ARVIN_PROJECT_KNOWLEDGE.md — دانش استخراج‌شده از گفتگوها، بررسی‌ها، اصلاح انحرافات و تجربه‌ها
ARVIN_USER_EXPERIENCE_LOG.md — نصب، استفاده واقعی، خطاها، بازخورد کاربر و مشکلات UX
ARVIN_PROBLEM_REGISTER.md — مشکلات کشف‌شده، حل‌شده و باقی‌مانده
ARVIN_EVIDENCE_MAP.md — Feature، Test، Result، Validation
هیچ نکته مهمی فراموش نشود. هر تصمیم، مشکل، تجربه، پیشنهاد و اصلاح معماری مهم باید در GitHub Documentation ثبت شود، نه فقط حافظه گفتگو.

========================================================
SECTION 7 — NO LOOP RULE
اگر موضوع قبلاً بررسی شده، دوباره تحلیل نکن؛ تصمیم قبلی و وضعیت فعلی را پیدا کن و از همان نقطه ادامه بده.
هر اجرا باید خروجی DONE یا BLOCKED یا NEXT ACTION داشته باشد.
پاسخ بدون مسیر عملیاتی ممنوع.

========================================================
SECTION 8 — ANTI DUPLICATE ENGINE
قبل از هر ساخت، Code، Commit، Issue، PR، Test و Documentation را جست‌وجو کن.
Existing: Improve
Incomplete: Complete
Broken: Repair
Missing: Create
ساخت تکراری ممنوع.

========================================================
SECTION 9 — PROJECT CORRECTION MEMORY
اصلاحات معماری قطعی:
Task هسته اصلی است.
Task تنها Source of Truth است.
Category = Group.
Quick Add و Full Form یک Task هستند.
Checklist متعلق به Task است.
Repeat قابلیت Task است و نباید Task کپی بسازد.
Calendar مالک Task نیست.
Tracking جایگزین CRM نیست.
Home نباید Storage مستقل داشته باشد.
Report مالک داده نیست.
هر انحراف از این موارد Architecture Drift است.

========================================================
SECTION 10 — CORE ARCHITECTURE
مدل اصلی Task شامل Title، Description، Date، Time، Project، Category، Tags، Priority، Checklist، Repeat، Tracking، Follow-up، Next Action، History و Calendar Link است.
هر قابلیت جدید باید مشخص کند چگونه به Task متصل می‌شود.

========================================================
SECTION 11 — REPEAT CONTRACT
Task → Repeat Definition → Occurrence → Execution State → History
Task اصلی حفظ شود؛ Task Copy ساخته نشود؛ گذشته Immutable باشد؛ آینده قابل تغییر باشد؛ History خراب نشود.

========================================================
SECTION 12 — CALENDAR CONTRACT
Task مالک است و Calendar Projection.
Sync: CREATE سپس UPDATE EXISTING.
تشخیص با Task ID و External Event ID.
Duplicate Event و Sync بر اساس عنوان یا تاریخ ممنوع است.

========================================================
SECTION 13 — USER EXPERIENCE CONTRACT
هدف Personal Assistant Experience است: ساده، سریع، واضح، آرام و با کمترین اصطکاک.
RTL، فارسی، Typography، Spacing، Feedback، Empty State و Consistency رعایت شود.

========================================================
SECTION 14 — HOME EXPERIENCE
Home مرکز تصمیم روزانه است و باید پاسخ دهد: چه دارم؟ چه مهم است؟ چه عقب افتاده؟ قدم بعد چیست؟
محورها: Time، Project، Category، Tag.

========================================================
SECTION 15 — AUTONOMOUS PROBLEM SOLVING
هر مشکل: Problem → Root Cause → Impact → Solution → Execution → Validation.
اگر راه‌حل امن و بدون تصمیم معماری است اجرا کن.
اگر شامل Data Risk، Architecture Change، Migration یا Product Decision است، Decision را ثبت کن و توقف کن.

========================================================
SECTION 16 — DEVELOPMENT LOOP
هر تغییر: Analyze → Inspect → Implement → Test → Validate → Commit → Document.

========================================================
SECTION 17 — QUALITY & EVIDENCE
هیچ کاری Done نیست مگر Code، Test، Build، Validation و Evidence.
Evidence شامل Commit، Test Result، Screenshot، Device Result و Report است.

========================================================
SECTION 18 — PRIORITY ENGINE
P0: Data Loss، Crash، Release Blocker
P1: Core Function، Architecture Risk
P2: UX، Performance
P3: Future Ideas

========================================================
SECTION 19 — USER EXPERIENCE LEARNING
بعد از هر نصب یا استفاده واقعی ثبت کن: Version، Device، Environment، Problem، User Feedback، Solution و Improvement.
آروین باید از تجربه کاربران یاد بگیرد.

========================================================
SECTION 20 — RELEASE DELIVERY MODE
هدف تحویل کامل محصول است.
قبل از انتشار بررسی کن: Core Flow، Backup، Restore، Migration، Calendar، Repeat، Checklist، Tracking، Installation، Device Validation و Evidence.

========================================================
SECTION 21 — FINAL HANDOVER
قبل از تحویل ایجاد کن: Release Notes، Installation Guide، User Guide، Known Issues، Architecture Summary و Evidence Report.

========================================================
SECTION 22 — STOP CONDITIONS
فقط در این موارد توقف کن: نیاز به تصمیم مالک پروژه، خطر از دست رفتن داده، تغییر معماری اساسی یا نبود دسترسی لازم.
در سایر موارد پروژه را جلو ببر.

========================================================
FINAL EXECUTION COMMAND
تو مسئول ادامه مسیر آروین هستی.
هر بار بررسی کن، یاد بگیر، تکرار نکن، اصلاح کن، ثبت کن و ادامه بده.
هدف نهایی: تحویل آروین به عنوان یک محصول کامل، پایدار، قابل اعتماد و آماده استفاده واقعی.
========================================================
END OF ARVIN AUTONOMOUS DELIVERY & EVOLUTION COMMAND V8.0
