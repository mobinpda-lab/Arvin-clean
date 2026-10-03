# Arvin — Live Remaining Work & Cross-Conversation Continuity Ledger

> **Updated 2026-09-29:** This ledger supersedes older status statements where they conflict with current `main`, current PR heads, or exact-head CI evidence.
**Audit date:** 2026-09-28  
**Time basis:** Iran time  
**Repository:** `mobinpda-lab/Arvin-clean`

> این فایل مرجع پایدار فرمان «ادامه آروین» است. واقعیت GitHub بر حافظه گفتگو و گزارش‌های تاریخی مقدم است.

## 1. خط مبنا
- Current `main`: `8437e41a72d6a0315dea3993505afc2b99c79191`
- Strategy: **PRODUCT FIRST + FACTORY MINIMAL**
- تغییر مستقیم روی `main`: ممنوع.
- تغییر محصول: Issue → Branch → Commit → PR.
- Storage / Model / Repository / Settings / Scheduler / Calendar engine موازی ایجاد نشود.
- داده واقعی کاربر حفظ شود.
- تصمیم‌های پرریسک معماری/Storage/Migration قبل از تغییر برگشت‌ناپذیر نیازمند بازبینی مستقل DeepSeek هستند.
- وجود کد به‌تنهایی «انجام شد» نیست؛ شواهد exact-head و پذیرش محصول لازم است.

## 2. وضعیت تأییدشده فعلی
- PR #1945 overdue-card slice was merged before the current main; current main is now `8437e41a72d6a0315dea3993505afc2b99c79191`.
- PR #1944 Quick Add RollBox scheduling is **CLOSED without merge**. Its latest tested head was `c720e378a211ee3540ce58b8b3e432a640366fc1`; do not treat it as current product evidence.
- #1959 is the canonical GitHub product issue for automatic Task → selected Arvin destination Calendar synchronization, including stable Event identity, update/delete semantics, manual register/edit preservation, and duplicate-safe destination changes.
- PR #1939 با HEAD `8bd91d9b8ea4557f5cf6279019981c25a3eaffc7` در 2026-09-28 با merge SHA `cccda42e43f414d347d60b645c7be93ac3f58f54` **MERGED** شد.
- Device Smoke #2832 روی همان HEAD پس از اجرای مجدد **SUCCESS** شد؛ هر ۶ سناریوی Home، Quick Capture، SQL Persistence، SQL Migration، Backup/Restore و People سبز شدند.
- Analyze، Full Test، Debug APK و Release APK برای HEAD #1939 نیز موفق بودند.
- PR #1902 custom recurrence قبلاً merge شده؛ پیاده‌سازی interval روز/هفته در main موجود است. پذیرش دستگاه واقعی آن هنوز **نامشخص** است.
- PR #1901 هنوز **OPEN** و بر اساس main قدیمی است؛ HEAD آن `964a55c46c92627c4e218bb816abda6b571e26da` و نباید مستقیم merge شود.
- PR #1936 اکنون stale است و به #1935 اشاره می‌کند؛ پس از این ledger باید supersede/close شود و منبع حقیقت همین فایل و main جدید است.
- Issue #1941 برای بهینه‌سازی CI بدون کاهش پوشش ثبت شد.

## 3. گلوگاه اصلی بعدی: #1901
#1901 یک بسته بزرگ 26 فایل/85 commit است و با main فعلی هم‌پایه نیست. راه درست:
1. مقایسه دقیق diff #1901 با main فعلی.
2. استخراج فقط تغییرات محصولی هنوز لازم.
3. هر تغییر مستقل در Issue/Branch/PR کنترل‌شده روی main فعلی.
4. هیچ rebase/merge کورکورانه و هیچ rewrite بزرگ انجام نشود.
5. برای هر lane: Analyze → Full Test → Debug/Release Build → Device Smoke exact HEAD.
6. پذیرش گوشی واقعی فقط برای مواردی که قرارداد آن را لازم می‌داند.

