# فرمان اجرایی جامع «ادامه آروین»
نسخه عملیاتی: PRODUCT FIRST + FACTORY MINIMAL + 5-MINUTE EXECUTION LOOP
Issue: #2123
Repository: mobinpda-lab/Arvin-clean

## فرمان فعال
هرگاه کاربر بگوید «ادامه آروین»، اجرای واقعی پروژه از آخرین وضعیت معتبر GitHub آغاز می‌شود؛ گزارش‌نویسی جای اجرا نیست.

## 1. حافظه و تداوم
GitHub حافظه عملیاتی پروژه است. تصمیم‌های مهم، Product Contract، Acceptance، Execution Ledger، Architecture/Release/CI Contract و وضعیت کار باید در GitHub Persist شوند. تغییر گفتگو یا اکانت نباید حافظه، قرارداد، کار انجام‌شده یا کار باقی‌مانده را تغییر دهد.

## 2. Recover اجباری
ابتدای هر اجرا این موارد بررسی شوند: main و آخرین SHA، Issueهای مرتبط، PRهای باز، Branchهای فعال، CI/Workflow، Failureهای جدید، تصمیم‌های محصول، Acceptance Criteria، تغییرات اخیر، کارهای تاریخی، duplicate/superseded، dependencyها، Release Gate و Execution Ledger. GitHub از گفت‌وگوی قدیمی معتبرتر است؛ نبود شواهد = UNKNOWN.

## 3. نقطه ادامه
همیشه مشخص شود: CURRENT_MAIN_SHA / ACTIVE_PR / ACTIVE_ISSUE / CURRENT_PRODUCT_GATE / CURRENT_BLOCKER / LAST_VERIFIED_EVIDENCE / NEXT_ELIGIBLE_ACTION. اجرای جدید از صفر شروع نشود.

## 4. ضدتکرار و Reconciliation
قبل از کار جدید، Issue/PR/Branch/Commit/merge و مسیرهای قبلی بررسی شوند. کار تاریخی یکی از Done, Superseded, Duplicate, Still Relevant, Blocked, Needs Revalidation, Unknown باشد. Failure روی SHA قدیمی تا بازتولید روی SHA فعلی، failure فعلی نیست.

## 5. Implementation ≠ Verification
کد موجود بدون Evidence جدید = Implementation موجود / Verification نامشخص. کد + تست + Evidence همان SHA = Verified. گزارش قدیمی به‌تنهایی Evidence نیست.

## 6. Product Critical Path
اولویت با Product Safety، Data/Migration، Release Blocker، Core Product، UX/Device و سپس Test/CI/Automation/Cleanup است. کار غیرضروری به Backlog/Future Roadmap منتقل شود. Factory فقط ابزار محصول است.

## 7. چرخه ۵ دقیقه‌ای
هر کار طولانی در checkpointهای ۵ دقیقه‌ای اجرا شود:
Observe → Reconcile → Select → Execute → Validate → Persist → Checkpoint → Continue
۵ دقیقه توقف نیست. اگر یک Lane منتظر CI/Device/External dependency است، Lane مستقل و ایمن ادامه یابد؛ No Idle Time.

## 8. چهار Lane موازی
A Product: قابلیت و Bug واقعی
B Quality: Test/Smoke/Validation
C Factory: CI/Worker/Automation
D Documentation/Continuity: Ledger/Contract/Acceptance/Reconciliation
وابستگی‌ها ترتیبی؛ کارهای مستقل موازی.

## 9. Single Source of Execution
برای هر Feature یک Canonical Issue، یک Active Implementation Lane و یک PR وجود داشته باشد؛ چند PR فقط با dependency صریح. Worker تکراری/Lease موازی ممنوع.

## 10. Failure
هر Failure ابتدا Product / Factory / Environment / Transient / Unknown طبقه‌بندی شود. Retry فقط محدود و پس از classification؛ Retry بی‌نهایت و Worker duplicate ممنوع.

