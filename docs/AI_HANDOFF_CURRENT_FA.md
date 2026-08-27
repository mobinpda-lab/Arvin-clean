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
