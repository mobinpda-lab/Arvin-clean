# فرمان اجرایی جامع «ادامه آروین»

> نسخه عملیاتی — **PRODUCT FIRST + FACTORY MINIMAL**

## فرمان فعال

**ادامه آروین**

این فرمان یعنی ادامه اجرای واقعی پروژه `mobinpda-lab/Arvin-clean` از آخرین وضعیت معتبر GitHub؛ نه صرفاً تهیه گزارش.

## اصول الزام‌آور

- **PRODUCT FIRST + FACTORY MINIMAL**: آروین محصول نهایی است؛ کارخانه فقط ابزار تولید، کنترل کیفیت، ایمنی داده و Release است.
- در هر اجرا: وضعیت واقعی GitHub بررسی، HEAD دقیق تعیین، تغییرات جدید و کارهای باقی‌مانده شناسایی، کار تکراری حذف، اولویت محصول تعیین، کارهای مستقل تا حد امکان موازی، کارهای وابسته پس از پیش‌نیاز، Validation و شواهد بررسی و مهم‌ترین گام بعدی اجرا شود.
- گزارش جایگزین اجرای واقعی نیست.
- GitHub منبع حقیقت است؛ اطلاعات قدیمی یا درصدهای قبلی بدون تأیید مجدد معتبر نیستند. موارد غیرقابل‌تأیید **❓ نامشخص** هستند.
- هر فعالیت Factory باید Product Enabler، Quality Gate، Data Safety Gate، Release Gate یا Developer Productivity با گلوگاه واقعی باشد؛ در غیر این صورت حذف، ادغام، سبک‌سازی یا متوقف شود.
- Automation هدف نیست؛ محصول هدف است.
- الگوی تغییرات: **Issue → Branch → Change → Test → PR → CI → Validation → Merge**؛ تغییر مستقیم و کنترل‌نشده روی `main` انجام نشود.
- قبل از کار جدید، Branch/PR/Issue/Worker/فایل و تغییرات مشابه بررسی شوند تا Duplicate Work ایجاد نشود.
- وضعیت کار فقط یکی از این‌هاست: ✅ انجام‌شده با شواهد، 🔄 در حال اجرا، ⏳ در صف، 🟡 باقی‌مانده و قابل اجرا، 🔴 شکست‌خورده، ⚠️ مسدود، ❓ نامشخص.
- اولویت‌ها: **P0 حیاتی**، **P1 محصول**، **P2 تضمین کیفیت**، **P3 بهینه‌سازی**؛ P3 قبل از P0/P1/P2 اجرا نشود مگر اینکه گلوگاه واقعی باشد.
- هر Task باید Product Value روشن داشته باشد: بهبود قابلیت، رفع خطای محصول، ایمنی داده، تست واقعی یا رفع مانع Release.
- در صورت امکان، کار واقعی مستقیماً در GitHub انجام شود؛ اگر نیازمند تصمیم مالک محصول است فقط همان تصمیم مشخص درخواست شود.
- اصل موازی‌سازی: **سریع + همزمان + موازی + کنترل‌شده**؛ سرعت نباید باعث تداخل، دوباره‌کاری، خرابی داده یا کاهش پوشش شود.

## CI و Validation

- CI حداقل مؤثر باشد: Analyze || Unit/Widget Test || Build و در صورت استقلال واقعی Android Smoke.
- Parallelization، Matrix، Cache و Artifact Reuse معتبر مجازند؛ حذف تست، Smoke، Build ضروری، Validation، پنهان‌کردن Failure یا سبزسازی مصنوعی ممنوع است.
- همه شواهد باید به **Commit دقیق** متصل باشند: MAIN_SHA / HEAD_SHA / WORKFLOW_RUN / JOB / RESULT / ARTIFACT.
- موفقیت Commit قدیمی، موفقیت Commit جدید محسوب نمی‌شود.
- Release-Ready فقط با CI سبز اثبات نمی‌شود. زنجیره موردنیاز:
  **Code → Analyze → Tests → Build → Android Smoke → Persistence/Migration → Backup/Restore → UI/UX → Real Device Evidence → Release Artifact**
- بدون شواهد لازم، «کامل شد»، «حل شد»، «Release-Ready شد»، «تست موفق است»، «Build موفق است»، «Device Test موفق است» یا «داده‌ها سالم‌اند» اعلام نشود.

## محصول و داده

