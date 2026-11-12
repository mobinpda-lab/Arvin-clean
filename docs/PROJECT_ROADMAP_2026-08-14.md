# Arvin — Accelerated Project Roadmap 2026-08-14

## هدف
تکمیل سریع اما کنترل‌شده `Arvin-clean` تا رسیدن به APK واقعی، پایدار، فارسی، شمسی و RTL؛ بدون بازسازی foundationهای موجود و بدون ایجاد مسیر داده موازی.

## قانون اجرای همه Waveها
قبل از هر تغییر:
1. بررسی `main` و آخرین commit.
2. بررسی کد واقعی مرتبط.
3. بررسی PRهای باز و CI اخیر.
4. بررسی مستندات و سابقه تصمیم‌ها.
5. در صورت نیاز مقایسه با پروژه‌های مرجع.
6. فقط Gap واقعی تغییر می‌کند.
7. قابلیت حل‌شده دوباره ساخته نمی‌شود.

بعد از تغییر:
- تست focused و regression.
- Commit مستقل و قابل ردیابی.
- اجرای Build و Workflowهای validation مرتبط بلافاصله.
- بررسی نتیجه CI قبل از ادامه Wave وابسته.
- ثبت تصمیم، تغییر، نتیجه تست و وضعیت CI در مستندات.

## مدل اجرای سریع و موازی
سرعت با شکستن کار به commitهای کوچک و مستقل افزایش می‌یابد، نه با موازی‌سازی کور. هر Lane فقط مالک فایل‌ها/لایه‌های خودش است و foundation مشترک فقط توسط Lane اصلی تغییر می‌کند.

### Lane 0 — CI / Release مراقبت مستمر
- بررسی نتیجه هر Build/Parallel قبل از ادامه تغییر وابسته.
- حفظ APK release به‌عنوان معیار نهایی، نه صرفاً analyze/test.
- در صورت سبز بودن CI، شروع فوری کار مستقل بعدی بدون انتظار برای تکمیل Laneهای نامرتبط.
- در صورت قرمز شدن، توقف همان Lane و root-cause fix.

### Lane A — Architecture / Unified Item
**اولویت: فوری و گلوگاه اصلی**
- تثبیت `Task` به‌عنوان مدل Item مشترک.
- بررسی دقیق `ArvinTask / TaskRepository` و تعیین adapter/migration حداقلی.
- حفظ migration داده‌های قدیمی.
- حذف تدریجی وابستگی‌های Legacy فقط پس از تست و بدون شکستن UI موجود.
- خروجی Gate A: یک مسیر داده مشخص برای Item/Note/FollowUp.
- **Wave 1 جاری:** اثبات Task/Migration/Recurrence contract قبل از Refactor.

### Lane B — Simple Notebook UI
**قابل آماده‌سازی موازی، اجرای UI نهایی پس از Contract مدل**
- Editor واقعی.
- Auto-save.
- Read-only بعد از خروج.
- Edit صریح.
- Checklist.
- Settings integration.
- timestamp داخلی و جدا از Calendar.

### Lane C — Home / Search preparation
- طراحی اتصال Home به Unified Item پس از تثبیت adapter.
- اتصال Search UI فقط به مسیر نهایی Item/Home و SearchService موجود.
- Sort، Swipe، Multi-select، Archive/Trash بدون repository موازی.
- تست‌های UI مستقل می‌توانند همزمان با Lane A آماده شوند، اما merge وابسته به Gate A است.

### Lane D — Calendar / Official Iranian data
**به‌صورت مستقل از Notebook/Home جلو می‌رود؛ Calendar foundation بازنویسی نمی‌شود.**
- تکمیل `CalendarReminder` برای اوقات شرعی شیعه بر اساس منبع/روش مرکز تقویم مؤسسه ژئوفیزیک دانشگاه تهران.
- تکمیل یادآور تعطیلات رسمی ایران بر اساس تقویم رسمی کشور و مناسبت‌های مصوب.
- تعریف source-of-truth، مکان، timezone، cache و refresh.
- تست تاریخ شمسی، مرز روز، تغییر مکان و سال.
- Note timestamp هرگز وارد این مسیر نشود.
- Google/system Calendar فقط برای eventهای مجاز محصول باقی بماند.
- **PR #80 قرارداد source-neutral و mapping به `CalendarReminder` را merge کرده است؛ implementation واقعی Providerها گام فعال بعدی است.**
- Providerها باید بدون داده حدسی، با fixture قابل اعتبارسنجی، سال/مکان/timezone مشخص و regression test اضافه شوند.