## 11. Exact-Head Evidence
تمام Evidence باید به SHA دقیق مربوط باشد و تا حد امکان Workflow/Run/Job/Result/Artifact را مشخص کند. Evidence قدیمی برای SHA جدید معتبر نیست.

## 12. CI و Test
Analyze, Unit, Widget, Build و Android Smoke تا حد امکان موازی شوند. Test Sharding فقط برای کارایی است؛ تست/coverage حذف یا ضعیف نشود. Smoke سناریوهای مستقل Home, Quick Add, Persistence, Migration, Backup/Restore, Calendar, Notification, Widget, Search و FollowUp را پوشش دهد.

## 13. Device Evidence
Calendar Provider، Notification، Widget، Keyboard، RTL، Typography، Swipe، Date/Time Picker، Layout، Permission و رفتار واقعی گوشی بدون Evidence دستگاه Done نیستند.

## 14. Storage و Migration
Storage/Repository/Model/Settings موازی ساخته نشود. مسیر canonical حفظ شود: UI → Application Service → Repository → DAO → Canonical Storage. Migration باید داده و ID را حفظ کند، duplicate و storage موازی نسازد، Backup/Restore را حفظ کند و Home قدیمی را به‌عنوان UI مهاجرت ندهد.

## 15. Product Contract Priority
Latest explicit product decision → Current GitHub contract → Acceptance criteria → Current implementation → Historical documentation.
تصمیم جدید کاربر: Conflict Check → Contract Update → اصلاح/شرط Superseded برای مسیر قدیمی.

## 16. Architecture
برای Migration, Storage, Database, Repository, Architecture, حذف مدل, تغییر بنیادی Home, CI مرکزی, Worker, Orchestrator و Release Pipeline ابتدا Architecture Review. Incremental Change > Rewrite؛ Big-Bang Rewrite ممنوع.

## 17. Release Gate
Code → Analyze → Full Test → Debug Build → Release Build → Android Smoke → Persistence → Migration → Backup/Restore → Calendar → Notification → Widget → Real Device → Product Acceptance → Release Artifact.
هر حلقه بدون Evidence = UNKNOWN.

## 18. Done و Merge
Feature فقط با Implementation + Acceptance + Test + Required Device Validation + Exact-head Evidence + No Known Blocking Dependency = Done.
Merge/Close فقط با Code + Tests + CI + Exact SHA + Acceptance + Dependencies. سبز بودن یک Job، APK، فشار زمانی یا بسته‌شدن Issue به‌تنهایی کافی نیست.

## 19. Product QA و UI
QA ثابت: Home, Quick Add, Task, Task Detail, FollowUp, Project, Category, Tag, Notebook, Checklist, Calendar, Reminder, Recurrence, Search, Backup/Restore, Persistence, Migration, RTL, Jalali, Iran Time, Notification, Widget, Swipe, Taxonomy, Settings.
UI باید قرارداد جدید محصول را در همه صفحات رعایت کند: RTL، فونت فارسی، Persian digits، رنگ، Contrast، Disabled/Error، Reminder color، RollBox/Selector و Responsive layout.

## 20. Cross-Feature Consistency
اصلاح یک رفتار باید مصرف‌کنندگان دیگر را بررسی کند. راه‌حل ریشه‌ای در مسیر canonical اعمال شود: One canonical fix → all consumers. Storage/Taxonomy/Selector موازی ممنوع.

## 21. داده کاربر
در هیچ اصلاحی داده واقعی حذف نشود، ID بی‌دلیل تغییر نکند، duplicate ایجاد نشود، storage موازی ساخته نشود و Backup/Restore تضعیف نشود.

## 22. Scope و Roadmap Lock
داخل Scope اجرا؛ ضروری برای Release به Critical Path؛ مفید ولی غیرضروری Backlog؛ آینده Future Roadmap؛ صرفاً ایده فعلاً اجرا نشود. در Release Closure: Finish → Verify → Release و Feature جدید غیرضروری وارد نشود.

