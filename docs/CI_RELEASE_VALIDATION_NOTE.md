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


## Wave 6.39 — Run reconciliation and release gate status (2026-10-22)

Product target SHA: `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`.

Live GitHub findings at this check:
- PR #2916 remains open and Draft; it is not merged. The latest known branch commit is `8bdb087b3ae0de9577a4c5073a63b587f9c0c99d` (documentation reconciliation commit). Submitted review list returned empty. No merge or Draft-state change was performed.
- PR #2916 diff was inspected for `.github/workflows/device-smoke.yml`, `test/device_smoke_workflow_contract_test.dart`, and `tool/validate_fast_lane.py`. The proposed `run_sql_migration` input defaults to false, maps to `RUN_SQL_MIGRATION`, and adds `sql-migration` wired to `integration_test/android_upgrade_migration_smoke_test.dart`. Contract test and Fast Lane validator assert the input/mapping. Existing Calendar and SQL Persistence input/mapping and exact-target checkout guard remain present in the reviewed diff; no weakening/removal was observed in these patch hunks.
- Build run [39773114803](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39773114803) is now completed with conclusion `cancelled`. The Release APK job [119805291482](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39773114803/job/119805291482) is also cancelled overall, although its Build APK, Verify APK, and Upload APK steps report success. A non-expired `arvin-release-apk` artifact exists (32,463,342 bytes). This is not accepted as an official deliverable: the run is cancelled, exact requested revision verification was skipped, and the live release build configuration still signs with the Debug signing config. No APK was installed or accepted as the final release in this check.
- Device Smoke run [39773114876](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39773114876) is now completed with conclusion `cancelled`. Home and Quick Capture jobs report success; SQL Migration, SQL Persistence, Calendar, Backup/Restore, and People jobs were cancelled. Artifacts for Home, Quick Capture, and Persian time picker exist, but they do not turn the overall run into a pass. These were PR-triggered jobs at PR head `6505e26484bf5d8772c91bf78a4e0b98cda75eb0`, not an exact-target workflow_dispatch acceptance run.
- Live main workflow `.github/workflows/device-smoke.yml` blob remains `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21` and still has no independent `run_sql_migration` manual-dispatch input or dispatch mapping. It does retain `inputs.target_sha` checkout and a mismatch-failing exact-SHA guard. Do not dispatch SQL Migration until authorized merge and a fresh main reread confirm the input and mapping.
- Live `android/app/build.gradle.kts` still sets `applicationId = "com.example.arvin"` and `release.signingConfig = signingConfigs.getByName("debug")`. Product-owner approval of the official application ID is not evidenced. Production signing setup, Android SDK signature verification, SHA-256 of the approved final APK, installation/launch, previous-version upgrade, and data retention/restore remain blocked or not verified. No secrets or private keys were read or changed.
- No `workflow_dispatch` run targeting `1fb3f47e76b3fd093eba8b108b745fadb35b3c69` was created. Exact-target SQL Migration acceptance remains NOT VERIFIED.

