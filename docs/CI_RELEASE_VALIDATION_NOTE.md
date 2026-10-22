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


## Wave 6.14 live evidence review

**Reviewed:** 2026-10-22  
**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**Decision:** `BLOCKED — RELEASE: NO-GO`

### Existing Build evidence (historical run, not exact-SHA acceptance)

- Run [39674729732](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39674729732) completed successfully. Required jobs observed: `quality (analyze)`, all six test shards (`test-0` through `test-5`), `apk (debug)`, and `apk (release)`.
- Actual checkout in all nine required jobs was merge commit `ee013f003f9c2fac9b78590d0ffa153f8a20cedf`, with log message: `Merge 1fb3f47e76b3fd093eba8b108b745fadb35b3c69 into d9fb7a247037762216662a20fb32028ecc8a0f6b`. This is not the requested Product Target SHA.
- `Verify exact requested revision` was `SKIPPED` in Analyze and both APK jobs, and the workflow definition makes the step conditional on a non-empty `workflow_dispatch` input. Therefore this successful run does **not** prove an exact-SHA build.
- Artifacts from this run: [arvin-release-apk, artifact 12381732028](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39674729732), [arvin-debug-apk, artifact 12381093796](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39674729732). Artifact existence does not prove release signing or product acceptance.
- Build workflow definition blob SHA on `main`: `a49cc2ff35e1dad0bb434ebe31a2593ca6a510ce`. It supports `target_sha` for manual dispatch. No direct workflow-dispatch action is available in the connected GitHub tools in this execution, so no new Build run was started: new exact-SHA Build is `NOT RUN`; dispatch capability is `BLOCKED`.

### Existing Device Smoke evidence (not exact-SHA acceptance)

- Run [39674729325](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39674729325) completed successfully for all seven existing lanes: Calendar, SQL Persistence, SQL Migration, Backup/Restore, Home, Quick Capture, and People.
- Logs for all seven jobs show checkout of `refs/remotes/pull/2903/merge`, resolved to merge commit `ee013f003f9c2fac9b78590d0ffa153f8a20cedf`, not the requested Product Target SHA.
- Device Smoke workflow definition blob SHA on `main`: `e5cd465a7d5a83be21a55535f7a0b3071ceeec45`. It has no `target_sha`, `run_calendar`, `run_sql_persistence`, or exact-checkout verification inputs. Exact-SHA Device Smoke remains `BLOCKED`; acceptance on the target SHA remains `NOT VERIFIED`.
- PR [#2911](https://github.com/mobinpda-lab/Arvin-clean/pull/2911) and PR [#2906](https://github.com/mobinpda-lab/Arvin-clean/pull/2906) are open Draft proposals for the dispatch path. Neither was merged or changed in this wave.

### Calendar and SQL acceptance status

- Existing Calendar integration test: [calendar_card_interaction_test.dart](https://github.com/mobinpda-lab/Arvin-clean/blob/1fb3f47e76b3fd093eba8b108b745fadb35b3c69/integration_test/calendar_card_interaction_test.dart). The current test covers a seeded Follow-up with a valid `reminderDate`, expected card key `reminder-card-followup:calendar-smoke-task:calendar-smoke-follow-up`, editor/time-picker interaction, cancel preserving the stored instant, card persistence after return, and task completion. The inspected test does not establish all seven requested Calendar criteria. Criteria not proven by a dedicated assertion and valid exact-SHA run remain `NOT VERIFIED`.
- Existing SQL smoke test: [android_sql_persistence_smoke_test.dart](https://github.com/mobinpda-lab/Arvin-clean/blob/1fb3f47e76b3fd093eba8b108b745fadb35b3c69/integration_test/android_sql_persistence_smoke_test.dart). The old smoke run's SQL lane passed on the merge commit, not the exact target SHA. SQL acceptance on the target SHA remains `NOT VERIFIED`.
- No root cause is inferred from these gaps: `NOT DETERMINED`.

### Release blockers

- On the target SHA, `android/app/build.gradle.kts` has `applicationId = "com.example.arvin"`; final product ID approval is not evidenced here.
- The same file configures the Release build with debug signing. No approved dedicated release-signing evidence was established in this wave. Secret contents were not accessed or changed.
- Final APK signature, final-file SHA-256, installation, upgrade, and data retention are not verified for a release candidate.
- Release remains `BLOCKED — RELEASE: NO-GO`.

### Wave 6.14 actions and limitations

- Inspected live PRs #2903, #2911, #2906, #2898, and #2895; inspected `main` workflow definitions and target-SHA build configuration; fetched job logs for all nine Build jobs and all seven Device Smoke jobs.
- No new workflow run was dispatched because the connected GitHub tools expose no workflow-dispatch operation. No PR was merged, promoted from Draft, or otherwise modified. No production code or secrets were changed.
- This section records the actual evidence and limitations of Wave 6.14. It does not replace or rewrite prior historical evidence.
