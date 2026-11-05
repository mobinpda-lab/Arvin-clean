# ARVIN Wave 7.32 — Live Baseline Before Changes

**Observed at:** 2026-10-24, approximately 17:24 UTC (GitHub Actions log timestamp)  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Issue / acceptance ledger:** [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139)  
**Reminder remediation:** [#2966](https://github.com/mobinpda-lab/Arvin-clean/issues/2966)  
**Reminder contract PR:** [#2963](https://github.com/mobinpda-lab/Arvin-clean/pull/2963)  
**Initial release status:** `BLOCKED — RELEASE: NO-GO`

## 1. Repository and environment

- GitHub repository is accessible. Repository metadata identifies `main` as the default branch; available permissions report admin/maintain/push.
- Current observed `main` tip: `18cbeecc95a03a3b301359ca5b96cfef175a3b15`.
- Commit: [18cbeecc](https://github.com/mobinpda-lab/Arvin-clean/commit/18cbeecc95a03a3b301359ca5b96cfef175a3b15), merge of PR #2916, “ci(arvin): add exact-SHA SQL migration smoke dispatch”.
- Main SHA was confirmed by recent commit search and fetching the commit itself. The commit-workflow-runs helper returned no runs for this main SHA because it filters to pull-request-triggered runs; this is **not** evidence that main has no workflow runs.
- No local checkout/terminal is available through the current execution path. Local branch, `git status`, uncommitted changes, local tests and local APK state are therefore **NOT VERIFIED**.
- No code or configuration was changed on `main` during this baseline collection.

## 2. Current product decision and document authority

The owner's latest explicit decision is settled: “پیگیری بعدی” and “پیگیری مستقل” were removed and replaced by Reminder. Current scheduling model is canonical Task + independent due date + zero or more stable-ID Reminders; Arvin alarm delivery and phone Calendar synchronization are separate delivery channels.

The following current decision files exist on the open documentation branch `docs/wave-7-31-reminder-contract`:
- [ARVIN_REMINDER_CONTRACT.md](https://github.com/mobinpda-lab/Arvin-clean/blob/docs/wave-7-31-reminder-contract/docs/arvin-memory/ARVIN_REMINDER_CONTRACT.md), content blob `b323eb35748c60c32a3001103e3b60cf7a6b91be`.
- [ARVIN_OWNER_DECISION_REMINDER_ONLY.md](https://github.com/mobinpda-lab/Arvin-clean/blob/docs/wave-7-31-reminder-contract/docs/arvin-memory/ARVIN_OWNER_DECISION_REMINDER_ONLY.md), content blob `be2ffa7ffc77671c28bfc9ab09413ea3a10cefc6`.
- The older `ARVIN_FOLLOW_UP_CONCEPT_DECISION.md` has a superseded-status notice on that branch.

PR #2963 is **OPEN / DRAFT / UNMERGED**, base `main` at `18cbeecc95a03a3b301359ca5b96cfef175a3b15`, head `7ab0d40e8f86333c6dc26f4ce14bc4aed77ae812`, mergeable reported true. Its Build succeeded, but Device Smoke failed in Calendar; therefore this PR is not product-accepted.

The requested Product Reference v1.4 was not found:
- Exact expected path `docs/arvin-memory/ARVIN_PRODUCT_REFERENCE_V1_4.md` returned GitHub 404.
- Searches for `ARVIN_PRODUCT_REFERENCE v1.4`, `product reference version 1.4`, and `ARVIN_PRODUCT_REFERENCE` returned no matching indexed results.
- `docs/product/ARVIN_PRODUCT_CONCEPTS.md` at main also returned 404.
This establishes only that the requested reference was not found at the checked paths/search results; it does not prove no differently named copy exists anywhere. Do not fabricate it.

## 3. Live issue state and conflict

- Issue #1139 is OPEN, last updated `2026-10-24T17:06:42Z`: [acceptance ledger](https://github.com/mobinpda-lab/Arvin-clean/issues/1139).
- Issue #2966 is OPEN, last updated `2026-10-24T17:06:53Z`: [P0 Reminder-only remediation](https://github.com/mobinpda-lab/Arvin-clean/issues/2966).
- Important discrepancy: current #1139 body still contains an older checklist item stating “FollowUp remains part of the canonical Task, supports multiple entries/history, latest FollowUp on Home, independent reminder”. This conflicts with the later owner decision and current Reminder-only contract. Correct the ledger after this baseline is recorded; preserve the older statement as historical context only if needed.
- #2966 tracks code-level remediation, but its existence is not evidence that implementation is complete.

## 4. Relevant PR inventory observed live

All SHA values below are GitHub PR metadata. “Open” does not mean accepted. Stacked PRs with stale bases must not be merged without rebase/reconciliation.

| PR | State / draft | Base SHA | Head SHA | Baseline interpretation |
|---|---|---|---|---|
| [#2963](https://github.com/mobinpda-lab/Arvin-clean/pull/2963) | Open / Draft | `18cbeecc...` | `7ab0d40e...` | Reminder contract docs; Build PASS, Device Smoke FAIL |
| [#2965](https://github.com/mobinpda-lab/Arvin-clean/pull/2965) | Open / Draft | `18cbeecc...` | `6b9a14a4...` | Calendar diagnostic-only; Device Smoke Calendar FAIL |
| [#2961](https://github.com/mobinpda-lab/Arvin-clean/pull/2961) | Open / Draft | `18cbeecc...` | `dd5279b4...` | File-backed SQLite multiple-reminder regression; earlier focused test passed, not full acceptance |
| [#2960](https://github.com/mobinpda-lab/Arvin-clean/pull/2960) | Open / Draft | `18cbeecc...` | `ff255529...` | Initializes reminder from legacy Next Follow-up; conflicts with current settled contract |
| [#2951](https://github.com/mobinpda-lab/Arvin-clean/pull/2951) | Open / Draft | `18cbeecc...` | `60a9f04f...` | Calendar exclusion behavior, description/contract requires reconciliation |
| [#2895](https://github.com/mobinpda-lab/Arvin-clean/pull/2895) | Open / Draft | `d9fb7a24...` | `6c94c708...` | Old-base diagnostic test; not current-main acceptance evidence |
| [#2940](https://github.com/mobinpda-lab/Arvin-clean/pull/2940) | Open / Draft | `18cbeecc...` | `6cdf192f...` | Removes Quick Entry Follow-up toggle; narrative needs Reminder-only reconciliation |
| [#2828](https://github.com/mobinpda-lab/Arvin-clean/pull/2828) | Open / Draft | `d9fb7a24...` | `4dded4d7...` | Old-base canonical-record work; reconcile |
| [#2832](https://github.com/mobinpda-lab/Arvin-clean/pull/2832) | Open / Draft | stacked on #2828 head `49910e58...` | `acb06279...` | Stacked legacy Follow-up reminder records; do not merge independently |
| [#2665](https://github.com/mobinpda-lab/Arvin-clean/pull/2665) | Closed / Merged | historical base `ee73adbc...` | `ec34aa8f...` | Already merged historically; its internal projection is present in current source and must be audited, not treated as an open PR |
| [#2662](https://github.com/mobinpda-lab/Arvin-clean/pull/2662) | Open / Ready | `ee73adbc...` | `44af216c...` | Old architecture record conflicts where it describes retired concepts as current |
| [#2640](https://github.com/mobinpda-lab/Arvin-clean/pull/2640) | Open / Ready | `326afaa2...` | `2d62e315...` | Experimental Calendar integration, old base |
| [#2636](https://github.com/mobinpda-lab/Arvin-clean/pull/2636) | Open / Ready | `326afaa2...` | `6d970ace...` | Old Calendar origin / Follow-up fields, contract reconciliation required |
| [#2667](https://github.com/mobinpda-lab/Arvin-clean/pull/2667) | Open / Draft | `3f4b7299...` | `85d8983e...` | Reminder foundation/migration; old base, reconcile before use |
| [#2866](https://github.com/mobinpda-lab/Arvin-clean/pull/2866) | Open / Draft | `d9fb7a24...` | `6f450f16...` | Product concept contract, old base; inspect against current owner decision |
| [#2934](https://github.com/mobinpda-lab/Arvin-clean/pull/2934) | Open / Draft | `18cbeecc...` | `d20b9b51...` | Release signing safety |
| [#2898](https://github.com/mobinpda-lab/Arvin-clean/pull/2898) | Open / Draft | `d9fb7a24...` | `1a800e13...` | Release signing guard, old base |
| [#2906](https://github.com/mobinpda-lab/Arvin-clean/pull/2906) | Open / Draft | `d9fb7a24...` | `7ad84215...` | Exact-SHA Device Smoke workflow, old base and mergeability false |
| [#2947](https://github.com/mobinpda-lab/Arvin-clean/pull/2947) | Open / Draft | `18cbeecc...` | `050a1784...` | Recurrence/Home projection; must be included in cross-feature regression |
| [#2919](https://github.com/mobinpda-lab/Arvin-clean/pull/2919) | Open / Draft | `18cbeecc...` | `b61d701b...` | Backup/Restore data integrity |
| [#2959](https://github.com/mobinpda-lab/Arvin-clean/pull/2959) | Not fully re-fetched in this baseline | — | — | Project persistence PR appeared in open search; inspect if project code is touched |
| [#2958](https://github.com/mobinpda-lab/Arvin-clean/pull/2958) | Not fully re-fetched in this baseline | — | — | Home note navigation PR appeared in open search; inspect if Home paths are touched |
| [#2941](https://github.com/mobinpda-lab/Arvin-clean/pull/2941) | Not fully re-fetched in this baseline | — | — | Home/Report taxonomy filters; inspect if report filters are touched |
| [#2932](https://github.com/mobinpda-lab/Arvin-clean/pull/2932) | Not fully re-fetched in this baseline | — | — | Backup/Restore and typography integration; inspect before touching backup path |

Search returned more open PRs than the table. This is a focused cross-cutting inventory, not a claim that every open PR in the repository has been inspected. Before touching recurrence, reports, checklist or backup code, expand the inventory to every relevant open PR and fetch its exact head/base/checks.

## 5. Workflow and device evidence

### PR #2963 head `7ab0d40e8f86333c6dc26f4ce14bc4aed77ae812`
- Build run [40114487936](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/40114487936): **SUCCESS**.
- Device Smoke run [40114487909](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/40114487909): **FAILURE**.
- Seven non-Calendar smoke lanes completed successfully: Backup/Restore, Home, SQL Migration, People, SQL Persistence, Quick Capture; Prepare selected scenarios also passed.
- Calendar job [120933077944](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/40114487909/job/120933077944): **FAIL**. It expected key `reminder-card-followup:calendar-smoke-task:calendar-smoke-follow-up`, found zero widgets at `integration_test/calendar_card_interaction_test.dart:66`. Artifact upload also failed because expected screenshot files were absent; that upload error is secondary to the assertion failure.

### PR #2965 head `6b9a14a4df421e1227a8f7807f657a19b0ebf465`
- Build run [40113975670](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/40113975670): **SUCCESS**.
- Device Smoke run [40113975705](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/40113975705): **FAILURE**.
- Calendar job [120931336455](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/40113975705/job/120931336455): **FAIL**. Other selected smoke lanes completed successfully.
- Diagnostic logs establish:
  - after SQLite seed: one Task, ID `calendar-smoke-task`, one legacy FollowUp ID `calendar-smoke-follow-up`, reminder date present;
  - after app startup: same Task and FollowUp still load;
  - standalone `FollowUpCalendarProjection`: count 1, ID `followup:calendar-smoke-task:calendar-smoke-follow-up`;
  - after navigating to Calendar, the expected UI card key remains absent.
- This narrows the failure to the UI/launcher/selected-day/card path after standalone projection. It does **not** yet prove the exact root cause. The current test and standalone projection still exercise the retired Follow-up flow, so this test is not valid final Reminder-only acceptance.

### Baseline workflow limitations
- The workflow-runs helper used here filters to pull-request-triggered runs. It returned no runs for main SHA; this is a tool/query limitation, not a successful or failed main validation result.
- No current-main APK artifact, signature verification, installed-device upgrade or owner acceptance was established by this baseline.

## 6. Repository audit findings from source on main

Observed source files include:
- `lib/models/task.dart`: `FollowUp` with `reminderDate` and `nextFollowUp`, legacy Task fields, and canonical `TaskReminder` coexist.
- `lib/services/follow_up_internal_calendar_projection.dart`: old `nextFollowUp`-driven internal Calendar projection exists.
- `lib/widgets/canonical_calendar_launcher.dart`: wires `FollowUpInternalCalendarProjection`, `FollowUpWriteCoordinator`, legacy editors and scheduler paths.
- `lib/services/follow_up_calendar_projection.dart`: legacy FollowUp projection exists alongside canonical Task Reminder data.
- `lib/services/follow_up_reminder_alarm_planner.dart` and `lib/android_follow_up_reminder_scheduler.dart`: legacy-named alarm path needs full caller/data-flow audit.
- `lib/task_editor_dialog.dart`, `lib/follow_up_entry_page.dart`, `lib/follow_up_repository.dart`, `lib/services/task_edit_apply_service.dart`, `lib/services/task_store.dart`, `lib/services/task_migration_writer.dart`, `lib/services/sql_task_migration_writer.dart`, `lib/services/calendar_inbound_sync_service.dart`: legacy edit/storage/migration paths.
- `lib/services/task_list_scope_service.dart`, `lib/services/home_list_projection.dart`, `lib/main.dart`: legacy list/scope/swipe paths.
- `integration_test/calendar_card_interaction_test.dart`, `test/calendar_page_test.dart`, `test/calendar_release_acceptance_test.dart`: legacy card key/Follow-up editor acceptance.
- Older docs, including `docs/arvin-memory/ARVIN_CALENDAR_PROJECTION_SEPARATION_DECISION.md`, still encode the retired split and must be marked historical where they conflict.

This is a verified inventory of examples, not a complete transitive call graph. No production code change is authorized until the affected paths and data contracts are mapped.

## 7. Baseline gate table

| Gate | Status | Evidence / reason |
|---|---|---|
| GitHub access and default branch | PASS | Repository metadata and branch search |
| Current main SHA | PASS | `18cbeecc95a03a3b301359ca5b96cfef175a3b15` from recent commits and fetched commit |
| Local Working Tree / uncommitted files | NOT VERIFIED | No local checkout/terminal in this environment |
| Product Reference v1.4 | NOT VERIFIED | Expected path 404; searches found no match |
| Reminder-only owner decision recorded | PASS (on PR branch only) | Contract and owner decision files exist on #2963 head; not merged into main |
| Issue #1139 internally consistent with current decision | FAIL | Issue body still contains older FollowUp-current checklist |
| Issue #2966 remediation tracked | PASS | Open P0 issue with audit scope/DoD |
| PR #2963 Build | PASS | Run 40114487936, exact head 7ab0d40e... |
| PR #2963 Device Smoke Calendar | FAIL | Run 40114487909, job 120933077944 |
| PR #2965 diagnostic Build | PASS | Run 40113975670, exact head 6b9a14a4... |
| PR #2965 diagnostic Device Smoke Calendar | FAIL | Run 40113975705, job 120931336455 |
| Full legacy call-graph audit | NOT VERIFIED | Only initial repository-wide search and selected source inspection completed |
| Safe/idempotent migration for all legacy records | NOT VERIFIED | No end-to-end migration acceptance evidence in this baseline |
| Current-main APK/signature/physical-device acceptance | NOT VERIFIED | No matching evidence established |
| Release | BLOCKED — RELEASE: NO-GO | Calendar acceptance failed and multiple release gates are unverified |

## 8. Approved next steps after baseline

1. Keep this baseline immutable as the before-state record.
2. Correct Issue #1139's contradictory current FollowUp checklist against the settled owner decision; do not rewrite product history as if it never existed.
3. Reconcile relevant PR descriptions/bases and identify already-merged legacy behavior. Do not merge anything without explicit owner permission.
4. Complete source/caller/data-flow audit for TaskReminder, legacy fields, Calendar projections, alarms, SQLite/JSON, migration, recurrence/checklist, reports and Backup/Restore.
5. Rebuild the Calendar integration test around canonical TaskReminder identity and current Reminder UX; preserve strong assertions and prove each stage.
6. Implement only the mapped fixes on a separate branch, with safe idempotent migration and no parallel store/engine.
7. Run baseline-relevant tests, changed tests, exact-head Analyze, test shards, Debug/Release builds and Device Smoke. Inspect all job logs/artifacts.
8. Only after CI passes, proceed to signed APK verification, install/upgrade on the owner's real device and explicit owner acceptance.

No PR was merged, no direct-main change was made, and no product-code fix is claimed in this baseline report.
