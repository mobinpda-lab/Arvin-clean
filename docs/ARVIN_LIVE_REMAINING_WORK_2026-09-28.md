# Arvin — Live Remaining Work & Cross-Conversation Continuity Ledger

> **Updated 2026-09-29:** This ledger supersedes older status statements where they conflict with current `main`, current PR heads, or exact-head CI evidence.
**Audit date:** 2026-09-29  
**Time basis:** Iran time  
**Repository:** `mobinpda-lab/Arvin-clean`

> این فایل مرجع پایدار فرمان «ادامه آروین» است. واقعیت GitHub بر حافظه گفتگو و گزارش‌های تاریخی مقدم است.

## 1. خط مبنا
- Current `main`: `f76b5b35fce30254b22627b0e8f7c0dd915f5a9b`
- Strategy: **PRODUCT FIRST + FACTORY MINIMAL**
- تغییر مستقیم روی `main`: ممنوع.
- تغییر محصول: Issue → Branch → Commit → PR.
- Storage / Model / Repository / Settings / Scheduler / Calendar engine موازی ایجاد نشود.
- داده واقعی کاربر حفظ شود.
- تصمیم‌های پرریسک معماری/Storage/Migration قبل از تغییر برگشت‌ناپذیر نیازمند بازبینی مستقل DeepSeek هستند.
- وجود کد به‌تنهایی «انجام شد» نیست؛ شواهد exact-head و پذیرش محصول لازم است.

## 2. وضعیت تأییدشده فعلی
- PR #1945 overdue-card slice is **MERGED** into current main; current main is `83e647ecc02b266e69e37f61fa214a17f97c2b51`.
- PR #1944 Quick Add RollBox scheduling status must be reconciled against current main; the merged current-main Quick Add implementation is now at `f76b5b35fce30254b22627b0e8f7c0dd915f5a9b`. The old #1944 status is historical.
- #1959 is the canonical GitHub product issue for automatic Task → selected Arvin destination Calendar synchronization, including stable Event identity, update/delete semantics, manual register/edit preservation, and duplicate-safe destination changes.
- PR #1939 was superseded by subsequent merges; current main is now `f76b5b35fce30254b22627b0e8f7c0dd915f5a9b`.
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
- Current main after Quick Add merge: **exact-head CI verified green**.
- #1945 overdue slice: **MERGED** on current main.
- Current-main Quick Add scheduling: **MERGED into `f76b5b35...` / exact-head CI green**.
- #1959 Calendar Sync: **OPEN / canonical product contract recorded**.
- #1901: **OPEN / stale / extraction required**.
- Device Smoke #2832: **SUCCESS** روی HEAD #1939.
- #1901: **OPEN / نیازمند استخراج تغییرات لازم روی main فعلی**.
- #1934: **آماده شروع پس از تعیین تکلیف laneهای بالاتر**.
- #1930: **ثبت‌شده و نیازمند اجرای کنترل‌شده**.
- CI parallelization: **از قبل فعال است؛ Issue #1941 برای بهینه‌سازی مبتنی بر اندازه‌گیری ثبت شده**.
- Release-Ready کل آروین: **نامشخص / هنوز اثبات نشده**.


## 2026-09-29 execution update
- PR #1944 latest HEAD: `c720e378a211ee3540ce58b8b3e432a640366fc1`.
- Exact-head Build #4644: Debug APK PASS, Release APK PASS, Analyze PASS; test-0/1/2/3 PASS; test-4 and test-5 FAILED only in Quick Add scheduling assertions because the test selected `FilledButton.last` and did not reach the time picker.
- Device Smoke #2861: SUCCESS.
- Root-cause follow-up: the date-confirm control now has stable key `quick-capture-date-confirm` and both affected tests target that key instead of an ambiguous generic FilledButton. Test commit: `c720e378a211ee3540ce58b8b3e432a640366fc1`; product commit immediately before it: `c7cf8b319349e74c1c4166d94654b4e6cd940f59`.
- New exact-head CI for c720e378 has not yet produced a workflow-run record at the time of this update; therefore the new fix remains **نامشخص** until CI runs on the exact SHA.
- Do not merge #1944 until exact-head Analyze/full Test/Debug/Release/Device Smoke are green and the branch is safely reconciled with current main.


