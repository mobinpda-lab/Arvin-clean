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


## WAVE 4.14 — TERMINAL CI CHECKPOINT — 2026-10-19

Candidate PR: [#2833](https://github.com/mobinpda-lab/Arvin-clean/pull/2833), branch `wave-4-10/follow-up-reminder-contract`. Candidate PR head at the run's source metadata: `77271d24f3ec132868689f17566a7a5e7953d78a`; base SHA last recorded: `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. The two runs below are terminal, but a new documentation commit after this checkpoint changes the candidate head again; the new head requires fresh CI.

### Terminal Build and Device Smoke evidence

- Build [39237043651](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39237043651): all 9 jobs completed successfully (Analyze, test shards 0–5, Debug APK, Release APK). However, the job log's checkout input is synthetic PR merge SHA `c8ddb21ae29ea102e55c02e5d092e783b60a177f`, and `Verify exact requested revision` was SKIPPED. This is successful PR-integration CI, not Exact-SHA proof.
- Device Smoke [39237043144](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39237043144): all 7 lanes completed successfully: Home, Quick Capture, SQL Persistence, SQL Migration, People, Backup/Restore, Calendar. The Calendar lane is generic UI/device smoke and does not replace Provider acceptance.
- Build artifacts tied by GitHub run metadata to source head `77271d24f3ec132868689f17566a7a5e7953d78a`:
  - Debug `arvin-debug-apk`, ID [12180240134](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12180240134), GitHub ZIP digest `sha256:a1557fbb675536d23c6d763546acee2e7ba6afb841244b6d467b054e116a4092`.
  - Release `arvin-release-apk`, ID [12179209418](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12179209418), GitHub ZIP digest `sha256:fa8e05857316696c45ab21c44538edbadb41d34eb6aadf70c088b41afa1b2ae2`.
- Device Smoke screenshot artifacts are named with checkout SHA `c8ddb21ae29ea102e55c02e5d092e783b60a177f`, confirming the synthetic merge checkout:
  - Home [12179422599](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12179422599), digest `sha256:c762ee7799e8e7067bdfeb20bf6cfee930f1a15fe471121a9c6190d0645e069a`.
  - Quick Capture [12178699907](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12178699907), digest `sha256:f68b9d6350534b0bce55817fe0e7b090fa811c066a6eaae1ffb5b11220012f32`.
  - Calendar [12180910145](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12180910145), digest `sha256:d0bf1df321c00583c9d1d82b01dc8a78a8c6dccbbf74a7ca3e23d33739c33212`.
  - People [12179689607](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12179689607), digest `sha256:a7914fe44f116a5564f7517239862922b04468934e6bef0749de0f7f9f658d8c`.
  - Persian time picker [12178869660](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12178869660), digest `sha256:56b658b6772d66adf0c8513b8171c7c6555d3762988b1f5aa410abd7453e0b0f`.
  - Only five artifacts were returned for the Smoke run; no artifact is claimed for each of the other lanes.

### Gates that remain open

- **Exact-SHA: BLOCKED.** PR-triggered checkout was `c8ddb21ae29ea102e55c02e5d092e783b60a177f`; assertion was skipped. Connected GitHub tools do not expose a workflow-dispatch action. PR [#2827](https://github.com/mobinpda-lab/Arvin-clean/pull/2827) remains Draft/open.
- **Calendar Provider acceptance: BLOCKED.** Provider diagnostic [39203189292](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39203189292), artifact [12165156149](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12165156149), records Android API 35 with `com.android.providers.calendar/.CalendarProvider2` present but no writable calendar row (`accessLevel >= 500`). Explicit result: `LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR`. No authorized alternate writable-provider environment is exposed; do not claim CREATE → NO-OP → UPDATE → DELETE acceptance. See [PR #2831](https://github.com/mobinpda-lab/Arvin-clean/pull/2831) and [evidence comment](https://github.com/mobinpda-lab/Arvin-clean/pull/2831#issuecomment-6264972663).
- **Official signing: BLOCKED.** Current default-branch `android/app/build.gradle.kts` lines 34–37 use `signingConfigs.getByName("debug")` for Release. PR [#2824](https://github.com/mobinpda-lab/Arvin-clean/pull/2824) documents that an approved release credential and independently approved certificate fingerprint are not available through the connected interface. Artifact existence/build success does not prove signing; no official APK is declared.
- **Follow-up Reminder and remaining product contracts:** implementation exists, but lifecycle, notification reschedule/cancel, idempotency, backup/restore relations and integrated product acceptance remain `IMPLEMENTED_NOT_VERIFIED` until the relevant focused and integrated evidence is available for a fixed candidate SHA. Home, Calendar UX, Reports, People/migration, PDF/font licensing/embedding/RTL visual comparison and Golden Flow remain open where not explicitly evidenced.
- **Release decision:** `BLOCKED — RELEASE: NO-GO`. No merge, tag, or release.

### Next action

After this documentation batch lands, read the new PR head, obtain fresh Build and all seven Device Smoke lanes for that head, and continue exact-SHA/provider/signing paths only through authorized workflows. Do not transfer the run evidence above to a newer SHA.


## WAVE 4.16 — REQUIREMENT STATUS UPDATE — 2026-10-19

| ID | Requirement | Status | Evidence / tested SHA | Next action |
|---|---|---|---|---|
| FUP-REM-01 | Follow-up Reminder title fallback, stable identity and time on title-only edit, idempotent repository update | IMPLEMENTED_NOT_VERIFIED | Regression cases added at `91d75f5495c4f98514bf3c977a7d3e77b96a0b47`; Build [39243365218](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243365218) was IN_PROGRESS at checkpoint | Verify terminal Build test shards; fix root cause if any test fails. |
| CI-DEVICE-01 | Device Smoke all seven lanes | BLOCKED / IN_PROGRESS for new head | Previous run [39240952294](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39240952294) is CANCELLED with Calendar lane cancelled; new run [39243365263](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243365263) was queued/starting | Obtain terminal 7/7 evidence on current final head. |
| CAL-ACCEPT-01 | Real writable Provider CREATE → NO-OP → UPDATE → DELETE | BLOCKED | Run [39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995); explicit `LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR`; diagnostics [12182310078](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995/artifacts/12182310078) | Provide authorized writable provider/account or supported isolated CI environment; do not relax acceptance. |
| CI-EXACT-01 | Exact target SHA checkout and assertion | BLOCKED | Build run 39240952251 skipped assertion; Provider run's assertion only covers PR #2831 SHA | Authorized dispatch using `target_sha`, with actual checkout assertion and artifacts tied to same SHA. |
| SIGN-01 | Official Release signer and approved certificate fingerprint | BLOCKED | main Gradle Release config uses Debug signing | Owner-authorized signing input and independently approved fingerprint; apksigner verification. |


## Wave 4.17 traceability delta — 2026-10-19

| ID | Requirement | Status | Evidence / limitation | Next action |
|---|---|---|---|---|
| FU-06 | Completed FollowUps never deliver stale due notifications | IMPLEMENTED_NOT_VERIFIED | Fixed missing completed-state guard in `FollowUpReminderDeliveryService.due`; regression test added to `test/follow_up_reminder_projection_test.dart`; commit [9b7386d](https://github.com/mobinpda-lab/Arvin-clean/commit/9b7386dd32dc545b20a1b9a267cbbb1e8cc7490b). | Confirm the test shard passes on the latest candidate SHA. |
| CI-01 | Build and six test shards on current candidate | IN_PROGRESS | Run [39243593152](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243593152) targets previous SHA `6287ecc...` and was nonterminal at last inspection; it cannot validate commit `9b7386d...`. | Inspect newly triggered run for the post-fix head. |
| CI-02 | Seven Device Smoke lanes on current candidate | IN_PROGRESS | Run [39243593281](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243593281) targets previous SHA and was queued/nonterminal. | Confirm latest-head run lane-by-lane. |
| CAL-02 | Real Provider CREATE → NO-OP → UPDATE → DELETE | BLOCKED | Run [39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995) failed on an older SHA; diagnostic artifact [12182310078](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995/artifacts/12182310078). | Establish an authorized writable Calendar Provider environment and run real operations. |
| CI-03 | Exact target SHA dispatch and checkout assertion | BLOCKED | `build.yml` has a `workflow_dispatch.target_sha` input and checkout assertion; the connected integration exposes no dispatch action. | Authorized workflow dispatch and exact checkout log required. |
| SIGN-01 | Official release signing with approved fingerprint | BLOCKED | `main` Release build uses debug signing; no approved keystore/fingerprint available. | Owner provisions authorized signing material and approved fingerprint. |

Release remains **BLOCKED — RELEASE: NO-GO**.


## Wave 4.17 Calendar Provider CI hardening — 2026-10-19

- Inspection of the real diagnostic ZIP for [Run 39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995), artifact [12182310078](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995/artifacts/12182310078), found `CALENDAR_SEED_EXIT=127` and `/system/bin/sh: --bind: inaccessible or not found`. The seed URI contains query-string ampersands, but the remote `adb shell` command did not quote the full remote command; this caused the shell to parse ampersands as control operators. Provider package discovery confirmed `com.android.providers.calendar/.CalendarProvider2` is installed on API 35, but the query returned no calendar rows.
- The current candidate's provider workflow was also found to have two gate issues: its inline script did not attempt to seed a writable acceptance calendar, and the limitation marker path could exit successfully; artifact upload lacked `if: always()`. Corrected the workflow to quote the remote seed command, record seed/query diagnostics, fail closed unless the integration test emits the real PASS marker, and upload diagnostics even on failure. The pull-request target filter now includes the PR's verified integration base branch.
- This is a candidate CI/workflow correction, **not** proof that the provider accepts a writable calendar. The actual CREATE → NO-OP → UPDATE → DELETE sequence must pass on the new workflow run; otherwise the gate remains BLOCKED. The fix is not validated until its run and artifact are inspected.

| CAL-03 | Provider seed and failure evidence are reliable | IMPLEMENTED_NOT_VERIFIED | Workflow now quotes the remote adb command, records seed output/calendar rows, fails closed on limitation and uploads evidence with `if: always()`; actual writable-provider result is pending. | Inspect new run and artifact; require real CREATE/NO-OP/UPDATE/DELETE PASS. |


## Wave 4.17 Calendar Provider runner compatibility correction — 2026-10-19

- New candidate run [39244544605](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39244544605) failed before executing provider setup: the emulator runner invokes its script using `/usr/bin/sh`, which rejected Bash-only `set -o pipefail` (`set: Illegal option -o pipefail`). Because failure occurred before `mkdir -p`, the artifact step ran with `if: always()` but had no evidence directory to upload. This is an orchestration failure, not a Calendar Provider acceptance result.
- Corrected the script to POSIX-compatible `set -eu` and added a host-side evidence-directory initialization step before emulator boot. This makes minimal source SHA/started evidence available even if the emulator script fails before reaching its own setup. Artifact upload remains unconditional. Re-run and inspect its terminal result/artifact; writable provider and CREATE → NO-OP → UPDATE → DELETE remain unproven until the integration test emits PASS.


## Wave 4.17 Calendar Provider script isolation fix — 2026-10-19

- Run [39244802042](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39244802042) failed after the shell-option issue was corrected. The actual emulator-runner contract executes each newline in its `script` input in a separate `/usr/bin/sh` process; therefore variables and control flow in the inline multiline script did not persist, and the test/output files were not produced. The artifact [12182643345](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39244802042/artifacts/12182643345) retained the preinitialized evidence file but did not prove Provider acceptance.
- Replaced the inline multiline script with one invocation, `bash .github/scripts/calendar-provider-acceptance.sh`, so Bash variables, seed result, test result and fail-closed logic execute in a single process. Added the script to workflow path filters and records both actual checkout SHA and PR head SHA. Artifact upload remains `if: always()` with evidence initialized before emulator boot.
- This is a CI harness correction, not a pass. The next run must show seed diagnostics, writable calendar rows, and the real CREATE → NO-OP → UPDATE → DELETE acceptance marker. Otherwise Calendar Provider remains BLOCKED.
