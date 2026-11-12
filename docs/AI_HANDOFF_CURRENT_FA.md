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


## COMMAND 07-A.2.25 — post-documentation HEAD refresh (2026-11-12)

- PR #3384 latest observed HEAD is now `318c9d7651299ecd0d1bfcda2653c52be87fb81f` (86 commits, 62 changed files), OPEN / DRAFT / UNMERGED. This SHA advanced after synchronizing the six existing `docs/project-continuity/` records; it supersedes the earlier 2ac358... checkpoint for current branch identity only.
- A fresh `actions/runs?head_sha=318c9d7651299ecd0d1bfcda2653c52be87fb81f` query returned no workflow runs at the time of this refresh. All Build/Device/SQLite/Persistence results on 2ac358... or older SHAs are historical and do not validate 318c9d....
- PR #3388 remains OPEN / DRAFT / UNMERGED; current observed HEAD `93f65ad4c42a2f9565a92b49058e68ff8b4eb3d7`.
- The five Vazirmatn binary SHA-256 values in typography contract §16 remain tied to the unchanged font blobs listed there; they do not establish APK inclusion or release readiness.
- Next action: wait for or trigger exact-head validation on 318c9d... using the repository's supported CI path, then inspect Build, SQLite Snapshot, Follow-up Persistence and all seven Device Smoke lanes. Do not reuse prior run outcomes.

Release remains NO-GO. Merge, release and deployment remain unauthorized.


## COMMAND 07-A.2.26 — exact-head checkpoint (2026-11-12)

Product candidate SHA: `b78488c0347e1a97a7a25f56c914a48761d44a25` on `feature/command-07-a-sqlite-contract-remediation`; PR #3384 OPEN / DRAFT / UNMERGED (87 commits, 62 files at last observed refresh). This supersedes 318c9d for current product validation only.

- Commit `b78488c0347e1a97a7a25f56c914a48761d44a25` corrected the PDF test's stale VazirHarf description/sample to Vazirmatn; assertions were preserved.
- All five actual TTF OpenType name tables report Version 33.003. Source repository: `rastikerdar/vazirmatn`; bundled license: SIL OFL 1.1. Exact upstream commit/tag and source-to-binary reproducibility remain pending. SHA-256 values remain in typography contract §16.
- Follow-up Persistence run `43219196583` is SUCCESS on this exact SHA. Both file-backed Repository Persistence and Alarm Overlay close/reopen diagnostic passed. The latter exercised Snooze, disposing the first overlay/SQLite connection, reopening the same file, loading the overlay again, tapping Complete and observing notification cancellation.
- Build `43219196600`: PENDING, no jobs allocated at last poll. SQLite A-D five-cycle run `43219196466`: QUEUED. Device Smoke run `43219196537`: QUEUED. Production Loop `43219196556`: SUCCESS. Orchestrator `43219196378`: SUCCESS.
- Existing schema tests cover Missing / explicit NULL / FALSE / TRUE metadata, retired-column absence, FK constraints and malformed-source migration preservation. The exact-head SQLite workflow is not yet complete; D01-D05 are not accepted as a whole. Snapshot A-D does not independently prove all triggers/indexes, backup/restore or forced interruption/recovery.
- Earlier SHA results are historical and must not be promoted to this candidate SHA.

Release remains NO-GO. No merge, release or deployment is authorized.


## COMMAND 07-A.2.28 — current handoff (2026-11-12)