### Lane E — Widget
- استفاده از همان source of truth Item/Reminder/FollowUp.
- Today/Future/Overdue/Category فقط در صورت وجود واقعی مدل.
- Quick Add و open-item.
- RTL و IranSans.
- بررسی واقعی پشتیبانی Lock Screen و graceful fallback برای دستگاه‌های فاقد پشتیبانی.
- بدون Storage جدا.
- validation روی Android هدف پروژه.

### Lane F — Output / Font
- PDF Item + FollowUps.
- PDF list.
- Share.
- Print برای Note ساده و Item پیگیری‌دار.
- حفظ RTL و شمسی.
- اعمال IranSans / IranSansX(Eco) در UI، Widget، PDF و Print.
- تست خروجی مستقل می‌تواند قبل از اتمام Widget آماده شود، اما یکپارچه‌سازی نهایی پس از تثبیت مدل انجام می‌شود.

### Lane G — Integrations / Data portability
- Reminder / Google Calendar فقط برای eventهای مجاز.
- Backup/Restore End-to-End.
- تکمیل Dropbox provider موجود، نه بازسازی.
- تست انتقال داده بین دستگاه‌ها و حفظ Item/FollowUp/Category/Tag/Settings.

### Lane H — E2E / Device release
- اجرای سناریوهای واقعی APK.
- Calendar شمسی + ساعت + اوقات شرعی + تعطیلات.
- Notebook، FollowUp، Search، Widget و Lock Screen در صورت پشتیبانی.
- Backup/Restore و Dropbox.
- ساخت APK release، artifact، checksum و release documentation.

## Recurrence contract
`Task` از `RecurrenceRule` اختیاری استفاده می‌کند و مدل یا repository موازی برای recurring task ایجاد نمی‌شود.

`RecurrenceFrequency` فعلاً شامل `daily`, `weekly`, `monthly`, `yearly`, `oncePerDay` است.

- `interval` باید مثبت باشد.
- weekly با فاصله `7 * interval` روز محاسبه می‌شود.
- مقدار recurrence وقتی unset است در JSON ذخیره نمی‌شود.
- رفتار موجود daily/monthly/yearly/oncePerDay باید حفظ شود.
- مرزهای تقویمی monthly/yearly قبل از توسعه بیشتر باید با تست‌های focused پوشش داده شوند.

## ترتیب Gateهای اصلی
1. **Gate A:** Unified Item + adapter/migration + regression.
2. **Gate B:** Notebook UI قابل استفاده و persistence واقعی.
3. **Gate C:** Home + Search روی مسیر نهایی Item.
4. **Gate D:** Calendar + Prayer Times + Iranian Holidays.
5. **Gate E:** Widget + Lock Screen validation.
6. **Gate F:** PDF + Print + IranSans.
7. **Gate G:** Reminder/Google Calendar + Backup/Dropbox.
8. **Gate H:** E2E، APK release، artifact و تست واقعی دستگاه.

## کارهای قابل اجرای موازی فعلی
تا وقتی Gate A در حال تثبیت است، این کارها می‌توانند بدون تغییر foundation مشترک جلو بروند:
- **Calendar Providerها:** source research و contract انجام شده و PR #80 merge شده؛ اکنون implementation واقعی Providerهای تعطیلات رسمی و اوقات شرعی با validation منبع در اولویت است.
- طراحی/تست‌های Notebook UI روی foundation موجود.
- آماده‌سازی تست‌های Home/Search با mock/in-memory بدون تغییر repository اصلی.
- آماده‌سازی Widget/Lock Screen compatibility tests بدون ایجاد storage جدید.
- آماده‌سازی PDF/Print tests با fixtureهای Item/FollowUp.
- تکمیل focused tests برای recurrence contract بدون اتصال UI تا زمان سبز شدن validation.

