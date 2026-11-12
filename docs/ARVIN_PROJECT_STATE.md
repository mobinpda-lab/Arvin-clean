# Arvin — Canonical Project State
## State Rule
GitHub Repository State is the source of truth for executable status. `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 is the single active governance and software-production reference.
## Repository
- Repository: `mobinpda-lab/Arvin-clean`
- Platform: Flutter / Dart
- Default branch: `main`
- Active documentation work: PR #135 on `docs/arvin-operating-package-v48-2-final-operational`
## Documentation Consolidation
- v48.0 governance is preserved as lineage.
- v48.1 execution optimization is preserved as lineage.
- Approved v48.2 integrated/editorial revision is preserved as the approved source record.
- v49.0 now unifies active governance, execution, architecture, Sync, UI, quality, recovery, documentation, continuity and communication rules in `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md`.
- Historical documents are evidence, not competing active authorities.
## Mandatory Start Audit
Before meaningful work: verify access, `main`, working ref, recent commits, open PRs, exact CI results, relevant documentation, existing implementation, dependencies, conflicts and risks.
## Execution Model
Independent work is parallel by default. Dependent work is sequential only when technically necessary. Shared foundation work requires explicit coordination. A blocked lane must not unnecessarily block unrelated work.
## Architecture Invariants
- Clean Architecture + Feature-Based Architecture.
- Domain remains independent of infrastructure.
- Unified Item/Task remains the shared product foundation unless an approved architectural decision changes it.
- Existing storage/data must remain backward compatible unless an approved tested migration changes the contract.
- Sync Engine is Foundation Core and no feature may create an independent Sync source of truth.
## UI Invariants
Approved Arvin UI is protected. Persian RTL-first behavior, canonical hierarchy, Reminder behavior and Lock Screen/widget expectations may not be changed without explicit approval and validation.
## Validation
Exact-commit GitHub Actions evidence is authoritative. Local checks are fast feedback. A delivery is complete only when implementation, applicable tests/builds, evidence, documentation and safe integration are complete.
## Communication
Reports and answers are compact, simple and understandable without programming knowledge. They are copyable, contain no unnecessary blank lines, distinguish verified facts from plans/blockers, and end with a separate copyable `ادامه` marker.
## High-Risk Review
DeepSeek may be used as an independent second reviewer for major architecture, migration, storage, CI or other high-risk decisions. It does not replace GitHub evidence or owner approval.
## Historical State
Older status files and dated reports remain historical records. They must not be interpreted as current status when they conflict with verified GitHub reality.

## Canonical Project / Category / Tag Architecture
- Domain decision: `docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md` (accepted 2026-10-10; conformance audit remains open in Issue #2580).
- Canonical concepts: Project, Category, Tag; Task remains the core actionable entity.
- Category and Group are synonyms, not separate entities. Standard Persian UI term: «دسته».
- Do not introduce parallel models/stores or a separate Group concept. Review the ADR before changes to Task, filters, search, reports, calendar, repeat or backup/restore.
- The semantic Project → Category → Task diagram does not prove a database Category-to-Project foreign key; that relationship remains an explicit audit question until evidenced and decided.


## AUTHORITATIVE LIVE STATE — WAVE 0 AUDIT — 2026-11-11

This section supersedes older live-status claims in this file where they conflict. Historical entries remain historical evidence.

### Repository and refs
- Repository: `mobinpda-lab/Arvin-clean`; default branch: `main`.
- Main base SHA used for WAVE 0: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Main commit date/message: 2026-10-31, merge of PR #2995 (Wave 7.61 Calendar conflict background-widget isolation).
- Documentation branch created from that exact main SHA: `docs/wave-0-canonical-governance`.
- SQLite execution branch: `feature/command-07-a-sqlite-contract-remediation`, PR #3384 head `c8996bae351d9aede87a251d57141456b945d0a8`.

### Active PR snapshot
- #3380: OPEN / DRAFT / UNMERGED; head `33a8fb14a9979d0d86775cb5457970c7e445077b`; branch `diagnostic/w3-c3-command06e-harness-recovery`.
- #3382: OPEN / DRAFT / UNMERGED; head `adee525e94fa2daec617255d57f9cfb65e3efe66`; branch `diagnostic/command-06-h-raw-sql-evidence`.
- #3384: OPEN / DRAFT / UNMERGED; head `c8996bae351d9aede87a251d57141456b945d0a8`; branch `feature/command-07-a-sqlite-contract-remediation`; base `fix/wave3-cycle3-calendar-product-repair`. Its current PR diff is six files; its history contains 12 commits. No review submissions were returned at audit time.
- None of these PRs was modified by WAVE 0.

### Latest relevant Actions evidence (no rerun requested or initiated)
- Build run [43076778275](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43076778275), exact SHA `c8996bae...`: COMPLETED / FAILURE. Analyze and Visual passed; all six test shards failed; Debug, Staging and Release APK jobs succeeded. Total shard test count recorded: 1,312 passed / 79 failed / 1,391 total.
- Follow-up file-backed persistence run [43076778148](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43076778148): COMPLETED / SUCCESS. This does not override the failed migration/history regression tests.
- Device Smoke [43076778211](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43076778211): PENDING at the audit; no jobs/steps/artifacts were available.
- Main-branch orchestration activity on 2026-11-11 includes successful runs [43079261584](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43079261584) and [43079306186](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43079306186), both on main SHA `45e4202b...`. These are orchestration/queue runs, not application Build or Device Smoke acceptance.
- Main-branch Release Closure / Final Head Release Validation runs observed around the PR activity were SKIPPED, including [43076793035](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43076793035) and [43076806994](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/43076806994).

### SQLite P0 register
- D01 — FAIL / NOT ACCEPTED: `follow_up_enabled` remains in the legacy `tasks` schema; the current migration addition targets a different legacy reminder column. Schema/index/trigger/relation preservation is not accepted.
- D02 — NOT ACCEPTED / CONTRACT CONFLICT: a reader test expects `followUpEnabled: null` for an input where the key is absent. Missing and explicit NULL must remain distinct; this test expectation requires contract clarification, not a default insertion.
- D03 — FAIL / ROOT CAUSE OPEN: `futureFollowUpField` is not retained as expected after SQLite close/reopen in `sql_task_migration_writer_test.dart` (expected true, actual false). Exact field-loss point remains unproven.
- Five-round serialization: NOT VERIFIED.
- Reminder migration: NOT ACCEPTED by final acceptance; the successful follow-up persistence workflow is not the complete migration gate.
- Person relations: database-level close/reopen coverage had a passing case, but related UI tests failed; complete acceptance NOT VERIFIED.
- Backup/Restore: NOT VERIFIED for this target.
- Migration Recovery: NOT VERIFIED.
- Transaction rollback/idempotency have passing individual historical/current tests in some slices, but this is not a complete SQLite acceptance pass.

### Release and change boundary
- Release: **NO-GO**.
- Merge: **NOT AUTHORIZED**.
- Production code/schema/test/workflow changes: none in WAVE 0.
- No CI was manually rerun by WAVE 0.
- See `docs/arvin-memory/ARVIN_EVIDENCE_MAP.md` for the run-specific evidence record and `docs/AI_HANDOFF_CURRENT_FA.md` for continuation instructions.


## COMMAND 07-A.2.24 live status addendum — 2026-11-12

- Main HEAD: `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3384: OPEN / DRAFT / UNMERGED; head `cbf7d241e588c6b4b6051dea5bb3d309a8c3cb05`, base `8c4c23f0c2a4f9b2374a2092c931782c4455fd41`.
- Exact-head Build run 43202151547: FAILURE; SQLite Snapshot 43202151552: SUCCESS; Follow-up File Persistence 43202151499: SUCCESS; Device Smoke 43202151481: QUEUED; Draft Review APK 43202151478: SKIPPED.
- SQLite Snapshot PASS is not D01-D05 acceptance. Build failure and queued Device Smoke remain unresolved.
- Typography owner decision: Vazirmatn only. See canonical contract. Main has three registered weights/assets; Light 300 and SemiBold 600 are not yet present on main.
- Merge and Release remain unauthorized; Release NO-GO.


