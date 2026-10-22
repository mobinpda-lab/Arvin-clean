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
