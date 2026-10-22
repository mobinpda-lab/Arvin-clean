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


## Wave 6.20–6.21 live CI closeout (2026-10-22)

### Final results of existing PR validation runs

- [Device Smoke PR Run `39757680037`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680037): final conclusion `success`. Run event is `pull_request`; run-level `head_sha` is PR head `18389a26dc62838993469a59537ea1c5b7e3c373`. All eight jobs completed successfully:
  - Prepare selected smoke scenarios `119754299800`: `success`
  - Home `119754341005`: `success`
  - Quick Capture `119754340995`: `success`
  - SQL Persistence `119754340929`: `success`
  - SQL Migration `119754341050`: `success`
  - Backup/Restore `119754341027`: `success`
  - People `119754340922`: `success`
  - Calendar `119754341045`: `success`
- Calendar Job log reports `All tests passed.`; SQL Persistence Job log reports `All tests passed.`. Both logs show actual `CHECKOUT_SHA=aae14883d6be96eb09aef701b71c24d14d9f9ec9`, the PR merge checkout, not Product Target SHA `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`. Since this was a `pull_request` event, the manual-dispatch exact-target assertion was not exercised. These successful jobs are PR integration evidence only; exact-SHA Calendar/SQL acceptance remains `NOT VERIFIED`.
- [Fast Lane Contract Run `39757680039`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680039): final conclusion `success`; contract Job `119753756210` passed. Run event `pull_request`, run-level `head_sha=18389a26dc62838993469a59537ea1c5b7e3c373`. Log: `Arvin Fast Lane workflow contract: OK`.
- [Build PR Run `39757680043`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680043): final conclusion `success`; all nine jobs passed (Analyze, six test shards, APK Debug, APK Release). Run event `pull_request`; run-level `head_sha=18389a26dc62838993469a59537ea1c5b7e3c373`. This PR CI result does not replace exact-target Build evidence.
- The previously approved [Wave 6.18 exact-target Build Run `39681652761`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761) remains `PASS` for Product Target SHA `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`; do not repeat it without a reason.

### PR #2911 and default-branch dispatch blocker