## COMMAND 07-A.2.25 — live continuation checkpoint (2026-11-12)

Canonical typography authority: [`docs/architecture/ARVIN_TYPOGRAPHY_CONTRACT.md`](architecture/ARVIN_TYPOGRAPHY_CONTRACT.md). This section supersedes earlier status snapshots below only for the refs and evidence explicitly listed here; historical records remain intact.

- Main HEAD remains `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3384 remains OPEN / DRAFT / UNMERGED. Branch `feature/command-07-a-sqlite-contract-remediation`; latest observed HEAD `2ac3580985a23e6ac5342d49c33343c8b4f01816`; 80 commits; 60 changed files; no merge/release/deployment.
- PR #3388 remains OPEN / DRAFT / UNMERGED. Branch `docs/wave-0-canonical-governance`; latest observed HEAD `fe7e001ec93446d78ad327a03771c849dfd81a48` after recording candidate Vazirmatn asset checksums.
- On PR #3384, exact-head fixes align Alarm Overlay and Calendar with the official Vazirmatn family and inherit the app-level font preference rather than forcing Vazirmatn locally. The Device Smoke scenario identifier was aligned from `smoke-reminder-vazirharf` to `smoke-reminder-vazirmatn` to match its contract test.
- The prior e941054 build failed due unresolved `AppFonts.vazirHarfFamily` references in runtime/test sources; the related test shards and APK builds were blocked by compilation. The same run's narrow file-backed persistence test passed, while its Alarm Overlay close/reopen diagnostic did not compile.
- New exact-head workflows for `2ac3580985a23e6ac5342d49c33343c8b4f01816`: Build `43217473284` PENDING; Device Smoke `43217473090` QUEUED; SQLite Snapshot `43217473138` QUEUED; Follow-up File Persistence `43217473064` QUEUED. These are not passes.
- Ruleset `main-protection` is active but still requires zero approving reviews and `require_code_owner_review=false`; CODEOWNERS exists on the documentation PR branch, but effective owner-review enforcement remains NOT VERIFIED / NOT ENABLED.
- Candidate Vazirmatn five-weight binary SHA-256 values are recorded in the canonical typography contract section 16. These are source-asset checksums, not APK packaging evidence.
- SQLite Snapshot A-D run `43212724352` passed on older SHA `e94105443e7516ed38eda6feaaee125d92fabaf4`; its five-cycle evidence is historical to that SHA and cannot be promoted to the newer acceptance SHA.

Release remains NO-GO. No artifact, PDF, device, or full SQLite acceptance is claimed for the current HEAD.


## COMMAND 07-A.2.25 — post-documentation HEAD refresh (2026-11-12)

- PR #3384 latest observed HEAD is now `318c9d7651299ecd0d1bfcda2653c52be87fb81f` (86 commits, 62 changed files), OPEN / DRAFT / UNMERGED. This SHA advanced after synchronizing the six existing `docs/project-continuity/` records; it supersedes the earlier 2ac358... checkpoint for current branch identity only.
- A fresh `actions/runs?head_sha=318c9d7651299ecd0d1bfcda2653c52be87fb81f` query returned no workflow runs at the time of this refresh. All Build/Device/SQLite/Persistence results on 2ac358... or older SHAs are historical and do not validate 318c9d....
- PR #3388 remains OPEN / DRAFT / UNMERGED; current observed HEAD `93f65ad4c42a2f9565a92b49058e68ff8b4eb3d7`.
- The five Vazirmatn binary SHA-256 values in typography contract §16 remain tied to the unchanged font blobs listed there; they do not establish APK inclusion or release readiness.
- Next action: wait for or trigger exact-head validation on 318c9d... using the repository's supported CI path, then inspect Build, SQLite Snapshot, Follow-up Persistence and all seven Device Smoke lanes. Do not reuse prior run outcomes.

Release remains NO-GO. Merge, release and deployment remain unauthorized.


## COMMAND 07-A.2.26 — exact-head checkpoint (2026-11-12)

Product candidate SHA: `b78488c0347e1a97a7a25f56c914a48761d44a25` on `feature/command-07-a-sqlite-contract-remediation`; PR #3384 OPEN / DRAFT / UNMERGED (87 commits, 62 files at last observed refresh). This supersedes 318c9d for current product validation only.

- Commit `b78488c0347e1a97a7a25f56c914a48761d44a25` corrected the PDF test's stale VazirHarf description/sample to Vazirmatn; assertions were preserved.
- All five actual TTF OpenType name tables report Version 33.003. Source repository: `rastikerdar/vazirmatn`; bundled license: SIL OFL 1.1. Exact upstream commit/tag and source-to-binary reproducibility remain pending. SHA-256 values remain in typography contract §16.
- Follow-up Persistence run `43219196583` is SUCCESS on this exact SHA. Both file-backed Repository Persistence and Alarm Overlay close/reopen diagnostic passed. The latter exercised Snooze, disposing the first overlay/SQLite connection, reopening the same file, loading the overlay again, tapping Complete and observing notification cancellation.
- Build `43219196600`: PENDING, no jobs allocated at last poll. SQLite A-D five-cycle run `43219196466`: QUEUED. Device Smoke run `43219196537`: QUEUED. Production Loop `43219196556`: SUCCESS. Orchestrator `43219196378`: SUCCESS.
- Existing schema tests cover Missing / explicit NULL / FALSE / TRUE metadata, retired-column absence, FK constraints and malformed-source migration preservation. The exact-head SQLite workflow is not yet complete; D01-D05 are not accepted as a whole. Snapshot A-D does not independently prove all triggers/indexes, backup/restore or forced interruption/recovery.
- Earlier SHA results are historical and must not be promoted to this candidate SHA.

Release remains NO-GO. No merge, release or deployment is authorized.


## COMMAND 07-A.2.28 — continuous execution checkpoint (2026-11-12)

### Product candidate and PRs
- Main HEAD: `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3384: OPEN / DRAFT / UNMERGED; base `fix/wave3-cycle3-calendar-product-repair` at `8c4c23f0c2a4f9b2374a2092c931782c4455fd41`; execution branch `feature/command-07-a-sqlite-contract-remediation`; current HEAD `a6d2d58d87530bfa184c93220cc329b819aca809`; 94 commits / 64 changed files at this refresh.
- PR #3388: OPEN / DRAFT / UNMERGED; branch `docs/wave-0-canonical-governance`; latest docs commit before this state update `7d438fb9afa8d6038a8244f1d1dc69673cc6cf6c`; base main `45e4202b03a434459e4c021a04efa7e8396359db`.