## 23. چرخه کامل
Recover → Reconcile → Protect P0/P1 → Plan Lanes → Execute → Parallelize → Validate → Persist → 5-Minute Checkpoint → Re-evaluate → Continue.

## 24. خروجی اجباری هر چرخه
هر چرخه باید حداقل یکی داشته باشد: تغییر واقعی، تست واقعی، Evidence واقعی، Reconciliation، رفع Failure، کاهش Scope، حذف Duplicate، رفع Blocker، ثبت تصمیم مهم یا Next Action دقیق. در غیر این صورت چرخه موفق نیست.

## 25. No Guess
UNKNOWN باید همراه با What is missing / Why / How to obtain / Who or what provides it ثبت شود. «احتمالاً درست است» وضعیت معتبر نیست.

## 26. کار بعدی
در هر checkpoint فقط این سؤال راهنماست:
«بیشترین اقدام قابل‌انجام و غیرتکراری که اکنون بیشترین پیشرفت واقعی محصول را ایجاد می‌کند چیست؟»
همان انتخاب شود.

## 27. Parallel Critical Path
A→B ترتیبی؛ A/B/C مستقل موازی. هدف کوتاه کردن Critical Path است، نه زیاد کردن Worker.

## 28. Stop / Continue
Continue اگر اقدام ایمن مشخص است؛ Parallel Continue برای کارهای مستقل؛ Wait فقط برای dependency خارجی؛ Block برای تصمیم/وابستگی واقعی؛ Reconcile برای ناسازگاری وضعیت.

## 29. مالکیت تصمیم
ChatGPT تصمیم محصول را جای مالک نمی‌گیرد. برای انتخاب محصولی، گزینه‌ها و اثرشان ارائه و تصمیم از کاربر گرفته شود؛ اجرای بدون نیاز به تصمیم اضافی متوقف نشود.

## 30. گزارش
گزارش حداکثر سه خط:
وضعیت: واقعیت فعلی + SHA/Gate
اجرا: کاری که واقعاً انجام شد
بعدی: مهم‌ترین اقدام یا مانع
بدون Evidence عبارت‌هایی مانند «کامل شد»، «حل شد»، «Release Ready»، «CI سبز» یا «تست موفق» ممنوع.

## 31. معیار بهره‌وری
Product Progress / Time معیار اصلی است. Commit زیاد، PR زیاد، Worker زیاد، CI سبز یا گزارش زیاد به‌تنهایی پیشرفت نیست.

## 32. Vertical Slice
کار بزرگ به Sliceهای کوچک و قابل اثبات شکسته شود؛ هر Slice Acceptance و Evidence مستقل داشته باشد.

## 33. عدم بازگشت
بعد از تأیید مرحله به عقب برنگرد؛ Regression → Root Cause → Targeted Fix → Revalidation، نه Rewrite.

## 34. تغییر گفتگو
هر اجرای جدید حتی در Chat/Account دیگر از GitHub Recover شود. حافظه ChatGPT جای GitHub نیست.

## 35. فرمان نهایی
«ادامه آروین» = بررسی GitHub → Recover → Reconcile → تشخیص Critical Path → جلوگیری از Duplicate → اجرای واقعی → موازی‌سازی ایمن → Validation → Persist Evidence → checkpoint پنج‌دقیقه‌ای → انتخاب Next Action → Continue.

## 36. قرارداد محصول فعلی
تمام تصمیم‌های جدید محصول، از جمله رفتار Calendar/Auto-Sync، UI/UX، Taxonomy، Reminder، Persistence، Migration و Release، باید با همین نظام Contract/Acceptance ثبت و با main فعلی reconcile شوند.

**مرجع:** Issue #2123
**اصل غیرقابل مذاکره:** Product First + Factory Minimal + Evidence First + GitHub Continuity + 5-Minute Execution Loop
