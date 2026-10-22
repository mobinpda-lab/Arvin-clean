# CI Release Validation Note

**Updated:** 2026-09-08

Arvin v1 release validation consumes repository-owned build inputs. Release workflows must not regenerate or patch critical Android/Gradle configuration at runtime.

Canonical reproducible inputs:
- Flutter SDK: `3.47.0`
- dependency graph: committed `pubspec.lock`, resolved with `flutter pub get --enforce-lockfile`
- Android project: committed `android/` configuration and Gradle wrapper
- Gradle: `9.3.1`
- Android Gradle Plugin: `9.1.0`
- Kotlin Android plugin: `2.4.0`
- Java/JVM target: `17`
- core-library desugaring: `com.android.tools:desugar_jdk_libs:2.1.5`
- VazirHarf source revision: `3cbc943b9fb9107baa77008b3e96b3c3e40e9ed8`

`Arvin Build`, `Arvin Device Smoke`, `Arvin Release Closure`, and `Arvin Final Head Release Validation` must validate these tracked inputs directly. Dependency resolution must fail on lock incompatibility and must not rewrite `pubspec.lock` silently.

Android SDK compile/min/target values remain provided by the pinned Flutter 3.47.0 Gradle integration referenced by the tracked Android project; changing Flutter or the Android toolchain requires explicit lock/toolchain revalidation.

This release-engineering contract does not change Task, Reminder, FollowUp, Calendar, migration, storage, or production save semantics.


## Wave 6.37 — SQL Migration exact-target gate (2026-10-22)

Product target SHA: `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`.

Current verified state:
- PR #2916 remains OPEN and DRAFT, unmerged. Head at inspection: `57a23d6cc8c11cb6502314984fbd5c0c280f7dce`. Submitted review list was empty. Human review/authorization is still required before merge.
- PR CI evidence is not exact-target acceptance: [Device Smoke run 39769360693](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39769360693) and [Build run 39769361490](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39769361490) were triggered by `pull_request` at PR head `57a23d6cc8c11cb6502314984fbd5c0c280f7dce`, not by `workflow_dispatch` at the Product target SHA.
- The PR SQL Migration job [119793286039](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39769360693/job/119793286039) ran `legacy storage upgrades into canonical SQL and survives a fresh store` on Android and logged `All tests passed!`. This is PR-head evidence only.
- The live `main` workflow [device-smoke.yml](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml) does not define the `run_sql_migration` workflow_dispatch input and does not select the SQL Migration scenario for manual dispatch. Exact-target migration acceptance is therefore BLOCKED and NOT VERIFIED.
- No `workflow_dispatch` run was created. Do not mark the exact-target SQL Migration gate PASS until main contains the approved input and a run records `CHECKOUT_SHA` / `EXACT_TARGET_SHA` equal to the Product target, a successful Android migration test, and successful final job/run conclusions.

Required next actions:
1. Human reviewer/authorized maintainer: review and approve PR #2916, then merge only under repository policy.
2. Authorized Actions operator: after merge, re-read `main/.github/workflows/device-smoke.yml`; if `run_sql_migration` is still absent or not wired to `integration_test/android_upgrade_migration_smoke_test.dart`, stop and report the blocker. Otherwise dispatch once with target SHA `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`, `run_sql_migration=true`, `run_calendar=false`, and `run_sql_persistence=false`.
3. Release owner: separately approve the official application ID and configure/verify production signing, installation, previous-version upgrade, and data retention. Debug-signed APKs are not approved official deliverables.

Release decision remains: `BLOCKED — RELEASE: NO-GO`.


## Wave 6.38 — Live reconciliation (2026-10-22)

Product target SHA: `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`.

Live GitHub findings at this check:
- Repository default branch is `main`; main's current base SHA observed for PR #2916 is `264bc7cb31ed19b15254d48926ef9c15f9a67f08`.
- PR #2916 remains OPEN, DRAFT, and unmerged. Current PR head is `6505e26484bf5d8772c91bf78a4e0b98cda75eb0`. Submitted review list remains empty. No ready-for-review transition or merge was performed.
- Current PR diff adds the independent `run_sql_migration` manual input (default false), passes it through `RUN_SQL_MIGRATION`, and appends scenario `sql-migration` using `integration_test/android_upgrade_migration_smoke_test.dart`. Contract test and Fast Lane validator assert the input/mapping. Existing Calendar and SQL Persistence inputs/mappings are retained in the diff; no scenario-removal change appears in the reviewed patch.
- Main's live `.github/workflows/device-smoke.yml` blob is `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21`; it still lacks the `run_sql_migration` manual-dispatch input and dispatch mapping. The workflow does retain exact-target checkout using `inputs.target_sha` and the mismatch-failing checkout guard. The requested manual SQL Migration dispatch must not be attempted against this main version.
- Existing PR-triggered run [Device Smoke 39773114876](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39773114876) is still in progress at the latest check. Its SQL Migration job [119805331974](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39773114876/job/119805331974) was queued, not completed. Other jobs also remained queued or in progress. This is PR-head CI, not exact-target acceptance.
- Existing PR-triggered Build run [39773114803](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39773114803) had release/debug APK jobs in progress at the latest check; it is not evidence of a completed official APK.
- Live `android/app/build.gradle.kts` blob `aaeea7506885814cc4c4a65ac6559872a80146a8` still sets `applicationId = "com.example.arvin"` and `release.signingConfig = signingConfigs.getByName("debug")`. Official application ID approval and production signing remain unverified/blocked. No signing secrets or private keys were read.
- No `workflow_dispatch` run targeting `1fb3f47e76b3fd093eba8b108b745fadb35b3c69` was created. Therefore there is no exact-target Android migration result to mark PASS.
- This Wave's documentation change is recorded by the commit that updates this file; reread and verify this section from GitHub before reporting completion.

Gate status:
- PR human review / merge authorization: BLOCKED (responsible: authorized human reviewer/maintainer).
- `run_sql_migration` input on main: FAIL (responsible: PR #2916 must be reviewed and lawfully merged, then main rechecked).
- Exact-target SQL Migration: NOT VERIFIED (responsible: authorized Actions operator after main workflow is updated).
- Official application ID: NOT VERIFIED (responsible: product owner must explicitly approve).
- Production signing, SDK signature verification, official APK SHA-256, installation, upgrade and data-retention proof: BLOCKED / NOT VERIFIED (responsible: release owner/operator after identity and signing are approved).
- Release decision remains `BLOCKED — RELEASE: NO-GO`.

Next minimal action: an authorized human must review PR #2916 and decide whether to approve/merge it. Until that happens, do not dispatch a new run and do not produce or publish a new official APK.
