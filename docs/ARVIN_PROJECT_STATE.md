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


## COMMAND 07-A.2.28.3 — PDF and font-integrity candidate (2026-11-12)

Current product candidate: `75737f4fb95b4357e8b6e0511ee2443c6aa5aff4`, PR #3384 OPEN / DRAFT / UNMERGED.

New changes since `551ecdc...`:
- Commit `cb0b2c1b0a29cd6ac022e9bbc68701b96068e1b0`: PDF test builds a Persian acceptance sample with ZWNJ, Jalali date, Persian/English numerals and mixed text; checks FontFile2, FontDescriptor, ToUnicode and Vazirmatn markers; CI runs Poppler font inspection, text extraction and PNG rendering.
- Commit `75737f4fb95b4357e8b6e0511ee2443c6aa5aff4`: APK Font Packaging Audit compares each TTF Git blob with the pinned upstream commit and logs actual byte size and SHA-256.

Exact-head runs at last observation:
- Build `43224808961`: PENDING, no jobs allocated.
- SQLite Snapshot `43224809374`: QUEUED.
- Follow-up Persistence `43224808860`: QUEUED.
- Device Smoke `43224808776`: QUEUED; preparation job not yet run.
- Draft Review APK `43224808804`: SKIPPED; no APK artifact.

The expanded D01 schema catalog, D04 file-based restore and D05 recovery tests are present but have not executed on this candidate. The PDF checks and SHA-256 reporting are also pending. Earlier SQLite passes on `a6d2d58...` remain historical.

## COMMAND 07-A.2.28.3 — PDF audit root-cause and exact-head continuation (2026-11-12)

Current product branch candidate at documentation checkpoint: `9a07f4680c49bc8c4246e2bf30b2cd4eaddd2e4e`.

### PDF evidence from prior candidate `75737f4...`
- PDF sample was generated successfully by the PDF typography test; size 18,334 bytes.
- `pdffonts` reported `Vazirmatn-Bold` and `Vazirmatn-Regular`, both embedded (`emb=yes`) with Unicode mapping (`uni=yes`).
- The actual PDF was downloaded from the run artifact, extracted with Poppler, and rendered to PNG. Manual visual inspection showed connected Persian glyphs, readable RTL layout, half-space text, Persian digits, mixed Persian/English, and Regular/Bold content.
- PDF file SHA-256: `9cd1f26a4e565be2b8e1e29b67aedaaa0266e73c5ec7a3fb439b4a817d3147cb`.
- Artifact ZIP SHA-256: `bd3fdcbe83b0ffdf2ffad819b05bec8d7769c01ea2000c6b76bfe178f0c2c7e3`; artifact ID `13949126911`; Run `43224808961`.

### Harness defects found and corrected
The visual job failed after the PDF generation test itself passed. Root cause 1: the `pdffonts` awk audit used incorrect whitespace-token field positions for `emb` and `uni`. Corrected in commit `97effacf705ae10e43760eec4e50d0905def11fa` (`$5` = emb, `$7` = uni).
Manual Poppler extraction then confirmed mixed-direction text is emitted in visual order inside the RTL paragraph; the English date appears as `12-11-2026`, and the company label as `Example Ltd`. The extraction assertions were aligned with that observed output in commit `9a07f4680c49bc8c4246e2bf30b2cd4eaddd2e4e`. No product assertions were removed.

The visual PASS from the previous candidate is not transferable. The complete PDF audit must pass again on `9a07f468...` or the later exact candidate, including embedded font check, text extraction, PNG rendering and preserved artifact.

### Latest relevant candidate commits
- `75737f4...`: build workflow added upstream Vazirmatn Git blob provenance, per-file SHA-256 reporting, OFL license check, APK asset path audit, and legacy runtime-reference guard.
- `97effacf...`: corrected PDF font audit column parsing.
- `9a07f468...`: aligned mixed RTL text extraction checks with observed Poppler output.

