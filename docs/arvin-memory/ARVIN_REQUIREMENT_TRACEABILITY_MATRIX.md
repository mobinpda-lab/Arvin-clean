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
| ARV-004 P0 | APK SHA-256, signer, source SHA, run and artifact provenance bound | §12 | #2824/#2827; artifacts 12168605271, 12167844011 | Build artifact archives exist; archive digest is not APK-file SHA-256 | Download APK, hash APK itself, apksigner verify, compare approved fingerprint on candidate | BLOCKED |
| ARV-005 P0 | Real Calendar Provider create/no-op/update/delete and explicit PASS | §§6,13; AC-09 | provider workflow/script; #2831 | Run 39211706224 failed with LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR; no artifact | After three prior seed/script attempts, use a demonstrably writable provider fixture/runner and capture CRUD evidence | BLOCKED |
| ARV-006 P0 | All Device Smoke lanes terminal-success on same candidate | §§13,17 | device-smoke.yml; #2827 | Run 39211706094 partially completed: Home, Quick Capture, SQL Persistence success; Backup/Restore, SQL Migration in progress; Calendar, People queued | Poll terminal, inspect logs/artifacts, rerun exact target | IN_PROGRESS |
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
| ARV-024 P1 | UI and PDF fonts separate; licensed weights embedded; Persian shaping/RTL/numerals/wrapping/pagination verified | §11; #2791/#2796 | UI assets, PDF renderer/preview; #2791 | Earlier artifact 12164731659 inspected and embeds four UI-FD weights; Persian RTL looked correct | In-app preview comparison missing; latest-head CI pending | IMPLEMENTED_NOT_VERIFIED |
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
