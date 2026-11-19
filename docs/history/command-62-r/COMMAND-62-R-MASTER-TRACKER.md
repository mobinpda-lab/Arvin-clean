# ARVIN — COMMAND 62-R MASTER TRACKER
**Checkpoint:** 2026-11-19 / 28 Aban 1405  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Operational PR:** #3052 — OPEN / DRAFT / UNMERGED  
**Operational branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**Reference PR:** #3495 — OPEN / DRAFT / UNMERGED  
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db` — protected by this execution; no write performed.  
**PR #3052 checkpoint before COMMAND 62:** `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`  
**Current COMMAND 62 documentation checkpoint:** `805375654d04b247cbac5038b92d30ce781fff7c`

## 1. Authority and safety
- COMMAND 62-R explicitly keeps PR #3052 as the operational delivery route. PR #3495 and PRs #3547–#3549 are read-only comparison sources until an individual change is inspected and adapted.
- No branch deletion, force-push, history rewrite, direct Main edit, merge, release, deploy or production-database operation is authorized.
- PR #3052 remains OPEN / DRAFT / UNMERGED.
- PR #3495 and source PRs #3547, #3548 and #3549 remain preserved.
- The product owner re-authorizes Local P2P Phase 1 in COMMAND 62-R. This supersedes the 2026-11-10 synchronization suspension for the scope of this command. Dropbox remains a separate Phase 2 and is excluded from Phase 1 implementation.
- Local P2P protocol, key exchange, device identity, conflict rules and transport are not yet security-accepted. Design and threat-model work must precede implementation.

## 2. Live branch reconciliation
| Ref | HEAD | State | Relation to Main |
|---|---|---|---|
| Main | `45e4202b03a434459e4c021a04efa7e8396359db` | protected / unchanged | baseline |
| PR #3052 | `aba68e44be0fcac7d4ad425b58fbe75e5aba264e` at audit start | OPEN / DRAFT | 2,192 commits ahead, 0 behind |
| PR #3495 | `1b1534924db9f251df83c36cabff30285194784e` at audit start | OPEN / DRAFT | 355 commits ahead, 0 behind |

Both PR branches share Main as their merge base but have diverged. Comparing #3052 directly with #3495 reports 355 commits on the #3495 side and 2,192 commits on the #3052 side. All 266 changed paths on #3495 also occur in the #3052 changed-path inventory; this is filename overlap, not content equivalence. No broad merge or blind cherry-pick is safe.

### Source PR inventory
- #3547 — two quality/test files; exact-head prior evidence showed test-1 fixed and test-2 blocked by Person Directory rehydration.
- #3548 — seven UI/theme/Home files; latest reviewed evidence showed six shard failures and Home Device Smoke failure. Do not port wholesale.
- #3549 — seven schema/TaskStore/migration/test files; contains a Person Directory exclusion tombstone fix and file-backed Occurrence persistence coverage. It does not prove V7→V20 migration acceptance.
- #3550 — open P0 issue for Center domain, M2M stores, management UI and Home Center filter.

## 3. COMMAND 62 implementation log
### A-01 — legacy scheduling field preservation contract
**File:** `test/services/g1_drift_completed_at_migration_test.dart`  
**Previous behavior:** test expected `follow_up_enabled`, `follow_up_date` and `reminder_date` columns to be removed by the active schema installer.  
**Conflict:** current Product Decisions on the reference branch explicitly preserve legacy Task Follow-up fields for compatibility; retirement requires a separate owner decision and verified migration plan.  
**Change:** replaced the obsolete removal expectation with positive assertions that:
- nullable `completed_at` is added;
- all three legacy scheduling columns remain present;
- their exact pre-existing values survive installation and readback;
- the Task completion value remains unchanged.
This is a contract correction and stronger data-preservation assertion, not removal or weakening of a test.
**Commits:**
- `cab49971c26cc46bc8ac58019e29418bf0c138a2` — initial fixture/test correction; superseded by the next correction.
- `c5d126f423e44b12c1c44fbf69324a7e326d800c` — corrected fixture construction and final assertion set.
**Validation:** exact-SHA workflows triggered for `c5d126f423e44b12c1c44fbf69324a7e326d800c`; Build, Device Smoke, Follow-up Persistence and artifact workflows were PENDING/QUEUED at the last poll. **NOT TESTED until those runs finish.**

## 4. Exact-SHA CI baseline
### PR #3052 pre-change SHA `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`
- Analyze: PASS.
- Six test shards: FAIL. Recorded shard totals: 6, 27, 11, 12, 14 and 11 failed tests respectively (81 failed test instances across shard reports; no assumption that these are 81 unique test names).
- Debug APK: PASS.
- Release APK: PASS.
- Staging APK: PASS.
- Visual job: PASS.
- Calendar Provider: PASS.
- Follow-up File Persistence: PASS.
- Device Smoke: CANCELLED.
- Draft Review APK: PASS.
The failures span Home filters/grouping, Quick Capture, Task Editor, Task Details, Checklist, Follow-up/People, Calendar, Reports, migration contracts and navigation. They must be classified and corrected against current product contracts; no assertion deletion is authorized.

### New COMMAND 62 candidate SHA `c5d126f423e44b12c1c44fbf69324a7e326d800c`
Workflows observed after the second test-file commit:
- Build run `44474272080`: PENDING.
- Device Smoke run `44474272030`: PENDING.
- Follow-up File Persistence run `44474272028`: PENDING.
- Draft Review APK run `44474272045`: PENDING.
- Calendar Provider run `44474272038`: QUEUED.
- Orchestrator / parallel-wave / lock-sync jobs: QUEUED.
No result from an older SHA transfers to this candidate.

### PR #3495 current run at audit
- Build `44473413246`: IN PROGRESS.
- COMMAND 20-E `44473413238`: IN PROGRESS.
- Device Smoke `44473413276`: CANCELLED.
- Follow-up File Persistence `44473413242`: SUCCESS.
These results are not evidence for PR #3052.

## 5. Font inventory — source archive verified
Library archive: `vazirmatn-v33.003 (2).zip`  
- Size: 13,047,191 bytes.
- Entries: 387.
- ZIP CRC test: clean.
- SHA-256: `0a9afd41967e6f57096a56a181a23f81a2b999b62f1f2a4e4b26736580854fdb`.
- Includes static TTF and WOFF2 families, variable fonts, UI variants, Farsi-digit variants and Non-Latin variants.
- Nine static weights: 100, 200, 300, 400, 500, 600, 700, 800 and 900.
- OFL.txt declares SIL Open Font License 1.1 and permits embedding/bundling subject to retaining the copyright notice and license.
- The audited #3052 pubspec registers weights 300, 400, 500, 600 and 700; current repository assets include those registered files. The full archive has not been copied into the application.
- No font asset or typography implementation was changed in this checkpoint. Full registration, coverage and visual acceptance remain open.

## 6. Product and architecture dispositions
| Path | Status | Current evidence / next action |
|---|---|---|
| A — Build/CI | BLOCKED | 81 failed test instances in old six-shard baseline; one obsolete migration expectation corrected; await exact candidate runs, then fix root causes in batches. |
| B — REV10 UI/UX | IN PROGRESS | #3548 is not safe to port wholesale. Build full route inventory and compare each page to REV10; Home Center filter remains a known gap on reference branch. |
| C — Font/visual system | PARTIAL | Vazirmatn archive and OFL verified; integrate only required static weights after package/build/visual test plan. |
| D — Local P2P | DESIGN REQUIRED | COMMAND 62 re-authorizes Phase 1; threat model, protocol, identity, secure pairing, durable change log, conflict matrix and retry semantics required before coding. Dropbox Phase 2 excluded. |
| E — Data integrity/migration | IN PROGRESS | Preserve legacy columns and values. V7→V20 sequential migration, explicit NULL, unknown fields, rollback/retry and independent backup/restore remain unaccepted. Historical installers/fixtures remain untouched. |
| F — People/entity relations | PARTIAL / NOT INTEGRATED | #3549 tombstone fix is a source candidate only; adapt to #3052 schema v17 after dependency and migration review. M2M relation graph and Center/Project/Category stores remain incomplete. |
| G — Device/product acceptance | BLOCKED | #3052 old Device Smoke cancelled; exact candidate run pending. Physical-device screenshots and two-device P2P tests not performed. |
| H — Integration | IN PROGRESS | Keep source PRs isolated; accept only per-file adaptations with focused tests and exact-SHA validation. |

## 7. Acceptance rules
- PASS only with implementation + relevant test + exact SHA + retained evidence.
- FAIL means an executed test or workflow failed.
- BLOCKED requires a concrete dependency or safety constraint.
- NOT TESTED means no relevant execution has occurred.
- INCONCLUSIVE means evidence is incomplete or not tied to the candidate SHA.
- A generated APK is not release acceptance.
- No release until all product gates and explicit owner approval are satisfied.

## 8. Next execution sequence
1. Poll all workflows for `c5d126f423e44b12c1c44fbf69324a7e326d800c`; inspect failed job logs, do not rerun blindly.
2. Review #3052 six-shard failures by root cause and test/product contract; fix the smallest coherent batch without deleting assertions.
3. Inspect and adapt the #3549 Person Directory exclusion migration for the #3052 schema v17 lineage; do not copy its schema blindly.
4. Complete REV10 page/route inventory and isolate non-conflicting design-token changes.
5. Verify bundled Vazirmatn assets, licenses and exact registered weights; add only the needed files and visual tests.
6. Draft Local P2P threat model/protocol and domain conflict matrix before implementation.
7. Continue data, entity, and device acceptance independently; update this tracker after each exact-SHA checkpoint.

**Release state: NO-GO. Main untouched. PR #3052 OPEN / DRAFT / UNMERGED. No merge, release or deploy.**


## 9. Follow-on checkpoint — 2026-11-19
- Commit `32daaa48bd63831668607e3547a39dc62057fb6e` added this Master Tracker to the operational branch.
- Commit `805375654d04b247cbac5038b92d30ce781fff7c` added `docs/architecture/COMMAND-62-R-LOCAL-P2P-SECURITY-AND-CONFLICT-DESIGN.md`.
- The P2P document defines the threat model, proposed pairing/trust lifecycle, authenticated encrypted transport requirements, durable operation envelope, idempotent retry/acknowledgement rules, causal conflict policy and two-device acceptance matrix. It is a design proposal only; no cryptographic or network code is implemented.
- The Vazirmatn v33.003 archive was materialized from the Library and inspected in the runtime: 13,047,191 bytes, 387 entries, CRC clean, SHA-256 `0a9afd41967e6f57096a56a181a23f81a2b999b62f1f2a4e4b26736580854fdb`. It includes static TTF/WOFF2 and variable/UI/Farsi-digit/Non-Latin variants, with nine static weights and SIL OFL 1.1. No font files were added to the app in this checkpoint.
- The code/test correction remains unverified. Workflows triggered on tracker SHA `32daaa48bd63831668607e3547a39dc62057fb6e` had Build and Device Smoke pending, Follow-up Persistence cancelled by a newer run, Calendar Provider in progress and staging review in progress at the last poll. Docs-only P2P design commit `805375654d04b247cbac5038b92d30ce781fff7c` had no PR-triggered workflow runs.
- The #3052 source schema uses `persons` + `person_directory` + `task_persons`, whereas #3549's tombstone fix is written against the separate #3495 `people`/legacy relation lineage. Direct copying is unsafe; an adapted #3052 fix requires a fresh reproduction and file-backed regression test before implementation.
- Current operational branch HEAD at this checkpoint: `805375654d04b247cbac5038b92d30ce781fff7c`. PR #3052 remains OPEN / DRAFT / UNMERGED; Main remains `45e4202b03a434459e4c021a04efa7e8396359db`.