Do not report PDF or APK acceptance on the current candidate until the exact-head Build workflow completes successfully and all three APK jobs plus font packaging audits produce verifiable artifacts.

### PDF extraction normalization follow-up — 2026-11-12

Manual extraction of the actual PDF from Run `43224808961` showed Poppler returns shaped Arabic glyphs in presentation-form code points, while the rendered PNG is visually connected and legible. Raw extraction is retained. Commit `ee200b573ef70df8101c77de2a68241192898244` now creates a second NFKC-normalized extraction artifact before semantic assertions, preserving both raw and normalized evidence. This is a harness normalization step; it does not change the PDF renderer or its font binaries. Re-run the complete PDF workflow on the current exact product SHA before claiming PDF acceptance.

### Vazirmatn upstream binary provenance — independently cross-checked

Upstream repository `rastikerdar/vazirmatn`, exact source commit `6e553e33489a8f9dfaccc76860a2e3f3c1e66de7` (2023-05-01), was checked through its Git tree. The five upstream TTF blob object IDs exactly match the expected blob IDs now enforced by the APK audit:
- Light — `2dfd5c35ed4c26f7ce9f3ba753f11d9a38356c42` (122,920 bytes)
- Regular — `64e4a8189557a17b63fd7a77794207483e592972` (122,752 bytes)
- Medium — `1e08dd54d90a4879451ef0f80fe0d8068fb7462f` (122,656 bytes)
- SemiBold — `6b3842aca6055c8258404b1758133b81c961a13f` (122,920 bytes)
- Bold — `efa9b095da01d299310bdcae293e24e657fe6da9` (123,036 bytes)

This establishes exact upstream Git-object identity for the five files. Per-file SHA-256 output and APK inclusion still require successful exact-head build jobs; the upstream Git blob SHA-1 values are not presented as SHA-256.

### Typography single-source refinement — current product candidate `3768b4e39f1235bd993337da8009349d632aa05d`

A duplicate Vazirmatn family literal existed in the canonical theme token and font option registry alongside `AppFonts`. Commit `3768b4e39f1235bd993337da8009349d632aa05d` now makes `lib/theme/app_fonts.dart` the single code-level family source; `ArvinTheme.fontFamily` and the user font registry alias `AppFonts.vazirmatnFamily`. The theme token test and build-time font audit now assert this relationship. This is a behavior-preserving refactor; exact-head Analyze, Typography tests and build audit remain required.

### Light/dark typography weight correction and Android preference reload coverage

Current product candidate: `63c67ea3a6788c8c33a7234c8c291c9607f1d299`.

Source inspection found the previous root ThemeData mapping did not match the approved weight contract (body text was 500/600, titleMedium/titleSmall 700, and labelLarge 700). Commit `63c67ea3a6788c8c33a7234c8c291c9607f1d299` aligns both light and dark themes:
- body/minor/calendar text: 400;
- card/task title styles: 600;
- page title: 700;
- labels/controls: 500.

The Android Reminder + Persian Typography smoke now exercises the actual Android SharedPreferences plugin: it saves System Default, recreates the app root and verifies both theme families are not forced; then saves Vazirmatn, recreates the root again, verifies both themes use Vazirmatn and checks the inherited overlay typography. This is app-root reinitialization on Android; a separate OS-level force-stop/process-kill persistence test remains NOT VERIFIED.

Exact-head Analyze, regression, typography and Device Smoke results remain pending until their jobs complete on `63c67ea...`.

### APK font audit strengthened — exact candidate `0aa1645999e38e32506bf3d3c15f900865428f90`

The APK packaging audit now extracts each of the five font entries directly from the built APK using `unzip -p`, computes SHA-256 over the embedded bytes, and compares that digest with the source font's SHA-256. A missing asset or content mismatch fails the job. This is stricter than archive-path presence alone. Debug, Staging and Release must each pass this check on the same final acceptance SHA; results are pending.

## Exact-head SQLite Snapshot result — COMMAND 07-A.2.28