### Changes committed on PR #3384
- Removed explicit `fontFamily: 'VazirHarf'` overrides from `lib/task_detail_page.dart`, `lib/home/home_filter_ui.dart` and `lib/quick_capture_dialog.dart`; these widgets now inherit the centralized Theme and do not override the System Default preference.
- Updated the Home visual integration test to assert the current Vazirmatn family contract rather than retired `familyForText` / `vazirHarfFamily` APIs.
- Corrected two Checklist test helper calls to provide the required scroll delta.
- Updated stale test finders to use semantic labels or stable widget keys for icon-only RollBox controls. Corrected the Home filter count assertion from five to four visible Home filter controls, matching the current Home layout contract.
- Corrected the typography contract test to inspect the actual Theme implementation rather than an escaped-newline source string that never matched.

### Exact-head workflows at observation time
All listed runs target exactly `a6d2d58d87530bfa184c93220cc329b819aca809`; they were queued/pending when inspected:
- Build / Analyze / six shards / Visual / Debug-Staging-Release: Run `43223035750` — PENDING, no jobs allocated at last poll.
- Device Smoke: Run `43223035920` — QUEUED; preparation job queued, seven scenario jobs not yet allocated.
- SQLite A-D five-cycle Snapshot: Run `43223035907` — QUEUED.
- Follow-up file-backed persistence: Run `43223035880` — QUEUED.

