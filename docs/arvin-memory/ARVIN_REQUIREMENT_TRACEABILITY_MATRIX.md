# ARVIN — REQUIREMENT TRACEABILITY MATRIX

Last updated: 2026-10-19 — Wave 4.12 live-state checkpoint

Status vocabulary: `IMPLEMENTED_AND_VERIFIED`, `IMPLEMENTED_NOT_VERIFIED`, `PARTIALLY_IMPLEMENTED`, `IN_PROGRESS`, `NOT_IMPLEMENTED`, `BLOCKED`, `CONFLICT_REQUIRES_PRODUCT_DECISION`, `NOT_APPLICABLE`.

## Candidate and evidence scope
- PR #2833 head at checkpoint: `d06062fb19c3f3ad54051f3a682f69be4146dd91`.
- Build Run [39234124721](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39234124721): 9/9 jobs SUCCESS on that SHA.
- Device Smoke Run [39234124429](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39234124429): at last poll 4 lanes SUCCESS, People and Backup/Restore IN_PROGRESS, Calendar QUEUED. Not a full pass.
- The broader product contract remains in [PRODUCT_CONTRACT_MATRIX.md](../PRODUCT_CONTRACT_MATRIX.md). This file tracks release-critical evidence and Wave 4.12 state; it does not replace that product source of truth.

## Traceability matrix
| ID | Requirement | Status | Evidence / limitation | Next action |
|---|---|---|---|---|
| DATA-01 | Task/Follow-up/Reminder IDs persist and reload | IMPLEMENTED_NOT_VERIFIED | PR #2833 model/repository changes and SQL + Backup/Restore regression test; current-head Build green, test lane evidence alone does not prove all lifecycle cases. | Inspect focused test output and Device Smoke terminal results. |
| DATA-02 | Legacy reminders without followUpId remain readable; no guessed links | IMPLEMENTED_NOT_VERIFIED | Optional JSON field; no migration/schema change; legacy records are not linked by title/time guess. | Verify focused legacy serialization and existing DB migration tests. |
| DATA-03 | Backup/Restore preserves IDs, Person, waiting state and unrelated reminders | IMPLEMENTED_NOT_VERIFIED | Integration test added in commit `2253ef62f404ef064b4bf85d40a16cbf880ed554`; Backup/Restore lane was still in progress at last poll. | Confirm test and device lane terminal success. |
| FU-01 | Form uses one “یادآور پیگیری بعدی” time input | IMPLEMENTED_NOT_VERIFIED | `lib/follow_up_entry_page.dart` changed on PR #2833. | Verify widget behavior and clear-time interaction. |
| FU-02 | Reminder is stable, linked to the correct Task and Follow-up | IMPLEMENTED_NOT_VERIFIED | Repository links by stable IDs; repeated writes reconcile existing Follow-up/Reminder. | Run focused repository/persistence tests on final head. |
| FU-03 | Title fallback and title edit preserve ID/time | IMPLEMENTED_NOT_VERIFIED | Repository title fallback and tests added. | Confirm focused tests and real UI flow. |
| FU-04 | Clearing reminder cancels only related reminder/notification and preserves other data | IMPLEMENTED_NOT_VERIFIED | Linked reminder is removed by explicit Follow-up ID; OS cancellation must be confirmed. | Verify scheduler cancellation and unrelated-reminder regression. |
| FU-05 | nextFollowUp alone creates no Reminder | IMPLEMENTED_NOT_VERIFIED | Repository regression test added. | Verify test result on final candidate SHA. |
| CAL-01 | Calendar projection avoids duplicate linked reminder event | IMPLEMENTED_NOT_VERIFIED | `follow_up_calendar_projection.dart` skips linked mirror; test added. | Verify test output. |
| CAL-02 | Real Provider CREATE → NO-OP → UPDATE → DELETE | BLOCKED | [Run 39211706224](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211706224) failed due to no writable provider. | Use authorized writable provider environment. |
| CI-01 | Analyze, full tests, Debug/Release build | IMPLEMENTED_AND_VERIFIED | Run 39234124721, all nine jobs SUCCESS on candidate SHA. | Re-run only if candidate SHA changes. |
| CI-02 | Device Smoke all required lanes | IN_PROGRESS | Run 39234124429 was non-terminal at last poll. | Verify final lane results. |
| CI-03 | Exact requested SHA is checked out and asserted | BLOCKED | PR #2827 Run 39211789444 shows Verify exact requested revision SKIPPED. | Authorized workflow_dispatch with target SHA; verify logs and artifact source. |
| SIGN-01 | Official release certificate verified independently | BLOCKED | PR #2824; Release variant uses debug signing; approved key/fingerprint not supplied. | Owner provisions approved secret and fingerprint; run apksigner + SHA-256. |
| PROD-01 | Recurrence and Resume from Today | IN_PROGRESS | Must be assessed against canonical product matrix; no new candidate-SHA acceptance evidence here. | Prioritize data integrity and exact requirements in PRODUCT_CONTRACT_MATRIX.md. |
| PROD-02 | Home/Calendar, Reports, People, Quick Entry, Full Task, Notes | PARTIALLY_IMPLEMENTED | Existing implementation and earlier PR evidence are not final-candidate acceptance. | Use focused regression tests for only open rows in canonical matrix. |
| PROD-03 | UI/PDF font acceptance | BLOCKED | Prior build/device runs do not prove visual parity on this candidate. | Capture approved UI/PDF comparison evidence. |
| DOC-01 | Canonical execution, evidence, decision, knowledge and problem records | IN_PROGRESS | Existing five files updated on PR #2833. | Keep run results and SHA scope current. |

