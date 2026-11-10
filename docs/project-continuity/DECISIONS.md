# آرشیو تصمیمات فنی آروین (Decision Log)

این سند مرجع رسمی "چراهای" فنی پروژه است. هرگونه تغییر در معماری یا رویکرد UI که پیامدهای عملکردی داشته باشد، باید در این لیست ثبت شود.

| تاریخ | موضوع | تصمیم اتخاذ شده | علت اصلی (Rationale) |
| :--- | :--- | :--- | :--- |
| 2026-11-07 | خطای Flutter Analyze | حذف تابع بلااستفاده `_dateRollBox` | رفع هشدار `unused_element` جهت تضمین قبولی CI. |
| 2026-11-07 | سرریز UI فیلترها | جایگزینی `Row` با `Wrap` در باتم‌شیت | رفع سرریز ۱۵۸ پیکسلی و تضمین تعامل‌پذیری در عرض‌های باریک. |


| 2026-11-08 | ترتیب و جایگاه فیلترهای اصلی صفحهٔ خانه | ردیف پنج فیلتر اصلی با ترتیب راست‌به‌چپ «زمان ← مرکز ← پروژه ← دسته‌بندی ← برچسب» حفظ شود؛ آیکون مستقل فیلتر در بالای سمت چپ صفحه نیز باقی بماند. | ترتیب و affordanceهای مصوب بخشی از الگوی ناوبری و پالایش اصلی آروین هستند؛ آیکون فیلتر مستقل با آیکون جست‌وجو یا منوی ناوبری یکی نیست و نباید حذف شود. |
| 2026-11-08 | بازهٔ زمانی فیلتر پیگیری | فیلتر پیگیری در صفحهٔ اصلی و گزارش‌ها باید گزینه‌های «امروز»، «دیروز» و «محدودهٔ تاریخی دلخواه» داشته باشد. مبنای فیلتر، زمان ثبت/ایجاد خودِ رکورد پیگیری است، نه موعد یا تاریخ سررسید کار مرتبط. | گزارش و پالایش پیگیری باید رویدادهای ثبت‌شده را بر اساس زمان وقوع/ثبتشان بازیابی کند؛ موعد کار معنای جداگانه‌ای دارد و نباید نتیجهٔ فیلتر پیگیری را تغییر دهد. |
| 2026-11-08 | جایگاه پیگیری‌ها در محصول | پیگیری‌ها و گزارش‌های پیگیری قابلیت هسته‌ای آروین هستند و باید در طراحی محصول، صفحهٔ جزئیات کار و بخش گزارش‌ها پوشش کامل و سازگار داشته باشند. | پیگیری صرفاً یک فیلد فرعی یا میان‌بر ثبت نیست؛ تاریخچه، ثبت و مشاهدهٔ آن باید در جریان اصلی کار و گزارش‌گیری قابل دسترس باشد. |
| 2026-11-08 | مرجع بصری صفحهٔ خانه | خط گوشهٔ بالای سمت راستِ مرجع بصری باید عیناً حفظ شود؛ حذف یا بازطراحی آن مجاز نیست، مگر با تصمیم صریح و بعدی مالک محصول. | جزئی از مرجع بصری تأییدشده است و نباید در بازطراحی‌های بعدی ناخواسته حذف یا تغییر کند. |

---
*مرجع: این سند بخشی از مستندات تداوم پروژه (Project Continuity) است.*


---

## REV9 decision record — 2026-11-10

- **REV9-001 — APPROVED:** REV9 is the active unified product/design/governance charter. REV8 is retained as a historical archive.
- **REV9-002 — APPROVED:** SQL-only durable product-data source of truth; JSON only for backup, import/export, transfer and temporary payloads.
- **REV9-003 — APPROVED:** Primary brand color #4169A1; historical teal-primary records remain preserved but are superseded where conflicting.
- **REV9-004 — NEEDS OWNER DECISION:** Vazirmatn vs VazirHarf, reopened explicitly by REV9 §32 despite older Issue #2974 / PR records.
- **REV9-005 — APPROVED:** 48dp × 48dp minimum interactive hit target.
- **REV9-006 — PROPOSAL:** Five Follow-up completeness loops; audit before owner approval and implementation.
- **REV9-007 — PROPOSAL:** Commitment as central domain concept; no new model/table authorized.
- **REV9-008 — PRODUCT SCOPE:** Product evolution waves 0–4; engineering execution waves remain separately archived.
- **REV9-009 — NEEDS OWNER DECISION:** Exact four Reminder states and transitions.

The complete clauses and definitions are in `MASTER_GOVERNANCE.md`. This summary does not replace or abbreviate the canonical charter.
