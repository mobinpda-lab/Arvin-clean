# ARVIN — COMMAND 63-R MASTER TRACKER (Cumulative)
**Checkpoint:** 2026-11-19 / 28 Aban 1405  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Operational PR:** #3052 — OPEN / DRAFT / UNMERGED  
**Operational branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**Reference PR:** #3495 — OPEN / DRAFT / UNMERGED  
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db` — protected by this execution; no write performed.  
**PR #3052 checkpoint before COMMAND 62:** `aba68e44be0fcac7d4ad425b58fbe75e5aba264e`  
**Latest code/test candidate:** `e9a74921fca32edb31478b80cc1c2d50b8d75222`  
**Latest P2P design commit:** `805375654d04b247cbac5038b92d30ce781fff7c`

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


## 10. Exact-head rerun boundary
- The Build, Device Smoke, Follow-up Persistence and Draft Review runs created for `32daaa48bd63831668607e3547a39dc62057fb6e` were subsequently marked CANCELLED when newer branch commits superseded that SHA before the jobs completed.
- This is not a test result. The code correction in `test/services/g1_drift_completed_at_migration_test.dart` remains NOT TESTED.
- A fresh documentation checkpoint is being created so GitHub Actions can validate the complete current candidate containing the code correction. Only runs tied to the resulting exact HEAD can upgrade its acceptance status.


## 11. Parallel lane checkpoint — 2026-11-19
### Operational candidate `e9a74921fca32edb31478b80cc1c2d50b8d75222`
- `test/services/g1_drift_completed_at_migration_test.dart`: PASS in shard 2. The fixture verifies additive nullable `completed_at` and exact retention of legacy Follow-up scheduling columns/values.
- `test/person_directory_history_file_reopen_test.dart`: PASS in shard 2. The test verifies file-backed SQLite reopen, directory removal, retained Person identity + Task relation, and re-addition under the same ID.
- Build run `44474830536`: FAIL overall. Analyze PASS; Visual PASS; Debug, Staging and Release APK jobs PASS; five of six shards completed FAIL and the sixth also completed FAIL. Shard failure counts: 11, 6, 11, 14, 12 and 26 = **80 failed test instances** (not necessarily 80 unique tests).
- Calendar Provider run `44474830516`: PASS.
- Follow-up File Persistence run `44474830556`: PASS.
- Draft Review APK run `44474830547`: PASS.
- Device Smoke run `44474830680`: PENDING / no jobs reported at last poll. No device acceptance can be claimed.
- The 80 failures remain broad: Home/Center filter contracts, Quick Capture, Task Editor and due-date contracts, Task Details/Checklist/People, Reminder migration, Reports and Follow-up UI. Do not patch by weakening assertions.

### Path B — isolated design-system PR #3556
- PR #3556: OPEN / DRAFT / UNMERGED; target is the operational branch, not Main.
- Branch: `command-62-r/path-b-design-system`.
- Head: `151e8f184db95d9524a9472bb4e1520a711e21e1`.
- Adds shared non-color tokens and applies them to the existing primary navigation; includes a widget test.
- Follow-up File Persistence run `44475246595`: PASS.
- Build run `44475246526`: PENDING at last poll; Device Smoke `44475246535`: PENDING.
- This is only a token/navigation foundation, not full REV10 page acceptance.

### Path C — isolated font-compliance PR #3557
- PR #3557: OPEN / DRAFT / UNMERGED; target is the operational branch.
- Branch: `command-62-r/path-c-font-license`.
- Head: `b3f6b237dca4eb47ccd71304b0de0ba8c1f67716`.
- Adds upstream Vazirmatn OFL and Authors attribution; no font binaries or typography registrations changed.
- Exact upstream license verification: Git blob SHA `be66b3824e9772e75141e631695c5256f105fb57` matches `git hash-object` of the archive's original `OFL.txt`.
- Added `test/fonts/vazirmatn_license_asset_test.dart` to load the OFL and Authors files through Flutter `rootBundle`. Build run `44476426493`: PENDING; Device Smoke `44476426659`: PENDING. Packaged-APK license inclusion remains NOT TESTED until the test passes and the APK is inspected.

### Path E — isolated migration-contract PR #3558
- PR #3558: OPEN / DRAFT / UNMERGED; target is the operational branch.
- Branch: `command-62-r/path-e-migration-contracts`.
- Head: `53537dd62569b68bc2c7a4f19d9797732e8e3150`.
- Aligns legacy reminder test with `Task.fromLegacyJson`, asserts canonical Follow-up `completedAt`, uses canonical `TaskReminder` in the due-date preservation test, and models the production migration-complete marker in the file-reopen test.
- Build run `44476129018`: IN PROGRESS at last poll; Analyze and test shards had not reported failures yet.
- Follow-up File Persistence run `44476129063`: IN PROGRESS.
- Device Smoke run `44476128976`: queued selected smoke scenarios.
- No result is accepted until exact-head runs complete.

### Reference PR #3495 exact-head result
For head `1b1534924db9f251df83c36cabff30285194784e`:
- Analyze: PASS.
- All six test shards: PASS.
- Debug APK: PASS.
- Release APK: PASS.
- Device Smoke: CANCELLED.
- COMMAND 20-E storage-persistence job remained IN PROGRESS at last poll.
This successful Build is reference evidence only; it does not transfer to #3052.

## 12. Progress estimates (analytical, not GitHub-native percentages)
| Path | Estimate | Basis |
|---|---:|---|
| A — Build/CI | 5% | Exact-head Build executed; Analyze and APKs pass, but 80 failed test instances remain. Two targeted regression tests pass. |
| B — REV10 UI/UX | 5% | Shared token/navigation slice exists as a Draft PR; no page-by-page redesign acceptance. |
| C — Font system | 25% | Archive, weights and OFL verified; license attribution proposed in Draft PR; packaging and visual acceptance open. |
| D — Local P2P | 15% | Threat model and protocol/conflict proposal documented; crypto review and implementation not started. |
| E — Data/migration | 10% | Several test contracts corrected in an isolated Draft PR; sequential migrations, rollback, NULL/unknown fields and backup/restore still open. |
| F — People/entities | 20% | File-backed historical relation regression passes; complete Person lifecycle and M2M entity acceptance remain open. |
| G — Device/product | 3% | APK jobs pass on candidate, but Device Smoke is pending and no physical two-device acceptance exists. |
| H — Integration | 15% | Branch divergence measured and three isolated Draft PRs created; no code lane has been integrated into #3052 yet. |

Percentages are planning estimates from the explicit scope above, not a claim of completed product acceptance.

**Current safety:** Main unchanged. PR #3052 OPEN / DRAFT / UNMERGED. PRs #3495, #3556, #3557 and #3558 remain OPEN / DRAFT / UNMERGED. No merge, release or deploy.


## 13. Latest lane metadata refresh
- PR #3556, #3557 and #3558 are all OPEN / DRAFT / UNMERGED and currently report mergeable=true against their operational-branch base. No merge has been performed.
- PR #3557 now includes a Flutter asset-bundle test for the Vazirmatn OFL and Authors files. Its current head is `b3f6b237dca4eb47ccd71304b0de0ba8c1f67716`; Build run `44476426493` is PENDING.
- PR #3558 Build `44476129018` remains IN PROGRESS; its Analyze job and Visual job are PASS, Follow-up File Persistence `44476129063` is PASS, and selected Device Smoke `44476128976` is QUEUED / running scenarios.
- PR #3556 Build `44475246526` is QUEUED; Follow-up File Persistence `44475246595` is PASS; Device Smoke `44475246535` is PENDING.
- The operational branch #3052 has moved to documentation checkpoint `e378ae0e40a0d3baf1570c8019022e3fb7b156e5`; its last code/test candidate remains `e9a74921fca32edb31478b80cc1c2d50b8d75222`. The documentation-only checkpoint does not change the test evidence attached to e9a.
- Main base SHA observed for #3052 and #3495 remains `45e4202b03a434459e4c021a04efa7e8396359db`. No write to Main occurred.


## 14. Final metadata poll before handoff
- PR #3052 HEAD `422ecc1dbc550ff4a5e7f64a28069b7c6f31d1e5`: OPEN / DRAFT / UNMERGED; GitHub currently reports `mergeable=false`. This is not resolved as a merge conflict diagnosis; no merge was attempted.
- PR #3495 HEAD `1b1534924db9f251df83c36cabff30285194784e`: OPEN / DRAFT / UNMERGED; `mergeable=true`.
- PR #3556, #3557 and #3558 remain OPEN / DRAFT / UNMERGED. GitHub currently reports `mergeable=false` for these lane PRs after the operational base branch advanced beyond their captured base checkpoint `e9a74921fca32edb31478b80cc1c2d50b8d75222`. They must be refreshed against the latest base and reviewed before any integration; no merge or force-push.
- PR #3052 Build on code candidate `e9a74921fca32edb31478b80cc1c2d50b8d75222`: FAIL with 80 failed test instances; Device Smoke `44474830680`: CANCELLED.
- PR #3558: Analyze PASS, Visual PASS, Follow-up File Persistence PASS; Build `44476129018` remains IN PROGRESS and Device Smoke `44476128976` remains QUEUED/running.
- PR #3556: Follow-up File Persistence PASS; Build `44475246526` QUEUED and Device Smoke `44475246535` PENDING.
- PR #3557: Build `44476426493` QUEUED; Follow-up File Persistence `44476426700` IN PROGRESS; Device Smoke `44476426659` PENDING.
- Latest operational documentation checkpoint is this tracker update; the latest code/test candidate remains `e9a74921fca32edb31478b80cc1c2d50b8d75222`. Main base remains `45e4202b03a434459e4c021a04efa7e8396359db`.


# COMMAND 63-R — cumulative live execution checkpoint
**Checkpoint:** 2026-11-19 (UTC+03:30)  
**Operational repository:** `mobinpda-lab/Arvin-clean`  
**Operational PR:** #3052  
**Operational branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**Latest code/test HEAD:** `bc2b3d61ab10e5cd6c9c72f56d522057f9ba5975`  
**Main/base SHA:** `45e4202b03a434459e4c021a04efa7e8396359db`  
**Release:** NO-GO  
**Main:** protected / unchanged  
**Merge, release, deploy:** not authorized

This tracker is cumulative: the complete COMMAND 62-R ledger above is retained verbatim as historical evidence. The entries below add COMMAND 63-R live findings and do not rewrite earlier results.

## 15. COMMAND 63-R — live repository and PR reconciliation
Repository permission check:
- Read: true
- Push/Write: true
- Maintain: true
- Admin: true
- Default branch: `main`
- Repository: public, not archived.

Live PR metadata:
| PR | State | Draft | Base branch / SHA | Head SHA | Mergeable | Disposition |
|---|---|---|---|---|---|---|
| #3052 | OPEN | yes | main / `45e4202b...` | `4b2a2ef4...` at first poll; advanced to `bc2b3d61...` by COMMAND 63 commits | true at first poll | Operational route; keep Draft |
| #3495 | OPEN | yes | main / `45e4202b...` | `1b153492...` | true | REV10 reference and comparison only |
| #3547 | OPEN | yes | `recovery-02/main-based-integration` / `7951a933...` | `1c83db84...` | false | Separate REV10 lane; no blind transfer |
| #3548 | OPEN | yes | `recovery-02/main-based-integration` / `7951a933...` | `e040eab4...` | true | Separate REV10 UI lane; review file-by-file |
| #3549 | OPEN | yes | `recovery-02/main-based-integration` / `7951a933...` | `ce9ce1d7...` | false | Separate REV10 data lane; schema lineage differs |
| #3556 | OPEN | yes | operational branch / stale base `e9a74921...` | `151e8f18...` | false | Design-token/navigation slice; stale base |
| #3557 | OPEN | yes | operational branch / stale base `e9a74921...` | `b3f6b237...` | false | OFL/Authors asset-test slice; no font binary change |
| #3558 | OPEN | yes | operational branch / stale base `e9a74921...` | `53537dd6...` | false | Migration-test-contract slice; no production code change |

The SHA references shown with ellipses are abbreviated for readability; full values are retained in the preceding historical section or PR metadata. PR #3052's current head is the full SHA recorded at the top of this COMMAND 63-R checkpoint. No branch was force-pushed and no PR was merged.

## 16. COMMAND 63-R — exact-head CI findings on prior operational HEAD
Candidate: `4b2a2ef418959420d6100d667431f35b55aba494`  
Build run: `44476625119`  
Device Smoke run: `44476625208`

Build run results:
- Analyze: PASS.
- Visual: PASS.
- Staging APK build, signature/manifest checks, font packaging audit and upload: PASS.
- Release APK build and verification: PASS.
- Debug APK: FAIL because Maven Central returned HTTP 429 while Gradle attempted to resolve Kotlin Gradle plugin BOM `2.2.20`. This is a dependency-service/rate-limit failure, not proof of a source compilation defect; it still leaves the Debug APK gate failed.
- Test shards: all six FAIL. Failure-instance counts by shard 1–6: 12, 11, 6, 26, 11, 14 = 80 reported failures. Counts are log-level failed test instances, not asserted to be 80 unique test names.
- Follow-up File Persistence: PASS.
- Calendar Provider: PASS.
- Draft Review APK: PASS.
- Device Smoke: PENDING at the last live poll; no PASS evidence.

Examples of concrete test mismatches from shard logs:
- Home filter/widget expectations: missing keys/text and filter-count/layout expectations.
- Task Detail expectations: missing timeline/details/independent-reminder keys and sections.
- Task metadata and date/reminder expectations: null vs expected date, missing metadata/labels.
- Work Agenda and reminder expectations: collection cardinality and legacy reminder serialization mismatches.
- Release critical path: test expected legacy `reminderDate == null`, while readback returned `2026-08-27T09:00:00Z`.
These examples are not a complete classification of all 80 failures. The remaining failures must be extracted from all six logs and mapped to source contracts before claiming closure.

## 17. COMMAND 63-R — first product correction on the operational branch
Source-backed gap found:
- The operational branch already has `ArvinCenter`, `CenterStore`, `CenterManagementPage`, Center-aware Project data and a Home Center filter selector/state.
- The Home filtering predicate already applies selected Center IDs, and the active-filter chip/clear behavior exists.
- However, the visible compact Home filter row rendered only Time, Project, Category and Tags. Center selection was reachable only through the secondary “More” menu. This did not satisfy the five-dimension REV10 Home filter contract.
- The existing test `test/home_stat_filters_test.dart` still described and asserted four REV5 filter controls.

Changes committed on the operational branch:
1. Commit `4f551ef3076bbcbe0dc86a097cade4a90d31d8ab` — added a visible Center filter pill to `lib/main.dart`, between Time and Project. It reuses the existing `_showCenterFilterSheet`, Center state, active styling and Center name lookup; it does not introduce a parallel data path.
2. Commit `e8506f9c1f9b578a1efa9841eedbe71f8c086d6f` — updated `test/home_stat_filters_test.dart` from four REV5 controls to five REV10 controls and added the Center key to all three responsive-layout assertions.
3. Commit `bc2b3d61ab10e5cd6c9c72f56d522057f9ba5975` — added a widget regression test confirming the Center pill opens the canonical Center selector and exposes the “projects without Center” option.

No assertions were removed or relaxed. No data model, schema, migration, backup format or Main file was changed. These commits are implementation changes, not accepted results: exact-HEAD Build, all six shards, Device Smoke and visual review remain required. At the time of this tracker creation, no workflow run had yet been returned for the final code/test HEAD `bc2b3d61...`; therefore these changes are **NOT TESTED** until fresh exact-SHA results are available.

## 18. COMMAND 63-R — Center and issue reconciliation
- Issue #3550 remains OPEN / P0. Its source description describes the #3495 canonical lineage, where the Center domain and Home filter were missing. On #3052, Center model/store/management UI and a Center selector/filter predicate already exist, but the visible Home Center pill was missing and is now added.
- #3052 still requires a full relationship audit: current Project data exposes a single `centerId` association, while the REV10 acceptance contract calls for explicit Center↔Project and Project↔Category many-to-many semantics. Do not label M2M acceptance complete based on the existing Center selector.
- #3550's remaining deliverables include explicit relationship operations, Task/Project/Category graph validation, file-backed fresh-reopen tests, backup/restore, responsive RTL screenshots and device acceptance. No Center association is inferred for legacy records.
- Issue #2682 is CLOSED in live issue metadata, but its stored body still contains a stale “P1 OPEN” status sentence. Closure metadata alone does not prove that current #3052 backup/restore round-trip and rollback acceptance is complete. Revalidate the actual implementation and exact-SHA evidence before treating the product gate as passed.

## 19. COMMAND 63-R — PR lane workflow outcomes observed
Workflow runs tied to the exact heads at the time of polling:
- #3495 head `1b1534924db9f251df83c36cabff30285194784e`: Build PASS; six shards included in that Build and passed; Debug/Release APK PASS; Follow-up File Persistence PASS; Device Smoke CANCELLED; COMMAND 20-E failed. This is reference evidence only, not evidence for #3052.
- #3547 head `1c83db84145675aa31e67feef95c23ddd84c181c`: Build FAIL; Device Smoke PASS; Follow-up File Persistence PASS.
- #3548 head `e040eab4bba72b615b0641cb95549982a73a4d18`: Build FAIL; Device Smoke FAIL; Follow-up File Persistence PASS.
- #3549 head `ce9ce1d755ae994d1f2567285304dc23b07aa823`: Build PASS; Device Smoke PASS; Follow-up File Persistence PASS. It remains a separate schema lineage and cannot be transplanted wholesale into #3052.
- #3556 head `151e8f184db95d9524a9472bb4e1520a711e21e1`: Build FAIL; Device Smoke PENDING; Follow-up File Persistence PASS.
- #3557 head `b3f6b237dca4eb47ccd71304b0de0ba8c1f67716`: Build FAIL; Device Smoke PENDING; Follow-up File Persistence PASS.
- #3558 head `53537dd62569b68bc2c7a4f19d9797732e8e3150`: Build FAIL; Device Smoke QUEUED at poll; Follow-up File Persistence PASS.
The failure logs for these lanes still require per-job extraction and root-cause classification. A PASS in a separate lane or on a different SHA never upgrades #3052.

## 20. COMMAND 63-R — remaining execution queue
| ID | Work | Priority | Branch / PR | Status | Acceptance still required |
|---|---|---|---|---|---|
| A-01 | Extract and classify every one of the 80 failed instances from #3052's six shard logs | P0 | operational / #3052 | IN PROGRESS | test name, source line, root cause, correction and exact-SHA regression |
| A-02 | Diagnose Debug APK Maven 429 and verify clean retry without conflating infrastructure and code failures | P0 | operational / #3052 | BLOCKED BY CI SERVICE RATE LIMIT | Debug APK PASS on exact candidate |
| B-01 | Visible five-dimension Home filter | P0 | operational / #3052 | IMPLEMENTED / NOT TESTED | Home widget, responsive widths, Center selector, OR/AND composition, exact-head CI |
| B-02 | Full REV10 route/page inventory and redesign | P0 | operational / #3052 | NOT STARTED AS A COMPLETE AUDIT | each page, states, RTL, sizes, screenshots, widget/device tests |
| B-03 | Center↔Project and Project↔Category relationship model | P0 | operational / #3052 | PARTIAL / ARCHITECTURE REVIEW REQUIRED | explicit M2M operations, migration, backup/restore and fresh-reopen evidence |
| C-01 | Reconcile approved palette and all theme tokens | P0 | operational / #3052 | NOT VERIFIED | compare `#078B91`, `#066F75`, `#DDF7F5`, `#F0FAF9`, `#D9ECEA` against actual token consumers and page surfaces |
| D-01 | Vazirmatn assets, weights, registration and packaged APK | P0 | operational / #3052; #3557 source PR | PARTIAL | compare each binary to source archive, verify 300/400/500/600/700 and any required variable font, license in APK, UI/PDF rendering |
| E-01 | Schema and migration lineage v7→v19→v20 / active schema | P0 | #3052 + #3495 reference | BLOCKED / DEEP REVIEW | file-backed sequential migration, idempotency, retry, rollback, explicit NULL, unknown fields, integrity and FK checks |
| F-01 | Person directory exclusions and historical relation retention | P0 | #3052 adaptation | PARTIAL | adapt behavior to `persons/person_directory/task_persons`; no direct copy of #3549's different `people` schema |
| F-02 | Backup/restore of standalone Person directory and all historical links | P0 | operational / #3052 | NOT ACCEPTED | independent file restore, injected-failure rollback, reopen and relation parity |
| G-01 | Exact-head seven-lane Device Smoke | P0 | operational / #3052 | PENDING | all seven lanes PASS, no cancelled/skipped substitute |
| H-01 | Safe refresh and file-by-file integration of #3556–#3558 | P1 | lane branches | BLOCKED BY STALE BASE / REVIEW | compare against latest operational head, no force-push, focused tests and exact-head CI |
| P2P-01 | Local P2P security design and two-device protocol | P1 | operational design doc | DESIGN ONLY | security review, authenticated pairing, encryption, replay protection, durable sync and real two-device tests |