### Product candidate
- Repo: `mobinpda-lab/Arvin-clean`
- PR #3384: OPEN / DRAFT / UNMERGED; branch `feature/command-07-a-sqlite-contract-remediation`; exact HEAD `a6d2d58d87530bfa184c93220cc329b819aca809`; base SHA `8c4c23f0c2a4f9b2374a2092c931782c4455fd41`.
- Main HEAD: `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3388: OPEN / DRAFT / UNMERGED; branch `docs/wave-0-canonical-governance`.

### Recent authorized fixes
- Removed explicit VazirHarf font overrides from Task Details, Home filter UI and Quick Capture. Theme inheritance now controls those surfaces.
- Corrected stale font test APIs and Checklist helper arguments.
- Updated icon-only RollBox tests to use semantic labels and stable keys; corrected Home's visible filter count to four.
- Pinned upstream Vazirmatn source commit and exact Git blob identities in typography contract §18.

### Exact-head runs to poll
- Build: `43223035750`
- Device Smoke: `43223035920`
- SQLite Snapshot: `43223035907`
- Follow-up Persistence: `43223035880`

All were PENDING/QUEUED at the last inspection. Poll them before making another product-code commit. If any failure is source-related, fix it without weakening assertions, then establish a new candidate SHA and rerun affected gates.

### Remaining acceptance work
1. Inspect all six Regression shards and Analyze; resolve failures by evidence.
2. Inspect Debug, Staging and Release APKs and verify all five packaged fonts and SHA-256.
3. Complete seven Android Device Smoke scenarios and collect logs/screenshots.
4. Complete SQLite D01-D05; existing five-cycle Snapshot is not sufficient for all gates.
5. Validate a real generated PDF for embedded fonts, Persian shaping, ZWNJ, mixed scripts, RTL and visual rendering.
6. Verify persisted font preference across restart and overlay compatibility.
7. CODEOWNERS exists on docs branch, but main Ruleset still does not require approval or CODEOWNER review. Security setting changes require owner authorization.

Keep PRs #3384 and #3388 Draft and unmerged. No merge, release or deployment.


## COMMAND 07-A.2.28.1 — latest exact-head SQLite checkpoint (2026-11-12)

Current product SHA remains `a6d2d58d87530bfa184c93220cc329b819aca809`.

New exact-head successes:
- SQLite Snapshot Run `43223035907`, Job `131199160903`: five Close/Reopen cycles and A-D comparison passed. Artifact `13946956406`; JSON SHA-256 `0d828bfb57417da75570f39186e55c4e65fb639c50440b46f421b9520ea9c574`; archive digest `a436ec262c87fde240c4065f650d47f80c861b75d37a146840af895e52c93efc`.
- Follow-up Persistence Run `43223035880`, Job `131199161718`: file-backed persistence and real Alarm Overlay Snooze/close/reopen/Complete/notification cancellation passed.

Still poll Build Run `43223035750` (PENDING, no jobs at last poll) and Device Smoke Run `43223035920` (QUEUED). Do not dispatch duplicates while pending/queued.

Do not call D01-D05 complete from Snapshot alone: verify full schema objects, actual Backup/Restore and D05 interruption/recovery. Continue PDF validation and APK audits after the current Build workflow produces jobs/results. No merge, release or deployment.


## COMMAND 07-A.2.28.2 — current candidate handoff (2026-11-12)

Current product SHA: `551ecdc0542bb00f72c21167b4c721094b3a3cba`.

New acceptance coverage committed:
1. `45c39211ece595b23ce0ea0d3f18525cfbbe854e`: complete SQLite schema catalog, all non-system FK definitions, trigger/index inventory and retired-column assertions included in A-D snapshot comparison.
2. `7d3466f8b46ee27d2312efcd41c0fa8090dccbad`: real backup file read and restore into a different file-backed SQLite database, then close/reopen and verify Reminder/Follow-up/Person data.
3. `551ecdc0542bb00f72c21167b4c721094b3a3cba`: malformed legacy migration failure now tests recovery by repairing source and retrying schema installation on the same executor.

Poll exact-head runs:
- Build `43224398615`
- SQLite Snapshot `43224398076`
- Follow-up Persistence `43224398303`
- Device Smoke `43224398160`

All were PENDING/QUEUED at last inspection. Do not reuse `a6d2d58...` PASS results. If the new tests fail, inspect the logs and fix the underlying migration/restore behavior rather than removing assertions.


## COMMAND 07-A.2.28.3 — latest candidate handoff (2026-11-12)

Current product candidate SHA: `75737f4fb95b4357e8b6e0511ee2443c6aa5aff4`.

- `cb0b2c1b0a29cd6ac022e9bbc68701b96068e1b0`: PDF Persian acceptance sample, embedded-font/ToUnicode checks, Poppler font inspection, text extraction and PNG preview.
- `75737f4fb95b4357e8b6e0511ee2443c6aa5aff4`: APK font audit checks five expected Git blob IDs and emits actual SHA-256 and file size.

Poll exact-head runs: Build `43224808961` (PENDING, no jobs allocated), SQLite Snapshot `43224809374` (QUEUED), Follow-up Persistence `43224808860` (QUEUED), Device Smoke `43224808776` (QUEUED). Draft Review APK `43224808804` was SKIPPED.

The new D01/D04/D05 and PDF checks have not executed. Do not transfer earlier `a6d2d58...` passes. Investigate any PDF marker, text extraction or Poppler render failure rather than relaxing assertions.

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

### PDF extraction normalization follow-up — 2026-11-12

Manual extraction of the actual PDF from Run `43224808961` showed Poppler returns shaped Arabic glyphs in presentation-form code points, while the rendered PNG is visually connected and legible. Raw extraction is retained. Commit `ee200b573ef70df8101c77de2a68241192898244` now creates a second NFKC-normalized extraction artifact before semantic assertions, preserving both raw and normalized evidence. This is a harness normalization step; it does not change the PDF renderer or its font binaries. Re-run the complete PDF workflow on the current exact product SHA before claiming PDF acceptance.
