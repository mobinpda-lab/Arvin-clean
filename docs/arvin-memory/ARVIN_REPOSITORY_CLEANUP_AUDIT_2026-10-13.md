# ARVIN Repository Cleanup Audit — 2026-10-13

## Scope and evidence boundary

- Repository: `mobinpda-lab/Arvin-clean`
- Working branch: `integration/follow-up-person-model-20261013`
- Draft implementation PR: [#2681](https://github.com/mobinpda-lab/Arvin-clean/pull/2681)
- Parent reminder/follow-up integration PR: [#2666](https://github.com/mobinpda-lab/Arvin-clean/pull/2666)
- Owner-approved architecture: [ARVIN_FOLLOW_UP_PERSON_MODEL_DECISION.md](ARVIN_FOLLOW_UP_PERSON_MODEL_DECISION.md)
- This is a source/documentation audit, not a claim that tests or a device build passed. GitHub Actions for parent head `460627f8461a2b82c7d69d85e141956dcacb73fa` were queued/pending when checked; no PR-associated runs were returned for the stacked child head `8c80309dd6cf8d46d97eeb0aaef34424a3f37326`.

## Verified implementation present on the working branch

- `FollowUp` JSON includes `waitingForResponse` and stable `personIds`, with backward-compatible defaults for older JSON.
- SQL schema includes `follow_ups.waiting_for_response`, `follow_ups.person_ids_json`, and the reusable `people_directory`; schema install adds missing Follow-up columns idempotently.
- Settings links to a lightweight Person directory with add/edit/search/delete.
- Follow-up entry UI requires at least one selected Person before saving a Follow-up as waiting for a response.
- Person deletion removes the Person's associations from Follow-up and Task relationship tables rather than deleting Tasks/Follow-ups.
- Quick Add no longer presents the old “پیگیری‌دار” flag and continues to support Checklist.
- The full Task editor has a Follow-ups section and no “کار پیگیری‌دار” switch.
- `nextFollowUp` and `reminderDate` remain separate fields.

## Cleanup changes applied in this pass

- Removed legacy `followUpEnabled` writes from `FollowUpRepository.add/update`, Calendar's Follow-up deletion/edit paths, Notebook-to-Task conversion, and Quick Add creation.
- Changed Report filtering to identify Follow-ups from canonical `followUps`/`followUpDate` data instead of the legacy flag.
- Fixed Calendar inbound editing to preserve `waitingForResponse` and `personIds` when rebuilding a Follow-up; added a regression test covering those fields plus independent reminder/next-action dates.
- Changed Task-level waiting detection to consider every active structured Follow-up rather than only the latest record.
- Changed the waiting-for-response list to retain every Person-linked waiting Follow-up instead of collapsing each Task to one latest row.
- Added/updated focused tests for legacy-flag independence, Calendar field preservation, Report filtering, and per-record waiting semantics.
- Updated execution state, decision log, knowledge, problem register, and evidence map to capture the findings and limitations.

## Findings that still block acceptance

### P1 — Person directory is not yet part of portable backup/restore

The current portable backup document includes Tasks, settings, Projects, Calendar links, Categories, and Tags, but not standalone `people_directory` entries. A Person who has no current Task/Follow-up association could be omitted from a backup. Restore/rollback must include the directory as part of the same existing backup contract; do not create a second backup system. This touches destructive restore and rollback behavior, so it requires an explicit staged implementation plus round-trip, malformed-payload, and rollback tests before marking resolved.

### P1 — Person-based reporting is not complete

The approved report behavior requires filtering by Person and showing Task, Follow-up, waiting status, and next action time. The current Report filter correction removes dependence on the legacy flag, but does not yet provide the full Person selector/Person-specific result rows.

### P1 — Exact-head validation is outstanding

- Flutter analyzer and focused tests: not run/confirmed on the current child head.
- Full test shards and Debug/Release APK: pending exact-head evidence.
- SQL migration idempotency against a pre-existing database: pending exact-head evidence.
- Backup/restore and failure rollback for the Person directory: not implemented/validated.
- Calendar provider acceptance and device smoke for the child head: no evidence.
- Physical-device acceptance: not evidenced.

## Architecture drift still to audit before release

- Search every remaining active read/write of `followUpEnabled`; keep the field only for legacy compatibility and remove it from product behavior once migration/reader compatibility is proven.
- Audit all Follow-up reconstruction/copy sites for preservation of `waitingForResponse`, `personIds`, `reminderDate`, `nextFollowUp`, and `completed`.
- Complete Person filtering and Person labels in reports/waiting list.
- Include Person directory data in the existing backup and restore/rollback pipeline.
- Verify Quick Add, Full Task Form, Task Detail, Home, Report Center, Calendar, migration and deletion semantics together.

## Release decision

**NO-GO.** The architecture is partially implemented and the cleanup regression tests are authored, but they are not proven passing on the exact child head. Do not merge PR #2681 before the parent PR #2666 is accepted and the child exact-head gates, backup/restore coverage, Person reports, and device acceptance pass.

---

## Latest status correction — 2026-10-13

- Current observed parent PR #2666 head: `d70827e1db927dcac2afc7367ca0d2e759359d8e`; Build/Device Smoke queued and Calendar Provider Acceptance in progress.
- Current observed child PR #2681 head: `d87f5a3e3de72e8227b4dd6dd954149757c79774`; Draft, unmerged, and GitHub reports not mergeable. No child-head workflow runs were returned.
- Related PR #2679 Build run failed in test shard 2 (232 tests passed, one waiting-list test failed). It is a different merge head and must not be treated as child-branch evidence.
- Follow-up issues opened: [#2682](https://github.com/mobinpda-lab/Arvin-clean/issues/2682) for Person directory backup/restore and [#2683](https://github.com/mobinpda-lab/Arvin-clean/issues/2683) for Person-specific reports.
- The child branch's waiting-list semantics now use structured per-Follow-up status and preserve multiple waiting records. Its updated tests still need exact-head CI confirmation.

---

## Branch synchronization gate — 2026-10-13

- Latest observed parent PR #2666 head: `d16e52050567a6631a21b563d336a0bba1c3c32b`; Build pending, Calendar Provider Acceptance in progress, Device Smoke queued.
- Child PR #2681 is Draft and GitHub reports it not mergeable. Its base snapshot is stale relative to the latest parent branch. Safely synchronize before any merge or exact-head validation.
- Do not force-update refs or overwrite the parent integration branch; several concurrent changes are present.
- Issues tracking remaining work: [#2682](https://github.com/mobinpda-lab/Arvin-clean/issues/2682) and [#2683](https://github.com/mobinpda-lab/Arvin-clean/issues/2683).
