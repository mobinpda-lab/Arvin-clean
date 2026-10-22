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


## Wave 6.04 — Exact-SHA validation snapshot (2026-10-22)

Product target SHA: `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`.
The live HEAD of PR #2903 was checked and still equals this target SHA. PRs #2895, #2903, #2898, and #2906 were all OPEN, Draft, and unmerged at the time of inspection.

### Workflow repair evidence
- Device Smoke workflow PR #2906 HEAD / workflow-definition SHA: `1ec45ccd2428a4c44d3ad534253811f8eb2005d7`.
- Workflow file: `.github/workflows/device-smoke.yml`, blob SHA at that revision: `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21`.
- Run [39735174265](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39735174265), event `pull_request`, was still active at inspection. Prepare matrix Job [119679064529](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39735174265/job/119679064529) succeeded; quick-capture Job 119679101914 succeeded; home Job 119679101782 and SQL Persistence Job 119679101807 were in progress; Calendar Job 119679101774 was queued. This is workflow-branch CI, not an exact-product-SHA run.
- The matrix preparation log shows the seven default PR scenarios were emitted using the valid `{include: ...}` matrix object. No final workflow conclusion was available at this snapshot.

### Exact-SHA evidence boundary
- Build Run [39669037892](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39669037892) completed successfully, but its event was `pull_request`, run/head SHA was `38d3424a4e051c299add47f3d5011b9b4c14cf4a`, and every Job's `Verify exact requested revision` step was skipped. This is not valid proof of Build on the target SHA.
- Device Smoke Run [39669037902](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39669037902) completed successfully on the same PR event SHA `38d3424a4e051c299add47f3d5011b9b4c14cf4a`. Calendar Job [119462154015](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39669037902/job/119462154015) and SQL Persistence Job [119462153449](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39669037902/job/119462153449) passed on that run, but it is not exact-SHA acceptance for `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`.
- The default-branch Device Smoke workflow definition is at SHA `e5cd465a7d5a83be21a55535f7a0b3071ceeec45` and does not currently declare a `target_sha` input. The updated definition with `target_sha` is still on Draft PR #2906. The available GitHub tool connection does not expose a workflow-dispatch action, so no manual exact-SHA Device Smoke run was initiated.
- The default-branch Build workflow definition is at SHA `a49cc2ff35e1dad0bb434ebe31a2593ca6a510ce` and declares optional `target_sha` plus an exact-revision check for manual dispatch, but this inspection did not initiate a manual dispatch. Build on the exact target SHA remains `NOT VERIFIED`.

### Acceptance status
- Exact-SHA Build: `NOT VERIFIED`.
- Exact-SHA Device Smoke (Calendar and SQL Persistence): `NOT VERIFIED`.
- Full Calendar A/B/C acceptance including SQLite, application State, Projection, active date/range, and Widget comparison: `NOT VERIFIED`; failure stage remains `NOT DETERMINED`.
- Release remains `BLOCKED — RELEASE: NO-GO`. No signing secrets were changed and no official APK was published.

Next action: allow Run 39735174265 to reach a terminal result, then use an authorized GitHub Actions workflow-dispatch capability to run Build with `target_sha=1fb3f47e76b3fd093eba8b108b745fadb35b3c69`. Before exact-SHA Device Smoke can be dispatched, the `target_sha`-capable workflow definition must be available to the dispatch mechanism without merging protected PR #2906. Keep all four PRs Draft and unmerged.
