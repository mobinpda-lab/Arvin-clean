# ARVIN Changelog — 2026-10-30

## Issue #823 — canonical product contract registration

This entry records the governing product decisions for Reminder-only scheduling, Follow-up history, gestures, Calendar actions, and typography. Registration of the contract is not, by itself, evidence that every legacy consumer has been removed or that release acceptance has passed.

### Canonical model and scheduling

- Retire **Next Follow-up** and the **`followUpEnabled`** column from active schema, models, DTOs, persistence, UI, queries, APIs, tests, and documentation. Retained historical compatibility data must not be read as active scheduling state.
- Use **Reminder-only** scheduling for all future actions. A Follow-up Record represents only a real action completed in the past and must carry its actual `completedAt` timestamp. Opening the Add Follow-up form must not create a record until the user saves it.
- Do not reintroduce future scheduling through Follow-up fields, aliases, or projections.

### Canonical gestures

- **Task-list swipe:** `ثبت پیگیری` opens the Add Follow-up form; it does not immediately create a Follow-up Record. Task-list swipe choices must not contain `انتقال به تقویم گوشی`.
- **Calendar swipe/gesture actions:** Edit, Trash/Delete, and Device Calendar Sync belong exclusively to Calendar items and remain isolated from Task-list swipe choices.

### Typography

- **Vazirmatn** is the exclusive application UI font. It must be registered and bundled inside every distributable APK.
- **System Default** and legacy font-family fallbacks/options are prohibited.
- CI Font Gate must inspect the built APK for Regular, Medium, and Bold Vazirmatn assets and fail if legacy font or System Default source references remain.
- PDF output must use Vazirmatn assets and retain the separate PDF embedding and Persian shaping acceptance checks.

### Acceptance status

- This changelog entry registers the canonical contract; it does not certify a repository-wide Next Follow-up / `followUpEnabled` purge.
- Exact-head Analyze, all six test shards, Debug/Release APK Font Gate, Calendar Provider CRUD, and remaining Issue #823 acceptance gates must pass with retained artifacts before release consideration.
- **Release:** `BLOCKED — RELEASE: NO-GO`.


## 2026-11-01 — Issue #823 full product audit and Staging path correction

- Added a complete canonical product baseline and evidence-led audit ledger in `docs/qa/ARVIN_FULL_PRODUCT_AUDIT_2026-11-01.md`; the ledger distinguishes implementation evidence from runtime/target-SHA acceptance.
- Corrected Staging APK verification, font audit, manifest and upload paths to follow the repository-level Gradle build directory configured by `android/build.gradle.kts` (`$GITHUB_WORKSPACE/build/app/outputs/apk/staging/app-staging.apk`).
- Added `test/build_staging_artifact_path_contract_test.dart` to prevent regression to the incorrect `android/app/build` location.
- No user database was modified; no destructive schema migration was attempted because live database emptiness and data-preservation requirements have not been established.
- Exact-head CI after these commits is pending. Staging v2/v3 signature, `APK_DEBUGGABLE=false`, and Release Manifest remain NOT VERIFIED until the new workflow provides raw evidence.
- Release remains **BLOCKED — RELEASE: NO-GO**.

- Implemented configurable Task-list “ثبت پیگیری” for either swipe direction: Settings exposes and persists the action; selecting it opens FollowUpEntryPage and writes a record only after explicit Save. Added left/right and no-auto-write regression tests. Exact-head CI validation is pending.
