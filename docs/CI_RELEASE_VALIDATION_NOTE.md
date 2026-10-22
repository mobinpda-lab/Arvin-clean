# CI Release Validation Note

**Updated:** 2026-10-22

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

## Wave 6.10 — Exact-SHA acceptance status

**Product target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`

**Release decision:** `BLOCKED — RELEASE: NO-GO`

### Live pull-request state (checked 2026-10-22)

| PR | HEAD SHA | State | Purpose / boundary |
|---|---|---|---|
| #2895 | `6c94c7084c8f95d7adacf0c2863decd267a48efc` | OPEN, Draft, unmerged | Calendar diagnostic; not the product target |
| #2903 | `1fb3f47e76b3fd093eba8b108b745fadb35b3c69` | OPEN, Draft, unmerged | Product target SHA |
| #2898 | `1a800e13b02b54a9c503541da020f72b4940a99c` | OPEN, Draft, unmerged | Release-signing guard; separate signing blocker |
| #2906 | `7ad84215663bee9831a5715512f702c8153e8f6e` | OPEN, Draft, unmerged | Earlier Device Smoke workflow proposal |
| #2911 | `867b6d11f4a29f87008c21af7a2caed773097ed7` | OPEN, Draft, unmerged | Selective exact-SHA Calendar/SQL dispatch proposal |

No protected PR was merged by this validation.

### Exact-SHA gate ledger

The following status labels are used consistently: `PASS`, `FAIL`, `IN PROGRESS`, `NOT RUN`, `NOT VERIFIED`, `BLOCKED`, `NOT DETERMINED`.

| Gate | Status | Run / Job | Product SHA | Actual checkout SHA | Evidence / limitation |
|---|---|---|---|---|---|
| Build workflow dispatch capability | PASS | Workflow definition only | `1fb3f47e76b3fd093eba8b108b745fadb35b3c69` | N/A | `build.yml` on `main`, blob `a49cc2ff35e1dad0bb434ebe31a2593ca6a510ce`, has `workflow_dispatch.inputs.target_sha`, checkout ref wiring, and a conditional exact-SHA check. [Workflow](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/build.yml) |
| Build execution on exact target | BLOCKED | No valid manual dispatch recorded | `1fb3f47e76b3fd093eba8b108b745fadb35b3c69` | NOT VERIFIED | The connected GitHub actions available in this session did not expose a workflow-dispatch operation. Existing PR-triggered run below is not a substitute. |
| PR #2903 Build CI | PASS (PR CI only) | Run [39674729732](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39674729732); Debug job `119481468309`; Release-variant job `119481468461`; Analyze job `119481468699` | `1fb3f47e76b3fd093eba8b108b745fadb35b3c69` (PR HEAD) | NOT VERIFIED | CI completed successfully and produced artifacts. Exact-SHA verification step was `SKIPPED`, so this run is not exact-target acceptance. |
| PR #2903 Debug APK artifact | PASS (CI artifact exists) | Run [39674729732](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39674729732), job `119481468309` | PR HEAD above | NOT VERIFIED | Artifact `arvin-debug-apk`, 92,593,900 bytes, exists and is not expired. This is a CI artifact, not an official release. |
| PR #2903 Release-variant APK artifact | PASS (CI artifact exists) | Run [39674729732](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39674729732), job `119481468461` | PR HEAD above | NOT VERIFIED | Artifact `arvin-release-apk`, 32,460,984 bytes, exists and is not expired. Artifact name does not prove release signing or release readiness. |
| Device Smoke workflow on default branch | BLOCKED | Definition only | `1fb3f47e76b3fd093eba8b108b745fadb35b3c69` | N/A | `device-smoke.yml` on `main`, blob `e5cd465a7d5a83be21a55535f7a0b3071ceeec45`, has a bare `workflow_dispatch` with no `target_sha`, `run_calendar`, or `run_sql_persistence` inputs. [Workflow](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml) |
| PR #2911 workflow design | PASS (static review only) | PR [#2911](https://github.com/mobinpda-lab/Arvin-clean/pull/2911), HEAD `867b6d11f4a29f87008c21af7a2caed773097ed7`; workflow blob `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21` | Intended target input | Not yet dispatched with target | Defines required `target_sha`, boolean `run_calendar` and `run_sql_persistence`, a selective matrix, and exact checkout validation. It is not on `main`; no merge was performed. |
| PR #2911 Build CI | PASS (PR CI only) | Run [39742261796](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39742261796); Release job `119702109102`; Debug job `119702109225` | PR #2911 HEAD `867b6d11f4a29f87008c21af7a2caed773097ed7` | Synthetic merge SHA `128aaa042f669098ea5829b9e4ebf6c0ee77d5d5` for PR checkout; exact check `SKIPPED` | Build jobs passed and CI APK artifacts exist, but this is not product-target acceptance. |
| PR #2911 Device Smoke | IN PROGRESS at last observation | Run [39742261790](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39742261790); Prepare job `119702108384`; Calendar job `119702142521`; SQL Persistence job `119702142585` | PR #2911 HEAD `867b6d11f4a29f87008c21af7a2caed773097ed7` | PR-run checkout, not the requested product target | This PR-triggered run selects the default full seven-scenario matrix. Calendar was queued and SQL Persistence had not reached its test step at the last observation. It is not a selective exact-SHA dispatch. |
| Calendar exact-target acceptance | NOT VERIFIED | No authorized exact-target Device Smoke run | `1fb3f47e76b3fd093eba8b108b745fadb35b3c69` | NOT VERIFIED | Prior Calendar PR CI is useful diagnostic evidence only. It does not prove every acceptance criterion on the target SHA. |
| SQL Persistence exact-target acceptance | NOT VERIFIED | No authorized exact-target Device Smoke run | `1fb3f47e76b3fd093eba8b108b745fadb35b3c69` | NOT VERIFIED | Prior SQL Persistence CI passed on a PR workflow checkout, not in the requested exact-target dispatch. |
| Release signing, installation, upgrade, and data preservation | BLOCKED | Separate release gates | Target SHA must be tested | NOT VERIFIED | PR #2898 reports that its current-head Build failed closed because `ARVIN_RELEASE_KEYSTORE_BASE64` is missing. The production application ID also requires owner approval. No signing secret was changed and no official APK was published. |

### Calendar and SQL acceptance coverage

The target-SHA test source was inspected, but source inspection is not execution evidence.

| Acceptance criterion | Current evidence in test source | Product status |
|---|---|---|
| Follow-up without `reminderDate` creates no standalone card | Projection unit test asserts history-only Follow-up produces no projection; UI/device behavior is not separately asserted there | NOT VERIFIED until valid target-SHA execution |
| `nextFollowUp` alone creates no card | Unit test proves `nextFollowUp` is not separately projected alongside a valid reminder; the nextFollowUp-only/no-reminder case is not explicit | NOT VERIFIED |
| Valid reminder creates exactly one card with ID `reminder-card-followup:calendar-smoke-task:calendar-smoke-follow-up` | Calendar integration test seeds a valid reminder and expects one keyed card | NOT VERIFIED until valid target-SHA execution |
| Cancelling the time picker preserves stored `reminderDate` | Calendar integration test compares SQLite reminder timestamp before and after cancellation | NOT VERIFIED until valid target-SHA execution |
| Returning from the edit form does not remove the card | Calendar integration test expects the card after return | NOT VERIFIED until valid target-SHA execution |
| Independently dated Task remains present | Projection unit tests assert independent due-date projection and coexistence with a separately dated Follow-up; UI/device persistence is not asserted there | NOT VERIFIED until valid target-SHA execution |
| No duplicate card is created | Projection unit test checks equivalent task/follow-up timestamps deduplicate; Calendar integration test expects one card for the seeded case | NOT VERIFIED until valid target-SHA execution |
| SQL persistence succeeds | Dedicated Android SQL persistence test exists and checks save/load cycle | NOT VERIFIED until valid target-SHA execution |

Sources:
- [Calendar interaction test at target SHA](https://github.com/mobinpda-lab/Arvin-clean/blob/1fb3f47e76b3fd093eba8b108b745fadb35b3c69/integration_test/calendar_card_interaction_test.dart)
- [SQL persistence test at target SHA](https://github.com/mobinpda-lab/Arvin-clean/blob/1fb3f47e76b3fd093eba8b108b745fadb35b3c69/integration_test/android_sql_persistence_smoke_test.dart)

No Calendar production code was changed. No root cause is inferred from missing UI assertions alone.

### Required next actions

1. An authorized repository operator should dispatch Build from `main` with `target_sha=1fb3f47e76b3fd093eba8b108b745fadb35b3c69`. The workflow dispatch was not started from this session because the connected GitHub tool did not expose that action.
2. A repository maintainer must review PR #2911 and explicitly authorize how the exact-SHA Device Smoke definition becomes available on the default branch. Do not merge it without approval.
3. Once the authorized workflow definition is available, run only Calendar and SQL Persistence with the exact target SHA; confirm `CHECKOUT_SHA`, `EXACT_TARGET_SHA`, Run/Job IDs, and final job conclusions.
4. Add evidence-based tests for the uncovered Calendar cases, without speculative production-code changes.
5. Re-evaluate release signing, production application ID, install, upgrade, and data-preservation gates independently.

**Release status remains: `BLOCKED — RELEASE: NO-GO`.**