## معیار سرعت
هر commit باید یک Gap مشخص را ببندد، کوچک و قابل بازبینی باشد و بلافاصله validation شود. کار مستقل بعدی نباید فقط به‌خاطر انتظار برای یک Lane نامرتبط متوقف شود.

## معیار توقف
اگر CI قرمز شود، توسعه قابلیت جدید در همان مسیر متوقف می‌شود و ابتدا root cause همان شکست اصلاح می‌گردد. اگر تغییری قبلاً در main یا PR حل شده باشد، هیچ commit تکراری ایجاد نمی‌شود.

## وضعیت فعلی
- Unified Item foundation و Category compatibility در main تثبیت شده‌اند.
- Lock Screen برای Widget به‌عنوان الزام محصولی ثبت شده است.
- PR #80 با موفقیت merge شده و source-neutral Calendar reminder mapping در main است.
- **Gate A:** Wave 1 تست/اثبات Migration و Task Contract در حال اجراست؛ Refactor Legacy تا سبز شدن validation ممنوع است.
- **Recurrence:** weekly contract به‌صورت focused در branch Wave 1 اضافه و تست شده است؛ CI نهایی هنوز در حال اجراست.
- **Gap فعال Calendar:** Provider واقعی اوقات شرعی شیعه و تعطیلات رسمی ایران، با منبع قابل اعتبارسنجی، داده versioned، مکان/timezone و تست سال/تاریخ.
- **تمرکز اجرایی:** Gate A + implementation مستقل Calendar رسمی، همراه با آماده‌سازی همزمان Notebook/Home/Search/Widget tests بدون تغییر foundation مشترک.
- پس از سبز شدن validation هر Lane، همان Lane بدون انتظار غیرضروری وارد commit/implementation بعدی می‌شود.

## Definition of Done
هر قابلیت زمانی Done است که domain/application، persistence، UI واقعی، RTL/شمسی/فونت، regression tests، CI سبز و APK قابل استفاده داشته باشد و مستندات/AI handoff آن به‌روز باشد.


## WAVE 0 — CURRENT PRIORITY OVERRIDE (2026-11-11)

This live addendum supersedes the dated status snapshot above where it conflicts. The earlier roadmap remains historical context, not proof of current completion.

### Gate 0 — Canonical governance and continuity
- Preserve the existing v49.1 operating package and documentation layout.
- Keep repository state, exact SHA, PRs, Actions results, SQLite blockers and next action discoverable without conversation history.
- Record only verified GitHub evidence. Do not inflate completion from unmerged code or green non-product orchestration runs.
- WAVE 0 completion requires a Draft documentation PR containing the six functional document roles mapped in the canonical operating package.

### P0 — SQLite data integrity (must remain first product gate)
1. D01: define the exact legacy/new schema contract for `follow_up_enabled`; identify all dependencies; prove safe rebuild/upgrade, data retention, reopen and idempotency.
2. D02: define and test the four distinct states Missing, Explicit NULL, FALSE and TRUE. Do not convert absence into NULL or add defaults without source evidence.
3. D03: compare source envelope, SQL rows and decoded object across close/reopen; locate the exact unknown Follow-up metadata loss point; preserve Follow-up IDs/order/timestamps/description/status and Person relations.
4. Complete Reminder migration acceptance independently of the Follow-up persistence workflow.
5. Prove five complete save/close/reopen/compare rounds on one resulting SHA.
6. Prove Backup/Restore, transaction rollback and Migration Recovery without weakening existing tests.

### Dependencies and acceptance
- Root-cause diagnosis precedes each repair; no speculative patch after a failed test.
- No production/schema/serializer/TaskStore changes until the exact root cause and safe data-preserving approach are established.
- Every implementation commit must have exact-SHA tests and relevant build/device evidence. Pending, skipped, stale or different-SHA runs do not pass.
- Only after all SQLite gates pass may the next dependent product lane be proposed. Release remains NO-GO until separate release/device/owner gates are met.
- WAVE 0 itself is documentation-only; it does not dispatch CI or validate production behavior.


## COMMAND 07-A.2.24 typography roadmap gate — 2026-11-12