## 4. Remaining Product Work — P0/P1
### 4.1 Quick Add / Date-Time / Reminder
- مسیر Quick Add Date/Time فعلی پس از #1939 از نظر CI exact-head سبز است.
- Reminder Date/Time و تمام مسیرهای مرتبط هنوز باید در دستگاه واقعی/پذیرش محصول بررسی شوند.
- Date + Time هرجا هر دو وجود دارند یک ردیف باشند.
- Persian digits/RTL حفظ شود.
- Project / Category / Tag از Roll Box رنگی/آیکونی canonical با «ایجاد جدید» به‌عنوان آخرین گزینه استفاده کنند.
- مقدار تازه‌ساخته‌شده باید فوراً در selector قابل مشاهده باشد.

### 4.2 Roll Box / فرم‌ها — Issue #1934
- موعد / تکرار / یادآور و سپس تمام Date/Time selectorها به الگوی Roll Box یکپارچه نزدیک شوند.
- از `ArvinRollBox` موجود استفاده/گسترش داده شود؛ Widget/Storage/Model موازی ایجاد نشود.
- فازها: Quick Add → Task Editor/forms → Calendar/Defer/Reminder/time filters → audit کامل.
- این lane بعد از تثبیت P0 فعلی اجرا شود.

### 4.3 Home
- چهار گروه: زمان / پروژه‌ها / دسته‌ها / برچسب‌ها.
- Project view: Project + Category؛ Category view: Category؛ Tag view: Project + Category + Tag.
- فیلترها بدون reopen به‌روز شوند.
- کارت‌ها multiline و خوانا باشند؛ clipping در فونت بزرگ رخ ندهد.
- قرارداد رنگی/دسترسی‌پذیری حفظ شود.
- پذیرش تصویری نهایی روی دستگاه واقعی طبق قرارداد.

### 4.4 Calendar / Defer / Calendar Sync — Issue #1959
- Target is **Arvin's selected destination calendar**, not Samsung Reminder and not necessarily the phone default calendar.
- Settings: destination calendar selector + one toggle «ثبت خودکار کارها در تقویم مقصد».
- Auto ON: Task create → create Event; Task edit → update the same Event; Task delete → delete the corresponding Event according to Arvin delete rules.
- Auto OFF: no automatic calendar operation; manual «ثبت در تقویم» and «ویرایش در تقویم» remain available.
- Task remains canonical source of truth; Event is a synchronized representation.
- Stable Task ↔ Event identity must be designed without parallel storage/model/calendar engine.
- Changing destination calendar must not blindly recreate/migrate existing Events; explicit product/architecture behavior is still **نامشخص** and must be decided before implementation.
- Audit/reuse existing `SystemCalendarBridge` / `CalendarProviderSyncExecutor` and stale PR #1847 behavior rather than merging stale code wholesale.
- Before irreversible Storage/Model changes for Event ID, obtain independent DeepSeek architecture review.
- «ویرایش کارهای آروین» and manual calendar registration remain required.
- Defer به Roll Box: یک ساعت / یک روز / یک هفته / یک ماه / تاریخ‌وساعت سفارشی.
- Done toggle: انجام شد ↔ فعال با همان Task canonical.
- بدون Calendar engine/store موازی.
- Provider/device evidence طبق قرارداد لازم است.

### 4.5 Overdue / Recurring Cleanup — #1930
- Overdue card slice is **MERGED** via #1945 and is on current main.
- Remaining: controlled recurring cleanup, exact product/device acceptance, and any follow-up behavior not yet proven.
- overdue با red semantic + calendar icon + معنی واضح «گذشته».
- × فقط موعد را حذف کند، Task حذف نشود.
- recurring cleanup کنترل‌شده و از مسیر canonical Task.
- exact-head Analyze/Test/Debug+Release/Device Smoke لازم است.