## 21. COMMAND 63-R — safety and release gate
- Main remains unchanged at base SHA `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3052 remains OPEN / DRAFT / UNMERGED. Its head advanced through three focused commits and is now `bc2b3d61ab10e5cd6c9c72f56d522057f9ba5975`.
- No merge, release, deploy, branch deletion, force-push, destructive migration or production-user-database operation was performed.
- No cancelled, queued, pending or in-progress job is counted as PASS.
- Overall release remains **NO-GO** until all required product gates pass on one exact candidate SHA and explicit owner approval is recorded.


## 22. Exact-head validation started for COMMAND 63 Home Center filter
Operational code/test candidate remains `bc2b3d61ab10e5cd6c9c72f56d522057f9ba5975`.
Fresh workflows now returned for this exact SHA:
- Build run `44482485655` (#11703): PENDING at the latest poll.
- Device Smoke run `44482485567` (#8862): PENDING.
- Follow-up File Persistence run `44482485720` (#2785): PENDING.
- Calendar Provider run `44482485593` (#2983): IN PROGRESS.
- Draft Review APK run `44482485649` (#1991): IN PROGRESS.
- Parallel Wave, G1 lock sync, Production Loop, Orchestrator and PR Wakeup: completed successfully. These orchestration successes do not replace Build/test/device acceptance.
PR #3052 remains OPEN / DRAFT / UNMERGED and currently reports `mergeable=true`. No result above is yet a PASS for the new code/test SHA.

Documentation lane:
- New cumulative tracker branch: `command-63-r/master-tracker`.
- Tracker PR #3564: OPEN / DRAFT / UNMERGED; base is the operational branch at `bc2b3d61ab10e5cd6c9c72f56d522057f9ba5975`; head is `ccefd74c99242410370a0923b2b224bdcee394db` at creation. It is documentation-only and does not alter Main.


## 23. Follow-up COMMAND 63 source audit — relationships and backup
### Center / Project / Category storage
The operational #3052 source is schema v17. The inspected `g1_drift_schema.dart` creates `centers`, `projects`, `project_items` and `taxonomy_categories`; it does not create `center_projects` or `project_categories`.
- `ProjectPlan.centerId` is scalar.
- `projects.center_id` is a nullable scalar FK.
- `ProjectStore.save` rebuilds Project rows and `project_items` in a transaction; any future relation tables must be explicitly preserved/restored in this transaction.
- Task categories remain Task-level strings; no Project↔Category relation is currently proven.
The safe additive design proposal is on the COMMAND 63 documentation branch:
`docs/architecture/COMMAND-63-R-CENTER-M2M-AND-SCHEMA-18-PLAN.md`
Commit: `c48ebb7d5c81a041990a8c9d65341f8c8c5ca23b`.
No schema migration or production code was changed for M2M. The issue #3550 source distinction and missing acceptance evidence were posted as comment ID `7003269413`; issue remains OPEN.

### Person Directory backup
Source review found the current #3052 portable backup code already has a `peopleDirectory` field in backup format v1:
- `ArvinBackupManager.backupCanonicalTasks` accepts standalone Person records and serializes them into the same existing document.
- `restoreCanonicalBackup` decodes and validates Person IDs and Follow-up person references; old backups without `peopleDirectory` remain distinguishable/backward-compatible.
- Tests include standalone Person + Follow-up association coverage in `test/canonical_backup_manager_test.dart`, and `test/backup_service_test.dart` validates optional People-directory round-trip.
- Issue #2682 is CLOSED in live metadata, while its description body still contains a stale “P1 OPEN” line.
Disposition: the serialization/restore-candidate layer is source-backed; independent SQLite-file restore, full apply/rollback integration and post-reopen relation parity still require exact tests/artifacts. Do not claim the complete backup/restore gate PASS from JSON candidate tests alone.

## 24. Latest operational code candidate and fresh exact-SHA runs
Operational branch head: `542b719efc99c632e09ba070e40388c10a448379`.
This includes the Home Center pill, updated five-filter widget assertions, Center-selector test and the canonical Reminder compatibility-getter test correction.
Fresh exact-head workflows:
- Build run `44482767738` (#11706): Analyze PASS, Visual PASS; Release APK, Debug APK, Staging APK and all six test shards IN PROGRESS at the last poll.
- Device Smoke run `44482767749` (#8865): PENDING; no job results yet.
- Follow-up File Persistence run `44482767791` (#2788): PENDING at the run poll; job fetch subsequently reported its single file-backed SQLite job SUCCESS.
- Calendar Provider run `44482767767` (#2984): IN PROGRESS.
- Draft Review APK run `44482767717` (#1994): QUEUED / IN PROGRESS.
No overall Build or Device Smoke result is accepted yet. The earlier exact-head result on `4b2a2ef...` remains FAIL with 80 failed test instances and a Debug dependency download HTTP 429.

Documentation lane updates:
- Architecture proposal commit: `c48ebb7d5c81a041990a8c9d65341f8c8c5ca23b`.
- Issue #3550 clarification comment: `7003269413`.
- Tracker PR #3564 remains OPEN / DRAFT / UNMERGED; its branch is documentation-only and is not merged into the operational branch.


## 25. COMMAND 63-R — next root-cause correction batch
New operational commits after candidate `542b719efc99c632e09ba070e40388c10a448379`:
- `24a34d2ab8505350d1d69a56dd39d0376b786419` — Home icon-only filter tests now query their accessible Semantics labels rather than looking for visible text that the compact icon-only control intentionally does not render.
- `8aac4e69fefaa9682bde106552c53914c9ea697e` — legacy reminder fixture now enters through explicit `Task.fromLegacyJson`, rather than canonical `Task.fromJson`. This matches the explicit migration boundary and preserves the reminder conversion assertion.
- `f828c66b227a5e83deefe83df61444dde5dbb3dc` — Task Details due-date test now seeds an explicit canonical `TaskReminder`, verifies its stable ID/date after due-date change, and verifies retired Task/Follow-up scheduling values remain in `legacyFollowUpMetadata` as inert data. The deprecated getters are not treated as active scheduling.
- `6abc38fe5fc9c83d83e675c3c89fc33e84ba4506` — migration writer test asserts canonical Follow-up `completedAt` serialization and explicitly asserts the legacy `dateTime` key is absent.
- `dab77700f864fee0a753e82b81df0adb1f2e3829` — file-backed SQL migration test now records the production migration-complete marker after the migration transaction and before closing/reopening SQLite. This prevents the reopen test from accidentally re-entering the legacy migration path.

These are test-contract/fixture corrections based on the canonical model, not production code changes. Assertions for retained identity, reminder date, historical Follow-up content and inert legacy metadata were preserved or made more explicit. No production data was deleted.

### Prior exact-head run on SHA `542b719efc99c632e09ba070e40388c10a448379`
Build run `44482767738` was superseded when the branch advanced:
- Analyze PASS; Visual PASS; Debug APK PASS.
- Five completed shards failed: shard 0 = 13, shard 1 = 6, shard 3 = 13, shard 4 = 10, shard 5 = 11 failures (53 reported failure instances across those completed shards).
- Shard 2 was CANCELLED by the newer candidate before completion.
- Release and Staging APK jobs were still in progress when superseded; no PASS is recorded for them on this SHA.
- Follow-up File Persistence `44482767791`: PASS.
- Draft Review APK `44482767717`: PASS.
- Device Smoke `44482767749`: no jobs/results before supersession; not accepted.
This run is historical evidence for SHA 542b only, not for the current candidate.

### Latest candidate at this update
Operational branch head: `dab77700f864fee0a753e82b81df0adb1f2e3829`.
Fresh exact-head runs:
- Build `44484305168` (#11713): Debug APK and two test shards were in progress; other shards queued; Analyze, Visual, Release and Staging not yet completed.
- Device Smoke `44484305107` (#8872): PENDING, no job result yet.
- Follow-up File Persistence `44484305216` (#2795): IN PROGRESS.
- Calendar Provider `44484305315` (#2989): IN PROGRESS.
- Draft Review APK `44484305327` (#2001): IN PROGRESS.
No exact-head acceptance gate is PASS yet, except jobs that subsequently report success; do not promote queued or in-progress work to PASS.


## 26. COMMAND 63-R — Vazirmatn binary and licensing reconciliation
The original Library archive was materialized and rechecked in the current runtime:
- File: `vazirmatn-v33.003 (2).zip`
- Size: 13,047,191 bytes
- ZIP entries: 387
- CRC test: clean
- SHA-256: `0a9afd41967e6f57096a56a181a23f81a2b999b62f1f2a4e4b26736580854fdb`
- Main family includes nine static TTF weights (100, 200, 300, 400, 500, 600, 700, 800, 900) and one variable `Vazirmatn[wght].ttf`.
- Archive includes SIL OFL 1.1 `OFL.txt` and upstream `AUTHORS.txt`.

Exact binary reconciliation:
- All five static fonts currently registered in #3052 `pubspec.yaml` match the source archive byte-for-byte by Git blob SHA:
  - Light 300: `2dfd5c35ed4c26f7ce9f3ba753f11d9a38356c42`
  - Regular 400: `64e4a8189557a17b63fd7a77794207483e592972`
  - Medium 500: `1e08dd54d90a4879451ef0f80fe0d8068fb7462f`
  - SemiBold 600: `6b3842aca6055c8258404b1758133b81c961a13f`
  - Bold 700: `efa9b095da01d299310bdcae293e24e657fe6da9`
- The repository does not contain the other four static weights (Thin 100, ExtraLight 200, ExtraBold 800, Black 900) or the variable font. They are not registered in `pubspec.yaml`; the current product typography uses only the five registered weights. No extra font binary has been added because there is no current UI token/use for those additional weights.
- Existing repository `assets/fonts/ui/vazirmatn/LICENSE.txt` has Git blob SHA `be66b3824e9772e75141e631695c5256f105fb57`, exactly matching the archive's `OFL.txt` blob. The license was already present; adding a duplicate `OFL.txt` would be unnecessary.
- The archive's exact `AUTHORS.txt` was missing. Added it to the operational branch, and added a rootBundle test against the existing `LICENSE.txt` plus new `AUTHORS.txt`.
- The app central family is `AppFonts.vazirmatnFamily = 'Vazirmatn'`; `ArvinTheme.fontFamily` and light/dark ThemeData also use Vazirmatn. Five weights in pubspec are 300/400/500/600/700. Font size remains user-scalable.
- The README under `assets/fonts` still describes optional proprietary IRANSansX assets; the audited central UI theme does not use that family. It is a documentation cleanup candidate, not proof of a runtime dependency.

Font commits on operational branch:
- `efc11cb7d37c11faeb185b87519d3304ebbee1de` — add upstream archive AUTHORS.txt.
- `34c461107b8cb758715d08d1b7aef5e34a2d1c30` — add bundled-license/author rootBundle regression test.
The #3557 branch's duplicate `OFL.txt` was not copied; its existing upstream Authors text was also not used because it differed from the archive's exact AUTHORS.txt. No font binary or registered weight changed.

Fresh workflows for candidate `34c461107b8cb758715d08d1b7aef5e34a2d1c30`:
- Build `44485072875` (#11716): PENDING.
- Device Smoke `44485072815` (#8875): PENDING.
- Follow-up File Persistence `44485073034` (#2798): IN PROGRESS.
- Calendar Provider `44485073037` (#2991): QUEUED.
- Draft Review APK `44485073188` (#2004): QUEUED.
No acceptance result is inferred from the pending runs.


## 27. Full 80-instance baseline inventory
All six shard logs from Build run `44476625119` were re-read and every failed test instance was extracted. The supporting inventory is:
`docs/history/command-63-r/COMMAND-63-R-80-SHARD-FAILURE-INVENTORY.md`
Commit: `180806f87bb12f9ca1259d281552571bf66eb3ab`.
Exact count reconciliation:
- test-0: 14
- test-1: 6
- test-2: 26
- test-3: 12
- test-4: 11
- test-5: 11
- Total: 80 — exact match with the Build summary.
The inventory preserves all 80 test names, shard job IDs and an initial triage category. Categories are not root-cause findings. Six test-contract/fixture corrections already committed are marked with their exact correction status; all remaining rows stay ROOT_CAUSE_PENDING until the full assertion/exception, source line, product contract and exact-SHA regression are documented.

## 28. COMMAND 63-R live checkpoint — 2026-11-19

### Repository and route reconciliation
- Main remains 45e4202b03a434459e4c021a04efa7e8396359db; no write was made to Main.
- PR #3052 remains OPEN / DRAFT / UNMERGED on fix/recovery-calendar-device-smoke-2026-10-31. At this checkpoint its exact HEAD is a2825e003bb9e6b5c2413b0dc74b085273b6148b, base Main SHA 45e4202b03a434459e4c021a04efa7e8396359db, and GitHub reports mergeable=true.
- The branch advanced through the reviewed sequence from e9a74921... → e378ae0... → 422ecc1... → 4b2a2ef... → Center-filter commits 4f551ef..., e8506f9..., bc2b3d6..., canonical-contract test commits through dab7770..., and Vazirmatn commits efc11cb..., 34c4611..., then this asset-manifest correction a2825e0.... This history is fast-forward; no force-push or rewrite was observed.
- Current #3052 is 2,214 commits ahead and 0 behind Main. PR #3495 remains OPEN / DRAFT / UNMERGED at 1b1534924db9f251df83c36cabff30285194784e and is reference-only. #3547, #3548, #3549 remain OPEN / DRAFT / UNMERGED on their separate #3495-based lineage. #3556, #3557 and #3558 remain OPEN / DRAFT / UNMERGED against stale #3052 base e9a74921...; no lane has been merged.
- Documentation PR #3564 remains OPEN / DRAFT / UNMERGED. Its branch command-63-r/master-tracker is documentation-only relative to its base checkpoint and is not merged into #3052.

### Exact-head CI findings — SHA 34c4611
- Build run 44485072875: Analyze PASS, Visual PASS, Debug/Release/Staging APK PASS; all six shards FAIL with 74 failed test instances (26, 10, 12, 11, 6, 9 by shard). This is a newer run than the historical 80-instance baseline; the two counts must remain separately identified.
- Follow-up File Persistence 44485073034: PASS. Calendar Provider 44485073037: PASS. Draft Review APK 44485073188: PASS. Device Smoke 44485072815: PENDING, not PASS.
- APK artifacts exist on this SHA, but they are review artifacts only and do not constitute release acceptance.
- The 74 test names, job IDs and shard totals are appended in COMMAND-63-R-80-SHARD-FAILURE-INVENTORY.md in this same documentation branch.

### First correction after the 34c failure
The font asset regression test failed because Flutter could not load assets/fonts/ui/vazirmatn/LICENSE.txt; the file existed in the repository but was not in the built asset bundle through the broad directory declaration. Updated pubspec.yaml to explicitly include:
- assets/fonts/ui/vazirmatn/LICENSE.txt
- assets/fonts/ui/vazirmatn/AUTHORS.txt
Commit: a2825e003bb9e6b5c2413b0dc74b085273b6148b.
This is a focused asset-manifest fix, not a font-binary change. Exact-SHA retest is still running; no PASS is claimed yet.

### Exact-SHA validation in progress — SHA a2825e0
- Build run 44490319550: Analyze PASS; Visual PASS; Staging APK FAIL due Gradle dependency resolution (org.jetbrains.kotlin:kotlin-stdlib, kotlin-gradle-plugin and BOM 2.2.21 unavailable from Plugin Portal in this run). This is currently classified as dependency-service/environment failure pending controlled retry; it is not yet a source compilation diagnosis. Other APK jobs and six test shards were IN PROGRESS at the last poll.
- Follow-up File Persistence run 44490319367: PASS.
- G1 lock sync run 44490319577: PASS.
- Calendar Provider run 44490319483: IN PROGRESS.
- Draft Review APK run 44490319361: IN PROGRESS.
- Device Smoke run 44490319359: PENDING.
No cancelled, skipped, queued, pending or in-progress job is counted as PASS. A failed dependency-resolution job may be rerun only after the complete workflow result is captured and the external cause is confirmed.

### Product source findings
- Center filter is now present in the compact Home row and its test coverage was updated to five dimensions. Issue #3550 received an evidence-based comment (comment ID 7004253676) describing remaining gaps.
- #3052 active schema is still v17. It has centers, scalar projects.center_id, legacy project_items, and no center_projects or project_categories tables. Task model carries centerId in its serialized envelope, but there is no relational tasks.center_id column. Center↔Project / Project↔Category M2M acceptance remains OPEN. The schema-18 additive design proposal is retained in COMMAND-63-R-CENTER-M2M-AND-SCHEMA-18-PLAN.md; it is design-only, not implementation authorization.
- Current ArvinTheme still defines Blue palette tokens (#4169A1, #355782, #E5EDF8, #F0F5FC, #F4F6F9, #E5E7F0), conflicting with COMMAND 63-R's approved teal palette (#078B91, #066F75, #DDF7F5, #F0FAF9, #D9ECEA). Path C remains P0 and unimplemented.
- Issue #2682 is CLOSED in live metadata. Its latest comment says the current #3052 backup path includes peopleDirectory, validation and rollback candidates, but independent SQLite-file restore/reopen parity and physical-device evidence are still not accepted. Do not reopen solely from stale body text; keep product gate open until proof is complete.
- Local P2P remains DESIGN ONLY. No pairing, cryptographic transport or sync implementation has been accepted; security review and two-device testing remain outstanding.

### Updated dispositions
| Path | Status | Next acceptance |
|---|---|---|
| A — CI / six shards | BLOCKED | Finish exact SHA a2825e0 run; classify every current failed test; rerun only infrastructure failures after diagnosis |
| B — REV10 UI / Home | PARTIAL | Full route/page inventory, state-by-state redesign and device evidence; Center pill now visible |
| C — Design System | NOT ACCEPTED | Replace blue tokens with approved teal palette after token-consumer audit; validate all pages and dark mode |
| D — Vazirmatn | PARTIAL | Explicit asset bundle fix awaits exact-SHA test; verify packaged APK and rendering; five static weights only are registered |
| E — Data / migration | IN PROGRESS | V7/V19/V20 lineage, schema 17→18 design, explicit NULL/unknown fields, rollback and independent restore |
| F — People / entities | PARTIAL | Adapt tombstone behavior to #3052 persons/person_directory/task_persons lineage; prove independent restore/reopen |
| G — Device | BLOCKED | Exact-SHA seven-lane Device Smoke and physical-device evidence |
| H — P2P | DESIGN ONLY | Security review, protocol decisions and two-device test plan before implementation |

**Release remains NO-GO. Main protected. PR #3052 and all source/documentation PRs remain OPEN / DRAFT / UNMERGED. No merge, release, deploy, destructive migration or production-database operation was performed.**

## 29. COMMAND 63-R — current lane split and follow-on CI (2026-11-19)

### Independent draft lanes created from the reviewed operational candidate a2825e003bb9e6b5c2413b0dc74b085273b6148b
- PR #3567 — Path C Design System, branch command-63-r/path-c-design-system, head 05869cdb634acbbfb6f928b8b1c4a832f4f25e16. Applies the exact approved teal brand tokens in ArvinTheme and updates the token regression test. Scope is token foundation only; no full-page redesign claim.
- PR #3569 — Path B Home grouping, branch command-63-r/path-b-home-grouping, head c00118e6f8854e74829213d9ef1a24c051bc75b0. Aligns the Home projection and HomeGroupingService to five groups, moves completed prior-day tasks into the historical group after active overdue work, and updates tests for the Center pill and five groups.
- PR #3570 — Path A Task contract, branch command-63-r/path-a-task-contract, head 99fcc90dee2deba29d0d1ba6395d8275b78f85b0. Changes stale legacy reminderDate test fixtures to canonical TaskReminder records and adds stable-ID/date readback assertions.
- All three are OPEN / DRAFT / UNMERGED. Their initial GitHub mergeability field returned false; do not infer conflict resolution or acceptability. Re-check compare/mergeability and exact-head CI before any promotion. No merge performed.

### Current exact-head result — PR #3052 SHA a2825e0
- Build run 44490319550: FAILURE. Analyze PASS; Visual PASS; Debug APK PASS; Release APK PASS; Staging APK first attempt FAIL due missing Kotlin 2.2.21 artifacts from Plugin Portal; all six test shards FAIL with 72 instances (12, 6, 25, 10, 9, 10).
- The Vazirmatn license/authors RootBundle test now PASSes, confirming the explicit pubspec asset entries fixed that specific test-level failure.
- The 72 exact failing test instances are appended in COMMAND-63-R-80-SHARD-FAILURE-INVENTORY.md.
- Follow-up File Persistence 44490319367: PASS. Calendar Provider 44490319483: PASS. Draft Review APK 44490319361: PASS. G1 Lock Sync 44490319577: PASS.
- Device Smoke 44490319359 remains PENDING with no jobs. No device acceptance.
- Debug and Release artifacts exist: arvin-debug-apk (93,488,372 bytes) and arvin-release-apk (38,041,994 bytes). Staging artifact absent.
- Staging failed job 135443981025 was retried individually after confirming an external dependency-resolution cause. Retry job 135449076966 was IN PROGRESS at last poll. No PASS is claimed until it completes.

### Known root-cause decisions
- Task contract failure is a stale fixture: Task.reminderDate constructor input is legacy-only and intentionally not converted by canonical Task constructor. Canonical TaskReminder fixture correction is isolated in PR #3570.
- Home grouping failure is a product-contract mismatch: REV10 requires five groups and no separate completed_past group. The implementation and regression update are isolated in PR #3569.
- Reminder table migration failure remains unresolved. Existing SQL table still contains is_legacy_task_reminder. No schema rebuild/drop was attempted because unknown columns, indexes, triggers, foreign keys and historical row preservation must be assessed first.
- Home filter Boolean logic test has a hit-test warning on an off-screen option; investigate scroll/viewport behavior rather than suppressing it.
- Quick Capture reminder/recurrence labels remain missing from the widget tree expected by tests; inspect the actual form, controls and responsive state before changing tests.

### Updated release gate
Build remains FAIL due six shards and the staging first attempt; controlled staging retry is still running. Device Smoke is PENDING. The release state is NO-GO. Main remains unchanged. PR #3052, #3564, #3567, #3569 and #3570 remain OPEN / DRAFT / UNMERGED. No destructive migration, merge, release or deploy was performed.

## 30. COMMAND 63-R — expanded lane execution and governance alignment (2026-11-19)

### Updated independent PR inventory
All are OPEN / DRAFT / UNMERGED, base PR #3052 operational branch at SHA a2825e003bb9e6b5c2413b0dc74b085273b6148b, and GitHub reports mergeable=true at this checkpoint:
- #3567 Path C Design System — head 024a9842e96325c9347a57c8f97fd304eee13067. Approved teal tokens, Home navigation brand icon, token/semantic/navigation tests.
- #3569 Path B Home — head 5444b5c888e9ca628664d2042d37a9590ce07348. Five due-date groups, completed past visibility, Center pill and filter-sheet test scrolling.
- #3570 Path A Task contract — head 402ab6faaed473fc260440491057f986db109f43. Canonical TaskReminder fixture, timeline label distinction and robust no-outbound-sync source-boundary test.
- #3571 Path B Quick Capture — head f07abcf1c0be11bdb103f10b5b527390feea49eb. Visible Project/Category/Tags/Reminder/Recurrence labels and corrected Center inline-create interaction.
- #3572 Path B Task Detail — head 09e0c011036f19cbe14935d71ecc4dd0cc08a7c8. Checklist widget test now uses a realistic 390×844 phone viewport and resets view state.
- #3564 Documentation lane — head 4c6c8ac720a6f2310e833ce25f54c91cc189dbc0; base checkpoint bc2b3d61ab10e5cd6c9c72f56d522057f9ba5975 is behind current #3052. It remains draft and is not merged. It contains cumulative Master Tracker, failure inventory, COMMAND63 owner-decision addendum, conflict register resolution and P2P authority reaffirmation.

### New exact-head workflow states
- #3567 head 024a984: Build 44493120042 PENDING; Follow-up File Persistence 44493120315 QUEUED; Device Smoke 44493119970 PENDING; Draft Review APK 44493120019 SKIPPED. A previous head 05869cdb... had one additional stale blue-brand test failure; the assertion was updated to the teal owner decision and the navigation harness now rebuilds selected state. Latest head has not yet completed CI.
- #3569 head 5444b5c: Build 44492511275 PENDING; Follow-up File Persistence 44492511319 PASS; Device Smoke 44492511322 PENDING; Draft Review APK 44492511398 SKIPPED.
- #3570 head 402ab6f: Build 44492832470 QUEUED; Follow-up File Persistence 44492832545 IN PROGRESS; Device Smoke 44492832373 PENDING; Draft Review APK 44492832384 SKIPPED.
- #3571 head f07abcf: Build 44493019393 PENDING; Follow-up File Persistence 44493019286 PASS; Device Smoke 44493019279 PENDING; Draft Review APK 44493019261 SKIPPED.
- #3572 head 09e0c01: Build 44493057686 QUEUED; Follow-up File Persistence 44493057861 QUEUED; Device Smoke 44493057739 QUEUED; Draft Review APK 44493057813 SKIPPED.
No queued, pending, skipped or in-progress lane is PASS.

### Staging retry and current #3052 result
- On #3052 SHA a2825e0, only the failed staging job was retried after its Gradle/Plugin Portal dependency-resolution error was isolated. Original job 135443981025 failed; retry job 135449076966 completed SUCCESS.
- This establishes a successful Staging APK build attempt on the exact same SHA. The original failure remains in the historical run, and the aggregate Build remains FAILURE because all six test shards still have 72 failed instances.
- Debug and Release APK jobs passed. The six-shard suite remains blocked. Device Smoke remains PENDING with no jobs.

### Owner-decision documentation synchronized
Documentation lane #3564 now carries:
- Product Decisions addendum dated 2026-11-19 with the fixed teal palette, Vazirmatn v33.003, five Home groups, five Home filters, M2M relationship graph and Local P2P Phase 1 reauthorization.
- Conflict Register updates resolving CR-002 (palette) and CR-027 (font) per COMMAND63; CR-028 (P2P authority) and CR-029 (five-group Home contract) added.
- P2P security design document reaffirmed under COMMAND63; design remains proposal-only, no networking or cryptographic implementation is claimed.

### Active blockers
1. Six-shard suite: 72 exact-head failures on #3052 SHA a2825e0. Current corrections are isolated in draft PRs and await their own CI.
2. SQLite reminder migration: is_legacy_task_reminder remains in the historical table. No migration change is accepted until unknown columns, indexes, triggers, FKs, NULL and backup/restore preservation are proven.
3. Backup/Restore: existing automated tests pass in part, but independent file-backed restore/reopen and physical-device evidence remain outstanding.
4. Device Smoke: pending on all active heads; no screenshot/log/artifact-backed physical-device acceptance.
5. REV10 page-by-page audit remains incomplete beyond the targeted Home, Quick Capture, Task Detail and design-token slices.
6. Local P2P is authorized for Phase 1 but remains design-only pending concrete protocol/security review and two-device acceptance.

**Release remains NO-GO. Main remains protected and unchanged. No source PR is merged; no release or deployment is authorized.**

## 31. COMMAND 63-R — Vazirmatn v33.003 source reconciliation and nine-weight completion

### Official source verification
- Official upstream repository/tag: rastikerdar/vazirmatn, v33.003.
- SourceForge mirror release page reports archive SHA-256 0a9afd41967e6f57096a56a181a23f81a2b999b62f1f2a4e4b26736580854fdb, matching the digest specified by COMMAND 63-R. The archive itself was not downloaded in this execution; the mirror's published digest was checked.
- The upstream fonts/ttf directory contains nine static TTF files: Thin, ExtraLight, Light, Regular, Medium, SemiBold, Bold, ExtraBold and Black.
- All five existing app weights (300–700) were fetched as upstream blobs and compared by Git blob SHA; all five matched exactly.
- Four missing weights (100, 200, 800, 900) were added to the Path D branch from the exact upstream tag. Their blob SHAs match upstream exactly:
  - Thin 100: b7a7d233e2a78b48d2eaa6733dd4ba683a92d847
  - ExtraLight 200: b7b947e6acda06dd5c545a2fcd506900500afaa8
  - ExtraBold 800: 380bd15866f3364d7c34af1cbd3c15a2e209dfee
  - Black 900: 4b9bd66179952e5b2edcfd97acbdef6d4acd0ea2
- Upstream OFL.txt and app LICENSE.txt are byte-identical (blob SHA be66b3824e9772e75141e631695c5256f105fb57). App AUTHORS.txt was synchronized to the exact upstream AUTHORS.txt (blob SHA 6efd2e62407e08b482647e134f9098b44e5ae5ec).
- The font binaries are static TTF weights, not a variable-font registration.

### Implementation lane
- PR #3573 — OPEN / DRAFT / UNMERGED, branch command-63-r/path-d-vazirmatn, head 160be20b6ac416d7cccc49859d5d597e9dacfba6.
- Added all four missing binary TTFs, registered all nine weights (100–900) in pubspec.yaml, preserved explicit LICENSE/AUTHORS asset entries, synchronized AUTHORS, documented the upstream source/archive digest, and extended the test to verify FontManifest.json plus successful rootBundle loading of every weight.
- Current PR #3052 branch itself still has the five-weight set until PR #3573 is independently accepted and integrated. Do not report nine weights as present in the operational PR #3052 source.
- Exact-head workflows for #3573: Build 44494245892 QUEUED; Device Smoke 44494246051 QUEUED; Follow-up File Persistence 44494246494 QUEUED; Draft Review APK 44494245954 SKIPPED. None is PASS.
- PR #3573 was created as draft and GitHub initially returned mergeable=false; recheck after GitHub computes mergeability. No merge performed.

### Remaining font acceptance
- Verify the generated FontManifest test on the exact PR head.
- Verify Debug, Release and Staging APKs package all nine weights.
- Verify actual Android rendering for Persian and Latin numerals, Arabic diacritics, punctuation, spacing, line height and every key page.
- Verify text-size Settings continue to work and no previous font dependency remains.
- Obtain physical-device screenshots and exact-SHA evidence.

**Disposition: Source identity and nine-weight source assets are verified on PR #3573; app-wide visual and device acceptance remains OPEN.**

## 32. COMMAND 63-R — live implementation and failure-triage checkpoint (2026-11-19)

### Live repository state
- Main: `45e4202b03a434459e4c021a04efa7e8396359db` — unchanged / protected.
- Operational PR #3052: OPEN / DRAFT / UNMERGED, branch `fix/recovery-calendar-device-smoke-2026-10-31`, HEAD `a2825e003bb9e6b5c2413b0dc74b085273b6148b`. No direct Main write, merge, release or deploy.
- #3052 Build run `44490319550`: Analyze PASS; Debug APK PASS; Release APK PASS; Visual PASS; all six test shards FAIL with 72 failed test instances. The original Staging APK job failed on external Kotlin 2.2.21 dependency resolution; isolated retry job `135449076966` completed SUCCESS on the same SHA. The aggregate Build remains FAIL because the six shards fail.
- #3052 Follow-up File Persistence `44490319367`: PASS. Calendar Provider `44490319483`: PASS. G1 Lock Sync `44490319577`: PASS. Draft Review APK `44490319361`: PASS. Device Smoke `44490319359`: PENDING; no device acceptance.

### Current independent Draft PRs
All remain OPEN / DRAFT / UNMERGED; none has been merged or promoted.

| PR | Lane / scope | Branch HEAD | Latest workflow state at poll |
|---|---|---|---|
| #3567 | Path C — approved teal palette, shared design tokens, app-wide Material theme and navigation | `6d9cb754cd5bade41dac130653d03e852774cbb1` | Build PENDING; Device Smoke PENDING; Orchestrator IN_PROGRESS; Follow-up Persistence PENDING |
| #3569 | Path B — five Home groups, REV10 header identity, five visible filters and RTL order | `19a657503bd7b1a28576a5a0676a0a48af7ffa34` | Build PENDING; Device Smoke PENDING; Follow-up Persistence QUEUED; Orchestrator QUEUED |
| #3570 | Path A — canonical TaskReminder contracts, reminder migration, Occurrence/Checklist persistence and report fixture | `fd4954d773e039cb56ed31806fd2b4790b82d3b5` | Build PENDING; Device Smoke PENDING; Follow-up Persistence QUEUED |
| #3571 | Path B — Quick Capture labels, Center inline creation and scroll-aware interaction tests | `60de06ecb0dae94fdbe3ebc6a4c0d93ce81f156e` | Build PENDING; Device Smoke PENDING; Follow-up Persistence PASS; PR Wakeup PASS |
| #3572 | Path B — Task Details metadata heading and lazy timeline visibility | `be9248d77348421bd044e2480634e804f5782aba` | Build QUEUED; Device Smoke PENDING; Follow-up Persistence QUEUED; Orchestrator PASS |
| #3573 | Path D — Vazirmatn v33.003 nine static TTF weights, official license/authors and bundle manifest test | `6d0dc85ed2ce8bb144c157e39aabd94fe7a049ba` | Build QUEUED; Device Smoke PENDING; Follow-up Persistence PASS; Production Loop PASS |
| #3574 | Path F — Person directory exclusion tombstones in schema 17 and TaskStore | `8aca2bd36ea28ae8c291e7418541453d12847de2` | Build PENDING; Device Smoke PENDING; Follow-up Persistence PASS; Production Loop PASS |
| #3575 | Path F — backup/restore of Person exclusions, rollback and independent SQLite round-trip | `6b1a03f502d5c642ba28a8884186f4a348b0e572` | Build PENDING; Device Smoke PENDING; Follow-up Persistence PASS; Production Loop PASS |

PR #3575 is stacked on PR #3574. Its captured base SHA is `90a8100c0e58fe0b6cedc9e1df3b234adf951b5d`; #3574 has since advanced to `8aca2bd36ea28ae8c291e7418541453d12847de2` by a documentation/test-comment commit. GitHub currently reports #3575 mergeable=true, but the stack is one base commit behind; do not merge or force-update. Reconcile the base before promotion.

### Actual code/test work recorded in these lanes
- #3567: fixed brand palette is now teal (#078B91 / #066F75 / #DDF7F5 / #F0FAF9 / #D9ECEA); added spacing, radius, typography, shadow, motion, touch-target, button, input, card, navigation and dialog tokens; applied them to app-wide light/dark Material themes and primary navigation; corrected the dark selected-navigation surface. This is a token foundation, not full-page REV10 acceptance.
- #3569: Home uses the five due-date groups; completed prior-day tasks remain in the historical group after active overdue work. Header is restored to the approved Bismillah capsule, title «مدیریت کارها و پیگیری آروین», physical-left notifications action and physical-right menu. Five visible filters use RTL order Time → Project → Category → Tag → Center. The notification action is informational only; a full notification inbox is not claimed.
- #3570: added file-backed schema-install/reopen coverage for Occurrence and Checklist, including explicit NULL and unknown nested fields; canonical TaskReminder fixtures replace legacy constructor-only reminderDate fixtures; Task Editor date-picker tests follow the current unified picker; swipe test now asserts the deprecated followUpEnabled getter reflects canonical Follow-up history; Work Agenda PDF fixture uses canonical TaskReminder and verifies Follow-up history remains in the report entry.
- #3571: Quick Capture Project/Category/Tags/Reminder/Recurrence labels are visible; Center inline creation has stable-ID selection/persistence coverage; tests scroll controls into view and settle before tapping; due-time test no longer expects an unconfigured reminder to mirror the due time; the Wave 2 wiring guard now verifies six legitimate canonical editor paths.
- #3572: Task Details metadata now has a «مشخصات کار» heading; the lazy latest-Follow-up and timeline sections are scrolled into view before assertions.
- #3573: all nine static upstream TTF weights 100–900 are registered; five existing weights were matched by Git blob SHA, and four missing weights were added from the official v33.003 tag. OFL and AUTHORS assets are explicit in pubspec. The font files are static TTFs, not variable-font registrations. APK packaging and device rendering remain unverified.
- #3574: adds `person_directory_exclusions` with idempotent schema migration; removal from the directory does not delete Task/Follow-up relations; explicit re-add of the same stable ID clears the exclusion; seed and stale Task writes cannot silently resurrect an excluded Person.
- #3575: adds optional `personDirectoryExclusions` to the existing backup v1 payload; validates IDs, timestamps, duplicates and active/excluded overlap; includes exclusions in normal/emergency backups and exact rollback; adds independent source/target SQLite round-trip tests for Task/Follow-up links, row cardinality, integrity and foreign keys.

### 72-instance failure triage corrections
The following corrections are authored in Draft branches; none is accepted until exact-head Build runs finish:
- Home filter Boolean test now scrolls category/tag options and the Apply action into view; it does not suppress hit-test warnings.
- Home More-menu tests scroll lazy Today actions into view.
- Home owner/widget tests assert the REV10 title, Bismillah capsule, both physical header actions and visible five-filter labels.
- Home filter contract asserts visible labels and exact RTL order.
- Tag roll-box contract explicitly enables its visible selected-count label; the teal branch asserts the approved primary token.
- Overdue status icon assertion now references `ArvinColors.primary` rather than a stale hard-coded blue value.
- Quick Capture tests locate reminder/recurrence controls by stable keys, scroll them into view and pump animations before tapping.
- Quick Capture scheduling-time assertion expects one due-time value when no reminder is selected.
- Task Editor tests follow the current unified date/time picker instead of an obsolete intermediate «انتخاب تاریخ و ساعت» action.
- Task Editor preservation fixture uses canonical TaskReminder rather than the legacy-only Task.reminderDate constructor.
- Follow-up swipe test asserts the compatibility getter from canonical Follow-up history.
- Task Details test scrolls lazy timeline content before asserting it; metadata section heading is now present.
- Work Agenda PDF fixture uses canonical TaskReminder and separately verifies Follow-up history in the report entry.
- Home Restore orchestration now injects failure after the People-directory stage and asserts exact Person-exclusion rollback and emergency snapshot coverage.
- A new file-backed independent SQLite backup/restore test validates Person exclusions and retained historical relations.

### Issue disposition
- #3550 remains OPEN / IN PROGRESS. Draft PR #3569 supplies the visible Center filter in the five-filter Home row, but schema 17 still has scalar `projects.center_id` and no accepted `center_projects`, `project_categories` or `task_centers` relation contract. The schema-18 proposal is design-only. No inferred legacy relationships or destructive migration.
- #2682 remains CLOSED in live GitHub metadata. Existing `peopleDirectory` serialization/candidate/apply/rollback path exists on #3052. New #3575 extends explicit exclusion/tombstone backup semantics and adds independent-file test coverage; exact-head Build and real Android file import/export/device acceptance remain pending. A status comment was added; issue was not reopened.

### Release and acceptance disposition
- No PR is PASS solely because a commit, test file or workflow trigger exists.
- Exact-head Build results for #3567–#3575 remain pending/queued at this checkpoint; the isolated Follow-up File Persistence and Production Loop successes do not replace the full Build or Device Smoke.
- The 72 failures from #3052 SHA a2825e0 remain the active baseline until the new PR heads finish their own exact-SHA runs. The earlier 80-instance baseline remains preserved as historical evidence.
- Full V7/V19/V20 migration acceptance, Center M2M, independent restore on physical Android, full REV10 page audit, Local P2P threat-model approval and two-device tests remain open.

**Release: NO-GO. Main protected and unchanged. PR #3052 and PRs #3567–#3575 remain OPEN / DRAFT / UNMERGED. No merge, release, deploy, destructive migration or production-database operation was performed.**
