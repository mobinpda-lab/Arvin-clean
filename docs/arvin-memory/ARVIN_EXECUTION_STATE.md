# ARVIN Execution State

**Checkpoint date:** 2026-10-11  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Default branch:** `main`  
**State:** IN PROGRESS — release readiness is not proven.

## Latest confirmed baseline
- Latest observed main commit: `a6ced27660d34cd87dd8915aff68d3a7555fd57a` — [backup/restore preservation](https://github.com/mobinpda-lab/Arvin-clean/commit/a6ced27660d34cd87dd8915aff68d3a7555fd57a).
- Previous durable continuity checkpoint and report-filter decision exist on documentation PR #2608's branch; these are not yet present at this path on main.
- Current checkpoint is being added to documentation PR #2608, branch `docs/report-filter-memory-20261011`; it is not a claim of merge or release acceptance.

## Last completed step
Live GitHub audit of latest main commit, open pull requests, open issues, branches, relevant documentation and exact-head workflow results.

## Completed with evidence
- Main includes the backup/restore preservation commit and prior calendar event update work; the commit descriptions cite validation, but this checkpoint does not substitute those checks for current installed-device acceptance.
- PR #2607 (`7526dc186a26d099368fb288fdc7891ed57222ce`) has Build success, all six test shards recorded successful in its current description, and Device Smoke skipped. It remains Draft.
- PR #2608 (`e56b63a39b0bdba5021c45dac097dc4e7a076118`) contains continuity and report-filter decision documentation. It remains Draft.
- A failed-job retry was requested for Build run `38139809938` on Task Editor PR #2602. At last check, retry test shards 0, 4 and 5 were still in progress; analyze and Debug/Release APK jobs were successful. Do not report the run green until all shards finish successfully.

## In progress
1. Reconcile report filter time picker: PR #2607 still uses Flutter's generic `showTimePicker` for the report filter; shared `showUniversalArvinTimePicker` exists in overlapping Draft PR #2591. Choose one canonical implementation and validate the combined exact head.
2. Complete Task Editor PR #2602 validation after retry; keep Draft until exact-head tests pass and RTL/device acceptance is addressed.
3. Validate recurrence defaults/date-time behavior in PR #2606; Device Smoke/physical-device acceptance remains unproven.
4. Review Project settings add/edit persistence and Notebook checklist/tap/persistence defects linked in the continuity checkpoint/issues; do not create duplicate issues before checking current state.
5. Classify overlapping documentation/UI PRs and reconcile duplicate paths before any merge.

## Blocked / acceptance gates
- No physical-device/owner acceptance evidence for the current cross-screen UI/report filter changes.
- Report time control is not yet Persian-first end-to-end.
- Several relevant PRs are Draft and some Android Device Smoke runs are skipped.
- The requested `docs/arvin-memory/ARVIN_DECISION_LOG.md`, `ARVIN_PROJECT_KNOWLEDGE.md`, `ARVIN_USER_EXPERIENCE_LOG.md`, `ARVIN_PROBLEM_REGISTER.md`, and `ARVIN_EVIDENCE_MAP.md` were not found at the requested paths on the current main baseline. Do not silently assume they exist; establish one canonical memory package through the existing documentation lane rather than creating parallel copies.

## Next action
Refresh the latest exact-head status for PR #2602's retry; then reconcile #2607/#2591's shared time-picker implementation and add focused Persian/Jalali time-picker regression coverage. Keep changes on isolated branches/PRs. No main-branch direct write, no merge without required tests and device/owner acceptance.

## Product guardrails
- Task is the canonical source of truth; Calendar is a projection.
- Project, Category and Tag are canonical taxonomy concepts; do not invent a separate Group model.
- Checklist and recurrence belong to the canonical Task flow; recurrence must not create copied Tasks.
- Reports are read-only consumers of canonical data.
- Preserve user data, stable IDs, Persian RTL and VazirHarf v34.003.
- Mark work DONE only with code, test, build, validation and evidence appropriate to the change.
