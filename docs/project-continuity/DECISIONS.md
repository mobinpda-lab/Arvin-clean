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



---

## Owner decision — 2026-11-12 — official Arvin typography (COMMAND 07-A.2.33)

**Status: APPROVED / binding current decision.**

- Vazirmatn is the only official and default Arvin UI font.
- VazirHarf is not an official font.
- System Default is an optional user-selected fallback, not a product default.
- Preserve weights 300, 400, 500, 600 and 700.
- Theme is the single source of truth; Dialog and Overlay surfaces must follow it.
- PDF embedding is independently validated; the official font must be packaged in the APK.
- A user's font selection must survive Force Stop and application restart.

This direct owner instruction dated 2026-11-12 resolves the typography question left open by REV9 §32 (dated 2026-11-10). Preserve the original REV9 clause as historical source text; this dated decision is the later controlling addendum.


---

## 2026-11-12 — Official typography decision for COMMAND 07-A.2.34

**Status:** ACCEPTED OWNER DECISION / IMPLEMENTATION VERIFICATION PENDING.

Mobin explicitly confirms Vazirmatn as the only official and default Arvin font. System Default is an optional preference only. VazirHarf is not an authorized official font and remains historical/inactive. Required font weights are 300, 400, 500, 600 and 700. Centralized Theme, persistent preference, PDF embedding/rendering and APK packaging audit remain acceptance gates.

This resolves the typography authority ambiguity for the current command without deleting or rewriting the earlier REV9 decision history.