**Tested product SHA:** `0aa1645999e38e32506bf3d3c15f900865428f90`  
**Snapshot workflow:** `43232240309` — SUCCESS  
**Job:** SQLite A-D snapshots (five real reopen cycles) — SUCCESS  
**Artifact ID:** `13950118322`  
**Artifact:** `arvin-command-07-a2-20-sqlite-snapshots-0aa1645999e38e32506bf3d3c15f900865428f90`  
**Artifact ZIP SHA-256:** `0452e415dfe87b7a2b0ac797440fc5bdfd5f9998e91be44d8bd0214f0fb8d071`

The downloaded JSON artifact was independently parsed:
- A/B/C/D snapshots all contain one Task, two Reminder rows, two Follow-up records, three Follow-up-Person links and three Person records.
- Five file-backed close/reopen cycles completed.
- All four snapshots have an empty `foreign_key_check`; foreign-key enforcement reports enabled.
- The three retired Task columns are absent.
- 50 sqlite_master objects were captured: 28 indexes and zero triggers.
- Declared Foreign Key definitions were captured for 14 tables.
- Snapshot comparison reports A/B/C/D consistency for data, full schema catalog and FK definitions.

This is a **PASS for the Snapshot A-D diagnostic only** on SHA `0aa164...`. It is not full D01 acceptance (fresh schema and all supported historical upgrades still require complete suite evidence), and it does not establish D02-D05 by itself.

At the same candidate's last poll:
- Follow-up File Persistence Run `43232240334`: IN_PROGRESS; repository persistence test executing, Alarm Overlay close/reopen step pending.
- Device Smoke Run `43232240252`: QUEUED.
- Build/Regression Run `43232240534`: PENDING; no jobs allocated yet.
No result transfers to a later product SHA.

### Governance verification — COMMAND 07-A.2.28

Live repository Ruleset `main-protection` (ID `20952260`) remains ACTIVE on `refs/heads/main`, but its pull-request rule currently has `required_approving_review_count=0` and `require_code_owner_review=false`; bypass actors are empty. Deletion and non-fast-forward protections are enabled. No repository security setting was changed.

The docs PR #3388 CODEOWNERS file was expanded to cover the canonical typography contract, Vazirmatn assets, pubspec registration, both theme directories, PDF renderer, app root, Settings, Alarm Overlay, build workflow, typography/PDF tests and Android typography smoke. It is still an unmerged PR; the current main branch does not yet contain this CODEOWNERS file. Therefore effective CODEOWNER enforcement is **NOT VERIFIED / NOT ACTIVE**. Enabling required approval and CODEOWNER review remains a separate product-owner-controlled repository settings action.

## COMMAND 07-A.2.30 — exact-head execution checkpoint (2026-11-12)

### Git continuity and candidate identity