## 2026-09-29 execution update — exact-head Gate verification and #1901 extraction audit
- **Exact current main:** `f76b5b35fce30254b22627b0e8f7c0dd915f5a9b`.
- **Analyze Gate:** PASS. Build workflow run `36538477828`, job `quality (analyze)` succeeded; repository-owned Android V2 audit also succeeded.
- **Full Test Gate:** PASS. The same Build run has all six test shards `test-0` through `test-5` successful. No required test shard failed or was skipped.
- **Debug APK Gate:** PASS. Build job `apk (debug)` succeeded, including APK verification and artifact upload.
- **Release APK Gate:** PASS. Build job `apk (release)` succeeded, including APK verification and artifact upload.
- **Device Smoke Gate:** PASS. Run `36538477892` has all 6 required scenarios successful: Home, Quick Capture, SQL Persistence, SQL Migration, Backup/Restore, People.
- **Exact-head release validation:** PASS. Run `36543138141` explicitly asserted exact current main, verified reuse of exact-head release evidence, and published validation evidence. Its artifact is named `arvin-final-head-release-validation-f76b5b35fce30254b22627b0e8f7c0dd915f5a9b`.
- **Release Closure:** run `36543094241` succeeded, but its actual release-build steps were skipped because no pending release was detected. Therefore this workflow is supporting evidence, not a replacement for the successful Release APK Gate above.
- **Current-main Gate result:** Analyze ✓ / Full Test ✓ / Debug ✓ / Release ✓ / Device Smoke 6/6 ✓. Thus the previously unknown CI status of current main is now **VERIFIED GREEN**.
- **Important limitation:** this proves exact-head CI/build/smoke evidence. It does **not** prove owner physical-phone acceptance, complete product Release-Ready status, or every outstanding product contract.
- **#1901 audit:** PR remains stale/diverged and must not be merged wholesale. Changed files are 27 total: 4 contract/docs files, 10 product implementation files, and 13 test files. Extracted product themes are:
  1. Notebook inline number/tick/checklist tools and removal of standalone checklist surface.
  2. Shared canonical Project/Category/Tag taxonomy and immediate catalog selection.
  3. Home mode-specific Roll Box filters and clipping/accessibility improvements.
  4. Task Editor checklist toggle and preservation of checklist data when disabled.
  5. Quick Add direct hour selection tests.
  6. Legacy-schema migration preservation test for task data.
  7. Swipe/RTL acceptance coverage and recurrence/checklist regression coverage.
- **#1901 decision:** these themes are requirements to audit against current main, not merge instructions. The Quick Add scheduling portion is already present on current main, so it must be extracted rather than imported from #1901.
- **Next controlled product lane:** audit the remaining #1901 deltas against current main, starting with **Notebook + Home filter contract**, then Task Editor/Taxonomy. Calendar Sync/Event-ID changes remain a separate higher-risk architecture lane and require the previously defined independent review before irreversible persistence changes.


## 2026-09-29 execution update — #1911 current-main gap audit
- #1911 is the existing owner issue for Notebook inline tools, shared taxonomy, Notebook/Home filters; no duplicate issue was created.
- Current main still has a separate Notebook «یادداشت‌ها / چک‌لیست‌ها» mode and a checklist preset chooser. Expected inline editor controls `notebook-inline-number`, `notebook-inline-tick`, and `notebook-inline-checklist` are not present.
- Current Notebook list exposes fixed category chips (`همه/شخصی/کاری/ایده‌ها`) rather than the full canonical Project + Category + Tag combined filter contract from #1911.
- Current Home has the four grouping controls, but the #1911 contextual Roll Box filter acceptance is not yet proven on current main.
- The extracted #1901 Task Editor checklist-toggle acceptance control is not present on current main.
- Current TaskStore taxonomy lifecycle also needs safety correction/audit: direct catalog deletion methods do not currently enforce a reference-protection rule. This was recorded on Issue #847; no parallel taxonomy store/model is permitted.
- **Next product implementation lane:** #1911 Notebook + Home filter contract, with #847 taxonomy safety kept as a dependent/shared-data safety constraint. Start from current main, add focused regression tests first, and preserve canonical Task/Notebook/Taxonomy storage.

## 2026-09-29 execution update — #1911 Home lane started
- Created current-main branch `feature/1911-home-contextual-rollbox-current-main` from `f76b5b35...`.
- PR #1981 opened as Draft: `feat(home): add contextual Roll Box filters for #1911`.
- Product change: Home grouping views now expose canonical contextual Roll Box controls:
  - Projects: Project + Category
  - Categories: Category
  - Labels: Project + Category + Tag
- Implementation reuses existing `tasks`, `projects`, category/tag data and existing filter state; no new storage/model/repository was introduced.
- Added widget coverage for the contextual controls and tag selection.
- PR #1981 HEAD: `45f5246ed80979767ff5f0fa757a0b7f77170c9f`.
- CI has started on exact HEAD. Current observed state: Build queued; Device Smoke workflow completed with **skipped** job, therefore Device Smoke acceptance for #1981 is **نامشخص/اثبات‌نشده** until the workflow contract/result is resolved.
- #1911 Notebook inline-editor work remains separate and has not been falsely marked complete.


## 2026-09-29 execution update — #1981 lint correction
- PR #1981 first exact-head Build attempt on `45f5246ed80979767ff5f0fa757a0b7f77170c9f` reached `flutter analyze` and failed with two `unnecessary_brace_in_string_interps` infos in `lib/main.dart:505` and `:514`; this is a real Analyze Gate failure for that head, not a workflow skip.
- Corrected those two interpolations on the same controlled branch.
- New PR #1981 HEAD: `22359b0b80f9679d96db4099b3accd99b3854aff`.
- Device Smoke for the previous head was skipped; therefore Device Smoke for #1981 remains **نامشخص/اثبات‌نشده** until the corrected exact HEAD gets valid smoke evidence.
- Notebook remains unmodified; current main audit confirms standalone checklist mode/presets still exist and inline controls are absent. Notebook implementation must preserve existing checklist data and canonical storage.
