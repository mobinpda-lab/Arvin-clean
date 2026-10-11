# ARVIN Execution State

**Checkpoint date:** 2026-10-11  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Default branch:** `main`  
**State:** IN PROGRESS — release readiness is not proven.

## Latest confirmed baseline
- Latest observed main commit: `a6ced27660d34cd87dd8915aff68d3a7555fd57a` — [backup/restore preservation](https://github.com/mobinpda-lab/Arvin-clean/commit/a6ced27660d34cd87dd8915aff68d3a7555fd57a).
- `docs/arvin-memory/` checkpoint package is being built in Draft PR #2608, branch `docs/report-filter-memory-20261011`; these files are not yet on main.
- The package now contains execution state, conversation continuity, report-filter decision, decision log, project knowledge, user-experience log, problem register and evidence map.

## Last completed step
Refreshed exact-head workflow evidence; inspected the Task Editor test failure logs; updated affected widget tests to expand the advanced-details section before interacting with controls that are intentionally collapsed by default; created and verified the canonical memory files on the existing documentation branch.

## Completed with evidence
- Main commit `a6ced27660d34cd87dd8915aff68d3a7555fd57a` records backup/restore preservation and reports Build + Android Device Smoke validation in its commit message. Fresh installed-user acceptance for the currently proposed release still remains separate.
- PR #2607 (`7526dc186a26d099368fb288fdc7891ed57222ce`) Build succeeded; Device Smoke was skipped. It remains Draft.
- PR #2591 (`eae0394163a958223b79fc3b7aa914f79b664b8a`) Build succeeded; Device Smoke was skipped. It remains Draft.
- PR #2606 (`323b5a6afddd7977450ead87467e5d9dac206b04`) Build succeeded; Device Smoke was skipped. It remains Draft.
- Earlier PR #2602 workflow run `38139809938` exposed four failures in test shard 5, including three Task Editor tests that attempted to interact with advanced controls while the section was collapsed, and one all-day test with the same missing expansion setup. Two other shards were still running at last check.
- Added explicit expansion of `task-editor-more-details` to the affected tests on PR #2602. New exact-head: `879c2bf618e53f3f0bf57f7592e60ea4b8cdde6d`. Build run `38166244359` was queued/in progress at last check; all nine jobs were in progress. This is not yet a pass.
- The memory package files were confirmed present on branch `docs/report-filter-memory-20261011`; PR #2608 remains Draft.

## In progress
1. Confirm fresh exact-head PR #2602 test shards/build after the targeted test fixes; inspect any remaining failures and repair product/test causes rather than rerunning blindly.
2. Reconcile Report Center with the shared Universal Arvin Time Picker: PR #2607 still has a generic `showTimePicker` gap identified in the report-filter decision, while PR #2591 contains the shared picker migration. Keep the changes in one coherent, tested branch/stack.
3. Review recurrence defaults/date-time behavior in PR #2606; Device Smoke/physical-device acceptance remains unproven.
4. Verify owner-reported calendar target identity/actions and recurring-day visibility on an installed APK, using issues #2248 and #2535.
5. Close Project settings and Notebook interaction/persistence defects from existing issues #2151 and #850 without duplicate issues or parallel storage.
6. Reconcile overlapping documentation/UI PRs and the memory package before merging any of them.

## Blocked / acceptance gates
- No fresh physical-device/owner acceptance evidence for current report/UI/Task Editor changes.
- Report time filter has not yet been validated on the combined branch with the shared Persian-first picker.
- Task Editor's new exact-head full tests/build are pending.
- Relevant UI/recurrence PRs remain Draft and their Device Smoke runs are skipped.
- No stable published release was returned by the current GitHub release query; available release entries are drafts/prereleases.

## Next action
Refresh jobs for PR #2602 head `879c2bf618e53f3f0bf57f7592e60ea4b8cdde6d`; fix any remaining test failures and wait for all shards/build to finish. Then reconcile #2607/#2591 and add focused Persian/Jalali time-picker regression coverage. Keep isolated branches, no direct main write, and no merge without exact-head checks plus relevant device/owner acceptance.

## Product guardrails
- Task is the canonical source of truth; Calendar is a projection and Reports are read-only consumers.
- Project, Category and Tag are canonical taxonomy concepts; do not invent a separate Group model.
- Checklist and recurrence belong to the canonical Task flow; recurrence must not create copied Tasks and past history must be preserved.
- Quick Add and Full Form must retain the same canonical Task identity.
- Preserve user data, stable IDs, Persian RTL and VazirHarf v34.003.
- Mark work DONE only with code, test, build, validation and evidence appropriate to the change.