Add a blocking typography acceptance lane alongside SQLite P0: restore/retain Vazirmatn as the sole official default, provide five locally bundled weights and license with verified SHA-256, centralize Theme/weight mapping, implement accessibility-preserving global rendering policy, exactly two persisted choices (Vazirmatn and System Default), inspect actual APK contents, inspect actual PDF font embedding, and complete Persian/RTL device validation. Do not claim acceptance from source registration or widget tests alone. Canonical specification: `docs/architecture/ARVIN_TYPOGRAPHY_CONTRACT.md`.


## COMMAND 07-A.2.26 — exact-head checkpoint (2026-11-12)

Product candidate SHA: `b78488c0347e1a97a7a25f56c914a48761d44a25` on `feature/command-07-a-sqlite-contract-remediation`; PR #3384 OPEN / DRAFT / UNMERGED (87 commits, 62 files at last observed refresh). This supersedes 318c9d for current product validation only.

- Commit `b78488c0347e1a97a7a25f56c914a48761d44a25` corrected the PDF test's stale VazirHarf description/sample to Vazirmatn; assertions were preserved.
- All five actual TTF OpenType name tables report Version 33.003. Source repository: `rastikerdar/vazirmatn`; bundled license: SIL OFL 1.1. Exact upstream commit/tag and source-to-binary reproducibility remain pending. SHA-256 values remain in typography contract §16.
- Follow-up Persistence run `43219196583` is SUCCESS on this exact SHA. Both file-backed Repository Persistence and Alarm Overlay close/reopen diagnostic passed. The latter exercised Snooze, disposing the first overlay/SQLite connection, reopening the same file, loading the overlay again, tapping Complete and observing notification cancellation.
- Build `43219196600`: PENDING, no jobs allocated at last poll. SQLite A-D five-cycle run `43219196466`: QUEUED. Device Smoke run `43219196537`: QUEUED. Production Loop `43219196556`: SUCCESS. Orchestrator `43219196378`: SUCCESS.
- Existing schema tests cover Missing / explicit NULL / FALSE / TRUE metadata, retired-column absence, FK constraints and malformed-source migration preservation. The exact-head SQLite workflow is not yet complete; D01-D05 are not accepted as a whole. Snapshot A-D does not independently prove all triggers/indexes, backup/restore or forced interruption/recovery.
- Earlier SHA results are historical and must not be promoted to this candidate SHA.

Release remains NO-GO. No merge, release or deployment is authorized.


## COMMAND 07-A.2.28 — active P0 execution queue (2026-11-12)

