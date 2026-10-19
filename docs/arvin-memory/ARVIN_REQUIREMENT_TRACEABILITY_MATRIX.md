# ARVIN Product Requirement Traceability Matrix — Wave 4.3

Updated: 2026-10-19  
Repository: https://github.com/mobinpda-lab/Arvin-clean  
Baseline: main = d9fb7a247037762216662a20fb32028ecc8a0f6b  
This working artifact lives on documentation branch docs/arvin-v4-wave1-evidence-20261019; it is not yet in main. It summarizes the supplied Wave 4.3 decisions and canonical repository decision/acceptance docs. It is a bounded traceability snapshot, not a claim of exhaustive access to every historical conversation.

Allowed statuses only: IMPLEMENTED_AND_VERIFIED, IMPLEMENTED_NOT_VERIFIED, PARTIALLY_IMPLEMENTED, IN_PROGRESS, NOT_IMPLEMENTED, BLOCKED, CONFLICT_REQUIRES_PRODUCT_DECISION, NOT_APPLICABLE.

| ID / Priority | Expected behavior | Source decision | Code / tests / PR | Actual evidence | Risk / required action | Final status |
|---|---|---|---|---|---|---|
| ARV-001 P0 | NO-GO until all mandatory gates pass | Wave 4.3 §§17–18; acceptance criteria | Final status docs; #2824/#2826/#2827/#2831 | Governance enforced; no merge/tag/release observed | Keep all gates closed until candidate evidence exists | IMPLEMENTED_AND_VERIFIED |
| ARV-002 P0 | One uniquely qualified source SHA; no stale CI reused | §§2,13,17 | build.yml, device-smoke.yml; #2827 | SHA metadata and target assertions implemented on PR branch; Run 39211789523 Build green but exact-target step skipped | Authorized exact-SHA dispatch/equivalent and checkout marker needed | IMPLEMENTED_NOT_VERIFIED |
| ARV-003 P0 | Official Release uses approved certificate, never Debug signer | §12; #2824 | android/app/build.gradle.kts; #2824 | Main still signs Release with Debug config; previous audit found Android Debug certificate | Owner-authorized release keystore and independent approved fingerprint required | BLOCKED |
| ARV-004 P0 | APK SHA-256, signer, source SHA, run and artifact provenance bound | §12 | #2824/#2827; artifacts 12168605271, 12167844011 | Downloaded artifact 12168605271 from Run 39211706034; app-release.apk size 70,056,469 bytes, file SHA-256 d1bf6ba6ed05b4cd5546dd4dc10de8c5e6016efda8d682d28466fda3102a38f7. No apksigner executable in inspection environment; signature not re-verified and exact-target step was skipped. | Download APK, hash APK itself, apksigner verify, compare approved fingerprint on candidate | BLOCKED |
| ARV-005 P0 | Real Calendar Provider create/no-op/update/delete and explicit PASS | §§6,13; AC-09 | provider workflow/script; #2831 | Run 39211706224 failed with LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR; no artifact | After three prior seed/script attempts, use a demonstrably writable provider fixture/runner and capture CRUD evidence | BLOCKED |
| ARV-006 P0 | All Device Smoke lanes terminal-success on same candidate | §§13,17 | device-smoke.yml; #2827 | Run 39211706094 latest poll: Backup/Restore, SQL Persistence, Home, Quick Capture, SQL Migration and People success; Calendar in progress | Poll terminal, inspect logs/artifacts, rerun exact target | IN_PROGRESS |
| ARV-007 P0 | Analyze, six test shards, Debug and Release build pass on qualified SHA | §§13,17 | build.yml; #2827/#2831 | Runs 39211706034 and 39211789523 succeeded for PR events; exact-target step skipped | Repeat on immutable qualified SHA and record workflow revision | IMPLEMENTED_NOT_VERIFIED |
| ARV-008 P0 | Task is source of truth; Follow-up is real record, not a flag | §4; Follow-up decision docs | #2796/#2828 | Branch removes legacy toggle from product decisions and creates/preserves records; #2828 Build 39203068667 and Device Smoke 39203068653 passed on PR checkout | Unmerged; current candidate behavior not verified | IMPLEMENTED_NOT_VERIFIED |
| ARV-009 P0 | nextFollowUp alone creates no Reminder, notification or calendar event | §4; ARVIN_FOLLOW_UP_AND_QUICK_ENTRY_DECISION.md | Follow-up/Reminder/scheduler/sync tests; #2828 | Contract documented; all independent side effects not proven on candidate | Add/verify tests for nextFollowUp-only writes | PARTIALLY_IMPLEMENTED |
| ARV-010 P0 | Explicit next-action reminder creates independent linked Reminder with title fallback; clear/delete isolated | §4 | Follow-up form, Reminder model/repository; #2790/#2828 | Related persistence work exists on branches; complete lifecycle acceptance not proven | Verify create/edit/clear/delete, title fallback, parent navigation and independence | PARTIALLY_IMPLEMENTED |
| ARV-011 P0 | Multiple Reminders have independent IDs; deleting one leaves others/Task/Follow-ups intact | §5; ARVIN_MULTIPLE_REMINDERS_DESIGN.md; AC-04 | #2790; Reminder tests | Full-cycle tests passed on PR head in Build 39204622671 and Device Smoke 39204622845 | Stale base; candidate exact interaction/legacy compatibility unverified | IMPLEMENTED_NOT_VERIFIED |
| ARV-012 P1 | Home projection includes eligible Tasks/Follow-ups/Reminders, excludes notes/raw phone events; deterministic dedup | §5; Home/report decision docs | Home projection tests; #2828/#2790 | Some Home smoke lanes passed on PR heads; full projection matrix not verified | Test imported Tasks, same-time Follow-up suppression, earliest Reminder, hidden-record preservation | PARTIALLY_IMPLEMENTED |
| ARV-013 P1 | Recurrence shows overdue/current/next and resume-from-today preserves history | §5; main commit d9fb7a2 | [Main commit](https://github.com/mobinpda-lab/Arvin-clean/commit/d9fb7a247037762216662a20fb32028ecc8a0f6b); #2816 | Triple-window projection and boundary/history tests merged in main | Resume-from-today end-to-end history preservation still needs focused verification | IMPLEMENTED_NOT_VERIFIED |
| ARV-014 P0 | Calendar separates raw phone events, imported Tasks, Reminders, Follow-up projections; stable IDs prevent duplicates | §6; ARVIN_CALENDAR_PROJECTION_SEPARATION_DECISION.md; AC-09 | Calendar sync/projection; #2831/#2828 | Exact-head metadata exists; actual Provider run failed due to no writable calendar | Validate create/no-op/update/delete with stable external IDs and no duplicate | BLOCKED |
| ARV-015 P1 | Calendar tap opens details; long press opens type menu; RTL/color/icons/status presentation correct | §6 | Calendar widgets, tests/screenshots; Device Smoke | Calendar lane queued at latest query; no terminal evidence | Poll lane, inspect screenshots and focused tap/long-press tests | IN_PROGRESS |
| ARV-016 P0 | Person IDs and waiting-response survive Follow-up edit/completion/migration; deleting Person preserves parent/history | §7; #2828 | SQL migration/backfill and regression tests; #2828 | Root cause of lost title/waiting state/Person links documented; repair tests passed on PR checkout | Latest candidate/base integration unverified; validate safe deletion | IMPLEMENTED_NOT_VERIFIED |
| ARV-017 P1 | Person settings add/edit/search/safe delete; no standalone CRM | §7 | Person settings/repository/widget tests; #2828 | People lane queued in latest Device Smoke; earlier PR smoke exists | Verify CRUD/search/association changes and no cascading parent deletion | IN_PROGRESS |
| ARV-018 P1 | Reports distinguish required entity types and filter Person/waiting-response with correct Task/Follow-up/Person/time output | §8; ARVIN_REPORT_FILTER_DECISION.md | Report Center/filter tests | Comprehensive report acceptance not evidenced by current runs | Test “waiting for response from Person” fields and filters | PARTIALLY_IMPLEMENTED |
| ARV-019 P1 | Report-row tap behavior follows latest authoritative decision | §8; report decision docs | Report row widgets/tests | Current live inspection did not independently resolve the row interaction contract | Inspect canonical decision log; mark conflict only if documents truly conflict | IN_PROGRESS |
| ARV-020 P1 | Quick entry, full Task form, notes, Follow-up, calendar and reports share agreed colorful UI, RTL/accessibility | §9; UI decision docs | Widgets/goldens; #2796 and smoke artifacts | Some screenshot artifacts exist; all-screen acceptance not established | Test all screens/sizes and preserve preferences | PARTIALLY_IMPLEMENTED |
| ARV-021 P1 | New-note category/project/tag controls use one row when possible; no duplicate Follow-up control | §9; #2796 | New-note/Quick Capture widgets; #2796 | Legacy switch removal on branch; latest-head validation pending | Widget/golden tests at compact and wide widths | IMPLEMENTED_NOT_VERIFIED |
| ARV-022 P0 | Backup→isolated DB reset→Restore preserves IDs, relationships, history, reminders, nextFollowUp and calendar links | §10; AC-08 | Backup manager and full-cycle test; #2790 | Expanded test passed on PR head in Build 39204622671 and Device Smoke 39204622845 | Stale base; candidate exact cycle and rollback not established | IMPLEMENTED_NOT_VERIFIED |
| ARV-023 P0 | Legacy followUpEnabled migration preserves Follow-up metadata without silent loss | §§4,10; #2796/#2828 | SqlTaskMigrationWriter/backfill tests; #2828 | Root cause/correction documented; tests passed on recorded PR head | Current-main reconciliation and candidate-exact evidence needed | IMPLEMENTED_NOT_VERIFIED |
| ARV-024 P1 | UI and PDF fonts separate; licensed weights embedded; Persian shaping/RTL/numerals/wrapping/pagination verified | §11; #2791/#2796 | UI assets, PDF renderer/preview; #2791 | Re-downloaded artifact 12164731659 and independently inspected PDF: one A4 page, four embedded UI-FD weights, Persian RTL/digits and wrapping look correct on sample; multi-page/table and in-app preview comparison not verified | In-app preview comparison missing; latest-head CI pending | IMPLEMENTED_NOT_VERIFIED |
| ARV-025 P1 | Vazirmatn source/version/license verified; unsupported fonts not offered | §11; #2796 | UI font README/pubspec/tests; #2796 | Branch records v33.003/OFL and supported choices | Latest head not validated; branch unmerged | IMPLEMENTED_NOT_VERIFIED |
| ARV-026 P0 | Physical-device install/core flows/RTL/calendar/backup accepted before release | §§10,17 | Physical device checklist | No physical-device acceptance evidence in current run set | Emulator CI is not physical-device proof | BLOCKED |
| ARV-027 P1 | Preserve existing architecture and backward compatibility; no parallel model/store/scheduler | §§4–5,10,15 | Architecture/migration tests; #2790/#2828 | PR descriptions state canonical stores retained; integrated candidate-wide review incomplete | Review integrated diff and round-trip tests after base reconciliation | PARTIALLY_IMPLEMENTED |
| ARV-028 P0 | Canonical docs record decision/reason/impact/implementation/tests/SHA/status/risks | §16 | Final status/evidence/execution docs; #2826 | Docs updated on this branch; latest provider failure/build outcomes recorded | Docs branch unmerged and requires fresh CI | IMPLEMENTED_NOT_VERIFIED |
| ARV-029 P1 | Phone-calendar import creates independently manageable Arvin Task; raw event not treated as Arvin-owned | §§5–6 | Calendar import/projection tests and decision docs | Contract documented; provider end-to-end validation unavailable | Test import, stable external event ID and edit/delete isolation | PARTIALLY_IMPLEMENTED |
| ARV-030 P1 | Notification/calendar sync idempotent; clearing/removing one reminder cannot delete unrelated events/records | §§4–6 | Reminder scheduler, external calendar store, integration tests; #2790/#2831 | Backup test covers calendar-link metadata on PR head; real-provider and candidate sync proof absent | Test repeat sync, clear/edit/delete and unrelated IDs | PARTIALLY_IMPLEMENTED |

## Evidence and decision sources
- [Acceptance criteria](ARVIN_ACCEPTANCE_CRITERIA.md)
- [Decision log](ARVIN_DECISION_LOG.md)
- [Conversation decision history](ARVIN_CONVERSATION_DECISION_HISTORY.md)
- [Follow-up and Quick Entry decision](ARVIN_FOLLOW_UP_AND_QUICK_ENTRY_DECISION.md)
- [Multiple Reminders design](ARVIN_MULTIPLE_REMINDERS_DESIGN.md)
- [Calendar projection separation](ARVIN_CALENDAR_PROJECTION_SEPARATION_DECISION.md)
- [Report filter decision](ARVIN_REPORT_FILTER_DECISION.md)
- [PR #2824 signing audit](https://github.com/mobinpda-lab/Arvin-clean/pull/2824)
- [PR #2827 exact-SHA workflow](https://github.com/mobinpda-lab/Arvin-clean/pull/2827)
- [PR #2828 Follow-up/Person/migration](https://github.com/mobinpda-lab/Arvin-clean/pull/2828)
- [PR #2831 Calendar Provider](https://github.com/mobinpda-lab/Arvin-clean/pull/2831)
- [PR #2790 Backup/Restore](https://github.com/mobinpda-lab/Arvin-clean/pull/2790)
- [PR #2791 PDF font](https://github.com/mobinpda-lab/Arvin-clean/pull/2791)
- [PR #2796 UI font and Follow-up switch](https://github.com/mobinpda-lab/Arvin-clean/pull/2796)
- [Provider run 39211706224](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211706224)
- [Build run 39211706034](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211706034)
- [Device Smoke run 39211706094](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211706094)
- [Build run 39211789523](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211789523)

## Interpretation rules
- Final-status field uses only the approved status vocabulary.
- An unmerged PR is not available in main.
- A green PR workflow does not imply real-provider pass, physical-device acceptance, official signing, or exact-target dispatch.
- Do not use IMPLEMENTED_AND_VERIFIED without current-candidate evidence for the specified behavior.
- Extend this bounded matrix when additional authoritative product decisions are found.


## APK artifact inspection addendum — 2026-10-19
- Downloaded the Release APK artifact archive [12168605271](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12168605271) from Build run [39211706034](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211706034), PR head 6ff5b3c70cb4bf4fe9f7c72bacfefefaf555e9da.
- Archive contained app-release.apk, size 70,056,469 bytes. Independently calculated APK-file SHA-256: d1bf6ba6ed05b4cd5546dd4dc10de8c5e6016efda8d682d28466fda3102a38f7.
- This is an observed artifact from a successful PR-triggered Release build, not a qualified official release. The exact-target verification step was skipped. The local inspection environment has no apksigner executable, so the APK certificate was not independently re-verified in this inspection. Main build.gradle.kts explicitly uses the Debug signing config; therefore the APK must not be distributed or presented as officially signed.
- Artifact archive digest and APK-file SHA-256 are different values. Do not substitute one for the other. Official signing remains BLOCKED pending owner-authorized release credentials/fingerprint and apksigner verification on the qualified candidate.


## Independent PDF artifact inspection — 2026-10-19
- Downloaded [PDF preview artifact 12164731659](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12164731659) from Build run 39203354122 and extracted arvin-report-preview.pdf (22,614 bytes).
- PDF structural inspection: one page, A4, PDF 1.7, not encrypted. pdffonts confirms all four embedded fonts: Vazirmatn-UI-FD-Regular, Medium, SemiBold and Bold.
- Raster inspection of page 1 shows Persian glyph shaping, right-to-left alignment, Persian numerals/dates, checklist bullets, tags, Reminder and Follow-up content, and long-text wrapping without visible clipping on this sample.
- Limitations: this artifact represents a one-page sample with substantial unused whitespace; it does not demonstrate multi-page pagination or table layout, and there is no matching in-app preview screenshot available for visual comparison. Treat PDF/font acceptance as PARTIAL, not complete release acceptance. Artifact belongs to an older PR-triggered run/head, not the qualified candidate.


## Device Smoke latest poll — 2026-10-19
Run [39211706094](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211706094) remains IN_PROGRESS on PR head 6ff5b3c70cb4bf4fe9f7c72bacfefefaf555e9da. Backup/Restore, SQL Persistence, Home, Quick Capture, SQL Migration and People lanes have completed SUCCESS; Calendar lane remains IN_PROGRESS. The run is not terminal and the full suite is not PASS. This remains a pull_request run, not exact-target dispatch.


## WAVE 4.4 LIVE RECONCILIATION — 2026-10-19 (latest authoritative poll)

- Current main remains `d9fb7a247037762216662a20fb32028ecc8a0f6b`; no qualified release candidate is declared.
- Relevant PRs #2824, #2826, #2827, #2828, #2831, #2790, #2791 and #2796 are open, Draft, and unmerged. PRs #2790/#2791/#2796 retain stale base SHA `824ca8f17c92e76b3887001891d7d5b6f17974a6`; reconcile before integration.
- Build run [39211706034](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211706034): terminal SUCCESS for Analyze, six test shards, Debug APK and Release APK. Trigger was pull_request against PR #2831 head `6ff5b3c70cb4bf4fe9f7c72bacfefefaf555e9da`; exact-target verification was SKIPPED.
- Device Smoke run [39211706094](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211706094): latest query shows all seven lanes terminal SUCCESS (Backup/Restore, SQL Persistence, Home, Quick Capture, SQL Migration, Calendar, People). This is PR-head evidence only; no workflow_dispatch/exact-target execution occurred, so it does not qualify a release candidate.
- Calendar Provider run [39211706224](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211706224): terminal FAILURE at real acceptance; output `CALENDAR_PROVIDER_ACCEPTANCE=LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR`. No evidence artifact was published because the acceptance job failed before the artifact-publication step. This is not a product pass and not proof of provider CRUD.
- Release build config on main still sets `signingConfig = signingConfigs.getByName("debug")`. The inspected APK from artifact 12168605271 has SHA-256 `d1bf6ba6ed05b4cd5546dd4dc10de8c5e6016efda8d682d28466fda3102a38f7`, but apksigner verification and approved certificate fingerprint comparison were not performed; it is not an authorized release APK.
- PDF artifact 12164731659 was independently inspected: one-page A4 sample with four embedded Vazirmatn UI-FD weights and plausible Persian RTL shaping. Multi-page/table acceptance and in-app preview comparison remain unverified; artifact is from an older PR run, not a qualified candidate.
- Connector limitations remain: no authorized workflow_dispatch operation and no repository Actions Secret/Variable inspection are exposed. No secrets, keys, tags, merges or public release were created.
- Final decision remains **BLOCKED — RELEASE: NO-GO**.


## Wave 4.5 gate traceability update — 2026-10-19

| Requirement ID | Exact behavior / canonical contract | Implementation / PR | Current status | Evidence / tested SHA | Remaining risk / required action |
|---|---|---|---|---|---|
| REL-SIGN-001 | Release APK must use owner-authorized official signing identity, never Debug signing | `android/app/build.gradle.kts`; PR #2824 signature audit proposal | `BLOCKED` | Main SHA `d9fb7a247037762216662a20fb32028ecc8a0f6b`; Gradle blob `aaeea7506885814cc4c4a65ac6559872a80146a8` still sets Release signing to Debug | Owner supplies authorized keystore via approved secret mechanism and approved certificate SHA-256; verify candidate APK with apksigner |
| CAL-PROV-001 | Real writable Calendar Provider create/no-op/update/delete, with explicit pass marker and preserved evidence | Workflow `.github/workflows/calendar-provider-acceptance.yml`; PR #2831 | `BLOCKED` | Main workflow blob `0c30d5f9183bd4edea5a40a6c4705aca2585e6cc`; previous reported run `39211706224` is historical and not re-run here | Provision legitimate writable provider; assert persisted provider rows after every operation; upload evidence on failure; run exact SHA |
| CI-SHA-001 | Build and seven Device Smoke lanes must checkout and assert the same qualified source SHA | `.github/workflows/build.yml`, `.github/workflows/device-smoke.yml`; PR #2827 | `IMPLEMENTED_NOT_VERIFIED` | Main Device Smoke blob `e5cd465a7d5a83be21a55535f7a0b3071ceeec45` lacks target SHA input; PR #2827 head `d437dbf6cc76bbb216916b94145a8ddae897e52b` proposes exact-SHA controls | Finish PR-head CI; dispatch Build and Device Smoke with exact SHA; verify every job/artifact provenance |
| FUP-REC-001 | Follow-up state is represented by actual Follow-up records, preserving title/result/history/People/waiting state | PR #2828 head `50f1d26a8e4102f078e2f184771f98d521152dc4` | `IN_PROGRESS` | Diff contains targeted record-preservation and SQL metadata backfill changes; full integration acceptance not yet established | Focused migration, persistence, Reminder, notification/calendar, reports, and Backup/Restore tests |
| DOC-BASE-001 | Reconcile old-base PRs against actual current main without dropping valid changes | PRs #2790, #2791, #2796 | `IN_PROGRESS` | Current bases all `824ca8f17c92e76b3887001891d7d5b6f17974a6`; current main `d9fb7a247037762216662a20fb32028ecc8a0f6b` | Review complete diffs, dependencies, conflicts, migrations, fonts and tests before branch update |

Status vocabulary follows the Wave 4.5 command. These entries record inspection results, not acceptance passes; all rows require refresh against the final candidate SHA.


## Wave 4.5 live traceability delta — 2026-10-19

| Requirement ID | Exact behavior / canonical contract | Implementation / PR | Status | Current evidence | Remaining action |
|---|---|---|---|---|---|
| REL-SIGN-001 | Release APK uses authorized non-Debug identity; fingerprint independently matches owner-approved SHA-256 | Main `android/app/build.gradle.kts`; audit workflow proposal PR #2824 | `BLOCKED` | Main SHA `d9fb7a247037762216662a20fb32028ecc8a0f6b`; Gradle blob `aaeea7506885814cc4c4a65ac6559872a80146a8` still sets Debug signing | Owner provides approved signing credentials and fingerprint; verify candidate APK with apksigner; record APK hash/artifact/run/source SHA |
| CAL-PROV-001 | Real provider create/no-op/update/delete and provider-state verification; explicit marker and failure evidence | PR #2831 head `6ff5b3c70cb4bf4fe9f7c72bacfefefaf555e9da` | `BLOCKED` | Existing historical attempts include provider limitation and script errors; none qualifies current candidate | Legitimate writable provider environment; preserve result/environment/test output artifacts; require `PASS_REAL_PROVIDER_CREATE_NOOP_UPDATE_DELETE` |
| CI-SHA-001 | Build and all seven Device Smoke lanes checkout/assert one immutable candidate SHA | PR #2827 head `d437dbf6cc76bbb216916b94145a8ddae897e52b` | `IMPLEMENTED_NOT_VERIFIED` | Workflow files now expose target SHA controls on PR branch; current main still lacks equivalent Device Smoke input/assertion | Terminal PR CI then authorized exact-SHA dispatch; verify every job and artifact provenance |
| FUP-REC-001 | Actual Follow-up records, not legacy boolean, preserve title/history/People/waiting state across edit/complete/migration | PR #2828 head `50f1d26a8e4102f078e2f184771f98d521152dc4` | `IN_PROGRESS` | Targeted SQL writer/backfill and repository tests exist on branch | Run integrated persistence, reminder independence, scheduler, calendar, report and backup/restore acceptance |
| BAK-MIG-001 | Backup → isolated test-data removal → restore preserves stable IDs and relations without touching real user data | PR #2790 head `6ca1cff18f6631352995241b783b7b3bfcec55d5` | `IMPLEMENTED_NOT_VERIFIED` | PR adds checklist and external-calendar-link assertions; historical PR CI is not current-candidate evidence | Reconcile base and rerun full-cycle test on qualified SHA |
| PDF-RTL-001 | PDF embeds licensed font weights and passes RTL/shaping/pagination plus in-app preview comparison | PR #2791 head `9cf025b5a9678373d6b5a89a8a043ba49bf53243` | `IMPLEMENTED_NOT_VERIFIED` | Historical artifact inspected; not bound to candidate SHA and preview comparison remains open | Generate/inspect candidate-bound PDF and compare with actual in-app preview |
| BASE-RECON-001 | PR branches integrate against current main without losing valid work or breaking migrations/UI/font contracts | PRs #2790, #2791, #2796 | `IN_PROGRESS` | All three bases still report old SHA `824ca8f17c92e76b3887001891d7d5b6f17974a6` | Inspect complete diffs and merge-bases; update branches only after dependency/conflict review |

No row above is a release pass. A green PR build is not exact-SHA acceptance. No qualified candidate SHA has been selected; release remains **BLOCKED — RELEASE: NO-GO**.


## Wave 4.6 live status delta — 2026-10-19

| ID / Priority | Expected behavior | Source decision | Code / tests / PR | Actual evidence | Risk / required action | Final status |
|---|---|---|---|---|---|---|
| ARV-002-W46 P0 | Build and Device Smoke must bind to one explicitly checked-out source SHA and workflow revision | Wave 4.6 §§17–18 | #2827; .github/workflows/build.yml; .github/workflows/device-smoke.yml | Documentation-head Build 39214701152 has target-SHA verification skipped on PR event; Analyze/six shards and Debug APK passed, Release APK still running. Device Smoke 39214701198 is not terminal. | Use authorized dispatch with immutable target_sha; verify checkout assertions and all terminal jobs | IMPLEMENTED_NOT_VERIFIED |
| ARV-003-W46 P0 | Release APK must use owner-approved official signing identity | Wave 4.6 §16 | android/app/build.gradle.kts; #2824 | Inspected signing branch still sets Release signing config to debug; approved owner fingerprint/credentials not available in evidence | Owner must provide secure authorized credentials and approved fingerprint; verify actual candidate APK with apksigner | BLOCKED |
| ARV-005-W46 P0 | Real Calendar Provider Create/No-op/Update/Delete acceptance with preserved artifacts | Wave 4.6 §8 | #2831 and provider acceptance workflow | Run 39203189292 documented stock-emulator writable-provider limitation; no verified actual CRUD acceptance artifact | Provision legitimate writable provider and capture result/test/environment evidence | BLOCKED |
| ARV-006-W46 P0 | All seven Device Smoke lanes pass on the same qualified SHA | Wave 4.6 §17 | #2827; run 39214701198 | Home and Quick Capture succeeded; SQL Persistence and SQL Migration running; People, Calendar and Backup/Restore queued at latest job query | Poll all lanes to terminal and rerun on selected exact SHA | IN_PROGRESS |
| ARV-008-W46 P0 | Follow-up is a real record; completion/edit preserves title, result, history, People and waiting state | Wave 4.6 §§4,11 | #2828; Follow-up repository, SQL migration/backfill | PR diff implements preservation of title/waiting state/person IDs and an idempotent metadata backfill; no integrated qualified-SHA acceptance yet | Run focused tests and migration/backup lifecycle checks after safe integration | IMPLEMENTED_NOT_VERIFIED |
| ARV-012-W46 P1 | Home projection deterministically includes eligible items and suppresses duplicate display without deleting records | Wave 4.6 §6 | Home projection and #2828 | Source inspection shows a canonical Home list projection, but this run does not prove the full Reminder/Follow-up dedup matrix | Add/verify independent projection tests for same-time Follow-up and earliest Reminder | PARTIALLY_IMPLEMENTED |
| ARV-REC-W46 P1 | Recurrence exposes overdue/current/next windows and Resume from Today preserves historical completion | Recurring-task contract and resume status docs | lib/services/home_list_projection.dart, lib/services/calendar_schedule_projection.dart, recurrence model/tests | Contract says Resume from Today is a pure future-schedule calculation preserving history; unified three-window Home/Calendar projection is not yet accepted on this candidate | Inspect existing recurrence architecture and implement only a narrow read-only projection gap if confirmed; focused regression tests required | IN_PROGRESS |

No row above is a release pass. Documentation-head CI is not candidate release acceptance; no qualified candidate SHA selected. Final release status remains BLOCKED — RELEASE: NO-GO.


## Wave 4.6 execution delta — 2026-10-19 (supersedes earlier pending-state snapshot)

- Documentation-head Build [39214701152](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39214701152) completed SUCCESS on source SHA 3f39b29df51aaa077b90938af74528644c0ea7f8. Analyze, all six test shards, Debug APK and Release APK jobs succeeded. Exact-target verification was SKIPPED because this was a pull_request event, so it is not exact-SHA candidate acceptance. Artifacts: Debug APK ID 12169626405 (archive digest sha256:f1063e15a9a8a0c67e283130d20fd161f8091bec82aa3ade6ad548b49b9f9a07); Release APK ID 12169556790 (archive digest sha256:b8632cb4cd250fa30a9adb57994cbc02cb1608e01fa98bc3d0a61c7456f2b120). These are documentation-branch build artifacts, not designated release candidates; official signing was not established.
- Device Smoke [39214701198](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39214701198) ended CANCELLED, not PASS. It did not provide all seven terminal-success lanes.
- Product fix added to existing PR #2828, without creating a duplicate PR: commit 85cf250dfb14953f3a91e0c7b59a0704cdeed73c changes lib/services/home_list_projection.dart to show only the earliest eligible Reminder in Home, deterministically sorted by date, sequence, then ID, while leaving all stored reminders untouched; commit 754fe797b63cd6462db2dc726142ffc7083e8a12 adds the regression test for unsorted reminders, same-time Follow-up suppression, and record preservation. Latest PR #2828 head is 754fe797b63cd6462db2dc726142ffc7083e8a12.
- Build [39215641618](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39215641618) for the latest PR #2828 head was PENDING at the last poll; Device Smoke [39215641723](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39215641723) was QUEUED with some lanes starting. Neither result is a pass; the older run for 85cf250dfb14953f3a91e0c7b59a0704cdeed73c is not evidence for the newer head.
- Current main remains d9fb7a247037762216662a20fb32028ecc8a0f6b. No candidate SHA selected. Official signing and real Calendar Provider acceptance remain BLOCKED. No merge, tag, or release. Final decision: BLOCKED — RELEASE: NO-GO.


## Wave 4.7 requirement status override — 2026-10-19

| Requirement | Current evidence | Status | Next action |
| --- | --- | --- | --- |
| P0 release policy / single candidate | No candidate SHA selected; no merge/tag/release. | BLOCKED | Close every mandatory gate on one immutable SHA. |
| Exact-SHA Build + seven-lane Device Smoke | PR #2828 Build 39215641618 and Smoke 39215641723 passed, but exact-requested-revision steps were skipped; Smoke artifacts use merge SHA 5b13c0052c576f3eee84a42c5ca637ba678b5452. | IMPLEMENTED_NOT_VERIFIED | Run authorized workflow_dispatch with target_sha and retain checkout assertion evidence. |
| Home Reminder projection | #2828 head 754fe797b63cd6462db2dc726142ffc7083e8a12; Build 39215641618 SUCCESS; Smoke 39215641723 SUCCESS all seven lanes; regression checks unsorted reminders, same-time suppression and source-record preservation. | IMPLEMENTED_NOT_VERIFIED | Verify on exact candidate SHA; do not infer whole Home acceptance from this slice. |
| Official Release signing | Main Gradle still configures Release with debug signing; no current-head signature audit proving owner-approved fingerprint. | BLOCKED | Owner supplies authorized keystore/secrets and approved SHA-256 certificate fingerprint. |
| Real Calendar Provider CRUD/no-op | #2831 run 39211706224 failed: no writable calendar on stock emulator; three independent attempts exhausted. | BLOCKED | Provision real writable provider environment; emit PASS_REAL_PROVIDER_CREATE_NOOP_UPDATE_DELETE artifact. |
| Follow-up/Person SQL metadata | #2828 Build/Smoke passed on PR merge checkout; migration/backfill regression included. Exact target not verified. | IMPLEMENTED_NOT_VERIFIED | Exact-SHA migration and isolated data-integrity acceptance. |
| Independent Reminder from Follow-up form | Existing form has separate reminderDate/nextFollowUp; stable TaskReminder link from Follow-up is not evidenced. | PARTIALLY_IMPLEMENTED | Trace scheduler/Calendar paths; implement stable link and isolated clear/delete without duplicate notification. |
| Backup/Restore integrity | #2790 Build 39204622671 and Smoke 39204622845 passed on its PR head, but base SHA is stale and exact-target step skipped. | IMPLEMENTED_NOT_VERIFIED | Reconcile against current main and run isolated Backup→Delete→Restore→Integrity Check on candidate SHA. |
| PDF font/render acceptance | #2791 Build 39203354122, Smoke 39203354193 and PDF artifact 12164731659 passed/inspected on PR head; no app Preview screenshot comparison or candidate exact-SHA proof. | IMPLEMENTED_NOT_VERIFIED | Compare actual PDF and app Preview on qualified candidate. |
| UI font/RTL acceptance | #2796 latest-head Build 39206323906 and Smoke 39206323907 passed; no physical-device acceptance. | IMPLEMENTED_NOT_VERIFIED | Reconcile branch and validate installed build on physical device. |
| Recurrence overdue/current/next + Resume from Today | Existing UI does not separately display overdue uncompleted and current-day occurrence windows; explicit old startDate may mask moved reminderDate in projection. | PARTIALLY_IMPLEMENTED | Add narrow recurrence-window projection and tests; preserve immutable occurrence history and count/end boundaries. |
| Reports Person/waiting filters | Current report code has Person/waiting filters; #2828 fixes Follow-up source-of-truth logic but no exact candidate acceptance. | IMPLEMENTED_NOT_VERIFIED | Reconcile stale #2755/#2762 and verify full source/type/filter matrix on one SHA. |
| Report-row tap behavior | Main navigates to Task Detail and existing test asserts it; Wave 4.7 says row tap should not unexpectedly navigate, but canonical report decision does not specify row behavior. | CONFLICT_REQUIRES_PRODUCT_DECISION | Locate authoritative owner decision before changing behavior or tests. |
| Physical-device acceptance | No current physical-device evidence. | BLOCKED | Owner/operator installs exact candidate and records core flows, Calendar, Backup/Restore, Persian RTL and compact-screen evidence. |

This override supersedes stale Wave 4.6 pending labels where terminal results are now available. PR-event PASS does not equal exact-candidate release acceptance. Final status remains **BLOCKED — RELEASE: NO-GO**.


## Wave 4.7 execution delta — Follow-up Reminder title correction — 2026-10-19

- Existing PR #2828 was extended by commit `4cdb6449f7b007e66e71b784738ffa5207ea3e26` (no new product PR). `FollowUpReminderCandidate.followUpLabel` now uses the explicit Follow-up title; when blank, it falls back to `پیگیری — <parent Task title>`. The future-reminder projection and due-delivery projection use the same rule. Notes/results remain metadata and are no longer used as the reminder label. Stable Follow-up ID, parent Task identity, scheduled timestamp and existing scheduler path are preserved; no second scheduler/store was introduced.
- Regression expectations were updated in `test/follow_up_reminder_projection_test.dart` and `test/follow_up_reminder_delivery_service_test.dart` for explicit title and blank-title fallback.
- Exact-head Build [39218125822](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39218125822): latest observation has Analyze SUCCESS; test shards 0–5 and Debug/Release APK jobs are still IN_PROGRESS. Device Smoke [39218125814](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39218125814) is QUEUED overall, with Home and Quick Capture lanes in progress and other lanes queued. **No final test verdict yet.** Do not mark this fix accepted until all jobs reach terminal status.
- This entry is a live status checkpoint, not release acceptance. PR #2828 remains OPEN/DRAFT, no merge/tag/release occurred, exact-target verification remains skipped for PR-triggered workflows, and official signing / real Calendar Provider gates remain BLOCKED. Release decision remains `BLOCKED — RELEASE: NO-GO`.


## Wave 4.8 — Exact Follow-up Reminder title verification checkpoint — 2026-10-19

- Live PR #2828 is OPEN/DRAFT, base `d9fb7a247037762216662a20fb32028ecc8a0f6b`, head exactly `4cdb6449f7b007e66e71b784738ffa5207ea3e26`; commit `fix(reminder): label Follow-up reminders from their title` is still the latest head commit. Source: https://github.com/mobinpda-lab/Arvin-clean/pull/2828 and https://github.com/mobinpda-lab/Arvin-clean/commit/4cdb6449f7b007e66e71b784738ffa5207ea3e26
- Exact-head Build run [39218125822](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39218125822) COMPLETED SUCCESS on the same SHA. Analyze and all six test shards passed; test shard logs explicitly include `follow_up_reminder_projection_test.dart` coverage for explicit title, parent Task identity, reminder time, stable key, blank-title fallback `پیگیری — کار`, and independent Task/Follow-up reminders; `follow_up_reminder_delivery_service_test.dart` coverage includes explicit title despite a result note, fallback when title/note are blank, stable delivery identity suppression, changed reminder time as new work, coexistence without duplicate identity, and due-time handling. Debug and Release APK jobs built and uploaded.
- Build artifacts for that exact SHA: Debug artifact ID `12170432382`, archive digest `sha256:e99db2f5cd4fbcdc84b4d76594a9d6b721d5274e8b8198cb83f367fbfe6aaa43`; Release artifact ID `12170353835`, archive digest `sha256:14654ffb439af1f148ae7a2febf35bdc8ce351cb633c21ee10290df218127c1f`. These are CI artifacts, not proof of official release signing.
- Device Smoke [39218125814](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39218125814) still IN_PROGRESS at checkpoint. Home, SQL Persistence, Quick Capture, People, SQL Migration, Backup/Restore lanes SUCCESS; Calendar lane still IN_PROGRESS. Therefore the complete seven-lane Smoke gate is not yet closed.
- Current canonical `android/app/build.gradle.kts` on `main` still uses `signingConfig = signingConfigs.getByName("debug")`. Official signing remains BLOCKED. Calendar Provider acceptance [39211706224](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211706224) failed with `LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR`; no real-provider acceptance marker is present. Exact-SHA verification has not been run as an authorized dispatch.
- Regression limitation to track: existing tests prove stable delivery identity across duplicate delivery and changed time, but do not yet directly assert title-only edits retain the same delivery identity or the empty-parent-title fallback. Code inspection shows identity is keyed by stable Task/Follow-up IDs and empty parent title returns `پیگیری`; add a narrow regression only if this gap is required before the next accepted SHA, and then rerun CI on the new SHA.
- Release remains `BLOCKED — RELEASE: NO-GO`. No merge, tag, or release performed. This is a checkpoint; final Device Smoke and official signing are still open.


## Wave 4.8 follow-up test coverage delta — 2026-10-19

- After verifying Build [39218125822](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39218125822) SUCCESS for the previous product commit `4cdb6449f7b007e66e71b784738ffa5207ea3e26`, two narrow regression tests were added to the existing PR #2828 in commit `49910e585ee73afcf56a7f8d927b9c69e763c5c5` (`test/follow_up_reminder_projection_test.dart`): title-only edits preserve stable Follow-up reminder identity/time while updating the visible label, and a blank parent Task title safely falls back to `پیگیری` without changing stable identity/time.
- The new head is `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. As of this checkpoint, no Actions run for that exact SHA was returned yet; do not inherit the prior SHA's green Build result or pending Device Smoke status as acceptance of this new test commit. Wait for exact-head CI and verify it.
- Prior exact-SHA Build evidence for `4cdb6449f7b007e66e71b784738ffa5207ea3e26` remains historical and valid only for that SHA. Its Device Smoke [39218125814](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39218125814) remains IN_PROGRESS at last observation; Calendar lane has not produced a terminal result.
- Documentation commit `a41ec7ba196f06891f8716bd3bce1d8769fb3877` already recorded the verified prior Build, artifact IDs/digests, passing test-shard evidence, official signing blocker, Calendar Provider limitation, and remaining regression gaps. This delta supersedes only the test-coverage status and current product SHA.
- Current `main` release build still uses debug signing config. Calendar Provider real-writable acceptance, Exact-SHA dispatch, and final seven-lane Device Smoke remain open. Release remains `BLOCKED — RELEASE: NO-GO`; no merge/tag/release occurred.


## LIVE TRACEABILITY OVERRIDE — 2026-10-19 — V10.0

This is an evidence update, not a declaration that all reminder or release requirements are complete.

| Requirement | Current status | Latest evidence | Remaining work / risk |
|---|---|---|---|
| Follow-up reminder title projection: use actual Follow-up title and safe Persian fallback when title is blank | `IMPLEMENTED_AND_VERIFIED` for the focused projection regression on PR head | PR [#2828](https://github.com/mobinpda-lab/Arvin-clean/pull/2828), SHA `49910e585ee73afcf56a7f8d927b9c69e763c5c5`; Build [39220016817](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39220016817) PASS | Scope is limited to the covered projection behavior; do not generalize to full release acceptance. |
| Title-only Follow-up edit preserves reminder stable identity and scheduled time | `IMPLEMENTED_AND_VERIFIED` for targeted regression | Same SHA and Build run; focused test in `test/follow_up_reminder_projection_test.dart` | Persistence, notification rescheduling, calendar synchronization and backup/restore still need candidate-level acceptance. |
| Analyze, unit/widget regression suite and Debug/Release APK build | `IMPLEMENTED_AND_VERIFIED` on PR head | Run 39220016817, all listed jobs SUCCESS on SHA `49910e585ee73afcf56a7f8d927b9c69e763c5c5` | Manual exact-SHA dispatch and final integrated candidate qualification not established. |
| Seven-lane Device Smoke | `IMPLEMENTED_AND_VERIFIED` for the PR run | Run [39220016763](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39220016763), all seven lanes SUCCESS on same SHA | Emulator-only; not physical-device acceptance or real Calendar Provider acceptance. |
| Official release signing | `BLOCKED` | Main `android/app/build.gradle.kts` still configures Release with Debug signing | Authorized release credential, approved certificate SHA-256, successful apksigner verification, signed APK hash and source/build provenance required. |
| Real Calendar Provider create/no-op/update/delete | `BLOCKED` | Prior run 39211706224 reported no writable calendar on stock emulator | Obtain authorized writable-provider environment and actual operation evidence; no fabricated marker. |
| Full release qualification across Person/reports, recurrence, migrations, backup/restore, RTL/PDF, install and physical device | `IN_PROGRESS` / individual gates remain unverified | Current PR Build and Device Smoke are green | Need one integrated candidate SHA with all mandatory gates and complete handover. |

Preserve the matrix's earlier requirement IDs and historical evidence. This addendum does not silently upgrade unrelated requirements.