- QA محصول‌محور است: Home، Quick Add، Task، Detail، FollowUp، Project، Category، Tag، Notebook، Checklist، Calendar، Reminder، Recurrence، Search، Backup/Restore، Persistence، Migration، RTL، Jalali/Iran Time، Notification، Widget و Swipe.
- Storage/Model موازی ممنوع. مسیر canonical:
  **UI → Application Service → Repository → DAO → Drift/SQLite**
- Migration باید بدون Data Loss و Duplicate، با حفظ ID، تاریخچه، Archive/Trash و Backup/Restore قابل اعتماد باشد.
- **Home قدیمی داده Migration نیست.** ساختار UI قدیمی Home نباید مهاجرت داده یا معماری جدید محسوب شود؛ وابستگی‌های کد و تست به Home قدیمی باید در همان جریان Migration شناسایی و اصلاح شوند.
- قرارداد UI جدیدتر و صریح‌تر بر مستندات تاریخی مقدم است.
- رفتارهای وابسته به Android واقعی فقط با CI اثبات نمی‌شوند؛ RTL، Swipe، Notification، Widget، Jalali Picker، Keyboard، Back، Layout، Screenshot، Persistence و Android behavior در صورت نیاز با Device Smoke یا دستگاه واقعی بررسی شوند.
- تغییرات پرریسک معماری، Migration، Storage، Database، Core Architecture، Model اصلی، Home مرکزی، CI مرکزی، Worker/Orchestrator و Release Pipeline ابتدا نیازمند بررسی عمیق معماری هستند؛ سرعت تابع ایمنی معماری است.

## Failure و Merge

- Failure ابتدا Product / Factory / Transient طبقه‌بندی شود.
- خطای AI/Worker به‌تنهایی شکست محصول نیست؛ Retry کنترل‌شده، آزادسازی Lease و جلوگیری از Duplicate Worker رعایت شود.
- هیچ PR صرفاً به دلیل سبز بودن Job، سبز بودن Factory، بسته شدن Issue، قدیمی بودن Branch یا فشار سرعت Merge نشود.
- Auto-Close اثبات تکمیل محصول نیست؛ Issue فقط با Acceptance کامل، وابستگی تکمیل و شواهد معتبر بسته شود.

## چرخه اجباری هر «ادامه آروین»

1. دریافت وضعیت واقعی GitHub
2. تعیین HEAD واقعی
3. بررسی تغییرات جدید
4. شناسایی کارهای باقی‌مانده
5. حذف کارهای تکراری
6. تشخیص وابستگی‌ها
7. تشخیص Product Blocker
8. تشخیص Factory Blocker
9. اولویت‌بندی P0 تا P3
10. تقسیم به Laneهای مستقل
11. اجرای موازی Laneهای مستقل
12. اجرای کارهای وابسته
13. Validation لازم
14. بررسی Failureها
15. بررسی Product Evidence
16. بررسی Data Safety Evidence
17. بررسی Release Evidence
18. ثبت نتیجه ضروری در GitHub
19. سبک‌سازی یا حذف گلوگاه‌های غیرضروری Factory
20. تعیین و اجرای مهم‌ترین گام بعدی

### قانون «تا جایی که می‌توانی انجام بده»

اگر کاری مشخص، مستقل، کم‌ریسک، قابل تأیید، دارای ارزش محصول و قابل انجام از طریق GitHub است، **خود کار انجام شود** و سپس نتیجه با شواهد گزارش شود.

### معیار نهایی

هدف نهایی، آروین به‌عنوان یک محصول واقعی Android، پایدار، قابل استفاده، قابل آزمایش، قابل بازیابی و آماده انتشار است؛ نه کارخانه بزرگ، پیچیده و سبز.

**PRODUCT FIRST + FACTORY MINIMAL — ALWAYS**

---

## تریگر پایدار

هر بار کاربر در هر گفت‌وگوی ChatGPT بگوید:

> **ادامه آروین**

این سند باید به‌عنوان قرارداد اجرایی پروژه در نظر گرفته شود و اجرای واقعی از آخرین وضعیت معتبر GitHub آغاز شود.

**نکته:** این فایل در GitHub ذخیره می‌شود و منبع پایدار پروژه است؛ تغییر صفحه گفت‌وگو یا تغییر حساب ChatGPT به‌خودی‌خود این قرارداد را از GitHub حذف نمی‌کند. با این حال، فعال‌شدن خودکار یک فرمان بین حساب‌ها/گفت‌وگوهای مستقل، قابلیت ChatGPT است و GitHub به‌تنهایی تضمین نمی‌کند که هر حساب آن را به‌طور خودکار بشناسد؛ در آن حالت، عبارت «ادامه آروین» باید به این سند/قرارداد پروژه ارجاع داده شود.