The prior Build Run `43219196600` on SHA `b78488c0347e1a97a7a25f56c914a48761d44a25` failed: six regression shards and Analyze reported failures; Debug and Release APK jobs failed because the runtime VazirHarf purge check found explicit overrides; Visual passed. Those results are historical to the old SHA and are not current-head outcomes.

The older SQLite Snapshot Run `43219196466` and Follow-up Persistence Run `43219196583` passed on `b78488c...`; neither result is transferred to `a6d2d58...`.

Release remains NO-GO. D01-D05, all seven Device Smoke scenarios, PDF output validation, and the three APK artifacts remain unaccepted.


## COMMAND 07-A.2.28.1 — exact-head SQLite results (2026-11-12)

On candidate SHA `a6d2d58d87530bfa184c93220cc329b819aca809`:
- SQLite Snapshot Run `43223035907`: SUCCESS. Job `131199160903`; five real Save/Close/Reopen/Verify cycles; A-D snapshot comparison; unknown Task/Follow-up future fields, two Reminder rows and their states/order, Follow-up records/order, Person relations, and foreign-key integrity preserved. `foreign_key_check=[]`; `foreign_keys_enabled=1`.
- Snapshot JSON SHA-256: `0d828bfb57417da75570f39186e55c4e65fb639c50440b46f421b9520ea9c574`.
- Artifact ID `13946956406`; archive digest `a436ec262c87fde240c4065f650d47f80c861b75d37a146840af895e52c93efc`.
- Follow-up File Persistence Run `43223035880`: SUCCESS. File-backed repository persistence and Alarm Overlay Snooze → close/dispose → reopen same SQLite file → reload → Complete → notification cancellation all completed.