Gate status:
- PR #2916 human review and merge authorization: BLOCKED (authorized human reviewer/maintainer).
- SQL Migration input present on main: FAIL (review and authorized merge of PR #2916 required, followed by reread).
- SQL Migration on exact product target: NOT VERIFIED.
- Official application ID approval: NOT VERIFIED (product owner).
- Production signing, SDK signature validation, final APK SHA-256, install/launch, upgrade, and data retention: BLOCKED / NOT VERIFIED (release owner/operator after identity and signing are approved).
- Official APK delivery: NO-GO. The existing artifact is not accepted as official evidence.
- Release decision remains `BLOCKED — RELEASE: NO-GO`.

Next minimal action: an authorized human reviewer/maintainer must review PR #2916 and explicitly decide whether to approve and merge under repository policy. Until then, keep it open and Draft, do not dispatch a new exact-target run, and do not label the existing APK artifact official.


## Wave 6.40 — Run status reconciled by Wave 6.41 (2026-10-22)

Product target SHA: `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`.

The earlier Wave 6.40 entry was a point-in-time snapshot. The later authoritative GitHub run metadata is reconciled below in Wave 6.41: both runs have since completed with conclusion `cancelled`, so neither run is a passing acceptance result.

- PR #2916 remains OPEN, DRAFT, and unmerged. Current head is `d736b483acbce9156e757263ec001f38d63c76ca`; submitted reviews are empty and no reviewer request is pending.
- Main's live Device Smoke workflow still has no independent `run_sql_migration` dispatch input. Exact-target SQL Migration dispatch was not attempted.
- `android/app/build.gradle.kts` still uses application ID `com.example.arvin` and Debug signing for Release. These do not establish official identity or production signing.

## Wave 6.41 — Existing run finalization and SQL Migration gate (2026-10-22)

Product target SHA: `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`.

### Final run outcomes from GitHub

- Device Smoke [39774623094](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39774623094): status `completed`, conclusion `cancelled`; event is `pull_request`, head SHA `e78289cf21de7266d2c8712bbc89b197c4bbb5ba`, not the Product target SHA.
  - `Prepare selected smoke scenarios`: success.
  - `device-smoke (home)`: success.
  - `device-smoke (quick-capture)`: cancelled.
  - `device-smoke (sql-migration)`: cancelled.
  - `device-smoke (sql-persistence)`: cancelled.
  - `device-smoke (calendar)`: cancelled.
  - `device-smoke (backup-restore)`: cancelled.
  - `device-smoke (people)`: cancelled.
  - Overall result is CANCELLED, not PASS. The SQL Migration job is not accepted evidence.
- Build [39774623123](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39774623123): status `completed`, conclusion `cancelled`; event is `pull_request`, head SHA `e78289cf21de7266d2c8712bbc89b197c4bbb5ba`, not the Product target SHA.
  - `quality (analyze)`, `quality (test-0)`, `quality (test-1)`, `quality (test-2)`, `quality (test-3)`, `quality (test-4)`, `quality (test-5)`: success.
  - `apk (debug)`: cancelled.
  - `apk (release)`: cancelled.
  - Artifact query returned no artifacts. The successful quality jobs do not make the overall Build run pass or prove an APK deliverable.
- No replacement run was created. The existing runs are now final, so there is no further polling needed for these run IDs.

### PR #2916 and SQL Migration dispatch

- PR [#2916](https://github.com/mobinpda-lab/Arvin-clean/pull/2916) remains OPEN, DRAFT, and unmerged; latest head `d736b483acbce9156e757263ec001f38d63c76ca`. Review submissions are empty; GitHub reports no requested individual or team reviewers. No merge or Draft transition was performed.
- The proposed PR workflow adds `run_sql_migration` defaulting to false, maps it to `RUN_SQL_MIGRATION`, and selects `integration_test/android_upgrade_migration_smoke_test.dart`; related contract and Fast Lane checks are included in the PR diff. This proposal is not yet present on main.
- Live main workflow [device-smoke.yml](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml) blob SHA: `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21`. It contains Calendar and SQL Persistence inputs and an exact-SHA checkout guard, but no independent `run_sql_migration` input. The migration test file name appearing elsewhere in the workflow does not replace the missing dispatch input/mapping.
- No `workflow_dispatch` was attempted. Exact-target SQL Migration acceptance remains NOT VERIFIED until an authorized merge, a fresh main reread confirming the input and mapping, and one eligible dispatch with target SHA `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`, SQL Migration enabled, Calendar disabled, SQL Persistence disabled, exact checkout evidence, successful Android test, and successful final job/run conclusions.

### Official APK gates

- Live [build.gradle.kts](https://github.com/mobinpda-lab/Arvin-clean/blob/main/android/app/build.gradle.kts) blob SHA `aaeea7506885814cc4c4a65ac6559872a80146a8` sets `applicationId = "com.example.arvin"` and `release.signingConfig = signingConfigs.getByName("debug")`.
- Product-owner approval of the official application ID: NOT VERIFIED.
- Production signing configuration: BLOCKED.
- Android SDK signature validation for a final APK: NOT VERIFIED.
- SHA-256 of the approved final APK: NOT VERIFIED.
- Installation and launch of that same APK: NOT VERIFIED.
- Upgrade from the previous version and proof that user data remains intact: NOT VERIFIED.
- No secrets or private keys were read or exposed; no user data was reset. No artifact from the cancelled Build run is accepted as an official APK.

### Gate summary and next action

- PR review and merge authorization: BLOCKED; responsible party is an authorized human reviewer/maintainer. No known authorized reviewer was available from the current GitHub review-request data, so no speculative reviewer request was sent.
- SQL Migration input on main: FAIL.
- Exact-target SQL Migration acceptance: NOT VERIFIED.
- Official APK release gates: BLOCKED / NOT VERIFIED.
- Release decision remains `BLOCKED — RELEASE: NO-GO`.

Smallest next action: an authorized human reviewer/maintainer must review PR #2916 and explicitly decide whether it may be approved and merged under repository policy. Until then, keep the PR open and Draft and do not dispatch SQL Migration. After authorized merge, re-read main before a single exact-target dispatch.



## Wave 6.43 — Build completion and Device Smoke still active (2026-10-22)

Product target SHA: `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`.

### Existing run reconciliation

- Build [39775672945](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39775672945) is `completed / success` at PR-triggered head `16f73f515bd645f0a4d299df9f441d10f4d1279c`, not the Product target SHA. All seven quality jobs and both APK jobs (`apk (release)`, `apk (debug)`) completed successfully.
- Non-expired Build artifacts exist: `arvin-release-apk` (32,463,351 bytes; artifact ID `12425066173`) and `arvin-debug-apk` (92,600,563 bytes; artifact ID `12424547910`). They are downloadable GitHub Actions artifacts, but are not accepted as official APKs because this run is PR-head evidence and live Gradle config still uses Debug signing for Release. The Build workflow's APK check only asserts that the file exists; no Android SDK certificate verification or final APK SHA-256 recording gate was found in the inspected workflow.
- Device Smoke [39775673103](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39775673103) has no final conclusion. The run API continues to report `queued` while the latest job list reports two jobs `in_progress`; therefore record the run as ACTIVE / NOT FINAL rather than infer a conclusion. Its head SHA is `16f73f515bd645f0a4d299df9f441d10f4d1279c`, not the Product target.
- Device Smoke jobs `home`, `quick-capture`, `sql-persistence`, and `sql-migration` are `success`. The SQL Migration job [119814398271](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39775673103/job/119814398271) logs `legacy storage upgrades into canonical SQL and survives a fresh store` and `All tests passed!`; SQL Persistence job [119814398150](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39775673103/job/119814398150) is also successful. These results are PR-head evidence only and do not satisfy exact-target acceptance.
- At this check, `backup-restore` and `people` remain `in_progress`, while `calendar` is `queued`. Non-expired screenshot/time-picker artifacts exist for Home, Quick Capture, and Persian time picker. Since the overall Device Smoke has no final conclusion, it is not a PASS. No cancellation or replacement run was initiated.
- The old Build and Device Smoke runs 39774623123 and 39774623094 remain historical cancelled runs; they are superseded for current run-status tracking by the two runs above, not retroactively accepted.

### PR and manual SQL Migration gate

- PR [#2916](https://github.com/mobinpda-lab/Arvin-clean/pull/2916) remains OPEN, DRAFT, and unmerged at head `16f73f515bd645f0a4d299df9f441d10f4d1279c`. Submitted review list is empty. No merge or Draft-state change was performed.
- Live main workflow [device-smoke.yml](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml), blob `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21`, includes the migration test path in its general scenario logic but does not define an independent `run_sql_migration` workflow_dispatch input/mapping. Do not attempt the requested manual exact-target dispatch until an authorized human reviews/merges PR #2916 and main is re-read to verify the final contract.
- No `workflow_dispatch` run targeting `1fb3f47e76b3fd093eba8b108b745fadb35b3c69` was created. Exact-target SQL Migration acceptance remains NOT VERIFIED.

### Official APK gates

Live main file references at this check:
- [android/app/build.gradle.kts](https://github.com/mobinpda-lab/Arvin-clean/blob/main/android/app/build.gradle.kts), blob `aaeea7506885814cc4c4a65ac6559872a80146a8`: application ID remains `com.example.arvin`; Release uses `signingConfigs.getByName("debug")`.
- [pubspec.yaml](https://github.com/mobinpda-lab/Arvin-clean/blob/main/pubspec.yaml), blob `b8d5ca0c31405fe14a5d3c9126eab507725bf6c5`: version `1.0.1+2`.
- [build.yml](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/build.yml), blob `a49cc2ff35e1dad0bb434ebe31a2593ca6a510ce`: supports `target_sha` and exact-SHA guard when manually dispatched, builds and uploads APKs, but does not prove production signing, SDK certificate verification, or APK SHA-256 recording.
- [release.yml](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/release.yml), blob `c5f45b9b1d66db22a585b0637a24537aeb95d098`: creates a GitHub Release/tag; this alone is not a secure APK signing/build gate.

Gate status:
- Product-owner approval of official application ID: NOT VERIFIED.
- Production Release signing: BLOCKED (Debug signing is configured).
- APK built on exact Product target SHA: NOT VERIFIED.
- Android SDK signature verification and SHA-256 of approved final APK: NOT VERIFIED.
- Installation/launch of the same approved APK, previous-version upgrade, and user-data retention: NOT VERIFIED.
- No secrets/private keys were accessed or disclosed; no user data was reset.
- Release decision remains `BLOCKED — RELEASE: NO-GO`.

Next action: allow Device Smoke run 39775673103 to finish without creating a replacement. Once final, append a reconciliation of its final result. In parallel, an authorized human maintainer must review PR #2916; after any authorized merge, re-read main's workflow before any single exact-target SQL Migration dispatch.