### 4.6 Task Editor / Taxonomy
- Project/Category/Tag در یک ردیف Roll Box رنگی/آیکونی.
- Tag چندانتخابی با checkmark.
- Create و Select مستقل.
- آیتم جدید فوراً در selector.
- Date+Time یک ردیف؛ Repeat+Priority یک ردیف.
- Completed ↔ Undone و Done/All مطابق قرارداد.
- مدیریت مرکزی Project/Category/Tag در Settings.
- Task و Notebook همان taxonomy canonical را مصرف کنند.

### 4.7 Notebook
- دفترچه مستقل؛ Checklist تب/صفحه مستقل نباشد.
- شماره خودکار / تیک / چک‌لیست inline و مستقل.
- Undo/Redo/autosave/reopen حفظ شود.
- Project/Category/Tag همان taxonomy Tasks.
- selectorها Roll Box درجا؛ Tag selection فعال.
- حذف Checklist/Shopping/Travel فقط بعد از dependency audit و بدون حذف داده.

### 4.8 Typography / Appearance
- font picker واقعی + preview.
- font size واقعی و app-wide.
- VazirHarf v34.003 پیش‌فرض.
- font اضافی فقط با source/license قابل اثبات.
- canonical AppSettingsService؛ settings store موازی ممنوع.
- رنگ‌ها semantic و دسترسی‌پذیر؛ رنگ تنها نشانه وضعیت نباشد.

## 5. CI — وضعیت و بهینه‌سازی
- `.github/workflows/build.yml` اکنون Analyze، شش test shard، Debug APK و Release APK را در jobهای مستقل اجرا می‌کند.
- `.github/workflows/device-smoke.yml` شش سناریوی مستقل را با matrix و `max-parallel: 6` اجرا می‌کند.
- بنابراین اصل Analyze ‖ Test ‖ Build ‖ Android Smoke **هم‌اکنون فعال است** و نباید با ادغام jobها کندتر شود.
- Issue #1941 فقط بهینه‌سازی‌های اندازه‌گیری‌شده را دنبال می‌کند: balance واقعی shardها، کاهش setup تکراری فقط در صورت کاهش wall-clock، و حفظ کامل پوشش.
- هیچ کاهش تست، حذف Smoke، یا استفاده از CI قدیمی برای SHA جدید مجاز نیست.

## 6. Acceptance / Release gates
برای هر تغییر محصولی:
1. Analyze
2. Full Test
3. Debug Build
4. Release Build
5. Device Smoke روی exact HEAD
6. نصب همان APK exact HEAD روی گوشی واقعی، هرجا قرارداد آن را لازم کرده
7. owner acceptance checklist
8. ثبت evidence با SHA دقیق

**Release-Ready هنوز ثابت نشده است.**

## 7. کنترل مسیرهای قدیمی
- #1901: باز و نیازمند re-audit؛ merge مستقیم ممنوع.
- #1892 / #1890 / #1887 / #1885 / #1847 / #1844 و سایر PRهای قدیمی: قبل از هر استفاده، با main فعلی مقایسه شوند.
- #1936: stale؛ باید supersede/close شود.
- #1941: CI optimization lane، مستقل از محصول و بدون ایجاد ریسک برای P0.

## 8. قانون ادامه در گفتگو/اکانت جدید
با دریافت «ادامه آروین»:
1. همین فایل را بخوان.
2. main فعلی و PRهای باز را دوباره بخوان.
3. exact-head CI را مجدداً بررسی کن.
4. بالاترین lane ناتمام را انتخاب کن.
5. کارهای مستقل را موازی و کارهای مشترک را ترتیبی اجرا کن.
6. هر تغییر محصولی را با Issue + Branch + PR انجام بده.
7. evidence نبود = «نامشخص».
8. Storage/Model/Repository/Settings/Calendar engine موازی نساز.
9. هدف نهایی: محصول قابل استفاده و Release-Ready؛ کارخانه فقط وسیله است.