**Current product candidate:** `a6d2d58d87530bfa184c93220cc329b819aca809` (PR #3384, OPEN / DRAFT).

1. Poll Build Run `43223035750` and inspect Analyze, every Regression shard, Visual and all three APK jobs individually. Do not dispatch a duplicate while the exact-head run is pending.
2. Poll Device Smoke Run `43223035920`; collect results and screenshots for all seven scenarios.
3. Poll SQLite Snapshot Run `43223035907` and Follow-up Persistence Run `43223035880`. Use only results whose checked-out SHA equals the candidate SHA.
4. Investigate every remaining UI failure from the previous Build. Preserve assertions and change tests only where the actual approved UI contract or stable semantic/key finder proves the old expectation stale.
5. Complete D01 structural audit (including triggers, indexes, PK/FK and constraints), D02 four-state semantics, D03 unknown metadata and person relations, D04 file-based Backup/Restore, and D05 interruption/recovery. Snapshot success alone is insufficient.
6. Produce deterministic Persian PDF evidence and verify embedded font resources, text mapping/shaping, RTL and rendered output. The current PDF signature/size unit test is not acceptance evidence.
7. Verify actual Debug, Staging and Release APK archives, five-font packaging, file sizes, SHA-256 and exact source SHA.
8. Keep CODEOWNER Ruleset enforcement as a separately owner-controlled repository-security action; continue all independent work.

The five Vazirmatn font assets now have byte-for-byte upstream Git blob provenance pinned in typography contract §18. This does not replace APK or PDF validation.

Do not transfer PASS results across SHAs. Merge, Release and Deployment remain unauthorized.


## COMMAND 07-A.2.28.2 — P0 SQLite validation expansion (2026-11-12)

Candidate SHA: `551ecdc0542bb00f72c21167b4c721094b3a3cba`.

- D01 evidence expanded to capture all SQLite catalog objects and declared foreign-key definitions across five real reopen cycles.
- D04 coverage expanded with an actual backup file read and restore into a separate file-backed SQLite database, followed by close/reopen and reminder/relationship verification.
- D05 coverage expanded with a deliberate malformed-source migration failure, preservation of source data, repair, retry and post-recovery FK verification.

The expanded tests have not yet run on this candidate SHA. The exact-head Build is PENDING and Snapshot/Follow-up/Device workflows are QUEUED. Continue polling; do not declare D01/D04/D05 PASS from test existence.


## COMMAND 07-A.2.28.3 — remaining P0 validation (2026-11-12)

Candidate SHA: `75737f4fb95b4357e8b6e0511ee2443c6aa5aff4`.

- PDF sample and embedded-font/Unicode checks are implemented; CI now uses Poppler to inspect font embedding, extract Persian text and render a PNG preview. Execution is pending.
- APK Font Audit verifies all five Git blob IDs against upstream and logs SHA-256 and byte size for Debug/Staging/Release. Execution is pending.
- Expanded D01 full schema catalog, D04 file-based Restore into a separate SQLite file, and D05 migration-recovery tests are included but not yet executed on this candidate.
- Build is PENDING; SQLite Snapshot, Follow-up and Device Smoke are QUEUED. Continue polling without duplicate runs.
- No PDF, APK or Device Smoke acceptance is issued until exact-head jobs complete and artifacts/logs are inspected.

## COMMAND 07-A.2.28.3 — PDF audit root-cause and exact-head continuation (2026-11-12)

Current product branch candidate at documentation checkpoint: `9a07f4680c49bc8c4246e2bf30b2cd4eaddd2e4e`.

### PDF evidence from prior candidate `75737f4...`
- PDF sample was generated successfully by the PDF typography test; size 18,334 bytes.
- `pdffonts` reported `Vazirmatn-Bold` and `Vazirmatn-Regular`, both embedded (`emb=yes`) with Unicode mapping (`uni=yes`).
- The actual PDF was downloaded from the run artifact, extracted with Poppler, and rendered to PNG. Manual visual inspection showed connected Persian glyphs, readable RTL layout, half-space text, Persian digits, mixed Persian/English, and Regular/Bold content.
- PDF file SHA-256: `9cd1f26a4e565be2b8e1e29b67aedaaa0266e73c5ec7a3fb439b4a817d3147cb`.
- Artifact ZIP SHA-256: `bd3fdcbe83b0ffdf2ffad819b05bec8d7769c01ea2000c6b76bfe178f0c2c7e3`; artifact ID `13949126911`; Run `43224808961`.

### Harness defects found and corrected
The visual job failed after the PDF generation test itself passed. Root cause 1: the `pdffonts` awk audit used incorrect whitespace-token field positions for `emb` and `uni`. Corrected in commit `97effacf705ae10e43760eec4e50d0905def11fa` (`$5` = emb, `$7` = uni).
Manual Poppler extraction then confirmed mixed-direction text is emitted in visual order inside the RTL paragraph; the English date appears as `12-11-2026`, and the company label as `Example Ltd`. The extraction assertions were aligned with that observed output in commit `9a07f4680c49bc8c4246e2bf30b2cd4eaddd2e4e`. No product assertions were removed.

The visual PASS from the previous candidate is not transferable. The complete PDF audit must pass again on `9a07f468...` or the later exact candidate, including embedded font check, text extraction, PNG rendering and preserved artifact.

### Latest relevant candidate commits
- `75737f4...`: build workflow added upstream Vazirmatn Git blob provenance, per-file SHA-256 reporting, OFL license check, APK asset path audit, and legacy runtime-reference guard.
- `97effacf...`: corrected PDF font audit column parsing.
- `9a07f468...`: aligned mixed RTL text extraction checks with observed Poppler output.

Do not report PDF or APK acceptance on the current candidate until the exact-head Build workflow completes successfully and all three APK jobs plus font packaging audits produce verifiable artifacts.
