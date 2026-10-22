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


## Wave 6.15 execution attempt and live status

**Reviewed:** 2026-10-22  
**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**Decision:** `BLOCKED — RELEASE: NO-GO`

### Fresh preflight

- Confirmed Product Target SHA remains `1fb3f47e76b3fd093eba8b108b745fadb35b3c69` using the commit endpoint.
- PR [#2914](https://github.com/mobinpda-lab/Arvin-clean/pull/2914) remains open, Draft, and unmerged. Its Wave 6.14 documentation commit remains `b2220826aa25e883bdebdf45287d0a4d142ff025`; no merge or PR-state change was performed.
- Re-read `.github/workflows/build.yml` on `main`. The workflow file blob SHA remains `a49cc2ff35e1dad0bb434ebe31a2593ca6a510ce`; it defines `workflow_dispatch` and a `target_sha` input.
- Re-read `.github/workflows/device-smoke.yml` on `main`. The workflow file blob SHA remains `e5cd465a7d5a83be21a55535f7a0b3071ceeec45`; it does not define `target_sha`, `run_calendar`, or `run_sql_persistence`.
- The available commit-associated workflow-run query returns the known historical runs, including Build `39674729732` and Device Smoke `39674729325`. This endpoint is documented as PR-triggered-run-only and first-page-only, so it cannot prove the absence of every other run.

### Wave 6.15 Build execution result

- A new `workflow_dispatch` could not be initiated: the connected GitHub tools available in this session do not expose a workflow-dispatch operation. No new Run ID exists for this attempt.
- Build execution status: `NOT RUN`.
- Dispatch blocker: `BLOCKED`.
- Exact-SHA acceptance: `NOT VERIFIED`.
- Historical Build run `39674729732` is not accepted as the Wave 6.15 exact-SHA run. Its nine required job logs show checkout of merge commit `ee013f003f9c2fac9b78590d0ffa153f8a20cedf`, not `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`; `Verify exact requested revision` was `SKIPPED` in the inspected Analyze and APK jobs.
- No new job IDs, run-specific artifacts, or exact-SHA checkout evidence can be reported because no new run was created.

### Device Smoke and product acceptance

- Device Smoke remains `BLOCKED` because the current `main` workflow lacks the three required dispatch inputs and strict exact-checkout gate.
- PRs [#2911](https://github.com/mobinpda-lab/Arvin-clean/pull/2911) and [#2906](https://github.com/mobinpda-lab/Arvin-clean/pull/2906) were checked; both remain open Draft proposals and neither was merged or changed.
- Calendar criteria 1–7 and SQL criterion 8 remain `NOT VERIFIED` on the exact Product Target SHA. Existing tests and historical PR-merge CI are not substitutes for an exact-SHA run.
- No Calendar/SQL production code, workflow, secret, signing configuration, application ID, or release artifact was changed.

### Required operator action

From an authorized environment with GitHub Actions write permission, run:

```bash
gh workflow run build.yml --repo mobinpda-lab/Arvin-clean \
  --ref main \
  -f target_sha=1fb3f47e76b3fd093eba8b108b745fadb35b3c69

gh run list --repo mobinpda-lab/Arvin-clean \
  --workflow build.yml --branch main --limit 10
```

Record the newly returned Run ID, watch that exact run to completion, then inspect every required job log. Accept only if the requested input, Product Target SHA, and each required job's actual checkout SHA match exactly and `Verify exact requested revision` ran successfully. Do not reuse a historical run ID.

For Device Smoke, first review and authorize the minimal workflow change in PR #2911 or #2906; do not merge or change Draft status without explicit approval.

### Change record

This section was appended to the existing Wave 6.14 documentation on the same review branch. It preserves the prior record and adds the Wave 6.15 preflight and execution limitation. No production code or workflow definition was modified.

## Wave 6.18 exact-SHA Build evidence

**Reviewed:** 2026-10-22  
**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**Decision:** `BLOCKED — RELEASE: NO-GO`

### Existing exact-SHA Build run found and evaluated

- Build was **not dispatched again in Wave 6.18** because a completed, successful `workflow_dispatch` run for the exact requested target already exists: [Run 39681652761](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761).
- Run metadata: workflow `.github/workflows/build.yml`, workflow ID `332566923`, event `workflow_dispatch`, status `completed`, conclusion `success`, branch `main`, created/started `2026-10-21T21:47:55Z`, completed/updated `2026-10-21T21:54:22Z`.
- The run display title is `Arvin Build (1fb3f47e76b3fd093eba8b108b745fadb35b3c69)`. The run-level `head_sha` is the dispatch ref commit `d9fb7a247037762216662a20fb32028ecc8a0f6b`; this metadata field is **not** treated as the job checkout SHA.
- Direct logs for all nine required jobs show checkout ref and `git checkout` of `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`. In each job, `TARGET_SHA` matches that value, `Verify exact requested revision` completed successfully, and the log emitted `EXACT_TARGET_SHA=1fb3f47e76b3fd093eba8b108b745fadb35b3c69`.

### Required jobs and direct evidence

| Job | Job ID | Result |
|---|---:|---|
| `quality (analyze)` | `119505357652` | `PASS` |
| `quality (test-0)` | `119505357487` | `PASS` |
| `quality (test-1)` | `119505357527` | `PASS` |
| `quality (test-2)` | `119505357741` | `PASS` |
| `quality (test-3)` | `119505357888` | `PASS` |
| `quality (test-4)` | `119505357660` | `PASS` |
| `quality (test-5)` | `119505357629` | `PASS` |
| `apk (debug)` | `119505357573` | `PASS` |
| `apk (release)` | `119505358327` | `PASS` |

- Analyze, all six test shards, both APK build/verify/upload jobs, and all nine exact-revision verification steps completed successfully. No required job or Exact-SHA gate was `SKIPPED`.
- Artifacts attached to this same Run: [`arvin-release-apk`, artifact ID `12384962220`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761) (32,460,982 bytes) and [`arvin-debug-apk`, artifact ID `12384217697`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761) (92,593,902 bytes). Both were reported unexpired and linked to Run `39681652761`.
- Build exact-SHA gate: `PASS` for the Product Target SHA, based on the completed run's direct job logs, successful required jobs, and same-run artifacts. This is a test-build result, not authorization or evidence of an official release.

### Wave 6.18 limitations and next product gates

- No new Run was created during Wave 6.18; the existing qualifying Run was reused, avoiding unnecessary duplicate execution.
- Exact-SHA Device Smoke for Calendar and SQL remains `NOT VERIFIED`. The current `main` Device Smoke workflow lacks the required `target_sha`, `run_calendar`, `run_sql_persistence`, and exact-checkout verification gate.
- Calendar acceptance criteria not established by dedicated assertions and a valid exact-SHA device run remain `NOT VERIFIED`; SQL persistence on an Android device at the exact target remains `NOT VERIFIED`.
- Official release signing, approved final application ID, final APK signature and SHA-256, installation, upgrade, and data retention remain `NOT VERIFIED`.
- No PR was merged or promoted from Draft. No production code, workflow definition, secrets, signing configuration, or application ID was changed in this wave.

### Wave 6.18 action record

- Re-read `.github/workflows/build.yml` on `main` (blob SHA `a49cc2ff35e1dad0bb434ebe31a2593ca6a510ce`); confirmed `workflow_dispatch` and `target_sha` input.
- Checked live `main` ref (`d9fb7a247037762216662a20fb32028ecc8a0f6b`) and the Product Target commit metadata.
- Queried recent Actions runs, then inspected Run `39681652761` metadata, all nine jobs, all nine job logs, and the run's artifact list.
- Appended this evidence to the existing documentation review branch only. PR [#2914](https://github.com/mobinpda-lab/Arvin-clean/pull/2914) remains open, Draft, and unmerged. No new Build was dispatched because qualifying evidence already existed.

## Wave 6.19 — Exact-SHA Device Smoke path and Calendar/SQL evidence

**Reviewed:** 2026-10-22  
**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**Release decision:** `BLOCKED — RELEASE: NO-GO`

### Preserve Wave 6.18 Build acceptance

- Exact-SHA Build remains `PASS` based on completed Run [`39681652761`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761), event `workflow_dispatch`, conclusion `success`, and direct logs for all nine required jobs. No duplicate Build was launched.
- The Build's two artifacts remain associated with that same Run: release ID `12384962220`, debug ID `12384217697`.

### Live workflow and PR review

- Default-branch Device Smoke file: [`.github/workflows/device-smoke.yml`](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml), blob SHA `e5cd465a7d5a83be21a55535f7a0b3071ceeec45`. It has a bare `workflow_dispatch` trigger, but does **not** declare `target_sha`, `run_calendar`, or `run_sql_persistence`, and does not enforce an exact-SHA checkout for manual runs. The requested exact-SHA dispatch cannot safely be run against this current default-branch definition.
- PR [#2911](https://github.com/mobinpda-lab/Arvin-clean/pull/2911) is the best existing path and is still **open, Draft, and unmerged**. Head branch: `ci/device-smoke-exact-sha-dispatch-wave-6-08`; latest head at review: `18389a26dc62838993469a59537ea1c5b7e3c373`. Its workflow proposal blob SHA is `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21`; it adds the required three inputs, generated selective matrix, requested-SHA checkout, and fail-closed checkout verification. No duplicate PR was created.
- PR [#2906](https://github.com/mobinpda-lab/Arvin-clean/pull/2906) is also open, Draft, and unmerged, and proposes a similar workflow-only change. Its scope overlaps PR #2911; keep one reviewed implementation path rather than duplicating or merging both.
- PR [#2914](https://github.com/mobinpda-lab/Arvin-clean/pull/2914) remains open, Draft, and unmerged for documentation.

### Minimal correction to PR #2911

The earlier PR validation exposed a real contract mismatch: Run [`39742261852`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39742261852), Job `119702108783`, failed because `tool/validate_fast_lane.py` required literal YAML entries such as `scenario: home`, while the proposed workflow correctly builds a JSON `include` matrix. The dynamic matrix was not a product-code failure.

- Updated `tool/validate_fast_lane.py` on the existing PR #2911 branch to validate all seven canonical scenario-to-test mappings for either static YAML or generated JSON, and to require the manual-dispatch inputs and fail-closed exact-checkout gate. Commit: `8034faaa0e873753ff6874ea5c4a38d8af044f99`; blob SHA `fc5b6aafbbb138a09fd4c5daca8732646b7ad520`.
- Updated `test/device_smoke_workflow_contract_test.dart` on the same branch to assert the dispatch inputs, checkout ref, logged SHA, and mismatch failure. Commit/head after that change: `18389a26dc62838993469a59537ea1c5b7e3c373`; blob SHA `28e7fc6df5293cda3e5d704e3ce7d92e6005df31`.
- Validation of the Fast Lane workflow contract passed in Run [`39757680039`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680039), Job `119753756210`. The job log ends with `Arvin Fast Lane workflow contract: OK`.
- At the latest check, the Build and Device Smoke PR checks for head `18389a26dc62838993469a59537ea1c5b7e3c373` were still pending without jobs listed: Build Run [`39757680043`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680043), Device Smoke Run [`39757680037`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680037). Their final conclusions are therefore `NOT VERIFIED` at this record's time.

### Existing PR-merge Device Smoke evidence, not exact-target acceptance

Run [`39742261790`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39742261790) ran Calendar and SQL Persistence successfully, but on merge checkout SHA `128aaa042f669098ea5829b9e4ebf6c0ee77d5d5`, not Product Target SHA `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`.

- Calendar Job `119702142521`: `success`; log includes card/editor/time-picker flow, SQLite reminder preservation around cancel, completion persistence, and `All tests passed`.
- SQL Persistence Job `119702142585`: `success`; log includes `All tests passed`.
- Calendar screenshot artifact ID `12411215373`: [open artifact](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39742261790/artifacts/12411215373).
- These are useful PR integration diagnostics only. The workflow was triggered by `pull_request`, checked out merge SHA `128aaa...`, and did not execute the manual-dispatch exact-target guard. Neither job is accepted as exact-SHA product validation.

### Calendar acceptance criteria on Product Target SHA

The source test at [`integration_test/calendar_card_interaction_test.dart`](https://github.com/mobinpda-lab/Arvin-clean/blob/1fb3f47e76b3fd093eba8b108b745fadb35b3c69/integration_test/calendar_card_interaction_test.dart) covers a valid reminder's canonical card key `reminder-card-followup:calendar-smoke-task:calendar-smoke-follow-up`, editor opening, cancel preserving the exact stored reminder instant, return/back behavior with the card still present, and persisted completion. Because no valid exact-SHA Device Smoke has run, all product-level criteria remain `NOT VERIFIED` pending that run; source coverage gaps are:

1. Follow-up without `reminderDate` creates no independent card: explicit test missing.
2. `nextFollowUp` alone creates no independent reminder card: explicit test missing.
3. A valid reminder creates exactly one card with the contractual key: assertion exists (`findsOneWidget`), but exact-SHA execution remains `NOT VERIFIED`.
4. Cancelling the time picker preserves the saved reminder value: assertion exists, but exact-SHA execution remains `NOT VERIFIED`.
5. Returning from the editor does not remove the card: a return/back assertion exists, but exact-SHA execution remains `NOT VERIFIED`.
6. A task with its own independent date is preserved: explicit test missing.
7. Duplicate reminder cards are not created: explicit duplicate-count scenario missing.

No Calendar or SQL production code was changed. Add only targeted test cases for criteria 1, 2, 6, and 7 after reviewing the product's intended card-generation contract.

### SQL persistence and next action

- SQL smoke source at [`integration_test/android_sql_persistence_smoke_test.dart`](https://github.com/mobinpda-lab/Arvin-clean/blob/1fb3f47e76b3fd093eba8b108b745fadb35b3c69/integration_test/android_sql_persistence_smoke_test.dart) checks a second `TaskStore` reading saved title, description, tags, category, checklist, Follow-up identity/note, and `completed=true`. Exact-target device execution remains `NOT VERIFIED`.
- **No exact-SHA Device Smoke run was dispatched in Wave 6.19.** The connected GitHub tools do not expose a workflow-dispatch action, and the current `main` workflow lacks the required inputs. No attempt was made to bypass branch protection or treat PR CI as product acceptance.
- Required human approval: review PR #2911 and explicitly authorize its promotion/merge to `main`. This wave deliberately leaves it Draft and unmerged. Once authorized and the workflow definition is present on the default branch, an authorized operator must dispatch Device Smoke with `target_sha=1fb3f47e76b3fd093eba8b108b745fadb35b3c69`, `run_calendar=true`, and `run_sql_persistence=true`, then inspect each Job's actual `CHECKOUT_SHA`, `EXACT_TARGET_SHA`, test result, and artifacts.
- Official release signing, final application ID, final APK signature/SHA-256, installation, upgrade, and full data-retention acceptance remain `NOT VERIFIED`.

### Wave 6.19 change safety

Only CI contract validation and test assertions were updated on existing Draft PR #2911, plus this documentation record on the existing Draft documentation PR #2914. No PR was merged or promoted from Draft; no secrets, signing settings, application ID, release configuration, or production Calendar/SQL code were changed.

### Wave 6.19 CI status refresh

At the latest live query on 2026-10-22 at approximately 09:45 UTC, the PR validation runs had advanced beyond their initial queue state but had not completed:

- [Device Smoke PR Run `39757680037`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680037): overall `IN PROGRESS`/queued. Matrix preparation Job `119754299800` passed and generated all seven scenarios. Jobs `119754340995` (quick-capture) and `119754341005` (home) were `IN PROGRESS`; jobs `119754340922` (people), `119754340929` (sql-persistence), `119754341027` (backup-restore), `119754341045` (calendar), and `119754341050` (sql-migration) were queued. These are PR integration checks, not a manually dispatched exact-SHA acceptance run.
- [Build PR Run `39757680043`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680043): `IN PROGRESS`, with nine required jobs listed and still executing. Its PR event does not request the Product Target SHA; Exact-SHA verification is skipped by design for this PR event, so this run cannot replace Wave 6.18 Build acceptance or establish exact-SHA Device Smoke.
- Final conclusions for these two PR runs remain `NOT VERIFIED` until their respective Actions runs complete and the completed results are inspected.
