# ARVIN Repository-Wide Audit — 2026-10-11
Status: Initial deep audit checkpoint; not a claim that every historical commit or every open issue has been individually reviewed.
Repository: mobinpda-lab/Arvin-clean
Current main: a6ced27660d34cd87dd8915aff68d3a7555fd57a
Audit branch: docs/arvin-autonomous-memory-20261011
GitHub access: Read/Write verified. No application code, schema, migration, release, PR state, or main-branch change was made during this audit.

## Inventory snapshot
- Current main recursive tree: 740 paths; 190 documentation files; 249 test/integration-test files; 21 GitHub Actions workflows.
- Branches: 1,248 returned across the first 13 pages (12 full pages plus 48 on page 13).
- Open pull requests: 19.
- Open issues: 1,096.
- Open issues matching AUTO-FIX search: 876.
- Open issues labelled priority:core: 16; factory:blocked: 4; release: 3.
- Actions query for the current main SHA returned 1,535 workflow runs at the latest poll. These are not 1,535 independent build validations: the list is dominated by release-closure/final-validation/orchestration workflow_run fan-out.

## P0 — release and automation
1. Release gate is still blocked. Issue #2102 is open and PR #1901 (P0/P1 installed-device regression) is open. Release Closure runs #38164280335 and #38164393875 failed at the explicit product gate; Final Head Release Validation #38164416537 was skipped. Existing prereleases remain Draft and marked unapproved. Do not publish or close gates automatically.
2. Release workflow feedback loop remains active on main. Current .github/workflows/release-closure.yml triggers on every completion of Arvin Production Orchestrator, while that orchestrator is awakened by Build, Device Smoke, Parallel Wave and a five-minute schedule. The same main SHA has hundreds of repeated Release Closure / Final Head Release Validation runs, many cancelled, skipped or failed. Existing PR #2531 specifically targets trigger isolation but remains open and is 18 commits behind current main in compare output. Reconcile and validate that existing lane; do not create a duplicate fix.
3. The separate manual .github/workflows/release.yml can create a release from workflow_dispatch with contents:write without consuming the explicit #2102 gate or verified APK/evidence flow. It is a potential release-policy bypass and must be consolidated/guarded before normal release use.
4. Version/tag contract is inconsistent. pubspec.yaml is 1.0.1+2; release-closure computes a tag of the form v1.0.1-build2-arvin-<current-main-short-SHA>, while existing Draft prerelease tags are v0.1.0-arvin-dd95132 and v0.1.0-arvin-33ed363. Issue #2135 is still open and its body still calls 1.0.0+1 the baseline. Reconcile one canonical naming rule and validate artifacts/checksums before delivery.

## P1 — report filter and time-picker acceptance
1. On current main, lib/report_center_page.dart still uses Flutter showDatePicker and showTimePicker (around lines 249 and 270). User-visible date/time selection is therefore not yet Persian/Jalali and shared-picker compliant on main.
2. PR #2607 head 7526dc186a26d099368fb288fdc7891ed57222ce has exact-head Build run #38163761104 SUCCESS: Analyze, all six test shards, Debug APK and Release APK all passed. Device Smoke #38163760935 is SKIPPED because the PR is Draft; no device pass is claimed.
3. PR #2607 and PR #2591 overlap in lib/main.dart, lib/report_center_page.dart and lib/widgets/universal_arvin_time_picker.dart. The picker file blob is identical on both branches, but report/home call-site changes still require deliberate sequencing/reconciliation. PR #2591's Build passed, but its Device Smoke was also skipped. Do not merge the two independently without reconciling the shared files.
4. The current Report Filter Decision file has the same blob SHA on PR #2607 and PR #2608. Keep one canonical owner for this decision and avoid duplicate ownership.

## P1 — task form contract mismatch
1. Issue #2593 accepts Quick Add + Full Editor as two experiences over one canonical Task and explicitly lists an optional Task Note distinct from Description. PR #2594 records that decision.
2. PR #2595's current source does not show a root Task.note field in Task serialization or a Note input/controller in the editor, even though the PR description still claims Task.note is implemented and lists an old head SHA. The only note field found in the inspected model excerpt is FollowUp.note. This is a source-vs-description mismatch and an incomplete accepted product requirement; update the PR description and complete or explicitly reconcile the Task Note slice before merge.
3. PR #2595 is stacked on the Universal Time Picker lane; PR #2602 separately changes Task Editor layout. They must be validated as one coherent final form, including draft identity, save/cancel, date/time, reminder, repeat, checklist, Follow-up, taxonomy and Note.