These passes are exact to `a6d2d58...`. D01-D05 remain separately assessed: full schema/trigger/index inventory, actual Backup/Restore, and forced interruption/recovery are not proven by the Snapshot workflow alone. Build Run `43223035750` remains PENDING with no jobs at last poll; Device Smoke Run `43223035920` remains QUEUED.


## COMMAND 07-A.2.28.2 — expanded SQLite acceptance candidate (2026-11-12)

The product branch has advanced to candidate SHA `551ecdc0542bb00f72c21167b4c721094b3a3cba`. PR #3384 remains OPEN / DRAFT / UNMERGED; Main remains `45e4202b03a434459e4c021a04efa7e8396359db`.

Additional test-only work since `a6d2d58...`:
- Commit `45c39211ece595b23ce0ea0d3f18525cfbbe854e`: SQLite A-D diagnostic now captures the complete `sqlite_master` catalog (tables, indexes, triggers), every non-system table's declared Foreign Key definitions, and checks all three retired Task columns are absent. The catalog is included in A-D comparisons.
- Commit `7d3466f8b46ee27d2312efcd41c0fa8090dccbad`: adds a real file-based Backup → decode from disk → restore into a different file-backed SQLite database → close/reopen → verify test for multiple Reminder IDs/order/enabled states and Follow-up Person relations.
- Commit `551ecdc0542bb00f72c21167b4c721094b3a3cba`: extends malformed legacy Task-person migration coverage to repair the preserved source row and retry schema installation on the same executor, verifying the Person row and FK integrity after recovery.

These are implementation/test additions, not PASS results. All exact-head validation must run on `551ecdc...`.

Exact-head workflows at last observation:
- Build Run `43224398615`: PENDING, no jobs allocated.
- SQLite Snapshot Run `43224398076`: QUEUED.
- Follow-up File Persistence Run `43224398303`: QUEUED.
- Device Smoke Run `43224398160`: QUEUED.

The prior exact-head Snapshot and Follow-up successes on `a6d2d58...` remain historical. No D01-D05 acceptance is claimed for `551ecdc...` until the new diagnostic and full test suite pass.