- [PR #2911](https://github.com/mobinpda-lab/Arvin-clean/pull/2911) remains open, Draft, and unmerged at head `18389a26dc62838993469a59537ea1c5b7e3c373`. Its proposed workflow defines `target_sha`, `run_calendar`, and `run_sql_persistence`; dynamically selects the requested Calendar and SQL Persistence scenarios for manual dispatch; checks the actual checkout against the requested SHA and fails on mismatch; and logs `CHECKOUT_SHA` / `EXACT_TARGET_SHA`. The workflow contract run passed, and all seven existing smoke scenarios remained present in the completed PR Device Smoke matrix.
- The live default-branch workflow [`.github/workflows/device-smoke.yml on main`](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml) is blob `e5cd465a7d5a83be21a55535f7a0b3071ceeec45`. It contains a bare `workflow_dispatch:` but none of the required inputs `target_sha`, `run_calendar`, or `run_sql_persistence`. Therefore exact-target selective dispatch from the current default-branch definition is `BLOCKED`.
- [Documentation PR #2914](https://github.com/mobinpda-lab/Arvin-clean/pull/2914) remains open, Draft, and unmerged. This Wave 6.21 update is recorded on its existing branch `docs/wave-6-14-exact-sha-evidence`; no duplicate documentation PR was created.
- No PR was merged or taken out of Draft. No protected PR, product Calendar/SQL code, secret, signing key, or release setting was changed.

### Required next step and acceptance boundary

The single blocking action is a human decision by the product/repository owner to authorize making the reviewed PR #2911 workflow definition available on `main`, through the repository's normal review and branch-protection process. Do not bypass protection, auto-merge, or mark the PR ready without explicit authorization.

Only after the workflow with all three inputs is present on `main` may an authorized operator run:

```bash
gh workflow run .github/workflows/device-smoke.yml \
  --ref main \
  -f target_sha=1fb3f47e76b3fd093eba8b108b745fadb35b3c69 \
  -f run_calendar=true \
  -f run_sql_persistence=true
```

That command has not been run in Wave 6.20–6.21. Exact-SHA acceptance requires a `workflow_dispatch` run whose matrix contains only `calendar` and `sql-persistence`, whose two jobs each log matching `CHECKOUT_SHA` and `EXACT_TARGET_SHA`, and whose real Android tests and artifacts are inspectable and successful. Calendar and SQL acceptance remain `NOT VERIFIED`; final release decision remains `BLOCKED — RELEASE: NO-GO`.


## Wave 6.22 — Final preflight for exact-SHA Calendar and SQL (2026-10-22)

**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**Release decision:** `BLOCKED — RELEASE: NO-GO`

### Fresh run evidence

- Exact-target Build [Run `39681652761`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761) was re-read and remains completed with event `workflow_dispatch`, conclusion `success`. Its nine jobs are complete and successful, including the exact-revision verification step. It was not re-run.
- Device Smoke PR [Run `39757680037`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680037) is complete with conclusion `success`, event `pull_request`, and PR head SHA `18389a26dc62838993469a59537ea1c5b7e3c373`. Matrix preparation and all seven canonical scenario jobs passed. Calendar and SQL Persistence logs report passing tests, but their checkout is merge SHA `aae14883d6be96eb09aef701b71c24d14d9f9ec9`, not the Product Target SHA.
- Fast Lane Contract [Run `39757680039`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680039) is complete and successful for PR head `18389a26dc62838993469a59537ea1c5b7e3c373`; contract log reports `Arvin Fast Lane workflow contract: OK`.
- Build PR [Run `39757680043`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680043) is complete and successful across all nine jobs. It is a `pull_request` run; exact-target verification was skipped by design and this run is not target-SHA acceptance.
- Current check-run inspection found 24 check runs attached to PR head SHA: the latest Device Smoke, Fast Lane Contract, and Build runs have final successful conclusions. One older contract run (`39757672563`) is cancelled; it is not a replacement for the later successful contract run. The combined legacy commit-status endpoint reports `pending` with zero legacy status entries, so do not treat that endpoint alone as proof that every repository-required merge check is satisfied.

### PR #2911 implementation and safety review

- [PR #2911](https://github.com/mobinpda-lab/Arvin-clean/pull/2911) is still open, Draft, and unmerged. Head: `18389a26dc62838993469a59537ea1c5b7e3c373`; base `main` at `d9fb7a247037762216662a20fb32028ecc8a0f6b`. GitHub reports `mergeable=true` but `mergeable_state=unstable`. There are no submitted reviews, no requested reviewers, and no review threads. Draft status and the unstable merge state mean it is not confirmed as authorized or merge-ready.
- The full three-file diff was inspected: `.github/workflows/device-smoke.yml`, `test/device_smoke_workflow_contract_test.dart`, and `tool/validate_fast_lane.py`. No production Calendar/SQL code, secrets, signing keys, or release settings are changed.
- The workflow defines required `target_sha`, `run_calendar`, and `run_sql_persistence` inputs; dispatch selection adds only the selected Calendar and/or SQL Persistence scenario and rejects an empty selection; non-dispatch events retain all seven canonical scenario mappings. Checkout uses the requested SHA on `workflow_dispatch`; the verification step logs `CHECKOUT_SHA`, rejects a mismatch with a nonzero exit, and logs `EXACT_TARGET_SHA` only after equality. The successful contract run validates this source contract, but does not prove that a real manual dispatch has occurred.
- The contract test and Fast Lane validator still enumerate all seven canonical mappings. The reviewed diff does not remove test assertions, emulator execution, screenshot assertions, or artifact checks. The three relevant latest CI runs all have final results. Source/diff review does not replace a runtime dispatch or a formal human review.
- PR [#2906](https://github.com/mobinpda-lab/Arvin-clean/pull/2906) remains open, Draft, and unmerged. It overlaps the same workflow scope; do not merge both alternatives.

### Default branch and repository governance

- The live `main` workflow [`.github/workflows/device-smoke.yml`](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml) remains blob `e5cd465a7d5a83be21a55535f7a0b3071ceeec45`. It has a bare `workflow_dispatch:` and does not declare `target_sha`, `run_calendar`, or `run_sql_persistence`. Exact-SHA selective dispatch using the requested arguments is therefore `BLOCKED`.
- The branch-protection endpoint returned HTTP 403 `Resource not accessible by integration`. Consequently, exact required-review rules, required-check rules, and the full branch-protection configuration could not be independently verified with the connected GitHub permission. Do not infer that branch protection is absent or bypassable. PR metadata alone reports mergeable but does not grant merge authorization.
- Documentation PR [#2914](https://github.com/mobinpda-lab/Arvin-clean/pull/2914) remains open, Draft, and unmerged. This Wave 6.22 record is appended to its existing documentation branch; no duplicate documentation PR was created.

### Remaining blocker and authorized next action

The next action is for the product owner/repository owner to review PR #2911 and explicitly decide whether to authorize this workflow-only change for the normal protected-branch review and merge process. Before that decision is acted on, the authorized reviewer must verify the repository's required checks/review rules through an account with sufficient permission and ensure the latest head checks are satisfied. No merge, Draft promotion, protection bypass, or PR #2906 merge was performed here.

Only after the approved workflow definition is actually present on `main`, and an authorized operator has the required Actions permission, run:

```bash
gh workflow run .github/workflows/device-smoke.yml \
  --repo mobinpda-lab/Arvin-clean \
  --ref main \
  -f target_sha=1fb3f47e76b3fd093eba8b108b745fadb35b3c69 \
  -f run_calendar=true \
  -f run_sql_persistence=true
```

This dispatch was **not run** in Wave 6.22. Product acceptance remains `NOT VERIFIED` until one completed `workflow_dispatch` run shows exactly `calendar` and `sql-persistence`, matching `CHECKOUT_SHA` and `EXACT_TARGET_SHA` in both jobs, passing Android integration tests, and inspectable logs/artifacts. Exact-target Build remains `PASS`; this does not change the overall release decision: `BLOCKED — RELEASE: NO-GO`.


## Wave 6.24 — PR review preflight and exact-SHA dispatch blocker (2026-10-22)

**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**Release decision:** `BLOCKED — RELEASE: NO-GO`

### Live PR #2911 state

- PR [#2911](https://github.com/mobinpda-lab/Arvin-clean/pull/2911) remains open, Draft, and unmerged. Current head SHA: `18389a26dc62838993469a59537ea1c5b7e3c373`; base SHA: `d9fb7a247037762216662a20fb32028ecc8a0f6b`. GitHub reports `mergeable=true` and `mergeable_state=unstable`; the cause of `unstable` is `NOT DETERMINED`.
- Current check-run query returned 24 check runs for the PR head. The latest relevant runs completed successfully: Device Smoke [Run `39757680037`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680037), Fast Lane Contract [Run `39757680039`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680039), and Build [Run `39757680043`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680043). One older contract run `39757672563` was cancelled; it is superseded by the later successful contract run. The latest three runs are PR CI, not exact-target product acceptance.
- Reviews endpoint returned zero submitted reviews; requested reviewer and team lists are empty; there are no review threads or PR discussion comments. No reviewer identity was inferred and no review request was sent.
- The active repository ruleset [`main-protection`](https://github.com/mobinpda-lab/Arvin-clean/rules/20952260) applies to `refs/heads/main`. Its visible rules prohibit branch deletion and non-fast-forward updates and require changes through a pull request; it lists zero minimum approving reviews and no required reviewer identities, and allows merge, squash, or rebase. It also enables `require_extra_approval_for_unattributed_changes`. The current integration cannot identify an authorized human reviewer from this ruleset. The separate branch-protection endpoint remains inaccessible (HTTP 403), so any settings not represented in this visible ruleset remain `NOT VERIFIED`.
- The source diff still contains only three files: `.github/workflows/device-smoke.yml`, `test/device_smoke_workflow_contract_test.dart`, and `tool/validate_fast_lane.py`. No production Calendar or SQL code, secrets, signing keys, or release settings are changed in this PR.

### Latest exact-SHA and default-branch status

- Exact-target Build [Run `39681652761`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761) remains completed with event `workflow_dispatch` and conclusion `success`. Its run-level `head_sha` is the dispatch ref SHA, not the job checkout SHA; the prior recorded direct logs for all nine jobs verify the requested Product Target SHA. No duplicate Build was launched.
- The current `main` Device Smoke workflow remains blob `e5cd465a7d5a83be21a55535f7a0b3071ceeec45` ([workflow file](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml)). It still has only a bare `workflow_dispatch:` and lacks `target_sha`, `run_calendar`, and `run_sql_persistence`. Exact-SHA selective dispatch on the current `main` definition remains `BLOCKED`; no dispatch was attempted.
- Device Smoke PR Run `39757680037` passed all seven canonical scenarios, including Calendar Job `119754341045` and SQL Persistence Job `119754340929`. Both are PR-event jobs and checked out merge SHA `aae14883d6be96eb09aef701b71c24d14d9f9ec9`, not the Product Target SHA. They do not satisfy the exact-SHA acceptance criteria.
- Calendar acceptance on the target SHA: `NOT VERIFIED`. SQL Persistence acceptance on the target SHA: `NOT VERIFIED`. Exact-SHA execution: `NOT RUN`.

### Review summary for the human reviewer

PR #2911 is a workflow-only change needed to run the Calendar and SQL Android smoke tests against the exact product commit, instead of relying on PR merge commits. It adds three manual-dispatch inputs, a selective matrix that can run only Calendar and SQL Persistence, requested-SHA checkout, a mismatch-fails-the-job guard, and `CHECKOUT_SHA` / `EXACT_TARGET_SHA` logging. Non-dispatch CI retains all seven canonical scenarios. The successful contract run checks the source contract, while successful PR CI remains integration evidence only.

Before approval, a reviewer should verify the workflow expression and matrix behavior, ensure mismatch exits before Android test execution, confirm all seven standard mappings remain intact, inspect the latest CI jobs and artifacts, and determine why GitHub reports `mergeable_state=unstable`. The reason remains `NOT DETERMINED`; no cause is guessed. The PR remains Draft pending explicit product/repository-owner authorization. No Draft promotion, merge, protection change, or PR #2906 merge occurred.

### Required next action

The product/repository owner must explicitly authorize the normal review path for PR #2911 and identify an authorized reviewer; no reviewer was guessed or requested. Once approved through the repository's normal process and the updated workflow definition is actually present on `main`, an authorized operator with Actions write permission may run the exact dispatch documented above in Wave 6.22. This dispatch must not run before the three inputs are verified on `main`.

This Wave 6.24 record was appended to the existing documentation branch for PR #2914. No duplicate documentation PR was created. No product code, secrets, signing settings, protected branch, or release configuration was changed.


## Wave 6.25 — Final review-path determination for PR #2911 (2026-10-22)

**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**Release decision:** `BLOCKED — RELEASE: NO-GO`

### Current PR head, checks, and review state

- Live PR [#2911](https://github.com/mobinpda-lab/Arvin-clean/pull/2911) is `open`, `draft=true`, and unmerged. Head SHA remains `18389a26dc62838993469a59537ea1c5b7e3c373`; base SHA is `d9fb7a247037762216662a20fb32028ecc8a0f6b`. GitHub still reports `mergeable=true`, `mergeable_state=unstable`. The API evidence does not expose a causal explanation for `unstable`; root cause remains `NOT DETERMINED`.
- The current check-run endpoint returns 24 entries. Latest Device Smoke [Run `39757680037`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680037) completed successfully, including Calendar Job [`119754341045`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680037/job/119754341045) and SQL Persistence Job [`119754340929`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680037/job/119754340929). Fast Lane Contract [Run `39757680039`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680039) and Build [Run `39757680043`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39757680043) also completed successfully. The older Contract Run `39757672563` is cancelled and is superseded by the later successful run.
- Reviews API: zero submitted reviews. Requested reviewers and teams: empty. PR remains Draft. These facts show no review is underway, but do not establish a failed required check.
- The visible active ruleset [`main-protection`](https://github.com/mobinpda-lab/Arvin-clean/rules/20952260) applies to `refs/heads/main`, requires pull-request-based changes, prohibits deletion/non-fast-forward updates, shows `required_approving_review_count=0`, no named required reviewers, and no bypass actors; `require_extra_approval_for_unattributed_changes` is enabled. The current user cannot bypass this ruleset (`current_user_can_bypass=never`). The separate branch-protection endpoint returns HTTP 403, so any other settings available only through that endpoint are `NOT VERIFIED`.
- Common CODEOWNERS locations `CODEOWNERS`, `.github/CODEOWNERS`, and `docs/CODEOWNERS` returned 404. The default-branch search for CODEOWNERS found no result. Common contribution-guide locations `CONTRIBUTING.md` and `.github/CONTRIBUTING.md` also returned 404. These checks do not prove that no governance guidance exists elsewhere in the repository or organization.
- No verified evidence identifies a human reviewer authorized to take ownership of this PR. Recent commit authors or the repository owner account are not treated as proof of review authority. No review request was sent.

### Review-path determination

- Formal reviewer assignment: `BLOCKED` until the product/repository owner identifies an authorized reviewer or team and confirms the intended review path.
- Draft promotion: not performed. Merge: not performed. Branch rules/protection: not changed. PR #2906 was not merged or combined with #2911.
- `mergeable_state=unstable` cause: `NOT DETERMINED`. Successful visible CI checks do not, by themselves, reveal the cause. An authorized maintainer with sufficient repository access should inspect the PR mergeability details and any repository-level policy/status information unavailable to the current integration.

### Exact-SHA product test readiness

- Exact-target Build [Run `39681652761`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761) remains completed `success`, event `workflow_dispatch`; it was not repeated.
- Current `main` workflow [`.github/workflows/device-smoke.yml`](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml), blob SHA `e5cd465a7d5a83be21a55535f7a0b3071ceeec45`, defines a bare `workflow_dispatch` and has none of the required inputs `target_sha`, `run_calendar`, `run_sql_persistence`. Exact-SHA selective dispatch remains `BLOCKED`; no dispatch was run.
- The latest PR Device Smoke jobs passed on merge checkout SHA `aae14883d6be96eb09aef701b71c24d14d9f9ec9`, not Product Target SHA `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`. They are not accepted as target-SHA product evidence.
- Calendar target-SHA acceptance: `NOT VERIFIED`. SQL Persistence target-SHA acceptance: `NOT VERIFIED`. New exact-SHA Device Smoke execution: `NOT RUN`.

### Smallest next action

The product/repository owner should name or authorize a reviewer/team for PR #2911 and clarify whether the PR should enter the normal review process while remaining Draft or be explicitly approved for a later ready-for-review transition. Only after a verified reviewer is identified should an authorized actor request that review. A maintainer with adequate permissions should separately determine why GitHub reports `unstable`. After the approved workflow is present on `main`, an authorized Actions operator can dispatch only `calendar` and `sql-persistence` with the exact target SHA and verify both jobs' checkout and test logs.

This Wave 6.25 record was appended to the existing documentation branch for PR #2914. The file was re-read from GitHub after writing to verify the record. No duplicate documentation PR, production code change, PR state change, merge, dispatch, secret/signing change, or protection change was made.


## Wave 6.26 — Live state after PR #2911 changed (2026-10-22)

**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**Release decision:** `BLOCKED — RELEASE: NO-GO`

### New live evidence

- PR [#2911](https://github.com/mobinpda-lab/Arvin-clean/pull/2911) changed since Wave 6.25: GitHub now reports `state=closed`, `merged=true`, merged at `2026-10-22T10:30:49Z`. Merge commit: `264bc7cb31ed19b15254d48926ef9c15f9a67f08`, now the `main` commit. This was an observed external repository change; this wave did not merge the PR or change its Draft state.
- PR #2911 review endpoint returned zero reviews; requested individual and team reviewers are empty. The merge therefore does not provide evidence of a formal human review. Do not infer reviewer authorization from the PR author or repository-owner account.
- GitHub's visible active ruleset `main-protection` still requires pull-request-based changes, prohibits branch deletion and non-fast-forward updates, shows zero minimum approving reviews and no named required reviewer identities, and enables `require_extra_approval_for_unattributed_changes`. The separate branch-protection endpoint remains inaccessible to this integration (HTTP 403). Collaborator and team membership endpoints were not available through the connected fetch capability; authorized reviewer identity remains `NOT VERIFIED`.
- The PR's prior `mergeable_state=unstable` is no longer a current actionable PR state because PR #2911 is closed and merged. Its earlier cause remains `NOT DETERMINED`; the latest API response does not explain the prior value.
- The live `main` workflow [`.github/workflows/device-smoke.yml`](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml) now has blob SHA `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21`. It visibly defines `target_sha`, `run_calendar`, and `run_sql_persistence`, dynamically selects requested scenarios, checks the actual checkout against `target_sha`, and logs `CHECKOUT_SHA` and `EXACT_TARGET_SHA`. Workflow input readiness on `main`: `PASS`.
- PR #2914 remains open, Draft, and unmerged at head `a668d1b806b00753ab1a09f4cb7ec10ab151730d`. The documentation branch was updated in place for this record; no duplicate documentation PR was created.
- Current check-run inspection for former PR head `18389a26dc62838993469a59537ea1c5b7e3c373` returned 37 entries. A newer PR-triggered Device Smoke run [`39763638138`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39763638138) was still queued/in progress when checked; Calendar and SQL Persistence jobs were queued. The previous completed PR Device Smoke run `39757680037`, Fast Lane Contract `39757680039`, and Build `39757680043` were successful, but none constitutes the required manual exact-target acceptance run.
- The most recent general `workflow_dispatch` run inspected, [`39763648725`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39763648725), belongs to `Arvin Production Orchestrator`, not `device-smoke.yml`. It is not Calendar/SQL exact-SHA acceptance evidence.
- The connected GitHub tool set exposes no operation to dispatch a workflow. Therefore no new Device Smoke dispatch was initiated in this wave. Exact-SHA Calendar/SQL run: `NOT RUN`; Calendar target-SHA acceptance: `NOT VERIFIED`; SQL Persistence target-SHA acceptance: `NOT VERIFIED`.
- Exact-SHA Build Run [`39681652761`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761) remains the previously verified successful Build and was not repeated.

### Required next action and release boundary

- An authorized Actions operator with workflow-dispatch capability should now run the documented command from Wave 6.25 against `main`, because the required inputs are present there. Accept only a completed `workflow_dispatch` run with exactly the Calendar and SQL Persistence scenarios, exact matching `CHECKOUT_SHA` and `EXACT_TARGET_SHA` in both jobs, successful Android tests, and inspectable logs/artifacts from that same run.
- The product/repository owner or authorized maintainer should clarify the review/governance record for PR #2911 because it was merged without any review recorded by the PR reviews endpoint. Do not attempt to reverse the merge or change protection as part of this wave.
- This wave changed only the existing documentation review branch. No new workflow run was started, no product code or secret/signing configuration was changed, and PR #2906 was not merged or combined with #2911.
- Release remains `BLOCKED — RELEASE: NO-GO` until exact-SHA Calendar and SQL acceptance and all other release gates are satisfied.


## Wave 6.27 — Exact-SHA Calendar and SQL acceptance status (2026-10-22)

**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**Release decision:** `BLOCKED — RELEASE: NO-GO`

### Live workflow and existing-run reconciliation

- Live `main` workflow [`.github/workflows/device-smoke.yml`](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml), blob `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21`, defines all required inputs: `target_sha`, `run_calendar`, and `run_sql_persistence`. Its dispatch matrix selects Calendar and SQL Persistence independently, and the checkout-verification step compares `git rev-parse HEAD` to `target_sha` and emits `EXACT_TARGET_SHA` only on a match.
- The target commit's own workflow blob `e5cd465a7d5a83be21a55535f7a0b3071ceeec45` does not contain these inputs or exact-SHA controls. The planned command explicitly uses `--ref main`, so dispatch would use the live main workflow and check out the target SHA.
- Run [`39763638138`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39763638138) remains reported as event `pull_request`, head `18389a26dc62838993469a59537ea1c5b7e3c373`, branch `ci/device-smoke-exact-sha-dispatch-wave-6-08`. Its job listing contains the standard seven-scenario matrix; it is not the required two-scenario manual dispatch. The run API still reported it queued when queried, although the jobs endpoint showed some jobs completed and others in progress/queued. It is not acceptance evidence.
- Existing run [`39674729325`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39674729325) is `event=pull_request`, `status=completed`, `conclusion=success`, with API `head_sha=1fb3f47e76b3fd093eba8b108b745fadb35b3c69` and attempt 2. Calendar Job [`119662166787`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39674729325/job/119662166787) and SQL Persistence Job [`119662117335`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39674729325/job/119662117335) both concluded `success`; their Android integration logs contain “All tests passed.” Calendar screenshots were uploaded as artifact [`arvin-device-smoke-calendar-ee013f003f9c2fac9b78590d0ffa153f8a20cedf`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39674729325). This run's event is still `pull_request`, the old workflow has no exact-SHA checkout control, and the artifact suffix is not the target SHA. Therefore these are useful prior CI results but do not satisfy Wave 6.27's exact-SHA acceptance contract.
- Run-list inspection of recent `workflow_dispatch` executions returned Production Orchestrator and other workflows, but no `.github/workflows/device-smoke.yml` dispatch for the target SHA. The existing successful Build Run `39681652761` was not repeated.
- The connected GitHub tools support read operations and selected file edits but expose no workflow-dispatch action or local authenticated GitHub CLI. No new Device Smoke dispatch was started. Exact-SHA run: `NOT RUN`; Calendar exact-SHA acceptance: `NOT VERIFIED`; SQL Persistence exact-SHA acceptance: `NOT VERIFIED`.

### Calendar test-source review at the target SHA

Source: [`integration_test/calendar_card_interaction_test.dart`](https://github.com/mobinpda-lab/Arvin-clean/blob/1fb3f47e76b3fd093eba8b108b745fadb35b3c69/integration_test/calendar_card_interaction_test.dart), blob `528aa30b6ebdf4e15bafa6a0cc59424b4277d6b6`.

| Acceptance criterion | Source coverage | Assessment |
|---|---|---|
| Follow-up without `reminderDate` creates no separate card | No negative fixture/assertion | `NOT VERIFIED` |
| `nextFollowUp` alone creates no card | No fixture/assertion | `NOT VERIFIED` |
| Valid reminder creates exactly one card with contractual ID | Seeded reminder; `findsOneWidget` for `reminder-card-followup:calendar-smoke-task:calendar-smoke-follow-up` | `PASS` for source assertion; runtime exact-SHA acceptance `NOT VERIFIED` |
| Cancelling time picker preserves stored value | Reads SQLite before and after cancel; checks same reminder instant | `PASS` for source assertion; runtime exact-SHA acceptance `NOT VERIFIED` |
| Returning from edit form does not remove card | After cancel/back, checks canonical card remains | `PASS` for source assertion; runtime exact-SHA acceptance `NOT VERIFIED` |
| Independent Task date remains intact | No independent task-date fixture/assertion | `NOT VERIFIED` |
| Duplicate card is not created | `findsOneWidget` detects more than one matching contractual key for the seeded valid reminder | `PASS` for this fixture only; broader duplicate-generation cases `NOT VERIFIED` |

Three source-level criteria are directly asserted without qualification; one more duplicate assertion applies only to the single valid-reminder fixture. No Calendar test source was modified in this wave because the required exact-SHA dispatch could not be launched and any new test change would need normal review and its own revision/acceptance evidence. The three uncovered cases must be added as isolated, non-weakened tests through the normal repository review path before claiming full seven-case coverage.

### SQL persistence and upgrade-data review

- Target-SHA source [`integration_test/android_sql_persistence_smoke_test.dart`](https://github.com/mobinpda-lab/Arvin-clean/blob/1fb3f47e76b3fd093eba8b108b745fadb35b3c69/integration_test/android_sql_persistence_smoke_test.dart), blob `689e9f7f3c28487c9eef2b06d64be431068687e4`, writes a task with description, tags, category, follow-up, completion state and checklist; loads through a fresh `TaskStore` and asserts those values. This tests ordinary SQL save/load persistence, not upgrade preservation.
- The existing [`integration_test/android_upgrade_migration_smoke_test.dart`](https://github.com/mobinpda-lab/Arvin-clean/blob/1fb3f47e76b3fd093eba8b108b745fadb35b3c69/integration_test/android_upgrade_migration_smoke_test.dart), blob `3f7d169a13f1546629e8e5cbaec0c9c9c0766c0b`, seeds legacy preferences, reads through `TaskStore`, mutates the legacy preferences after cutover, then verifies a fresh store still returns migrated SQL data. Source coverage for legacy-to-SQL migration is present.
- In prior PR run `39674729325`, SQL Persistence Job `119662117335` and SQL Migration Job `119662118286` both concluded `success`; the former log says “All tests passed.” This is PR-triggered evidence, not a manual exact-target run with explicit checkout confirmation. Upgrade migration acceptance on the exact target: `NOT VERIFIED`. Full real-device install/upgrade lifecycle beyond this migration smoke: `NOT VERIFIED`.

### Next action

- An authorized GitHub Actions operator with workflow-dispatch capability must run the documented `gh workflow run` command against `main` with target SHA `1fb3f47e76b3fd093eba8b108b745fadb35b3c69` and both booleans true, then inspect the real run, both jobs, checkout logs, Exact-SHA control, Android test output and artifacts.
- The maintainer should add isolated Calendar tests for (1) missing `reminderDate`, (2) `nextFollowUp` without a reminder, and (3) preservation of a Task's independent date, via the normal review process. Do not weaken existing assertions or treat a PR CI result as exact-SHA acceptance.
- Release remains `BLOCKED — RELEASE: NO-GO` until exact-SHA runtime acceptance and the remaining release gates are supported by inspectable evidence.


## Wave 6.28 — Exact-SHA execution blocker and Calendar coverage proposal

**Reviewed:** 2026-10-22  
**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**Release decision:** `BLOCKED — RELEASE: NO-GO`

### Live workflow and prior-run reconciliation

- Live `.github/workflows/device-smoke.yml` on `main`: blob `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21`. Inputs `target_sha`, `run_calendar`, and `run_sql_persistence` are present. The dispatch path builds a selective matrix, checks out the requested SHA, logs `CHECKOUT_SHA`, and emits `EXACT_TARGET_SHA` only after equality succeeds.
- Latest repository commit/main checkpoint observed: merge commit `264bc7cb31ed19b15254d48926ef9c15f9a67f08` (PR #2911). Product Target SHA remains the distinct immutable commit above.
- No qualifying completed `workflow_dispatch` Device Smoke run was found in the connected GitHub evidence. The connected GitHub tools do not expose a workflow-dispatch action or authenticated shell, so no new dispatch was started. No Run ID is claimed for Wave 6.28 exact-SHA execution.
- Existing Run [39763638138](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39763638138) is a `pull_request` event with a seven-scenario matrix, not the requested two-scenario dispatch. At this checkpoint the job API showed Calendar `119773657375` and People `119773657426` still `IN PROGRESS`; the other listed smoke jobs had completed successfully. It is not exact-SHA acceptance regardless of its eventual conclusion.
- Existing Run [39674729325](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39674729325) is `pull_request` and concluded success. Calendar Job `119662166787`, SQL Persistence Job `119662117335`, and SQL Migration Job `119662118286` concluded success, but that run does not establish the required dispatch event, two-scenario matrix, and exact-checkout gate. Treat it as PR diagnostic evidence only.
- Historical exact-SHA Build Run [39681652761](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761) remains accepted for Build; it was not repeated.

### Independent Calendar / SQL acceptance

| Gate | Wave 6.28 status | Evidence boundary |
|---|---|---|
| Exact-SHA Calendar Android smoke | `NOT VERIFIED` | No qualifying manual dispatch run or job checkout log |
| Exact-SHA SQL Persistence Android smoke | `NOT VERIFIED` | No qualifying manual dispatch run or job checkout log |
| Exact-SHA workflow guard in both jobs | `NOT VERIFIED` | Workflow definition supports the guard, but no qualifying run exercised it |
| SQL ordinary persistence source test | `PASS` | Existing test writes a complete Task, then loads it via a fresh `TaskStore` |
| SQL legacy-to-SQL migration source test | `PASS` | Existing test seeds legacy preferences, verifies migration and fresh-store persistence |
| Exact-target SQL persistence / migration runtime | `NOT VERIFIED` | Prior PR job success is not exact-target dispatch evidence |
| Full installed-app upgrade/data-retention lifecycle | `NOT VERIFIED` | Not proved by the migration smoke test |

### Calendar source contract and test gaps

- The Product Target source keeps `FollowUp.reminderDate` and `FollowUp.nextFollowUp` independent. `FollowUpCalendarProjection` projects explicit reminder dates only; `FollowUpInternalCalendarProjection` projects `nextFollowUp` as an internal action. That action must not be mislabeled as an independent reminder or passed to outbound Calendar sync.
- Three targeted tests were added on a separate review branch and proposed in Draft PR [#2915](https://github.com/mobinpda-lab/Arvin-clean/pull/2915), head `110d33b7c859fb55a444022af87ae45f08bc5db3`, based on current main `264bc7cb31ed19b15254d48926ef9c15f9a67f08`:
  1. Follow-up with no `reminderDate` produces no reminder projection, and projection does not mutate Task JSON.
  2. `nextFollowUp` alone produces an internal action but no reminder/outbound-sync projection; both canonical fields remain unchanged.
  3. A Follow-up reminder coexists with the independent Task due date; projections do not replace or clear the Task date.
- These tests exercise the canonical projection outputs and stored object values. They are **proposed coverage**, not accepted product-SHA tests. PR #2915 is open, Draft, and unmerged; CI was observed starting on its head (Build Run [39765328108](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39765328108) `IN PROGRESS`; Device Smoke Run [39765328178](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39765328178) `QUEUED` at this checkpoint). The test change has not been locally executed through an available Flutter/Android environment, and final CI results remain `NOT VERIFIED` until polled.
- No production Calendar, SQL, model, workflow, signing, or release code changed in Wave 6.28.

### Documentation and remaining action

- This update is appended to the existing documentation branch `docs/wave-6-14-exact-sha-evidence` for PR #2914; no duplicate documentation PR is created. Re-read the committed file after update to verify this section.
- Required operator action: use an authorized GitHub Actions interface to dispatch `.github/workflows/device-smoke.yml` from `main` with target SHA `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`, `run_calendar=true`, and `run_sql_persistence=true`; then retain run URL, event, inputs, matrix, each job's checkout SHA / `EXACT_TARGET_SHA`, logs, artifacts, and terminal result.
- Required maintainer action: review PR #2915 and wait for CI on its exact head; do not merge without authorization. Follow-up acceptance on any changed/new product SHA must be rerun against that exact SHA.
- Full real-device upgrade, release signing identity, final APK cryptographic verification, installation, and owner release authorization remain `NOT VERIFIED` or `BLOCKED` as applicable.
- Final release decision remains **`BLOCKED — RELEASE: NO-GO`**.


## Wave 6.29 — PR #2915 CI status and exact-target acceptance

**Reviewed:** 2026-10-22  
**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**Release decision:** `BLOCKED — RELEASE: NO-GO`

### PR #2915: live CI reconciliation

- PR: [#2915](https://github.com/mobinpda-lab/Arvin-clean/pull/2915), `[DRAFT] test(calendar): cover Follow-up reminder projection gaps`; remains open, Draft, and unmerged.
- PR head used by the runs: `110d33b7c859fb55a444022af87ae45f08bc5db3`.
- Build Run [39765328108](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39765328108): `IN PROGRESS` at the last live poll. Debug APK job `119779230445` concluded success; quality test jobs `119779230765`, `119779230922`, `119779230958`, `119779231063`, `119779231088`, and `119779231106` concluded success; Analyze job `119779231093` concluded success. Release APK job `119779230846` was still `IN PROGRESS`. Therefore the overall Build run was not terminal at this checkpoint.
- Device Smoke Run [39765328178](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39765328178): `IN PROGRESS` at the last live poll. Prepare matrix job `119779230866` succeeded; Quick Capture job `119779262606` and Home job `119779263136` succeeded. SQL Migration job `119779262633` and SQL Persistence job `119779263255` were `IN PROGRESS`; Backup Restore `119779262649`, People `119779262677`, and, critically, Calendar job `119779262745` were `QUEUED`. Thus the three added Calendar integration tests had not yet been shown to execute in the Calendar job at the last poll.
- Step evidence from successful quality jobs shows the generic `Test` step succeeded, but `integration_test/calendar_card_interaction_test.dart` is exercised by the Android Device Smoke Calendar job. Generic quality tests do not replace that integration job.
- The workflow-job API exposed job/step summaries; direct decoded log retrieval returned a 404 for the attempted log query, so no log contents are claimed for those jobs. The real run links and job IDs above are available for continued review. No duplicate CI run was created.

### Three proposed Calendar tests

The PR head source was re-read from GitHub at [the PR branch test file](https://github.com/mobinpda-lab/Arvin-clean/blob/test/calendar-followup-reminder-gaps-wave-6-28/integration_test/calendar_card_interaction_test.dart), blob `ab69b72ce3dc7f3a524875dc1707fd8aef809b1b`. All three named tests are present:
1. Follow-up without `reminderDate` does not project an independent reminder card.
2. `nextFollowUp` alone remains an internal action, not a reminder card.
3. Follow-up reminder projection preserves the independent Task date.

The Product Target version of the same test file remains blob `528aa30b6ebdf4e15bafa6a0cc59424b4277d6b6`; the new tests exist only on the proposed PR branch. No production code change was made in this PR update. The proposed tests' runtime result is `NOT VERIFIED` until Device Smoke Calendar job `119779262745` completes successfully and its final logs are reviewed. The PR-wide CI result remains `IN PROGRESS`, not `PASS`.

### Exact-target Calendar / SQL acceptance

- Live workflow on `main`: [device-smoke.yml](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml), blob `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21`. The three inputs `target_sha`, `run_calendar`, and `run_sql_persistence` are present, with a dispatch-only exact-checkout guard.
- Existing target-associated Device Smoke Run [39674729325](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39674729325) is `pull_request`, not `workflow_dispatch`. Calendar Job `119662166787`, SQL Persistence Job `119662117335`, and SQL Migration Job `119662118286` all concluded success, but this run does not meet the required event, selected matrix, and exact-SHA evidence conditions.
- No qualifying prior `workflow_dispatch` run was identified in the connected evidence. Available GitHub connector actions do not include workflow dispatch or authenticated shell execution, so no new dispatch was started. Exact-target Calendar `NOT VERIFIED`; exact-target SQL Persistence `NOT VERIFIED`; exact-target migration runtime `NOT VERIFIED`. No new Run ID is claimed.
- Previously accepted Build Run [39681652761](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761) was not repeated.
- Independent SQL Migration source coverage remains present. Real install/upgrade of the app and preservation of prior-version user data remain `NOT VERIFIED`.

### Required next actions

1. A workflow-authorized operator must dispatch `.github/workflows/device-smoke.yml` from `main` with target SHA `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`, `run_calendar=true`, and `run_sql_persistence=true`; then verify event, inputs, two-entry matrix, checkout SHA, successful non-skipped Exact-SHA guard, Android tests, final jobs, logs and artifacts.
2. Continue polling the existing PR #2915 Build and Device Smoke runs, especially Release APK job `119779230846`, SQL Migration `119779262633`, SQL Persistence `119779263255`, and Calendar `119779262745`. Do not start duplicate runs while these are active.
3. Review the exact final Calendar job logs to confirm the new tests actually ran. A successful PR run applies only to PR head `110d33b7c859fb55a444022af87ae45f08bc5db3`, not the Product Target SHA.
4. Keep PR #2915 unmerged until review and explicit authorization. Release remains **`BLOCKED — RELEASE: NO-GO`**.


## Wave 6.30 — final CI reconciliation and exact-product-SHA acceptance

**Review date:** 2026-10-22  
**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**PR #2915 test SHA:** `110d33b7c859fb55a444022af87ae45f08bc5db3`  
**Release decision:** `BLOCKED — RELEASE: NO-GO`

### Existing PR #2915 runs

- Build Run [39765328108](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39765328108): terminal `success`, event `pull_request`, head SHA `110d33b7c859fb55a444022af87ae45f08bc5db3`. All nine reported jobs concluded `success`: debug APK `119779230445`, release APK `119779230846`, quality tests `119779230765`, `119779230922`, `119779230958`, `119779231063`, `119779231088`, `119779231106`, and analyze `119779231093`. The exact-target guard step was skipped in these PR-triggered build jobs, as expected for this event; this run is not Product Target acceptance.
- Device Smoke Run [39765328178](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39765328178): event `pull_request`, head SHA `110d33b7c859fb55a444022af87ae45f08bc5db3`. At the latest poll the run-level API still reported `queued` with no conclusion, while job data showed active jobs, so its final outcome is `IN PROGRESS` / not terminal. Prepare matrix `119779230866`, Quick Capture `119779262606`, and Home `119779263136` succeeded. SQL Migration `119779262633` and SQL Persistence `119779263255` were `in_progress`; Backup Restore `119779262649`, People `119779262677`, and Calendar `119779262745` were `queued`. No replacement run was created.
- The live PR test file was read at [the PR test SHA](https://github.com/mobinpda-lab/Arvin-clean/blob/110d33b7c859fb55a444022af87ae45f08bc5db3/integration_test/calendar_card_interaction_test.dart), blob `ab69b72ce3dc7f3a524875dc1707fd8aef809b1b`. All three additional test cases are present:
  1. Follow-up without `reminderDate` does not project an independent reminder card.
  2. `nextFollowUp` alone stays an internal action, not a reminder or external Calendar-sync item.
  3. Follow-up reminder projection preserves the independent Task due date.
- These three tests are **`NOT VERIFIED` at runtime**: Calendar job `119779262745` had not started in the latest job poll. Generic quality test success is not evidence that this Android integration-test file ran. Job-log retrieval for the queued Calendar job returned 404 because logs were not yet available; no log contents are inferred.

### Exact Product Target Calendar and SQL

- Live `main` workflow [`.github/workflows/device-smoke.yml`](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml) was re-read, blob `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21`. It contains `workflow_dispatch` and all three inputs: `target_sha`, `run_calendar`, and `run_sql_persistence`.
- The available connected GitHub actions expose workflow-run/job reads and selected rerun operations, but no workflow-dispatch action or authenticated shell/CLI. No qualifying prior `workflow_dispatch` run for target SHA `1fb3f47e76b3fd093eba8b108b745fadb35b3c69` was identified in the available evidence. No dispatch was started and no Run ID was invented.
- Exact-target Calendar: `BLOCKED` pending an authorized operator dispatch; acceptance status `NOT VERIFIED`.
- Exact-target SQL Persistence: `BLOCKED` pending the same authorized dispatch; acceptance status `NOT VERIFIED`.
- Exact-target SQL Migration: `NOT VERIFIED` for the Product Target SHA. The currently active PR migration job belongs to the PR SHA, not the Product Target SHA.
- Required exact-target evidence remains: `workflow_dispatch` event; exact target input; matrix containing only `calendar` and `sql-persistence`; each job checkout SHA equal to target; successful, non-skipped Exact-SHA control; successful Android scenario; terminal-success jobs and run; and inspectable logs/artifacts.

### Product acceptance gates and ownership

| Gate | Status | Evidence / next owner |
|---|---|---|
| Build on Product Target SHA | `PASS` | Previously accepted Build Run [39681652761](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761); do not repeat without cause |
| Three new Calendar tests on PR SHA | `NOT VERIFIED` | Source exists on PR SHA; maintainer/operator must wait for Calendar job and inspect its actual test log |
| Calendar on Product Target SHA | `BLOCKED` | Workflow-authorized repository operator must dispatch exact inputs and capture job evidence |
| SQL Persistence on Product Target SHA | `BLOCKED` | Same exact-target dispatch; evaluate independently from Calendar |
| SQL Migration on Product Target SHA | `NOT VERIFIED` | Existing migration evidence is PR-run evidence, not exact-target acceptance |
| Real install/upgrade and prior-data retention | `NOT VERIFIED` | Android/release owner must run and record an actual upgrade lifecycle; migration smoke alone is insufficient |
| Documentation | `IN PROGRESS` | This Wave 6.30 section must be re-read from the documentation branch after commit |

### Smallest next actions

1. **CI maintainer:** continue polling existing Build/Device Smoke runs; do not create duplicates. Once Calendar job `119779262745` runs, inspect its log for all three test names and successful results, then record its terminal result for PR SHA only.
2. **Workflow-authorized operator:** dispatch `.github/workflows/device-smoke.yml` from `main` with `target_sha=1fb3f47e76b3fd093eba8b108b745fadb35b3c69`, `run_calendar=true`, `run_sql_persistence=true`; then record the real Run ID/URL and verify every exact-target acceptance condition. If no authorized Actions UI/CLI is available, keep both gates `BLOCKED`.
3. **Android/release owner:** separately prove real installation/upgrade and previous user-data retention.
4. Keep PR #2915 unmerged absent explicit authorization. Final release decision remains **`BLOCKED — RELEASE: NO-GO`**.


## Wave 6.31 — existing Device Smoke follow-up and exact-SHA gate

**Reviewed:** 2026-10-22  
**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**PR #2915 head SHA:** `110d33b7c859fb55a444022af87ae45f08bc5db3`  
**Release decision:** `BLOCKED — RELEASE: NO-GO`

### Existing Device Smoke Run 39765328178

- Run: [39765328178](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39765328178)
- Latest run-level API read still reported event `pull_request`, head SHA `110d33b7c859fb55a444022af87ae45f08bc5db3`, status `queued`, and no conclusion. Job state had progressed since Wave 6.30; therefore the run is **`IN PROGRESS` and not terminal**, not a final success or failure.
- Job `119779230866` Prepare selected smoke scenarios: `success`.
- Job `119779262606` Quick Capture: `success`; checkout guard step succeeded; scenario step succeeded.
- Job `119779263136` Home: `success`; checkout guard step succeeded; scenario step succeeded.
- Job `119779263255` SQL Persistence: `success`; checkout guard step succeeded; Android scenario step succeeded. The retrieved log proves checkout SHA `c23af6b187522574374f08d2eca83c7fc85d8d08` and contains `canonical SQL persists a full task cycle on Android` followed by `All tests passed!`.
- Job `119779262633` SQL Migration: `success`; checkout guard step succeeded; Android scenario step succeeded. The retrieved log proves checkout SHA `c23af6b187522574374f08d2eca83c7fc85d8d08` and contains `legacy storage upgrades into canonical SQL and survives a fresh store` followed by `All tests passed!`.
- Job `119779262649` Backup Restore: `in_progress` at the latest poll.
- Job `119779262677` People: `in_progress` at the latest poll.
- Job `119779262745` Calendar: `queued`, no conclusion. Its job-log request returned HTTP 404 / BlobNotFound because logs were not available. Do not infer test execution from this missing log.
- Actual checkout SHA for the SQL jobs is the PR merge checkout `c23af6b187522574374f08d2eca83c7fc85d8d08`, not Product Target SHA. Since the event is `pull_request`, the workflow's target-SHA equality check is conditional and is not the exact-product-SHA guard required for acceptance. These successful scenarios are PR-run evidence only.

### Three additional Calendar tests

- Test source was fetched from PR head `110d33b7c859fb55a444022af87ae45f08bc5db3`, blob `ab69b72ce3dc7f3a524875dc1707fd8aef809b1b`: [integration_test/calendar_card_interaction_test.dart](https://github.com/mobinpda-lab/Arvin-clean/blob/110d33b7c859fb55a444022af87ae45f08bc5db3/integration_test/calendar_card_interaction_test.dart).
- Test 1, `Follow-up without reminderDate does not project an independent reminder card`: source present `PASS`; runtime execution/result `NOT VERIFIED`; no Calendar job log available.
- Test 2, `nextFollowUp alone remains an internal action, not a reminder card`: source present `PASS`; runtime execution/result `NOT VERIFIED`; no Calendar job log available.
- Test 3, `Follow-up reminder projection preserves the independent Task date`: source present `PASS`; runtime execution/result `NOT VERIFIED`; no Calendar job log available.
- The job has not started according to the latest job data, so none of these three tests may be called runtime-`PASS`. Their runtime SHA is therefore `NOT VERIFIED`. If the Calendar job starts and completes, inspect its actual log and record each test's result independently.

### Live workflow contract and exact-dispatch search

- Re-read [`.github/workflows/device-smoke.yml` on `main`](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml), blob `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21`.
- Inputs `target_sha`, `run_calendar`, and `run_sql_persistence` exist. For `workflow_dispatch`, the matrix builder adds only `calendar` when `run_calendar=true` and only `sql-persistence` when `run_sql_persistence=true`; the source does not add other scenarios in that event. If neither is selected, preparation fails.
- Each scenario checks out `inputs.target_sha` for `workflow_dispatch`, records `git rev-parse HEAD`, and fails when actual SHA differs from requested target. The exact-target equality branch is conditional on `GITHUB_EVENT_NAME=workflow_dispatch`.
- A live repository Actions run listing was queried (first 100 entries returned). No qualifying `workflow_dispatch` for the Product Target SHA was found in the returned evidence. This is not proof that every historical page was exhaustively searched; no valid existing target run has been identified.
- Connected GitHub tools in this session expose read operations for workflow runs/jobs and log retrieval but no workflow-dispatch action or authenticated shell/CLI. No dispatch was attempted, no run was fabricated, and no duplicate run was created.
- Exact-target Calendar: `BLOCKED` / acceptance `NOT VERIFIED`.
- Exact-target SQL Persistence: `BLOCKED` / acceptance `NOT VERIFIED`.
- Exact-target SQL Migration: `NOT VERIFIED`; the current migration success belongs to checkout `c23af6b187522574374f08d2eca83c7fc85d8d08`, not the Product Target SHA.

### Independent release gates

| Gate | Status | Evidence / owner |
|---|---|---|
| Exact Product Target Build | `PASS` | Previously accepted Run [39681652761](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761); not repeated |
| Three additional Calendar tests on PR branch | `NOT VERIFIED` | Test source exists; CI maintainer must inspect the Calendar job after it actually runs |
| Calendar on Product Target SHA | `BLOCKED` | Workflow-authorized operator must dispatch and verify exact SHA |
| SQL Persistence on Product Target SHA | `BLOCKED` | Same exact-SHA dispatch; independent acceptance |
| SQL Migration on Product Target SHA | `NOT VERIFIED` | Current PR merge-checkout test is not target-SHA evidence |
| Actual APK installation on a device | `NOT VERIFIED` | Android/release owner must install and record the candidate APK |
| Real upgrade from previous version and user-data retention | `NOT VERIFIED` | Android/release owner must test the real upgrade lifecycle; migration smoke is not sufficient |
| Final application ID approval | `NOT VERIFIED` | Target source previously showed `com.example.arvin`; approved production ID evidence remains outstanding |
| Approved release signing | `NOT VERIFIED` | Target source previously configured debug signing for Release; approved signing evidence remains outstanding. No secret was accessed or changed |
| Final APK SHA-256 | `NOT VERIFIED` | Must hash the actual approved final APK artifact after build/signing acceptance |

### Smallest next actions

1. **CI maintainer:** continue polling existing Run `39765328178` without starting a replacement; wait for Calendar job `119779262745` and inspect its real log for all three test cases. Also record terminal Backup Restore and People results.
2. **Workflow-authorized GitHub Actions operator:** start the `device-smoke.yml` workflow from `main` with `target_sha=1fb3f47e76b3fd093eba8b108b745fadb35b3c69`, `run_calendar=true`, and `run_sql_persistence=true`. Record the actual Run ID/URL, then verify event, two-scenario matrix, checkout SHA, successful non-skipped exact-SHA check, Android tests, logs, and final conclusions.
3. **Android/release owner:** independently prove real APK installation, previous-version upgrade/data retention, approved application ID, approved Release signing, and SHA-256 of the final APK.
4. Keep PR #2915 unmerged absent explicit authorization. Final decision remains **`BLOCKED — RELEASE: NO-GO`**.


## Wave 6.31 live recheck addendum — 2026-10-22 11:02 UTC

This addendum supersedes earlier *poll-time* descriptions only where newer live evidence below is available. It does not change the release decision.

### Existing PR Device Smoke Run

- Run [39765328178](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39765328178) was re-read from GitHub. Event remains `pull_request`, head SHA `110d33b7c859fb55a444022af87ae45f08bc5db3`; the Run is still `in_progress` with no final conclusion.
- Latest job listing: Prepare selected smoke scenarios `success`; Quick Capture `success`; SQL Migration `success`; Backup Restore `success`; People `success`; Home `success`; SQL Persistence `success`; Calendar `in_progress`.
- Calendar job `119779262745` step listing confirms the Android emulator test step is still `in_progress`; screenshot evidence steps are pending. Attempts to retrieve its job log again returned HTTP 404 / BlobNotFound. Therefore the three new Calendar tests are present in source, but runtime execution/result remains `NOT VERIFIED` until the job log and final result become available.
- The PR SQL Persistence and SQL Migration successes remain evidence for their recorded PR merge checkout, not the Product Target SHA. This Run is not exact-target acceptance.

### Newly discovered manual-dispatch Run

- A live search of the returned Actions run listing identified Run [39767200300](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39767200300), event `workflow_dispatch`, currently `in_progress`. Its workflow head SHA is `264bc7cb31ed19b15254d48926ef9c15f9a67f08` (the workflow revision on `main`); this head SHA alone does **not** prove the requested product checkout SHA.
- Prepare job `119785506180` succeeded. Its retrieved log explicitly records `RUN_CALENDAR=true`, `RUN_SQL_PERSISTENCE=true`, and selected matrix exactly `calendar` plus `sql-persistence`.
- The only scenario jobs are Calendar `119785537501` and SQL Persistence `119785537406`; both were `in_progress` at this poll. Their step listings show the checkout and “Record and verify checkout revision” steps succeeded, but the active job logs were not downloadable (HTTP 404 / BlobNotFound). The actual checkout SHA and explicit Exact-SHA output are therefore not yet independently verified from available log text. Do not mark either scenario `PASS` until the run reaches a terminal result and the checkout/test logs establish the requested Product Target SHA and successful non-skipped equality guard.
- No additional dispatch was created during this recheck. Continue polling Run `39767200300`; do not create a replacement while it is active.

### Current gate status after this poll

- Existing PR Device Smoke Run `39765328178`: `IN PROGRESS`; Calendar remains active.
- Three new Calendar tests on PR SHA: source `PASS`; runtime/result `NOT VERIFIED`.
- Exact-target Calendar and SQL Persistence: Run `39767200300` is active, but acceptance remains `NOT VERIFIED` until actual checkout SHA, non-skipped exact-SHA check, Android test results, and terminal Run/Job conclusions are confirmed.
- Exact-target SQL Migration: `NOT VERIFIED`; no target-SHA migration scenario is included in the selected dispatch matrix.
- APK installation, real upgrade/data retention, approved application ID, approved Release signing, and final APK SHA-256: `NOT VERIFIED`.
- Next owner action: CI maintainer/operator should continue polling both existing Runs and capture terminal logs; do not start duplicate runs. Android/release owner still owns device install/upgrade and release identity/signing/hash evidence.
- Release decision remains **`BLOCKED — RELEASE: NO-GO`**.


## Wave 6.32 — final evidence for existing runs (2026-10-22)

This section records the terminal results obtained by re-polling GitHub Actions and retrieving the complete job logs. Earlier Wave 6.31 statements that these runs were still active are historical and are superseded by this section.

### 1. PR #2915 Device Smoke — terminal result

- Run: [39765328178](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39765328178)
- Event: `pull_request`
- Run head SHA: `110d33b7c859fb55a444022af87ae45f08bc5db3`
- Final Run conclusion: `success`
- All eight listed jobs concluded `success`: Prepare selected smoke scenarios (`119779230866`), Quick Capture (`119779262606`), SQL Migration (`119779262633`), Backup Restore (`119779262649`), People (`119779262677`), Calendar (`119779262745`), Home (`119779263136`), SQL Persistence (`119779263255`).
- Calendar job log confirms actual checkout SHA `c23af6b187522574374f08d2eca83c7fc85d8d08`, the PR merge checkout, not the PR head SHA and not the Product Target SHA.
- The Calendar Android integration log explicitly reports all three new tests passing:
  1. `Follow-up without reminderDate does not project an independent reminder card`
  2. `nextFollowUp alone remains an internal action, not a reminder card`
  3. `Follow-up reminder projection preserves the independent Task date`
  The log ends with `All tests passed`; Calendar job conclusion is `success`. Thus source presence and runtime success are both confirmed, but the runtime SHA is the merge checkout `c23af6...`.
- Calendar screenshot evidence upload step concluded `success`; artifact [arvin-device-smoke-calendar-c23af6b187522574374f08d2eca83c7fc85d8d08](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39765328178/artifacts/12420971356) was uploaded (artifact ID `12420971356`, SHA-256 digest `9291398eccf1d0a8d23c594543f357b52aba6451c427ef3b48cfc8cbe32c1b35`). The separate generic screenshot and Persian time-picker upload steps were skipped for Calendar by workflow conditions; this is not a test failure.
- PR SQL Persistence and SQL Migration both concluded `success` on this PR merge checkout. They are not target-SHA acceptance.

### 2. Exact Product Target acceptance — terminal result

- Run: [39767200300](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39767200300)
- Event: `workflow_dispatch`
- Workflow revision/head SHA: `264bc7cb31ed19b15254d48926ef9c15f9a67f08` (this is the workflow revision, not the product checkout).
- Final Run conclusion: `success`.
- Prepare job `119785506180` concluded `success`; its log recorded both inputs as true and the selected matrix exactly `calendar` and `sql-persistence`.
- Both scenario jobs concluded `success`: Calendar `119785537501`; SQL Persistence `119785537406`.
- Both complete job logs explicitly record `CHECKOUT_SHA=1fb3f47e76b3fd093eba8b108b745fadb35b3c69` and `EXACT_TARGET_SHA=1fb3f47e76b3fd093eba8b108b745fadb35b3c69`. The “Record and verify checkout revision” step concluded `success` in both jobs; it was not skipped.
- Calendar ran `integration_test/calendar_card_interaction_test.dart` on Android emulator and logged `00:07 +2: All tests passed`; job conclusion `success`. This target SHA's Calendar test file reported two tests passing. The three newer follow-up regression tests are not present in this target checkout and were instead executed successfully in the PR merge checkout documented above.
- SQL Persistence ran `integration_test/android_sql_persistence_smoke_test.dart` on Android emulator and logged `canonical SQL persists a full task cycle on Android` followed by `00:01 +2: All tests passed`; job conclusion `success`.
- The Calendar evidence artifact [arvin-device-smoke-calendar-264bc7cb31ed19b15254d48926ef9c15f9a67f08](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39767200300/artifacts/12421051690) was uploaded successfully (artifact ID `12421051690`, SHA-256 digest `d346428b073e7969f60a7ec5b8ea2eeb1b75c076e9db3ed021f4bd2ba535a17e`). The generic screenshot and Persian time-picker upload steps were skipped by their workflow conditions; SQL Persistence had no matching scenario-specific screenshot artifact upload.
- Exact-target Calendar and SQL Persistence acceptance: `PASS` for these two CI Android smoke scenarios, with Run ID, URLs, checkout SHA, non-skipped equality check, test output, and final conclusions recorded above.

### 3. Workflow and independent release gates

- The live `main` workflow was re-read; current blob SHA remains `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21`. It defines `target_sha`, `run_calendar`, and `run_sql_persistence`; the manual matrix selects only requested Calendar and SQL Persistence scenarios, and checkout verification fails on target mismatch. No workflow change was needed.
- Exact Product Target Build: `PASS`, existing Run `39681652761`; no duplicate build was created.
- Three new Calendar regression tests: `PASS` on PR merge checkout `c23af6b187522574374f08d2eca83c7fc85d8d08`; they are not evidence that those three tests ran on Product Target SHA.
- Calendar on Product Target SHA: `PASS` for the target's existing Calendar Android smoke test.
- SQL Persistence on Product Target SHA: `PASS`.
- SQL Migration on Product Target SHA: `NOT VERIFIED`; the exact-target manual matrix intentionally contained only Calendar and SQL Persistence. The PR run's SQL Migration success is not a substitute.
- Actual installation of the approved final APK on a physical user device: `NOT VERIFIED`.
- Real upgrade from the prior installed version and preservation of existing user data: `NOT VERIFIED`.
- Final approved application ID: `NOT VERIFIED`.
- Approved Release signing: `NOT VERIFIED`.
- SHA-256 of the final approved APK: `NOT VERIFIED`.
- Next owners: CI maintainer to decide whether exact-target SQL Migration is required and arrange it only if needed; Android/release owner to supply physical-device install/upgrade, app-ID, signing, and final APK hash evidence. No secrets, signing settings, app ID, protected PRs, or branch protections were changed.
- Overall release decision remains **`BLOCKED — RELEASE: NO-GO`** until all required release gates have valid evidence.


## Wave 6.33 — APK artifact inspection and remaining release gates

**Reviewed:** 2026-10-22  
**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**Decision:** `BLOCKED — RELEASE: NO-GO`

### Preserve Wave 6.32 evidence

- Exact-SHA Build remains **PASS**: [Run 39681652761](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761). The `apk (release)` job `119505358327` checked out the Product Target SHA, passed the exact-revision check, built `build/app/outputs/flutter-apk/app-release.apk`, verified only that the APK was non-empty, and uploaded the artifact. This run was not repeated.
- Exact-target Calendar and SQL Persistence remain **PASS** on [Run 39767200300](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39767200300): Calendar job `119785537501` and SQL Persistence job `119785537406`. Both logs recorded `CHECKOUT_SHA` and `EXACT_TARGET_SHA` equal to `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`; both Android-emulator tests passed.
- The three Calendar regression tests remain confirmed on PR merge checkout `c23af6b187522574374f08d2eca83c7fc85d8d08` in [Run 39765328178](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39765328178). This does not change their provenance to the Product Target SHA.

### Actual APK artifact retrieved and inspected

- Source Build: [Run 39681652761](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761), release job `119505358327`.
- Artifact: [`arvin-release-apk`, ID `12384962220`](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761/artifacts/12384962220), archive digest reported by GitHub as `sha256:5e970b7a9dcea77d47adc7538c04c3ecc7e156e6bf449b74e7d52a977cb1ecf9`. This digest is for the uploaded ZIP archive, not the APK file inside it.
- Downloaded archive contained exactly `app-release.apk`. The extracted APK is **70,056,469 bytes**. Its locally calculated file SHA-256 is `3d5821ebbe8982cc59cf530f159a15a6f0f4586d1be55fcf9ab4db8a072a8b13`.
- APK binary manifest extraction returned package/application ID `com.example.arvin` and version name `1.0.1`. The target source `android/app/build.gradle.kts` independently sets `applicationId = "com.example.arvin"` and retains the TODO to specify a unique application ID. No approved production application ID was found in the reviewed release evidence. Extraction is factual; approval of the product ID is **NOT VERIFIED**.
- The APK v2 signing block contains a certificate with subject/issuer `C=US, O=Android, CN=Android Debug`, serial `1`, certificate DER SHA-256 fingerprint `fb48742cd4d297e7c98b7efcdfa3d77c9e6b721ead02e1edef659c0c09630390`. The target source configures the Release build with `signingConfigs.getByName("debug")`. Therefore approved official Release signing is **BLOCKED**, not PASS. The local environment did not include `apksigner`, so a full standalone `apksigner verify` report was not produced. No secret or signing configuration was accessed or changed.
- The GitHub Build step called “Verify APK” only ran `test -s build/app/outputs/flutter-apk/app-release.apk`; it proves a non-empty file, not release-signature validity, installability, or official release approval.

### SQL Migration requirement and execution path

- The canonical migration scenario is present on the Product Target SHA at [`integration_test/android_upgrade_migration_smoke_test.dart`](https://github.com/mobinpda-lab/Arvin-clean/blob/1fb3f47e76b3fd093eba8b108b745fadb35b3c69/integration_test/android_upgrade_migration_smoke_test.dart). It exercises legacy preference data conversion into canonical SQL and loading through a fresh `TaskStore`. This is a required independent migration regression gate in the release-validation matrix, but it is not proof of upgrading an installed app while retaining real device data.
- Current default-branch workflow [`.github/workflows/device-smoke.yml`](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml), blob `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21`, already has a strict `target_sha` guard but manual dispatch selects only Calendar and SQL Persistence. SQL Migration runs on ordinary push/PR matrices, not as a selectable exact-SHA manual scenario. The successful PR migration result is not target-SHA evidence.
- The smallest workflow/test-contract-only proposal is available as Draft PR [#2916](https://github.com/mobinpda-lab/Arvin-clean/pull/2916), initial head commit `54f41345ad411aff11badbc50ad7ce0454339b22`; latest head after the CI-contract correction is `57a23d6cc8c11cb6502314984fbd5c0c280f7dce`. It adds opt-in `run_sql_migration`, keeps the existing canonical scenario mapping and fail-closed exact-SHA check, and extends the workflow contract test and Fast Lane validator. It remains open, Draft, and unmerged. No merge was attempted.
- The connected GitHub tools available for this review do not expose a workflow-dispatch action. Thus no exact-target SQL Migration run was started or fabricated. SQL Migration on the Product Target SHA is **BLOCKED** until PR #2916 receives authorized review/merge and an Actions-authorized operator dispatches it with `target_sha=1fb3f47e76b3fd093eba8b108b745fadb35b3c69` and `run_sql_migration=true`, then checks the actual checkout SHA, non-skipped guard, test output, and final conclusion.

### Installation, upgrade, and data retention

- Exact-target Calendar/SQL Persistence CI uses a temporary Android emulator and test-generated data. It does not establish that this Release APK was installed and launched as the candidate on a physical device or a release-acceptance device.
- No connected ADB device was available in the review environment. No APK install, launch, prior-version upgrade, or post-upgrade reopen/data-recovery test was performed. No user data was erased or reset.
- The migration smoke test uses mocked SharedPreferences and a fresh store instance; it is not a substitute for the real app upgrade lifecycle with existing device data.

### Wave 6.33 gate table

| Gate | Status | Evidence / remaining action |
|---|---|---|
| Exact-SHA Build | `PASS` | Run [39681652761](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761); not repeated |
| Actual APK artifact identified and downloaded | `PASS` | Artifact [12384962220](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761/artifacts/12384962220), extracted file and hash recorded above |
| SQL Migration on Product Target SHA | `BLOCKED` | Workflow capability proposal in Draft PR [#2916](https://github.com/mobinpda-lab/Arvin-clean/pull/2916); requires authorized review/merge and dispatch |
| APK package ID extracted | `PASS` | Observed `com.example.arvin`; approval against a production ID remains `NOT VERIFIED` |
| Approved production application ID | `NOT VERIFIED` | Product owner must supply/approve the expected ID |
| Official Release signing | `BLOCKED` | APK certificate identifies Android Debug; source Release config uses debug signing |
| APK file SHA-256 | `PASS` | Candidate artifact file hash: `3d5821ebbe8982cc59cf530f159a15a6f0f4586d1be55fcf9ab4db8a072a8b13`; this is not an approved final release hash |
| Install and launch of this Release APK | `NOT VERIFIED` | Android/release owner must install the candidate in an appropriate acceptance environment and record launch evidence |
| Upgrade from prior installed version | `NOT VERIFIED` | Requires a prior-version installation and real upgrade path |
| Existing data retained and recovered after upgrade | `NOT VERIFIED` | Requires before/after evidence from the real upgrade lifecycle |
| Calendar on exact target SHA | `PASS` | Run [39767200300](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39767200300), job `119785537501` |
| SQL Persistence on exact target SHA | `PASS` | Run [39767200300](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39767200300), job `119785537406` |

### Required next owners and release decision

1. **CI maintainer/reviewer:** review Draft PR [#2916](https://github.com/mobinpda-lab/Arvin-clean/pull/2916); do not merge without normal authorization. After it is authorized and available on the dispatch ref, run the SQL Migration scenario on the exact target and retain job logs.
2. **Product owner:** state and approve the intended production application ID.
3. **Android/release owner:** supply an approved release-signing configuration through the established secret-management process, produce the approved candidate without exposing keys, then verify the APK with Android SDK signing tools and record the final APK SHA-256.
4. **Android/release owner:** install and launch that exact candidate, then upgrade a prior-version installation containing test data and prove that data remains accessible after relaunch. Do not use a destructive reset of real user data.

No PR was merged, no workflow run was dispatched, no new Build was started, and no secret, signing configuration, application ID, branch protection, or user data was changed in this wave.

**Final decision: `BLOCKED — RELEASE: NO-GO`.** The artifact exists and its exact file hash is known, but its current signing certificate is Android Debug and the required SQL Migration exact-SHA, approved app ID, installation, real upgrade, and data-retention gates are not closed.


### Wave 6.33 workflow-proposal CI follow-up

- Draft PR [#2916](https://github.com/mobinpda-lab/Arvin-clean/pull/2916) initially triggered Build Run [39769189308](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39769189308) and Device Smoke Run [39769189344](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39769189344) for its initial head `54f41345ad411aff11badbc50ad7ce0454339b22`.
- The first Build Analyze job `119792131496` failed because the new Dart contract assertion interpolated the literal GitHub expression `${{ inputs.run_sql_migration }}` as Dart syntax. This was a test-contract issue, not a production-code or migration-test failure.
- Corrected the assertion to a raw Dart string in commit `57a23d6cc8c11cb6502314984fbd5c0c280f7dce`. The branch now contains that correction. A subsequent poll identified Build Run [39769361490](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39769361490) and Device Smoke Run [39769360693](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39769360693) for the corrected head; both were still pending with no terminal conclusion at the latest poll. Validation of the corrected head is therefore **IN PROGRESS**. The older Build run must not be presented as passing.
- Device Smoke Run `39769189344` was a normal pull-request run, not an exact-target manual dispatch. Its `sql-migration` job `119792161514` was queued at the poll, so it did not establish a migration test result. No target-SHA migration result is claimed.
- PR #2916 remains open, Draft, and unmerged. Continue with its normal review and inspect the new head's CI before considering it ready. No merge or manual dispatch was performed.


## Wave 6.34 — SQL Migration path and real Release readiness

**Review date:** 2026-10-22  
**Product Target SHA:** `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`  
**Release decision:** `BLOCKED — RELEASE: NO-GO`

### 1. PR #2916 and its live CI

- [PR #2916](https://github.com/mobinpda-lab/Arvin-clean/pull/2916) remains open, Draft, mergeable, and unmerged. Current head at review: `57a23d6cc8c11cb6502314984fbd5c0c280f7dce`.
- The PR adds `run_sql_migration` (default false), passes it as `RUN_SQL_MIGRATION`, and maps it to the existing canonical `sql-migration` scenario and `integration_test/android_upgrade_migration_smoke_test.dart`. The previous Calendar and SQL Persistence inputs and scenario mappings remain present; no existing test was removed or weakened in the reviewed diff.
- Strict dispatch checkout remains `ref: ${{ github.event_name == 'workflow_dispatch' && inputs.target_sha || github.sha }}`. The “Record and verify checkout revision” step compares the actual `git rev-parse HEAD` to `TARGET_SHA`, exits nonzero on mismatch, and emits `EXACT_TARGET_SHA` on success. The matrix rejects dispatches that select no scenarios.
- The raw-string fix for the workflow contract assertion is in head commit `57a23d6cc8c11cb6502314984fbd5c0c280f7dce`. Its Build Run [39769361490](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39769361490) had Analyze **PASS** (job `119793308664`, log says “No issues found!”) at the latest poll, while APK build jobs and six test shards were still running. Device Smoke Run [39769360693](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39769360693) had Prepare pass and Home/Quick Capture running; SQL Migration job `119793286039` was still queued. These are PR CI runs, not exact-target dispatch acceptance.
- No further run was created to duplicate these active runs. The PR must stay Draft until all required checks reach terminal success and human review is complete. No merge or promotion was attempted.

### 2. SQL Migration exact-target dispatch gate

- The live default-branch workflow is [`.github/workflows/device-smoke.yml`](https://github.com/mobinpda-lab/Arvin-clean/blob/main/.github/workflows/device-smoke.yml), blob `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21`. It does **not** yet declare `run_sql_migration`; therefore no exact-target migration dispatch was started.
- The capability exists only in Draft PR #2916 until normal authorized review and merge. After the workflow is present on the approved dispatch ref, an authorized operator must dispatch `workflow_dispatch` with target SHA `1fb3f47e76b3fd093eba8b108b745fadb35b3c69`, `run_sql_migration=true`, `run_calendar=false`, and `run_sql_persistence=false`. Verify the matrix contains only `sql-migration`, the actual checkout SHA and `EXACT_TARGET_SHA` match the target, the Android test succeeds, and the whole run concludes success.
- SQL Migration on the Product Target SHA remains **NOT VERIFIED** until that run exists and passes.

### 3. Application ID and Release signing

- At Product Target SHA, `android/app/build.gradle.kts` sets namespace and application ID to `com.example.arvin` and still contains the TODO asking for a unique application ID. Product `pubspec.yaml` reports `version: 1.0.1+2`. Searches of repository code for an approved production application ID did not identify a separate authoritative value. Thus the extracted package ID is known, but approval of the official production ID is **NOT VERIFIED**. The ID was not changed.
- The current `build.yml` builds `flutter build apk --release` and checks only that the output file is non-empty before upload. It does not configure a production signing identity or verify the APK with `apksigner`. Product Target `build.gradle.kts` explicitly uses `signingConfigs.getByName("debug")` for the Release build.
- The current `release.yml` creates a GitHub Release tag and release notes; it does not build/sign an APK. No public repository workflow configuration reviewed here establishes an approved release keystore or signing identity. Secret values were not read or changed.
- Official Release signing remains **BLOCKED** pending owner-approved application ID and authorized signing configuration. Do not generate a purported official APK before those approvals exist.

### 4. APK, install, upgrade, and retained data

- The previously inspected candidate remains the artifact from Build [39681652761](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761), Artifact [12384962220](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761/artifacts/12384962220). It was `app-release.apk`, 70,056,469 bytes, extracted ID `com.example.arvin`, version `1.0.1`, file SHA-256 `3d5821ebbe8982cc59cf530f159a15a6f0f4586d1be55fcf9ab4db8a072a8b13`. Its certificate was Android Debug. This hash belongs only to that prior candidate, not to any future official APK.
- The Build Run above was not repeated. The active PR Build Run `39769361490` is for the PR head, not the Product Target SHA, and cannot replace the target build or provide a signed official candidate.
- No device installation, launch, real upgrade from a previous installed version, or post-upgrade data-recovery evidence was available. These gates remain **NOT VERIFIED**. Migration smoke tests and emulator integration tests do not prove the real installed-app upgrade lifecycle. No user data was reset.

### 5. Preserve previous successful target-SHA evidence

- Exact-SHA Build: **PASS**, Run [39681652761](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761); not repeated.
- Exact-target Calendar and SQL Persistence: **PASS**, Run [39767200300](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39767200300), jobs `119785537501` and `119785537406`.
- Calendar regression tests on the separate PR merge checkout: **PASS**, Run [39765328178](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39765328178). Their provenance remains separate from the Product Target SHA.

### 6. Wave 6.34 status table

| Gate | Status | Evidence / next action |
|---|---|---|
| PR #2916 contract and CI | `IN PROGRESS` | Analyze passes; Build test shards/APK and Device Smoke not yet terminal at latest poll |
| Workflow has migration input on main | `BLOCKED` | Current main workflow blob `f9c79cd182e242beeec01aa8ffdf3e8e4d2fbf21` lacks input |
| SQL Migration on Product Target SHA | `NOT VERIFIED` | Wait for authorized PR review/merge, then exact-target manual dispatch |
| Official application ID | `NOT VERIFIED` | Product owner must confirm the intended production ID |
| Official Release signing | `BLOCKED` | Release build uses Android Debug signing; authorized signing configuration and verification required |
| Existing candidate APK/hash | `PASS` | Artifact [12384962220](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39681652761/artifacts/12384962220); not an official release candidate |
| New official APK and SHA-256 | `BLOCKED` | Produce only after ID/signing approval; calculate hash from the new downloaded file |
| Install and launch approved APK | `NOT VERIFIED` | Requires installable approved candidate and suitable Android acceptance environment |
| Upgrade and data retention | `NOT VERIFIED` | Requires prior-version installation with test data and before/after recovery evidence |
| Documentation on GitHub | `PASS` | This Wave 6.34 update is being recorded on the existing documentation branch and must be reread after commit |

### 7. Required owners and decision

1. **CI reviewer/maintainer:** finish reviewing PR #2916, confirm its complete CI is green, then use normal authorized review/merge. Do not leave Draft or merge automatically.
2. **Product owner:** approve the production application ID in an authoritative project record.
3. **Android/release owner:** arrange authorized signing configuration through established secret management, then verify the produced APK using Android SDK tools without exposing private key material.
4. **Android/release owner:** install/launch the exact signed APK and execute the non-destructive previous-version upgrade/data-retention acceptance.

No workflow dispatch, merge, signing-secret change, application-ID change, user-data reset, or repeat of Build Run `39681652761` was performed during this wave.

**Final decision: `BLOCKED — RELEASE: NO-GO`.**
