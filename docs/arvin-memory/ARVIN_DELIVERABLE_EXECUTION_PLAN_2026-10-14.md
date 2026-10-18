# Arvin Deliverable Execution Plan — 2026-10-14

## Status
**NEXT ACTION — execution plan prepared; release remains NO-GO.**

Repository: `mobinpda-lab/Arvin-clean`

This plan converts the next execution step into reviewable artifacts. It does not claim that code, tests, builds, or physical-device validation have passed.

## Deliverable 1 — Exact-head integration and CI evidence
**Output:** a dated evidence report identifying the selected candidate PR/head SHA, base SHA, mergeability, workflow run IDs, terminal job results, and any failures.

Acceptance:
- Inspect current `main`, the candidate PR, changed files, related issues, and dependencies.
- Do not choose a candidate solely because its PR is newer or has a green historical run.
- Record Build/Analyze, every test shard, Debug APK, Release APK, Calendar Provider Acceptance, and all six Device Smoke lanes for the exact same candidate SHA.
- If a required run is missing, queued, failed, or for a different SHA, mark the gate BLOCKED and preserve the logs.
- Do not merge while a required gate is unresolved.

## Deliverable 2 — Multiple-reminder acceptance packet
**Output:** model/persistence/backup/Calendar/notification test matrix with evidence links.

Acceptance scenarios:
1. Create a Task with zero, one, and multiple independent reminders.
2. Edit and delete one reminder without changing siblings, Task, or Follow-up history.
3. Decode legacy singular `Task.reminderDate` exactly once; verify migration/tombstone prevents deleted legacy data from reappearing.
4. Preserve stable Calendar identity on update; avoid duplicate events; deleting one reminder does not delete another.
5. Verify notification scheduling/delivery identity and configurable all-day notification time.
6. Save/reload through SQL and round-trip portable backup/restore, including old backups without newer settings.
7. Verify `nextFollowUp`, Follow-up reminder, and Task reminders remain semantically independent.

**Gate:** no acceptance claim without exact-head test results and backup/restore integrity evidence.

## Deliverable 3 — Person directory end-to-end acceptance packet
**Output:** a traceable issue/PR checklist for persistence, Settings UI, Follow-up associations, reports, backup/restore, and rollback.

Acceptance:
- Add/edit/search/delete a Person from Settings.
- Deleting/detaching a Person never deletes a Task.
- Waiting-for-response Follow-ups require valid Person association(s) according to the approved contract.
- Person associations survive Task edit, Calendar inbound updates, SQL reload, backup/restore, and rollback.
- Reports filter by Person and return the correct Follow-up records.
- Legacy backups without a Person directory remain restorable.
- Invalid or duplicate stable IDs are rejected without partial data loss.

Known linked work: [#2682](https://github.com/mobinpda-lab/Arvin-clean/issues/2682), [#2683](https://github.com/mobinpda-lab/Arvin-clean/issues/2683), [PR #2681](https://github.com/mobinpda-lab/Arvin-clean/pull/2681), [PR #2695](https://github.com/mobinpda-lab/Arvin-clean/pull/2695), [PR #2696](https://github.com/mobinpda-lab/Arvin-clean/pull/2696).

## Deliverable 4 — Calendar interaction and data-integrity packet
**Output:** test report plus screenshots or recording from emulator and physical device.

Acceptance:
- Short tap opens canonical Task Detail.
- Long press opens typed operations (edit, add to calendar, manage reminders, change time, delete).
- Task ID and external event ID are used for reconciliation.
- Repeated sync performs UPDATE EXISTING and does not create duplicate events.
- Internal next-action/follow-up projections do not accidentally become outbound events or notifications without explicit user action.
- Persian RTL layout is legible on a compact physical screen.

Related issue: [#2685](https://github.com/mobinpda-lab/Arvin-clean/issues/2685).

## Deliverable 5 — Release evidence bundle
**Output:** release notes, installation guide, user guide, known issues, architecture summary, evidence report, and a signed-off acceptance checklist.

Release gates:
- Core Task flow, Checklist, Repeat, Tracking, Follow-up, multiple Reminders, Person, Calendar, Reports, Backup/Restore, migrations, and installation pass.
- All required CI checks are terminal and match the final candidate SHA.
- Physical-device acceptance is documented.
- Backup restore is tested from a real generated backup and integrity is compared before/after.
- No unresolved data-loss or architecture blocker remains.

## Execution order
1. Inspect latest `main` and current PR heads; identify failed build/device runs and the exact failing job/log.
2. Select one integration candidate only after comparing branch ancestry, changed files, and dependency stack. Do not merge stacked or divergent PRs blindly.
3. Repair the first reproducible blocker, add/retain regression coverage, and rerun the required checks.
4. Complete reminder acceptance and Person/Calendar integration without introducing parallel sources of truth.
5. Publish evidence bundle and update `docs/arvin-memory/ARVIN_EXECUTION_STATE.md`, Decision Log, Problem Register, and Evidence Map.
6. Promote only when every release gate has evidence for the exact final SHA.

## Current stop conditions
- **Release:** NO-GO until all mandatory evidence is present.
- **Do not infer:** a successful older run does not validate a newer commit.
- **Do not merge:** PR #2681 while its recorded branch synchronization/mergeability issue remains unresolved.
- **Do not declare done:** from implementation descriptions alone; require code, tests, build, validation, and evidence.


## V5.09 — Release governance hardening (NO-GO; staged, not merged)

Reference candidate SHA: `d9fb7a247037762216662a20fb32028ecc8a0f6b`
Target version: `1.0.1+2`
Proposed tag (DO NOT CREATE): `v1.0.1-build2-arvin-d9fb7a2`

### HARDENING TASK 1 — Neutralize stale prerelease/tag purge
- [ ] Remove automated deletion of stale Arvin prereleases and Git tags from `.github/workflows/release-closure.yml`.
- [ ] Do not mutate, delete, move, or recreate any existing tag or release as part of this task.
- [ ] Verify the staged workflow contains no stale-tag deletion operation.

### HARDENING TASK 2 — Mandatory manual approval before build/publication
- [ ] Require a manual `workflow_dispatch` with `authorized_by_product_owner=true`.
- [ ] Fail closed for `workflow_run`, missing input, or false input before build, artifact upload, tag creation, or binary publication.
- [ ] Keep product acceptance Issue #2102 and regression PR #1901 open until hardening and physical-device evidence are cross-audited.
- [ ] A true dispatch input authorizes entry to the workflow only; it is not final release authorization and does not waive telemetry or acceptance gates.

### WORKSTATION TELEMETRY GATE
- [ ] Record SHA-256 for downloaded Release and Debug APKs and compare against the exact files under test.
- [ ] Attach raw `apksigner verify --verbose --print-certs` output and verify the expected signer certificate identity.
- [ ] Attach physical-device cold-start logs.
- [ ] Attach Jalali calendar interaction/visual acceptance logs.
- [ ] Attach SQL persistence, process restart, and reload evidence.
- [ ] Bind each evidence file to workflow run ID, device/build identity, and exact commit SHA.

### Release decision
**RELEASE: NO-GO.** No tag creation/push, Release publication, Issue #2102 closure, or PR #1901 closure is authorized by this plan. All checklist items require reviewable evidence; this register records required work and must not be read as proof that the work has passed.