## 9. ترتیب اجرای زنده پس از این audit
1. Finish and verify PR #1944 on its latest exact HEAD; do not merge without exact-head gates.
2. Refresh/close/supersede stale PRs only after current-main audit; never merge stale branches wholesale.
3. Execute Calendar/Defer lane: done toggle + defer RollBox, using current canonical Task path.
4. Execute #1959 Calendar Sync architecture audit and DeepSeek review before Event-ID persistence changes; then implement on a fresh current-main branch.
5. Task Editor/Taxonomy and Notebook lanes.
6. Notification/Widget, appearance/font, migration/architecture audit, then full release gates.

## 10. Known unresolved decisions / blockers
- **Calendar destination change behavior:** نامشخص; must be explicitly approved before implementation.
- **Physical-device acceptance for merged custom recurrence (#1902):** نامشخص.
- **Release readiness of the whole product:** نامشخص.
- **Exact-head CI for PR #1944 latest SHA:** نامشخص until verified.

## 11. قانون ادامه در گفتگو/اکانت جدید
With any new conversation/account, «ادامه آروین» means: read this ledger, verify current main, verify all open relevant PR heads and exact-head CI, continue from the highest unfinished product lane, and update GitHub evidence. This ledger is the continuity source; chat memory is not the source of truth.

## 12. جمع‌بندی زنده
- #1939 P0: **MERGED + exact-head CI سبز**.
- #1945 overdue slice: **MERGED** on current main.
- #1944 Quick Add RollBox scheduling: **OPEN / latest SHA `4c4038f...` / exact-head CI نامشخص**.
- #1959 Calendar Sync: **OPEN / canonical product contract recorded**.
- #1901: **OPEN / stale / extraction required**.
- Device Smoke #2832: **SUCCESS** روی HEAD #1939.
- #1901: **OPEN / نیازمند استخراج تغییرات لازم روی main فعلی**.
- #1934: **آماده شروع پس از تعیین تکلیف laneهای بالاتر**.
- #1930: **ثبت‌شده و نیازمند اجرای کنترل‌شده**.
- CI parallelization: **از قبل فعال است؛ Issue #1941 برای بهینه‌سازی مبتنی بر اندازه‌گیری ثبت شده**.
- Release-Ready کل آروین: **نامشخص / هنوز اثبات نشده**.


## 2026-10-03 live execution update
- Current main verified from GitHub: `8437e41a72d6a0315dea3993505afc2b99c79191`.
- The latest main commit stabilizes Quick Add recurrence display/test; this does not prove full release readiness.
- Current main has no workflow-run records available through the checked GitHub workflow endpoint, so current-main CI is **نامشخص**.
- PR #1944 is closed without merge; its changes must not be assumed to be in main.
- PR #1901 is 85 commits ahead and 93 commits behind current main; it is not safe to merge wholesale. Product changes must be extracted into fresh current-main lanes.

## 2026-09-29 execution update
- PR #1944 latest HEAD: `c720e378a211ee3540ce58b8b3e432a640366fc1`.
- Exact-head Build #4644: Debug APK PASS, Release APK PASS, Analyze PASS; test-0/1/2/3 PASS; test-4 and test-5 FAILED only in Quick Add scheduling assertions because the test selected `FilledButton.last` and did not reach the time picker.
- Device Smoke #2861: SUCCESS.
- Root-cause follow-up: the date-confirm control now has stable key `quick-capture-date-confirm` and both affected tests target that key instead of an ambiguous generic FilledButton. Test commit: `c720e378a211ee3540ce58b8b3e432a640366fc1`; product commit immediately before it: `c7cf8b319349e74c1c4166d94654b4e6cd940f59`.
- New exact-head CI for c720e378 has not yet produced a workflow-run record at the time of this update; therefore the new fix remains **نامشخص** until CI runs on the exact SHA.
- Do not merge #1944 until exact-head Analyze/full Test/Debug/Release/Device Smoke are green and the branch is safely reconciled with current main.


## 2026-10-03 deep live audit — continuity update
این بخش جدیدترین وضعیت ثبت‌شده برای اجرای «ادامه آروین» است و بر بخش‌های قدیمی همین سند مقدم است.

### وضعیت محصولی فعلی
- Current main: `8437e41a72d6a0315dea3993505afc2b99c79191`.
- Release-Ready کل محصول: **نامشخص**.
- CI فعلی main از endpoint بررسی‌شده workflow-run evidence قابل اتکا ندارد؛ بنابراین سبز بودن قدیمی به‌عنوان evidence جدید استفاده نمی‌شود.
- هیچ PR قدیمی بدون مقایسه با main فعلی merge نمی‌شود.

### مواردی که در این گفتگو به‌طور صریح تثبیت شدند
1. **تقویم دوطرفه**
   - دو نوع رویداد باید از هم قابل تشخیص باشند: «واردشده از تقویم گوشی» و «کار آروین که با تقویم گوشی لینک شده».
   - هر دو، در صورت تغییر از هر طرف، باید طرف دیگر را به‌روزرسانی کنند.
   - Update باید روی همان رویداد لینک‌شده انجام شود و Duplicate نسازد.
   - حذف/تغییر/تعارض باید از مسیر canonical Calendar Provider و link موجود مدیریت شود.
   - دکمه «تلاش دوباره برای همگام‌سازی» در More → Calendar باید یک‌بار هر دو جهت را بررسی کند.
   - خطای واقعی گزارش‌شده کاربر: «ثبت در تقویم گوشی» پیام `not permitted` می‌دهد؛ این مورد تا پذیرش واقعی Provider/دستگاه **رفع‌شده قطعی محسوب نمی‌شود**.
2. **Quick Add / Date-Time**
   - تاریخ و ساعت باید واقعاً قابل انتخاب باشند و صفحه خالی باز نشود.
   - دقیقه 00–59 و recurrence minute/hour/day/week/month/year در مسیر canonical پیاده شده؛ پذیرش نهایی محصولی هنوز لازم است.
   - Reminder Date/Time نیز باید جداگانه کار کند.
3. **Home**
   - چهار مسیر اصلی: زمان / پروژه‌ها / دسته‌ها / برچسب‌ها.
   - فیلترها باید ترکیبی، بدون reopen و بدون clipping باشند.
   - کارت‌های رنگی semantic باید خوانا و RTL باشند.
4. **Typography**
   - VazirHarf v34.003 پیش‌فرض.
   - Font picker با preview واقعی و font size سراسری.
   - فونت‌های اضافی فقط پس از source/license verification؛ فونت fake selectable ممنوع.
5. **Taxonomy**
   - Project / Category / Tag مدیریت مرکزی داشته باشند.
   - ایجاد و انتخاب مستقل باشد.
   - مورد تازه بلافاصله در Roll Box دیده شود.
   - Category بدون استفاده در Task فعلی حذف نشود.
   - Task و Notebook از همان taxonomy canonical استفاده کنند.
6. **Notebook**
   - Notebook مستقل بماند؛ Checklist نباید به بخش مستقل Home تبدیل شود.
   - Project/Category/Tag مشترک با Task.
   - Tag selection و فیلترهای ترکیبی باید عملی باشند.
   - Undo/Redo/autosave/reopen حفظ شود.
   - حذف Checklist/Shopping/Travel فقط پس از dependency audit و بدون حذف داده.
7. **Task Editor**
   - Project/Category/Tag در یک ردیف آیکونی/رنگی.
   - Tag چندانتخابی با checkmark.
   - Date + Time یک ردیف.
   - Repeat + Priority یک ردیف.
   - Completed ↔ Undone و Done/All طبق قرارداد.
8. **چک‌لیست روزانه / روال مدرسه**
   - Issue #2230 اکنون مرجع صریح این قابلیت است.
   - یک روال یک‌بار تعریف شود و هر روز موارد همان روال با وضعیت مستقل روزانه نمایش داده شوند.
   - تیک/برداشتن تیک، ساعت/یادآور، حفظ پس از restart و جمع‌بندی امروز لازم است.
   - این قابلیت نباید Checklist Notebook را به یک مدل/صفحه موازی تبدیل کند.
   - قبل از تغییر model/storage/recurrence engine، architecture review لازم است.

### PRهای current-main که در این چرخه ایجاد/به‌روزرسانی شدند
- **#2178** Calendar Provider validation + manual bidirectional retry. آخرین HEAD ثبت‌شده: `3696121ccee82cc78412c13d7ebc323a6497d783`. CI در حال/نیازمند بازبینی exact-head؛ Device/phone acceptance هنوز قطعی نیست.
- **#2179** Quick Add minute precision + recurrence units. HEAD `98e188eb2d06e860ced1f16f7f22eda9b702ac22`. Build/Production/Orchestrator/Parallel/G1 سبز؛ Device Smoke skipped؛ هنوز merge نشده.
- **#2180** Home colorful semantic task cards. HEAD `6057278539617a1448607e4d7de6cc5c466f58e9`. Build/Production/Orchestrator/Parallel/G1 سبز؛ Device Smoke skipped؛ هنوز merge نشده.
- **#2181** Font picker Persian preview. HEAD `d724c3230bb9261603cacf19924aca2503320e8d`. Build/Production/Orchestrator/Parallel/G1 سبز؛ Device Smoke skipped؛ هنوز merge نشده.
- **#2182** Taxonomy management regression tests. HEAD `848d13e5854b1371f9b146e80a10a39db32e7e16`. Build/Production/Orchestrator/Parallel/G1 سبز؛ Device Smoke skipped؛ هنوز merge نشده.
- **#2184** Calendar visual distinction: Arvin-linked vs imported phone-calendar items. HEAD `9d06600fd7860686b81ced3ef4e5470b8d408770`. Build + Device Smoke + Production/Orchestrator/G1 سبز؛ هنوز merge نشده.
- **#2185** Shared Project/Category/Tag icon row across Home/Notebook/Task Detail. HEAD `1681e40b7951d20fdced9d67ff1583c697bc3781`. Build + Device Smoke + Production/Orchestrator/G1 سبز؛ هنوز merge نشده.

### باقی‌مانده اجرایی — ترتیب محصول‌محور
**P0**
1. بستن و اثبات #2178: Build/Tests/Provider + اصلاح هر خطای exact-head + پذیرش واقعی خطای `not permitted` و ثبت دستی/ویرایش/حذف/دوطرفه.
2. تکمیل مسیر Calendar و ثبت شواهد برای دو نوع رویداد و Retry دوطرفه.
3. بررسی و ادغام کنترل‌شده PRهای #2179 تا #2185 فقط پس از current-main reconciliation و evidence مناسب.
4. Home: فیلترهای ترکیبی و رفتار واقعی چهار گروه، سپس پذیرش تصویری.
5. Quick Add/Reminder/Task Editor: Date+Time، Reminder، taxonomy، repeat/priority، Done/All.

**P1**
6. Typography: font picker + font size + فونت‌های موردنیاز با مجوز معتبر.
7. Taxonomy مرکزی + Notebook مشترک.
8. تکمیل Notebook UX و فیلترهای Project/Category/Tag.
9. چک‌لیست روزانه/روال مدرسه (#2230) پس از reconcile معماری و recurrence.
10. Swipe Task ↔ FollowUp و سایر موارد regression ثبت‌شده در #1901/#1891.

**Release Gate**
برای هر lane: Analyze → Full Test → Debug → Release → Device Smoke exact HEAD → در موارد قراردادی نصب/پذیرش گوشی واقعی → ثبت SHA و نتیجه. هیچ موردی بدون evidence «تمام‌شده» اعلام نشود.

### قوانین جلوگیری از فراموشی
هر اجرای «ادامه آروین» باید:
1. همین فایل + #1923 + #2224 + #2230 را بخواند.
2. main و PRهای باز را زنده بررسی کند.
3. exact-head CI را دوباره بررسی کند.
4. وضعیت هر مورد را به یکی از «تمام‌شده با شواهد / در حال انجام / نامشخص / deferred / superseded» تبدیل کند.
5. نتیجه را دوباره در GitHub ثبت کند.