- Main observed HEAD: `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3384 remains OPEN / DRAFT / UNMERGED. Its base branch is `fix/wave3-cycle3-calendar-product-repair` at `8c4c23f0c2a4f9b2374a2092c931782c4455fd41`; the implementation branch was 108 commits ahead of that base at the prior checkpoint. The base branch itself is 2,200 commits ahead of main and 0 behind main. This is the deliberate branch strategy recorded in the PR body to avoid proposing an unrelated 2,200-commit diff directly against main.
- The previous exact-head candidate `46f7b28e6631310b4617da5e717565470f7ecdbe` was advanced by commit `492a5c433ee215d0188a6075b159d4d72329d35e` (`fix(timeline): avoid repeating reminder heading as note`). PR #3384 now has 109 commits and 68 changed files.
- Commit `492a5c4...` changes `lib/task_timeline_page.dart`: a reminder note is omitted when it duplicates the rendered `یادآور` heading. This is the production correction for the duplicate Reminder title regression. All dependent gates must be evaluated on `492a5c4...`; no result transfers from `46f7b28...`.
- PR #3388 remains OPEN / DRAFT / UNMERGED, based on main `45e4202...`; it now has 48 commits and 8 changed files. This documentation update is append-only except for the explicitly corrected five font SHA-256 values in the typography contract.

### Exact-head workflow evidence on previous candidate `46f7b28...`

- Build run `43238200093`: Analyze PASS; Visual/PDF PASS; Debug APK PASS; Release APK PASS; Staging was IN_PROGRESS at the last poll. Regression shards 0, 1, 2 and 4 completed with 43 failure records total (11 + 2 + 21 + 9). Shards 3 and 5 were cancelled when the PR advanced to the next SHA; they are not PASS and the full regression run is incomplete.
- Device Smoke run `43238200496`: the prepare-selected-scenarios job remained QUEUED; none of the seven device scenarios can be marked PASS.
- Follow-up file-backed persistence run `43238200586`: SUCCESS on exact SHA `46f7b28...`.
- SQLite A-D snapshot run `43238200490`: SUCCESS on exact SHA `46f7b28...`; artifact ID `13952699032`; ZIP SHA-256 `bdb0d42bcb7473bd91501a0a4e3c261d2c9001f95122b8db47356cc364089d5a`; JSON SHA-256 `fe64bc1b9a8275ab018ac3683e29d8b3d0462dc48f6eaec38572c05bfe465e2c`.
- The SQLite snapshot artifact contains 22 tables, 28 indexes, zero triggers, enabled foreign keys, empty `foreign_key_check`, and identical A/B/C/D data/schema/FK definitions across five file-backed reopen cycles. This is a PASS for the A-D snapshot diagnostic only, not full D01 or D01-D05 acceptance.

### Current candidate `492a5c4...` — latest exact-head evidence

- SQLite snapshot run `43247842246`: SUCCESS; job `131285215042`; artifact ID `13958416974`; artifact ZIP digest `0e57caf9e4357d8d4d43e82ad0f60377f69d3ebd4c7cbaefb89b6818fa93565b`; JSON SHA-256 `445a3b733834ef118a0d7ae79e91b7b5f867538aa6e77910ea3a3752e47c7721`.
- The new `492a5c4...` snapshot again records 22 tables, 28 indexes, zero triggers, FK enforcement enabled, an empty foreign-key check, and identical A/B/C/D data/schema/FK definitions across five reopen cycles.
- Follow-up file-backed SQLite persistence run `43247842181`: SUCCESS; job `131285224802`.
- Build run `43247842294`: PENDING / no jobs allocated at the last poll.
- Device Smoke run `43247842521`: QUEUED; the preparation job is still queued and no scenario has a result.
- No Debug, Staging or Release APK artifact has yet been verified for `492a5c4...`; the successful Debug and Release APK evidence below belongs only to `46f7b28...`.

### D01-D05 acceptance boundary

- D01: PARTIAL. Exact-head A-D snapshot and five reopen cycles pass on `492a5c4...`; full fresh-schema and supported historical-version migration acceptance is not yet established.
- D02: NOT ACCEPTED. The snapshot covers explicit NULL and FALSE metadata examples, but the independent Missing / NULL / FALSE / TRUE contract has not yet been signed off as a complete exact-head acceptance gate.
- D03: NOT ACCEPTED. Stable IDs, order, titles, notes, results, waiting-response flags and person links appear in the snapshot; full unknown Follow-up metadata preservation through independent close/reopen remains unproven.
- D04: NOT ACCEPTED. No current exact-head evidence yet proves the complete file-based Backup → independent Restore → close/reopen → relational/data comparison sequence.
- D05: NOT ACCEPTED. No current exact-head evidence yet proves interrupted-migration recovery, transaction rollback, or source-database non-destruction under injected failure.

### Typography, PDF and APK evidence on `46f7b28...`

- Upstream source commit: `6e553e33489a8f9dfaccc76860a2e3f3c1e66de7` in `rastikerdar/vazirmatn`; bundled license: SIL OFL 1.1.
- The corrected source/embedded SHA-256 values for all five weights are recorded in `docs/architecture/ARVIN_TYPOGRAPHY_CONTRACT.md` §16 and §21. Exact-head Debug and Release audits verified all five embedded font hashes against their source files and passed the legacy-font purge.
- Debug artifact ID `13953344600`; APK SHA-256 `41924a4be7470bb425d19baa76bb6781f9b3dbebbd9e31bc3716073adeacb16a`; artifact ZIP digest `c3844157fdc84e3c731bec9881f4a5ce3b8c63455962dcde5d07955145b16bd8`.
- Release artifact ID `13956310335`; APK SHA-256 `eb3b681fa1e7030eeb6a09ef74c1aacb7527f1170cdafa76f1d94e289a2d16c3`; artifact ZIP digest `f68610edd91855f4bf80577c5c9710c248fc3395f681417f47198541ffa5c8df`.
- Staging remained in progress at the last poll; no Staging artifact or APK SHA-256 is available.
- PDF artifact ID `13953438208`; PDF SHA-256 `0b276df9ed223a31033ace1fed04daadb3bd21a962a476b69c6a4bca8bf4dccb`; ZIP digest `05ade08cf47cd3ff2866406c685e56b3398c9a8240ad8fcfc3be5ba9e9d32b86`. The PDF sample passed the visual workflow, Poppler confirmed embedded Regular/Bold CID TrueType fonts with Unicode maps, extracted text preserved the tested Persian/RTL/ZWNJ/numeric/mixed-direction content, and the rendered PNG was independently inspected.

### Remaining blockers and next execution

- The 43 observed Regression failure records on `46f7b28...` still require individual disposition; the two cancelled shards have no result. No failed assertion may be deleted or weakened. Test-contract corrections must preserve the product contract.
- The Task Timeline duplicate Reminder heading is fixed in `492a5c4...`; verify it on the new exact-head Build run.
- Task People visibility/persistence, Checklist scrolling, Quick Capture create/select and time rendering, Home due-date grouping and filter semantics, Follow-up Office timeout, editor/calendar/navigation and RTL swipe failures remain under investigation.
- System Default has only app-root reinitialization evidence in historical documentation; OS-level Force Stop/process termination and relaunch remain NOT VERIFIED.
- No Merge, Release or Deployment is authorized. PR #3384 and #3388 remain Draft and unmerged.
- Next: complete the `492a5c4...` Build, all six regression shards, seven Device Smoke scenarios, Staging APK, then run only the missing D01-D05 acceptance probes against the same final SHA. Reconcile all dependent artifacts again if any source commit advances.
### SQLite subtest evidence refinement — previous exact SHA `46f7b28...`

The completed Regression shard logs also expose the following narrower acceptance results. These are historical subtest results on `46f7b28...` and must be rerun on `492a5c4...` before they count toward the current Candidate:

- D01 supporting tests: `creates the complete G1 relational schema`, `upgrades an existing pre-taxonomy schema without losing task data`, and five-cycle A-D snapshot all reported PASS. Full supported historical-version migration coverage is still not signed off.
- D02: `legacy presence preserves Missing, NULL, FALSE and TRUE independently` and `legacy Task metadata preserves missing, explicit NULL and concrete values` both reported PASS.
- D03 supporting test `round-trips canonical task JSON, IDs, order, and follow-up history through TaskStore` reported PASS. The more demanding test `preserves complete Follow-up history across closing and reopening SQLite`, including the unknown per-record `futureFollowUpField`, has no PASS line in the completed-shard logs; therefore it remains unverified.
- D04 supporting test `deleted migrated legacy reminder does not return after SQL and backup restore` reported PASS. The full file-backed test `canonical backup file restores multiple Reminders and Follow-up Person links into a new SQLite file` has no PASS line in the completed-shard logs; therefore the complete seven-step D04 sequence remains unverified.
- D05 supporting tests `failed migration leaves the complete legacy document unchanged`, `transaction rolls back all rows when one relation violates SQL constraints`, and `re-running the same migration is idempotent` reported PASS. Interrupted migration/recovery after an injected mid-flight interruption remains unverified.

These distinctions prevent a narrow passing test from being promoted into a full D01, D03, D04 or D05 acceptance claim.

### Staging completion correction — 46f7b28... (later poll)

The earlier interim statement that Staging was still running has been superseded. Staging job `131251173638` completed SUCCESS on `46f7b28e6631310b4617da5e717565470f7ecdbe`. Staging APK artifact ID `13957987267`; artifact ZIP SHA-256 `d380b5f028799fa3f3c7fafd5e80c79d56b1c1a151036ea8073c6e7ee35258f8`; extracted APK size 80,373,632 bytes; APK SHA-256 `b61bc476b29c5a862c007c493729f9b7d74f394a995fb8edd09981b27869b875`. The extracted Staging APK contains all five Vazirmatn weights and LICENSE.txt; all five embedded font hashes match the corrected source hashes. The staging workflow explicitly reported the provenance, APK content, legacy-font purge, OFL 1.1 license and Vazirmatn five-weight gate as PASS. This closes the Staging APK artifact requirement only for the historical `46f7b28...` candidate; the current `492a5c4...` still needs its own Staging build.

### Staging signing-scope detail

The Staging verification artifact `13957842406` records `source_sha=46f7b28...`, `apk_status=PASS`, APK SHA-256 `b61bc476b29c5a862c007c493729f9b7d74f394a995fb8edd09981b27869b875`, `android_debuggable_value=false`, and `publishable=false`. `apksigner` verified V2 and V3; V1 was not present. The signing class is explicitly `EPHEMERAL_TEST_ONLY_NOT_PRODUCTION`; this is a build-validation APK, not a production-signable deliverable. The manifest reports `signer_certificate_sha256=NOT_AVAILABLE` although the raw apksigner log contains the certificate SHA-256; the manifest field should be reconciled in a future validator improvement.
### Build status correction — current candidate `492a5c4...`

The initial PENDING observation has been superseded. Build run `43247842294` now has Analyze PASS and Regression Shard 2 FAIL (job `131289156187`, 21 failure records). Shards 0, 1, 3, 4 and 5 remain QUEUED; Visual/PDF and all three APK jobs remain QUEUED. Device Smoke run `43247842521` remains QUEUED. The current run is not complete.

**Exact failed test records in Shard 2:**

1. `settings_page_test.dart` — settings exposes date, swipe, projects and canonical backup controls.
2. `widgets/home_quick_capture_test.dart` — Home primary add persists canonical task and preserves history.
3. `quick_capture_dialog_test.dart` — Quick Add shows the selected scheduling time and uses injected now.
4. `follow_up_entry_page_test.dart` — waiting FollowUp can add, select, reopen and remove a stable person.
5. `home_last_follow_up_real_record_test.dart` — Home shows last FollowUp only for a real record and does not create one.
6. `device_smoke_workflow_contract_test.dart` — device smoke defines exactly seven canonical lanes on one exact target SHA.
7. `widget_test.dart` — Home exposes the canonical workflow controls.
8. `task_editor_dialog_test.dart` — Back-style close prompts and can save Task edits without data loss.
9. `home/home_owner_reference_test.dart` — Home follows the owner header, real summary values and Today navigation.
10. `home/home_filter_boolean_logic_test.dart` — Home filters combine OR within each dimension and AND across dimensions.
11. `task_editor_due_date_preservation_test.dart` — editing preserves canonical due date independently.
12. `follow_up_office_page_test.dart` — selects one of multiple tasks and persists only to that task.
13. `task_detail_person_persistence_test.dart` — Task Details Follow-up person selection persists through canonical Person and relation tables.
14. `task_detail_master_screen_test.dart` — Task Details persists checklist reorder and additions immediately without changing Follow-up history.
15. `notebook_page_test.dart` — editor tag picker replaces tags on the same canonical note.
16. `task_detail_checklist_crud_test.dart` — checklist add, inline edit and delete persist immediately and preserve legacy follow-up timestamps.
17. `home_today_about_test.dart` — Today menu action has a dedicated empty state.
18. `quick_capture_project_create_test.dart` — Quick Add offers Project create-new and selects the created project.
19. `report_center_page_test.dart` — Report Center exposes center and searchable task controls.
20. `home_stat_filters_test.dart` — Home time filter exposes precise date and time range controls.
21. `home_stat_filters_test.dart` — category checkbox selection applies OR only after confirmation.

These are the current exact-head failure records, not the older 22-item report. The test Timeline duplicate-title case is not in Shard 2's failure list; its result remains pending until the shard containing that test completes. No assertion is removed or reclassified as fixed solely because its failure did not occur in this shard.

### Known test-contract defects identified for the next patch (not yet committed)

- `device_smoke_workflow_contract_test.dart` rejects `pumpAndSettle` in the device smoke integration source; `integration_test/alarm_overlay_smoke_test.dart` still contains one unbounded call despite the existing bounded `_pumpFrames` helper.
- `validate_fast_lane.py` requires `max-parallel: 1` while `device-smoke.yml` intentionally declares `max-parallel: 2`; exact 40-hex `TARGET_SHA` validation and checkout equality checks must remain fail-closed while this stale parallelism assertion is corrected.
- `task_editor_due_date_preservation_test.dart` treats the compatibility `reminderDate` getter as a null legacy field even though it projects the first canonical Reminder; the assertion should target the canonical Reminder date.
- `task_detail_checklist_crud_test.dart` and `task_detail_due_date_action_test.dart` assert the retired `followUpDate` getter. The supported contract is `followUpDate == null` with original legacy value preserved in `legacyFollowUpMetadata.taskLevel`.
- `widget_test.dart` and `home_stat_filters_test.dart` expect visible text for icon-only filter controls that expose accessible Semantics labels; assertions should target Semantics.
- `home_owner_reference_test.dart` expects a Center filter that is absent from the approved four-dimension Home filter contract (Time, Project, Category, Tag).
- `task_detail_person_persistence_test.dart` passes a ListView key where Flutter's scrolling helpers require the descendant Scrollable; `task_detail_checklist_flow_test.dart` similarly selects the first nested Scrollable instead of the task content list.
- `home_today_about_test.dart` assumes a ListTile ancestor for a Today menu item that is implemented as a popup menu entry.
- Several async widget tests assert immediately after `pumpAndSettle`; this may return before file-backed SQLite futures finish when no frame is scheduled. Their assertions must remain and wait for the actual completion/UI state.

### Release APK signing boundary — 46f7b28...

The Release APK artifact `13956310335` is a successful build/font-packaging artifact, not a signed release deliverable. The extracted APK has SHA-256 `eb3b681fa1e7030eeb6a09ef74c1aacb7527f1170cdafa76f1d94e289a2d16c3`; binary APK Signing Block inspection found no `APK Sig Block 42`, so the APK is unsigned. The Gradle contract only assigns the production signing config when all protected production inputs are present; no production signing evidence is present in this workflow. Keep Release distribution/installation blocked. Debug and Staging have APK signing blocks; Staging is explicitly test-key-only and non-publishable.

### Canonical Home latest-FollowUp regression identified

The canonical owner contract in `docs/FOLLOWUP_FINAL_OWNER_CONTRACT_2026-08-28.md` §Gapهای پذیرش (#357) requires the Home card to show the exact timestamp of the latest real `Task.lastFollowUp` with an optional relative helper, and explicitly forbids using legacy `followUpDate` as real history. The current `492a5c4...` Home task card has no `آخرین پیگیری:` presentation in `lib/main.dart`, while `home_last_follow_up_real_record_test.dart` expects it. This is a confirmed product-surface gap, not merely a stale text assertion. Next product patch must add a display-only line derived solely from `task.lastFollowUp?.dateTime`; it must not create a Follow-up, project legacy date as real history, or modify dueDate/reminders. The test's legacy getter expectations must be corrected to assert `followUpDate == null` and the old value remains in `legacyFollowUpMetadata.taskLevel`.