## P1 — governance and memory drift
1. Main docs/ARVIN_STATUS.md still refers to PR #135 and package v49.0; docs/ARVIN_PROJECT_STATE.md also describes old documentation state. The current operating package on main is v49.1. These are stale operational instructions.
2. docs/ARVIN_PROJECT_OPERATING_PACKAGE.md points to AMPOP v5 as the highest authority, but that constitution file is only introduced by unmerged PR #2598 and is not present on main. The owner supplied Command v8 is not yet preserved as a canonical file on main; this audit branch adds an exact v8 record for review.
3. PRs #2598, #2599, #2600 and #2601 were created from merge base 72a2f4cc24df7a38eff9856ce403461615db5280 and are behind current main. Compare output: #2598 is 16 commits ahead/2 behind, #2599 6 ahead/2 behind, #2600 116 ahead/2 behind, #2601 72 ahead/2 behind. PR #2598 and #2599 both change docs/ARVIN_STATUS.md, creating overlapping documentation ownership. Reconcile against current main and consolidate the canonical status/governance layer before merge.
4. Before this audit, PR #2600 contained 11 files under docs/arvin-memory, not only the six named required memory files; it also contained parallel/history files (CHAT_HISTORY_SUMMARY, CONVERSATION_DECISION_HISTORY, PROBLEMS, PROBLEM_REGISTER, SOLUTIONS, ROADMAP). This audit adds two files (the verbatim owner Command v8 and this audit), bringing the branch total to 13. Decide which supplementary files are canonical vs historical so memory itself does not become a new source of duplication. The memory directory is absent from main until a PR merges.
5. docs/project_completion_scorecard.json and docs/progress_scorecard.json still use August 2026 baseline dates and old main SHAs. DOCUMENT_AUTHORITY_INDEX calls them official scorecards, so their stage values need current-main evidence reconciliation before being treated as current progress.
6. .gitignore's font comment still mentions Vazirmatn although pubspec.yaml uses VazirHarf. This is low-risk but clear stale documentation.

## P1 — queue, issues and acceptance
1. There are 876 open AUTO-FIX search results, which can compete with current product work. The queue has stale-lease protection, but the volume and repeated failures suggest a feedback/noise problem; classify historical failure records by exact SHA/root cause and close only when evidence proves they are superseded.
2. Issue #866 remains open for premature Recovery Wave auto-close. Its acceptance requires a regression test proving a parent Wave cannot close after only a partial child PR merge. Keep this open until that behavior is proven on current main.
3. Issue #1139 is the current installed-device acceptance ledger and still has unchecked owner acceptance: install current-main APK on phone/tablet, verify Quick Entry and same-draft Full Editor continuation, tablet contrast, imported calendar event actions, Notebook flows, and Persian/Jalali/Iran-local presentation. This newer ledger conflicts with older Issue #358 text that had temporarily deferred physical-device checks; use the newer explicit acceptance ledger for current handover.
4. Issue #2248 remains an architecture/acceptance gate: changing target calendar may leave sync directed at the old calendar; acceptance requires two real target calendars, stable Task↔Event identity and no duplicates.
5. Issue #2254 and #2605 keep Repeat cycle/history/tracking acceptance open. Preserve one canonical Task/Repeat model; prove occurrence independence and immutable past history.
6. Issue #2580 remains open for Project/Category/Tag cross-surface conformance. The ADR says Project, Category and Tag are the only taxonomy concepts; Category and Group are synonyms, not separate entities.
7. Issue #1324 remains open even though current main TaskStore uses SQL/Drift with a one-time SharedPreferences migration path. Its latest recorded exact-main evidence refers to an older SHA from September. Re-run current-main migration/idempotency/round-trip/backup evidence and then reconcile the issue; do not claim migration missing solely from its old status.

## P2 — repository scale and historical drift
1. The 1,248 branches need a branch inventory separating active PR branches, accepted/recovery branches, historical branches and orphan candidates. Do not bulk-delete branches without checking open PRs and release evidence.
2. The latest 300 commit API entries were sampled for history context, but not every historical commit diff was individually reviewed. Likewise, the 1,096 open issues were not read one by one; the audit used complete open-PR inventory, repository inventory, targeted high-priority issue reads and issue-search counts. This is a bounded audit checkpoint, not a false claim of exhaustive line-by-line review.
3. Current main source is the authority for implementation. Old project docs and old issue comments remain historical evidence unless explicitly reconciled with current code and newer owner decisions.

## Open PR inventory reviewed
#2600 memory; #2607 pastel/report filters; #2608 owner requirements/report decision; #2606 repeat defaults; #2595 task form (stacked); #2602 task editor; #2591 shared time picker; #2590 time-picker standard; #2598 governance; #2601 integrated APK candidate; #2599 repository audit; #2594 task-form decision; #1901 real-device regression; #2578 Home taxonomy filters; #2577 Notebook category filter; #2579 Settings taxonomy entry; #2556 queue deferral; #2538 notification settings; #2531 release-closure isolation. All remain open at this snapshot.

## Next actions in dependency order
1. Stop release-closure fan-out using the existing #2531 lane after rebasing/reconciling it to current main and running exact-head contract/Build checks.
2. Preserve Command v8 and consolidate the governance/memory PRs; rebase stale documentation branches and remove overlapping status/decision ownership.
3. Reconcile #2591/#2607 shared time-picker/report files and validate Persian/Jalali date and time selection on the installed app; keep Draft until smoke/owner acceptance is complete.
4. Reconcile #2593/#2594/#2595/#2602 Task Note and form contracts, then validate same-Task draft identity, persistence, backup/restore and all relevant tests.
5. Refresh exact-main Build/Device Smoke evidence, resolve #2102/#1901/#1139 and only then evaluate the release tag/artifact contract.
6. Continue targeted issue/branch/commit history passes; do not declare the whole repository audit complete until remaining history and stale queue records are reconciled.