## Release rule
No requirement is considered verified merely because code or a test exists. Release remains `BLOCKED — RELEASE: NO-GO` until every mandatory gate passes on one fixed candidate SHA.


## Wave 4.13 traceability update — 2026-10-19

This section is the newest evidence scope; earlier rows remain historical where they describe older heads.

| ID | Requirement / gate | Status | Current evidence | Next action |
|---|---|---|---|---|
| FU-01 | Single “یادآور پیگیری بعدی” input | IMPLEMENTED_NOT_VERIFIED | Follow-up editor and tests are present on PR #2833; Build run 39235854952 tests passed on PR integration run, exact checkout skipped | Verify UI clear/edit and persisted relation on final head. |
| FU-02 | Stable reminder ID, Follow-up and parent Task association | IMPLEMENTED_NOT_VERIFIED | FollowUpRepository reconciles linked TaskReminder by stable followUpId; test shards passed, but exact-head/device proof incomplete | Verify ID, parent Task navigation, repeated save and unrelated reminder isolation. |
| FU-03 | Title fallback and title edit preserve ID/time | IMPLEMENTED_NOT_VERIFIED | Repository derives title from Follow-up, then parent Task, then safe “پیگیری” fallback | Confirm focused tests on exact candidate SHA. |
| FU-04 | Clear time cancels only linked notification/reminder | IMPLEMENTED_NOT_VERIFIED | Repository removes only TaskReminder linked to Follow-up; notification cancellation and independent siblings still require full lifecycle proof | Verify alarm/notification schedule, reschedule and cancellation. |
| FU-05 | nextFollowUp alone does not create reminder | IMPLEMENTED_NOT_VERIFIED | Existing projection/repository tests are present; full exact-candidate evidence pending | Confirm focused tests on final candidate. |
| DATA-01 | Legacy serialization, SQL persistence and ID stability | IMPLEMENTED_NOT_VERIFIED | Build run 39235854952 test shards all SUCCESS; exact checkout step SKIPPED | Rerun/verify on final exact SHA. |
| DATA-02 | Backup/Restore retains IDs, Persons, history and Calendar links | IMPLEMENTED_NOT_VERIFIED | Backup integration test exists; Device Smoke Backup/Restore queued at last poll | Confirm terminal lane and exact-head backup round-trip. |
| CAL-01 | Real Provider CREATE → NO-OP → UPDATE → DELETE | BLOCKED | Artifact 12165156149: Provider installed, no writable calendar row | Authorized writable Provider; require explicit identity/count/result evidence. |
| CI-01 | Analyze, six test shards, Debug and Release APK | IMPLEMENTED_NOT_VERIFIED for exact source head | Run 39235854952 9/9 SUCCESS; exact-revision step SKIPPED | Re-run after this docs commit; exact target path must execute assertion. |
| CI-02 | Device Smoke all seven lanes | IN_PROGRESS | Run 39235854812: Home/Quick Capture SUCCESS; SQL Persistence/SQL Migration in progress; People/Backup/Restore/Calendar queued | Complete 7/7 and refresh after head advances. |
| CI-03 | Exact requested SHA checkout and assertion | BLOCKED | PR Build assertion SKIPPED; no direct workflow_dispatch action exposed | Authorized target_sha dispatch; prove checkout and artifact source SHA. |
| SIGN-01 | Approved official release signer | BLOCKED | Release APK SHA recorded, but Gradle uses Debug signing and approved fingerprint/key is not verified | Authorized keystore/fingerprint, apksigner output and independent comparison. |
| PDF-01 | Persian font license, embedding, RTL shaping, page layout and preview | IMPLEMENTED_NOT_VERIFIED / BLOCKED where external authorization needed | No new candidate-specific PDF visual acceptance evidence in this wave | Audit license and compare actual generated PDF with in-app preview. |
| PROD-01 | Home, Calendar UX, Reports, People, migration and Golden Flow | IMPLEMENTED_NOT_VERIFIED | Existing canonical implementations and prior tests are not equivalent to final-candidate integrated acceptance | Prioritize remaining contract rows by data-loss risk; retain exact links and screenshots. |

No row is promoted to IMPLEMENTED_AND_VERIFIED based solely on code presence or a PR-triggered build whose exact checkout assertion was skipped.


## CI refresh after Wave 4.13 documentation commit

The Wave 4.13 memory updates above were committed as a documentation batch. Earlier intermediate documentation commits used a CI-skip marker to avoid repeatedly canceling active workflows; therefore, their existing run results do not validate the resulting batch head. A fresh Build and Device Smoke run on the current final head is required. At the time of this entry, no run for that resulting head has been returned by the connected GitHub Actions query. Exact-SHA assertion, writable Calendar Provider acceptance and approved release signing remain BLOCKED.
