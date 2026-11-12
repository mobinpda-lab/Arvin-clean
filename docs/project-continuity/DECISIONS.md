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


| 2026-11-12 | فونت رسمی رابط کاربری | VazirHarf v34.003 از variant UI-Farsi-Digits، پنج وزن 300/400/500/600/700 و مجوز OFL 1.1، فونت canonical برنامه است. فایل‌های Vazirmatn حذف نمی‌شوند و فقط از runtime خارج می‌مانند. | انطباق با تصمیم مالک محصول و منبع/مجوز واقعی؛ جلوگیری از حذف فایل‌های legacy بدون بررسی سازگاری. |
| 2026-11-12 | SQLite P0 و شواهد Reopen | Snapshotهای A-D و پنج چرخه file-backed Reopen روی SHA دقیق ثبت می‌شوند؛ حفظ Missing/NULL/boolean، metadata ناشناخته، شناسه/ترتیب Reminder و Follow-up و Person links باید قابل اثبات باشد. | جلوگیری از پذیرش مبتنی بر تست‌های قدیمی یا جابه‌جایی شواهد میان SHAها. |
| 2026-11-12 | سیاست پذیرش COMMAND 07-A.2.21 | Analyze، شش Shard، Visual، سه APK و هفت Device Smoke باید روی یک SHA واحد موفق باشند. | نتیجه موفق یک workflow یا SHA دیگر به‌تنهایی مجوز پذیرش نیست. |


| 2026-11-12 | Owner-approved official typography — COMMAND 07-A.2.24 | Vazirmatn is the only official/default font. VazirHarf is not an official or fallback brand font. Exactly two user choices are permitted: Vazirmatn (Official Default) and System Default (Optional User Preference). | Latest explicit written Product Owner decision; supersedes conflicting historical font decisions without deleting their records. Any future change requires Mobin's explicit written approval. |


## COMMAND 07-A.2.25 — 2026-11-12

Canonical typography authority: `docs/architecture/ARVIN_TYPOGRAPHY_CONTRACT.md` (recorded on documentation PR #3388). Vazirmatn is the sole official/default family; System Default is the only optional preference. This entry supplements historical records and does not erase them.

Live checkpoint at this entry: PR #3384 HEAD `2ac3580985a23e6ac5342d49c33343c8b4f01816`; PR remains OPEN / DRAFT / UNMERGED. Main remains `45e4202b03a434459e4c021a04efa7e8396359db`. PR #3388 remains OPEN / DRAFT / UNMERGED.

Implementation changes on PR #3384: corrected Alarm Overlay and Calendar font-family references; removed their local family overrides so the root Theme controls Vazirmatn/System Default; aligned Device Smoke scenario `smoke-reminder-vazirharf` with `smoke-reminder-vazirmatn`; aligned its workflow contract test. Related commits include `415cb976ad280f28ff8b780ffe6b4d3a6a8ff17b`, `951d5bd1b359d59ec84662ededcd2f1515083d70`, `8f159f5597a020b3d1e06665c5c123b686872162`, `8127c7a3bc85e9d155ec7131cec25b570eaa787f`, `fbf1b6502a7baed655a9a479fbc28abc6789be3b`, `6fe8a2fbdbb47c6cac402b4d0cf61eb75c23043c`, `83208c93d06ac42b478d0f46212338873f5c7e95`, `a3001d2ac5f81ef44b12514f1f90418f283b9409`, `f63f38b332df68ddc2588eb256378842f9705cfd`, `195e8a9e3802c8637b597c23245dbe86561791ee`, `e8c27100ffa70ebe183e66975380d861d34cb973`, `bcb2d24f94f6c23a8f3131aa5853ad8afb6bf507`, and final `2ac3580985a23e6ac5342d49c33343c8b4f01816`.

Exact-head CI at `2ac3580985a23e6ac5342d49c33343c8b4f01816`: Build run `43217473284` PENDING; Device Smoke `43217473090` QUEUED; SQLite Snapshot `43217473138` QUEUED; Follow-up File Persistence `43217473064` IN_PROGRESS. No outcome is claimed. Older Snapshot run `43212724352` passed on `e94105443e7516ed38eda6feaaee125d92fabaf4` only and cannot be transferred to the current SHA.

The active `main-protection` ruleset remains insufficient: zero required approvals and `require_code_owner_review=false`. CODEOWNERS is present on PR #3388 but effective enforcement is not yet enabled. Release remains NO-GO; no merge, release, deployment, data-destructive operation or history rewrite is authorized.
