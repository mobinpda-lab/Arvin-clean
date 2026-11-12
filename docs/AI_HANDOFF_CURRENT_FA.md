# Arvin-clean — Live AI Handoff

## Primary Rule

مرجع حاکم فرایند `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 است. GitHub تنها Source of Truth عملیاتی است؛ این فایل فقط checkpoint فشرده برای ادامه سریع است.

## Start Here

در هر گفتگوی جدید یا Trigger «ادامه آروین»:

1. `main`، PRهای باز، Issueهای فعال، Head SHAها و workflowهای همان Head را تازه از GitHub بخوان.
2. این Handoff و `docs/PROJECT_STATUS.md` و scorecardها را با GitHub تطبیق بده؛ GitHub مقدم است.
3. قبل از foundation/model/storage جدید، کد canonical موجود را بخوان.
4. کوچک‌ترین Gap واقعی و مستقل را انتخاب کن؛ Laneهای غیرمسدود را موازی ادامه بده.
5. Merge فقط با exact-head evidence؛ سپس `main` را دوباره Build + Device validate کن.

## Live Checkpoint — 2026-08-27

Snapshot مبنا:

`bec99214534a8c9972f9e3145dde792cecf2f9e3`

این main نتیجه Merge PR #245 است.

### Verified recent merges

- #243 — deterministic `device/**` exact-ref Device Smoke lane
- #242 — Persian Semantic Search v1 on existing `TaskSearchService`
- #247 — Build matrix: shared quality + parallel release/debug APK jobs
- #245 — canonical Privacy / Encryption boundary audit

### Verified evidence

- #242 head: Parallel #751 / Build #826 / Device #66 ✅
- post-#242 main: Build #829 / Device #69 ✅
- #247 head: Parallel #753 / Build #831 / Device #71 ✅
- post-#247 main: Build #832 / Device #72 ✅
- #245 head: Parallel #754 / Build #834 / Device #74 ✅
- post-#245 main: Build #835 + Device Smoke were triggered after merge; re-read live status before claiming post-merge success.

## Official Scores

- Project A-H: **70.0%**
- Extension: **25.0% overall**
- Wave X1: **59.4%**

No score may increase from unmerged work. Project gates remain capped at 70 until their physical-device/E2E acceptance gaps are actually closed.

## Active Parallel Lanes

### 1. Main health

Close post-#245 Build #835 + Device Smoke on exact current main.

### 2. Documentation — PR #227

This PR has been rebuilt on the post-#245 main. It must validate the scorecards via Arvin Progress Score and pass the normal exact-head Fast Lane before merge. It credits only merged evidence.

### 3. Security implementation — Issue #248

Next narrow slice after audit acceptance:

`canonical validated backup bytes → versioned authenticated encrypted envelope → SAF / Cloud`

Restore:

`SAF / Cloud → detect envelope → authenticate/decrypt → existing backup validation → restore candidate`

Required:
- legacy plaintext v1 read compatibility
- authenticated corruption/tamper failure before mutation
- recoverable cross-device key/passphrase design
- same SAF/cloud byte path
- no credential serialization

Forbidden in this slice:
- local `TaskStore` encryption migration
- multi-device Sync implementation
- second backup repository/database/path
- hard-coded or device-only recovery assumption

## Product/Foundation Invariants

- Persian RTL Flutter app.
- Canonical foundation: `Task / Unified Item → Reminder → FollowUps[] → History`.
- Home/Search/Today/Timeline/FollowUp/Calendar/Backup/Settings/Widget/PDF must converge on shared existing foundations.
- Semantic Search remains deterministic/local v1; no required embeddings/network/index/database/search UI second path.
- Backup SAF and cloud must continue sharing one canonical byte representation.

## Fast Lane Contract

- Draft PR → Parallel Wave; heavy Build/Device skip.
- Ready PR → Build + Device.
- Build → one `quality` job then independent parallel `apk (release)` / `apk (debug)` matrix jobs.
- `device/**` provides deterministic exact-ref smoke fallback for automation/API delivery.
- Do not create exact-ref fallback runs when normal PR event evidence already arrived unless needed; avoid duplicate CI.
- Exact-head SHA must be rechecked immediately before merge.

## Continuation Trigger

«ادامه آروین» یعنی:

`Fresh GitHub audit → reconcile stale docs → continue independent lanes in parallel → avoid duplicate foundations → validate exact head → merge safe work → post-merge validate → next real vertical slice → document → short nontechnical report`

Repository reality always overrides conversation memory.


## Live Conversation Checkpoint — 2026-09-23

> آخرین ممیزی زنده: PR #1373 باز و قابل ادغام است؛ Head واقعی این شاخه `2c6b6923df8bc105a3f044a5468c7b5ede52a56c` است. برای این Head هنوز هیچ Workflow Run/Combined Status از GitHub برنگشته؛ بنابراین Analyze/Test/Build سبز اعلام نمی‌شود. مسیر بعدی: فعال‌کردن اجرای CI از طریق همین PR و سپس رفع هر خطای واقعی قبل از merge.

این بخش برای انتقال کار بین گفتگوها و حساب‌های ChatGPT ثبت شده است. در صورت تغییر صفحه گفتگو، نباید وضعیت کار از حافظه گفتگو حدس زده شود؛ GitHub باید دوباره خوانده شود.

### Active product branch
- Branch: `fix/final-ui-home-quick-entry-20260923`
- آخرین تغییر ثبت‌شده در کد: `67df2fc6e95f74bc45525530ad3808e639d78199`
- آخرین Head شاخه/PR: `2c6b6923df8bc105a3f044a5468c7b5ede52a56c`
- تغییر قبلی مرتبط: `5b78bff1d619c85e017ff9a4e9e85018a26d4454`
- Task Detail dashboard: `c3e82af6d16463bc4a6bdda1874164e1a859af1f`

### Current authoritative UI/product requirements
- Home باید داشبورد حرفه‌ای مدیریت چرخه زندگی کار باشد، نه فهرست ساده.
- Home: عنوان «مدیریت کارها و پیگیری آروین»، اعلان در سمت فیزیکی چپ، منو در سمت فیزیکی راست، جست‌وجو، و دقیقاً چهار فیلتر/نمای اصلی: زمان / پروژه‌ها / دسته‌ها / برچسب‌ها؛ این چهار مورد چهار موجودیت نیستند و موجودیت‌های این حوزه فقط پروژه، دسته و برچسب‌اند.
- رفتار باز/بسته‌شدن بخش‌های نمایشی Home مطابق قرارداد حفظ شود؛ «گروه‌بندی» در اینجا فقط چیدمان نمایشی است، نه موجودیت مستقل.
- کارت کار باید تا حد امکان خلاصه کامل مدیریت کار را نشان دهد: عنوان، پروژه، دسته، برچسب، اهمیت، وضعیت، آخرین FollowUp و موعد.
- آخرین FollowUp باید از `Task.followUps[]` و `lastFollowUp` canonical بیاید؛ تاریخ legacy نباید به‌عنوان تاریخ واقعی پیگیری نمایش داده شود.
- Task Detail باید یک داشبورد مسیر پیگیری باشد: خلاصه، وضعیت، آخرین پیگیری، Timeline، فاصله بین پیگیری‌ها، اقدام بعدی، یادآوری و دو اقدام روشن «افزودن پیگیری» و «انجام کار».
- Task Editor باید Full Screen و lifecycle-oriented باشد؛ هدر ثابت، عنوان در ابتدا، توضیحات مستقل، پروژه/دسته/برچسب، موعد/یادآوری/تکرار/اهمیت، سپس پیگیری، چک‌لیست و قابلیت‌های موجود.
- فونت نهایی: VazirHarf v34.003. رنگ‌های نهایی و RTL مطابق قرارداد محصول.
- هیچ Storage/Model/Repository موازی برای Project، FollowUp یا Search ساخته نشود.
- داده‌های کاربر نباید حذف یا مهاجرت مخرب شوند.

### Current real implementation
- Home کارت‌ها اکنون پروژه را از ارتباط canonical `ProjectPlan.itemIds` نشان می‌دهد.
- Home تاریخ پیگیری نمایش‌داده‌شده را از `task.lastFollowUp?.dateTime` می‌گیرد.
- Task Detail dashboard در commit `c3e82af6` پیاده شده و باید با Build/Test واقعی اعتبارسنجی شود.
- مسیر افزودن پیگیری و انجام کار به TaskStore canonical متصل است.

### Remaining acceptance gates
1. بررسی compile/analyze/test روی Head فعلی.
2. Build واقعی APK.
3. Device/UI evidence برای Home، Quick Entry، Task Editor و Task Detail.
4. بررسی دقیق RTL، فونت VazirHarf، فاصله‌ها و چهار فیلتر/نمای Home (زمان، پروژه، دسته، برچسب).
5. فقط پس از exact-head evidence، PR/merge و سپس post-merge validation.
6. هر تغییر بعدی باید در همین handoff ثبت شود تا ادامه کار به گفتگو وابسته نباشد.

### Continuation rule
هر بار کار با «ادامه آروین» شروع شد:
`GitHub live audit → read this handoff → verify current branch/head → inspect open PR/workflows → continue from first unfinished acceptance gate → perform real GitHub work → validate → update this handoff → short report`.

این فایل یک حافظه مستقل از ChatGPT است؛ گفتگو یا حساب جدید نباید مبنای وضعیت پروژه باشد.

## PCTADP — mandatory cross-conversation architecture reference (2026-10-10)
- Canonical ADR: `docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md`; tracking Issue #2582; repository-wide conformance audit #2580 remains open.
- Exactly three taxonomy concepts: Project, Category, Tag. Category and Group are one concept; technical name `Category`, standard Persian UI term «دسته». No independent Group model/store/repository/manager.
- Task remains the core actionable entity. A Task can have 0/1 Project, 0/1 Category and multiple Tags. Project/Category/Tag filters remain distinct and combine with AND.
- Before changing Task/Project/Category/Group/Tag/Filter/Search/Report/Calendar/Repeat/Backup/Restore, read the ADR, inspect current main and related PRs/issues, and link the ADR in the PR. Date-based grouping is presentation-only.
- Current-code caveat: Project membership and Category catalog are represented separately; do not claim a physical Project→Category foreign key exists. This conformance question is part of Issue #2580.


## WAVE 0 — CURRENT HANDOFF — 2026-11-11

### Verified repository checkpoint
- Repository: `mobinpda-lab/Arvin-clean`.
- Default branch and WAVE 0 base: `main` at `45e4202b03a434459e4c021a04efa7e8396359db`.
- Documentation branch: `docs/wave-0-canonical-governance`, created from that exact main SHA.
- PRs #3380, #3382 and #3384 were verified OPEN / DRAFT / UNMERGED and were not changed.
- SQLite PR #3384 current head at audit: `c8996bae351d9aede87a251d57141456b945d0a8`; Build failed (six shards, 79 failures), narrow Follow-up persistence run succeeded, Device Smoke remained pending with no jobs.

### Read before any next work
1. `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` — canonical v49.1 operating standard and WAVE 0 governance mapping.
2. `docs/ARVIN_PROJECT_STATE.md` — live repository/PR/CI/SQLite status.
3. `docs/arvin-memory/ARVIN_DECISION_LOG.md` — accepted decisions and WAVE 0 hold.
4. `docs/arvin-memory/ARVIN_EVIDENCE_MAP.md` — exact SHA and run evidence.
5. `docs/PROJECT_ROADMAP_2026-08-14.md` — read the 2026-11-11 override, not the old dated snapshot.
6. This handoff and the relevant PR/CI logs from live GitHub.

### Immediate next task (not authorized by this WAVE)
Resume SQLite P0 only after an authorized follow-on command. First perform root-cause diagnosis on the exact current #3384 head:
- D01: trace `follow_up_enabled` schema ownership, all migration versions, table rebuild logic, and dependent indexes/triggers/foreign keys.
- D02: settle test/source semantics for absent key vs explicit NULL, then test Missing, NULL, FALSE and TRUE independently.
- D03: capture the same source JSON envelope, SQL rows and deserialized object before/after close/reopen; identify exactly where `futureFollowUpField` is dropped.
- Do not patch until the root cause is proven. Preserve all existing tests and assertions.
- Recheck live GitHub refs and CI first; never reuse this snapshot as current without refresh.

### Hard boundaries
- This WAVE is documentation-only. Do not change production, tests, schema, serializers, TaskStore, workflows or application configuration.
- No CI rerun/dispatch, cancellation, merge, release, deployment, main modification or history rewrite.
- Keep PR #3380, #3382 and #3384 untouched.
- SQLite P0 remains OPEN; Release NO-GO; Merge NOT AUTHORIZED.
- Stop after this documentation PR is created and its exact head/status/CI state is recorded.


## COMMAND 07-A.2.24 continuation handoff — 2026-11-12

1. Re-read live main, PR #3384, PR #3388 and their exact branch refs before any further write.
2. Treat `docs/architecture/ARVIN_TYPOGRAPHY_CONTRACT.md` as the canonical font decision: Vazirmatn only; System Default is the sole optional user preference.
3. Resolve the VazirHarf contradiction introduced on PR #3384 before considering typography acceptance. Do not delete historical assets/evidence blindly.
4. Complete font provenance, all five weights, checksums, centralized Theme, accessibility-preserving global rendering, preference persistence, APK asset inspection and actual PDF inspection.
5. Continue SQLite D01-D05 and five independent persistence cycles on a single exact acceptance SHA. The current Snapshot PASS is insufficient.
6. Inspect the failed Build run and queued Device Smoke without cancelling valid jobs or weakening assertions.
7. Effective Ruleset enforcement for CODEOWNER review remains pending; current ruleset requires zero approvals and does not require CODEOWNER review.
8. Do not merge, release, deploy, rewrite history, delete user data or destroy historical evidence. Release remains NO-GO.


## COMMAND 07-A.2.25 — continuation handoff (2026-11-12)

Read the canonical typography decision first: [`docs/architecture/ARVIN_TYPOGRAPHY_CONTRACT.md`](architecture/ARVIN_TYPOGRAPHY_CONTRACT.md). Vazirmatn remains the only official/default font; System Default is the only optional preference. Historical VazirHarf assets are not active registration or branding.

### Current live refs
- PR #3384: `feature/command-07-a-sqlite-contract-remediation`, HEAD `2ac3580985a23e6ac5342d49c33343c8b4f01816`, OPEN / DRAFT / UNMERGED.
- PR #3388: `docs/wave-0-canonical-governance`, HEAD `fe7e001ec93446d78ad327a03771c849dfd81a48`, OPEN / DRAFT / UNMERGED.
- Main: `45e4202b03a434459e4c021a04efa7e8396359db`.

### Implemented in PR #3384 since e941054
- Replaced stale `AppFonts.vazirHarfFamily` runtime/test references with the official Vazirmatn contract.
- Removed local forced font-family overrides from Alarm Overlay and Calendar so both inherit the root Theme and respect System Default.
- Aligned Device Smoke scenario name to `smoke-reminder-vazirmatn` and its workflow contract test.
- Candidate five-weight asset SHA-256 values are recorded in typography contract §16; upstream source release/commit remains to be pinned.

### Immediate continuation
1. Poll the four exact-head workflows listed in `ARVIN_PROJECT_STATE.md`; inspect Build logs and every Device Smoke lane.
2. Confirm the full branch no longer references removed `AppFonts.vazirHarfFamily` / `familyForText` APIs. Keep unused historical VazirHarf files only as classified evidence; do not register or package them.
3. Run the five-weight asset test, actual APK font audit on Debug/Release, PDF output inspection and Persian/RTL checks on the same acceptance SHA.
4. Continue D01-D05 from existing snapshots. Preserve Missing/NULL/FALSE/TRUE, unknown metadata, IDs/order/person links, reminder migration, backup/restore, rollback and recovery. Do not infer acceptance from the older e941054 snapshot run.
5. Complete all seven Device Smoke lanes on the same exact SHA.
6. Ruleset update is still required: the active ruleset currently has zero required approvals and `require_code_owner_review=false`; CODEOWNERS alone is insufficient.
7. Keep both PRs Draft. No merge, release, deployment, destructive data operation or history rewrite.

Release: NO-GO until every required gate passes on one exact SHA.
