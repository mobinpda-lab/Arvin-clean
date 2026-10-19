# ARVIN — GO / RELEASE FINAL STATUS

Last updated: 2026-10-19 (Wave 4.12 live-state checkpoint)

## Decision
**BLOCKED — RELEASE: NO-GO**

No merge, tag, or release is authorized. This status is tied to the source and CI evidence listed below; later commits require fresh evidence.

## Current Follow-up Reminder candidate
- PR: [#2833](https://github.com/mobinpda-lab/Arvin-clean/pull/2833), OPEN / DRAFT / UNMERGED.
- Base: `fix/follow-up-record-authority-20261019`, SHA `49910e585ee73afcf56a7f8d927b9c69e763c5c5`.
- Head at checkpoint: `d06062fb19c3f3ad54051f3a682f69be4146dd91`.
- Build Run [39234124721](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39234124721): all 9 jobs SUCCESS (Analyze, six test shards, Debug APK, Release APK).
- Device Smoke Run [39234124429](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39234124429): last observed with Home, Quick Capture, SQL Persistence, SQL Migration SUCCESS; People and Backup/Restore IN_PROGRESS; Calendar QUEUED. Do not report 7/7 PASS until terminal results are verified.
- Artifacts from Build Run 39234124721: `arvin-debug-apk` (artifact ID 12178910414) and `arvin-release-apk` (artifact ID 12177339192), both attached to the candidate SHA. Artifact existence does not prove official signing.

## Mandatory release gates
| Gate | Status | Evidence / blocker |
|---|---|---|
| Analyze + full tests + Debug/Release build | IMPLEMENTED_AND_VERIFIED for head `d06062fb19c3f3ad54051f3a682f69be4146dd91` | Build Run 39234124721, all 9 jobs SUCCESS. |
| Device Smoke 7/7 | IN_PROGRESS at last poll | Run 39234124429; terminal People, Backup/Restore and Calendar results must be checked. |
| Exact-SHA dispatch/checkout | BLOCKED | PR #2827 Run [39211789444](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211789444) has “Verify exact requested revision” SKIPPED on its Device Smoke jobs. |
| Release signing / approved certificate | BLOCKED | PR #2824 head `ccc9f9b122420ef999828088f70a7aa950c5b979`; `android/app/build.gradle.kts` uses debug signing for release. Authorized keystore and independently approved fingerprint unavailable. |
| Real Calendar Provider acceptance | BLOCKED | PR #2831 Provider Run [39211706224](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39211706224) failed; environment reports no writable Calendar Provider. |
| Follow-up Reminder persistence/lifecycle | IMPLEMENTED_NOT_VERIFIED | Code and regression tests exist on PR #2833; current-head Build is green, but Device Smoke terminal result and full contract-level evidence remain incomplete. |
| Migration and Backup/Restore relation | IMPLEMENTED_NOT_VERIFIED | Integration test added; Device Smoke Backup/Restore lane still non-terminal at last poll. |
| PDF/UI font and remaining product acceptance | BLOCKED / PARTIALLY_VERIFIED | Prior PR runs are not proof of the final candidate SHA; visual product acceptance remains outstanding. |
| Canonical evidence/docs | IN_PROGRESS | This file and the requirement matrix are being established on the existing PR branch. |

## Safety constraints
- Never disclose secrets or create a guessed signing key/fingerprint.
- Do not treat a green generic Calendar Device Smoke as Provider acceptance.
- Do not infer exact checkout from workflow metadata alone.
- Do not merge, tag, or release until every required gate passes on one qualified candidate SHA.

## Next actions
1. Confirm terminal Device Smoke results and artifacts on the current head.
2. Run or obtain an authorized exact-target workflow dispatch and verify actual checkout SHA.
3. Obtain owner-approved release keystore/secret setup and independent certificate fingerprint; run apksigner verification and SHA-256.
4. Provision a writable Calendar Provider and pass CREATE → NO-OP → UPDATE → DELETE.
5. Refresh this status after the final candidate SHA is fixed.



## Wave 4.13 release gate update — 2026-10-19

**Decision: BLOCKED — RELEASE: NO-GO.** PR #2833 remains Draft/Open/Unmerged; no merge, tag or release was performed.

- Candidate before this documentation update: `4567397be8374c82993271a12f552219a3727be1`; this documentation commit advances the candidate and invalidates transfer of previous CI evidence to the new head.
- Build [39235854952](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39235854952): 9/9 jobs SUCCESS, including Analyze, test shards 0–5, Debug APK and Release APK. The exact-revision assertion was SKIPPED because the run was PR-triggered.
- Artifacts: Debug [12178863114](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12178863114), Release [12179281920](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12179281920). Release APK SHA-256: `6c6e38199c9d29ae26a4ff33e45082882ff05d0ee0bd8d276889148e78f2fabd`. This does not prove official signer identity.
- Device Smoke [39235854812](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39235854812) is incomplete: Home and Quick Capture PASS; SQL Persistence and SQL Migration IN_PROGRESS; People, Backup/Restore and Calendar QUEUED at last poll.
- Exact-SHA dispatch: BLOCKED; connected GitHub interface does not expose workflow_dispatch.
- Calendar Provider: BLOCKED; API 35 emulator has CalendarProvider2 but no writable calendar row. See [diagnostic artifact](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12165156149) and [PR #2831 evidence comment](https://github.com/mobinpda-lab/Arvin-clean/pull/2831#issuecomment-6264972663).
- Official signing: BLOCKED; Release uses Debug signing and approved key/fingerprint is not available for verification.
- Follow-up persistence/lifecycle and Backup/Restore remain IMPLEMENTED_NOT_VERIFIED until all required exact-candidate evidence is terminal and complete.
- PDF/font, physical-device/visual acceptance and end-to-end Golden Flow remain open.

Next: wait for the current Smoke run where useful, then trigger/obtain all required gates for the new documentation head. Do not treat old-head results as validation of the new candidate.


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


## Wave 4.16 release gate refresh — 2026-10-19

**Decision: BLOCKED — RELEASE: NO-GO.**

- PR #2833 remains Draft/Open/Unmerged; current code test commit is `91d75f5495c4f98514bf3c977a7d3e77b96a0b47`. Repository-level Follow-up Reminder regression tests were added; Build run [39243365218](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243365218) and Device Smoke [39243365263](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243365263) were non-terminal at the recorded checkpoint. Any later documentation commit requires candidate-specific CI recheck.
- Previous Build [39240952251](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39240952251) succeeded 9/9 but its Exact-SHA assertion was skipped. Artifacts were Debug ID `12181028571` and Release ID `12180934054`; these are not official-release proof.
- Previous Device Smoke [39240952294](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39240952294) is CANCELLED; Calendar lane was cancelled, so it is not a complete pass.
- Calendar Provider acceptance [39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995) failed because the stock API 35 emulator had no writable calendar row. Diagnostics were published in Artifact [12182310078](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995/artifacts/12182310078).
- Exact-SHA workflow dispatch is unavailable through the current connected GitHub action interface; an authorized workflow_dispatch with target_sha assertion is required.
- Release configuration on main still uses Debug signing. Authorized keystore and independently approved certificate fingerprint are not available.
- No merge, tag, or official APK publication is authorized.


## Wave 4.17 release gate update — 2026-10-19

**Decision: BLOCKED — RELEASE: NO-GO.** PR #2833 remains OPEN / DRAFT / UNMERGED.

- Implemented a targeted notification lifecycle fix: completed FollowUps are now excluded by `FollowUpReminderDeliveryService.due`; a regression test was added. Commit: [9b7386dd32dc545b20a1b9a267cbbb1e8cc7490b](https://github.com/mobinpda-lab/Arvin-clean/commit/9b7386dd32dc545b20a1b9a267cbbb1e8cc7490b). Validation is pending on the new candidate.
- Build [39243593152](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243593152) and Device Smoke [39243593281](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39243593281) are evidence for prior SHA `6287eccfe7bd24d0412ae146bd8c6a11ca5a0ce7`, not the post-fix candidate. At last inspection Build was nonterminal and Device Smoke was queued/in progress; no final conclusions are allowed.
- Provider acceptance remains blocked after [Run 39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995), whose unexpired diagnostic artifact is [12182310078](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995/artifacts/12182310078). This was an older source SHA and is not a pass.
- Exact-SHA dispatch remains blocked by lack of a workflow-dispatch action in the connected integration. Official Release signing remains blocked because `main` uses debug signing and approved signing credentials/fingerprint are unavailable.
- No merge, tag, or release is authorized.


## Wave 4.17 Calendar Provider CI hardening — 2026-10-19

- Inspection of the real diagnostic ZIP for [Run 39241395995](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995), artifact [12182310078](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39241395995/artifacts/12182310078), found `CALENDAR_SEED_EXIT=127` and `/system/bin/sh: --bind: inaccessible or not found`. The seed URI contains query-string ampersands, but the remote `adb shell` command did not quote the full remote command; this caused the shell to parse ampersands as control operators. Provider package discovery confirmed `com.android.providers.calendar/.CalendarProvider2` is installed on API 35, but the query returned no calendar rows.
- The current candidate's provider workflow was also found to have two gate issues: its inline script did not attempt to seed a writable acceptance calendar, and the limitation marker path could exit successfully; artifact upload lacked `if: always()`. Corrected the workflow to quote the remote seed command, record seed/query diagnostics, fail closed unless the integration test emits the real PASS marker, and upload diagnostics even on failure. The pull-request target filter now includes the PR's verified integration base branch.
- This is a candidate CI/workflow correction, **not** proof that the provider accepts a writable calendar. The actual CREATE → NO-OP → UPDATE → DELETE sequence must pass on the new workflow run; otherwise the gate remains BLOCKED. The fix is not validated until its run and artifact are inspected.


## Wave 4.17 Calendar Provider runner compatibility correction — 2026-10-19

- New candidate run [39244544605](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39244544605) failed before executing provider setup: the emulator runner invokes its script using `/usr/bin/sh`, which rejected Bash-only `set -o pipefail` (`set: Illegal option -o pipefail`). Because failure occurred before `mkdir -p`, the artifact step ran with `if: always()` but had no evidence directory to upload. This is an orchestration failure, not a Calendar Provider acceptance result.
- Corrected the script to POSIX-compatible `set -eu` and added a host-side evidence-directory initialization step before emulator boot. This makes minimal source SHA/started evidence available even if the emulator script fails before reaching its own setup. Artifact upload remains unconditional. Re-run and inspect its terminal result/artifact; writable provider and CREATE → NO-OP → UPDATE → DELETE remain unproven until the integration test emits PASS.


## Wave 4.17 Calendar Provider script isolation fix — 2026-10-19

- Run [39244802042](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39244802042) failed after the shell-option issue was corrected. The actual emulator-runner contract executes each newline in its `script` input in a separate `/usr/bin/sh` process; therefore variables and control flow in the inline multiline script did not persist, and the test/output files were not produced. The artifact [12182643345](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39244802042/artifacts/12182643345) retained the preinitialized evidence file but did not prove Provider acceptance.
- Replaced the inline multiline script with one invocation, `bash .github/scripts/calendar-provider-acceptance.sh`, so Bash variables, seed result, test result and fail-closed logic execute in a single process. Added the script to workflow path filters and records both actual checkout SHA and PR head SHA. Artifact upload remains `if: always()` with evidence initialized before emulator boot.
- This is a CI harness correction, not a pass. The next run must show seed diagnostics, writable calendar rows, and the real CREATE → NO-OP → UPDATE → DELETE acceptance marker. Otherwise Calendar Provider remains BLOCKED.


## Wave 4.18 live gate update — 2026-10-19

- Build [39245131077](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39245131077): historical SUCCESS, 9/9 jobs; exact-SHA assertion skipped.
- Device Smoke [39245131071](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39245131071): historical SUCCESS, all seven lanes.
- Calendar Provider [39245131251](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39245131251): FAILURE at UPDATE; artifact [12183547745](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39245131251/artifacts/12183547745).
- Native fix commit [3cc2b4551ea5c30903a697cdff3b3450e6bf609f](https://github.com/mobinpda-lab/Arvin-clean/commit/3cc2b4551ea5c30903a697cdff3b3450e6bf609f) is IMPLEMENTED_NOT_VERIFIED until fresh exact-head CI and real provider acceptance.
- Official signing remains BLOCKED: main `android/app/build.gradle.kts` uses the debug signing configuration for Release. No authorized release key and independently approved certificate fingerprint have been verified.
- Release decision: **BLOCKED — RELEASE: NO-GO**. No merge, tag or release.


## Wave 4.19 execution update — 2026-10-19

- PR #2833 remains OPEN / DRAFT / UNMERGED. Source head at evidence collection: `0b1a97c4a71dd95b0cf4c59a265b8928a217cb70`; Build and Calendar Provider Actions checkout SHA: `bf4f1a94f515c213f0630b6c642451d73ab17a4c`, the synthetic PR merge of the source head into base `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. These are merge-candidate results, not Exact-SHA proof for the branch head.
- Build [39252493984](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252493984) completed SUCCESS, 9/9 jobs (Analyze, test shards 0–5, Debug APK, Release APK). Debug artifact [12186790429](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12186790429), digest `sha256:baa2062d28c7f685447dd0fb5ca20a00958aaee26d8c760aa00627867540f87b`; Release artifact [12185434678](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12185434678), digest `sha256:b4683f64eb5c8e2c170f33f4cb9c9995c854cfe160e0463672099d8f435ee7df`. The Exact-SHA step was skipped.
- Calendar Provider Acceptance [39252494348](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494348) completed SUCCESS on the merge SHA. Artifact [12186224225](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494348/artifacts/12186224225), digest `sha256:7b2dbaeee8ad6caccca1d9438808af289e7960fb1f42c8f6ee5d35e59a7ee911`. Its `environment.txt` confirms Android API 35, CalendarProvider2 installed, seeded writable calendar ID 1 (access level 700), `CHECKOUT_SHA=bf4f1a94f515c213f0630b6c642451d73ab17a4c`, and `PR_HEAD_SHA=0b1a97c4a71dd95b0cf4c59a265b8928a217cb70`. The real-provider test emitted `RESULT=PASS_REAL_PROVIDER_CREATE_NOOP_UPDATE_DELETE`; one writable calendar was available, so two-calendar destination migration was explicitly limited, not passed.
- Device Smoke [39252494030](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494030) was still in progress at last poll: Home, Quick Capture, SQL Persistence and SQL Migration SUCCESS; People and Backup/Restore IN_PROGRESS; Calendar QUEUED. This is not a 7/7 pass and may be superseded by the next candidate update.
- Review found a test-coverage gap in the existing provider acceptance: NO-OP counters were asserted without re-querying the real provider for event uniqueness/identity; the multi-calendar cleanup path did not query final provider state. The existing test is being strengthened to assert exactly one event after CREATE and NO-OP, preserve event ID, and verify provider absence after DELETE in the migration path. Fresh CI validation is required.
- Exact-SHA remains BLOCKED: no authorized workflow-dispatch action is exposed in connected GitHub tools; normal PR workflows checkout the merge ref and skip `Verify exact requested revision`. Official signing remains BLOCKED: `main/android/app/build.gradle.kts` configures Release with the Debug signing key and no approved certificate fingerprint/authorized key has been verified. Release remains `BLOCKED — RELEASE: NO-GO`; no merge, tag, or release.

Release decision remains NO-GO until fresh candidate validation completes, all seven smoke lanes pass, the exact requested SHA is asserted, the approved release certificate is verified with apksigner, and integrated/PDF acceptance is complete.


## Wave 4.24 — live acceptance evidence and release gate checkpoint (2026-10-19)

### Revision identity and CI
- PR #2833 is OPEN / DRAFT / UNMERGED. Branch `wave-4-10/follow-up-reminder-contract`; source HEAD at evidence collection: `78dd233f855fdd433b098b861a9e3d33aee44539`; base `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`.
- Build [39259685729](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39259685729): SUCCESS, 9/9 jobs (Analyze, test-0..test-5, APK Debug, APK Release); event `pull_request`; run head SHA `78dd233f855fdd433b098b861a9e3d33aee44539`. Every observed job skipped `Verify exact requested revision`, because it was not a `workflow_dispatch` event.
- Device Smoke [39259685756](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39259685756): SUCCESS, all 7 lanes: Home, Quick Capture, SQL Persistence, SQL Migration, People, Backup/Restore, Calendar. Run metadata binds it to source HEAD `78dd233f855fdd433b098b861a9e3d33aee44539`.
- Calendar Provider Acceptance [39259685716](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39259685716): SUCCESS on `78dd233f855fdd433b098b861a9e3d33aee44539`. Artifact [12189897161](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39259685716/artifacts/12189897161), archive ZIP digest `sha256:f5ca9a7b68a73c45ed338478a1832ce14fba3375eccf446345d7d961b3e8ecae`. Real-provider log: unrelated event IDs 1 and 2 preserved; CREATE produced event ID 3; NO-OP retained one event ID 3; UPDATE retained ID 3 and changed title; migration to destination calendar 2 produced event ID 4 and `CALENDAR_PROVIDER_DESTINATION_MIGRATION=PASS from=1 to=2`; DELETE logged `targetPresent=false calendarId=2`; final `CALENDAR_PROVIDER_ACCEPTANCE=PASS calendarId=1`.
- Build artifact Release ID `12191485284`, archive digest `sha256:e469d28d238a2fa04d1ae30091cf981f4d532fb0f9885ee00f643a7279e20aa6`; Debug ID `12190236537`, archive digest `sha256:4ac84224418afd349e2eb724f6a03a7980a5efcfd0c482cc84ac3b8aabea0bba`. Both unexpired at verification. These digests are for artifact ZIP archives, NOT the extracted APK file SHA-256.
- Device Smoke artifact records were unexpired: Calendar ID `12191647845`, ZIP digest `sha256:28f9f0581df8932616bb48efbb07a98baa8799122b4d6b01d3f7fc5879d71a69`; People ID `12190801898`, `sha256:389b019feae859b77a0dc715330c26e4eeb8e505bc7029068c2be7741cc4a30e`; Persian time picker ID `12190421213`, `sha256:3443555b4e16abfc2a9591cec08aae830fe88581876c4d33f639c4e70056dcc7`; Home ID `12190271340`, `sha256:47f13af9d2b0bbd225705b84e5523bc215d22f4730d73573da411ab0d3905b40`; Quick Capture ID `12190121552`, `sha256:68d97f839a58af18211edd673e1d30373fd15f5fb384ea3b1016dd30fe5e3064`. All are ZIP digests, not APK hashes.
- These run/artifact results are valid only for source SHA `78dd233f855fdd433b098b861a9e3d33aee44539`. This documentation commit creates a new SHA and inherits no CI PASS automatically.

### Follow-up Reminder and notification
- Existing tests in `test/follow_up_repository_test.dart`, `test/follow_up_reminder_projection_test.dart`, `test/follow_up_reminder_model_test.dart`, `test/follow_up_reminder_delivery_service_test.dart`, `test/follow_up_reminder_runtime_contract_test.dart`, `test/services/follow_up_reminder_alarm_planner_test.dart`, and `test/integration_task_reminders_migration_backup_test.dart` passed as part of Build 39259685729 on `78dd233f855fdd433b098b861a9e3d33aee44539`.
- Coverage includes Persian title fallback, stable identity/time when title changes, deduplication, Task/Follow-up reminder independence, completed/archived/trashed suppression, legacy scheduler identity, alarm rescheduling/reboot wiring, and SQL plus canonical Backup/Restore. Test `Follow-up Reminder IDs and relation survive SQL plus canonical Backup/Restore` asserts stable Task, Follow-up and linked TaskReminder IDs, date/title, waiting-for-response, and Person ID.
- Notification scheduling/cancellation is implemented via existing AlarmManager scheduler (alarm ID 42002), reschedule and cancel paths, reboot rescheduling, background runner and persisted delivery state; tests prove code/runtime contracts, not real Android delivery/tap acceptance.
- Notification tap routing fix is included in this candidate: both existing notification services now encode Task ID plus optional Follow-up ID using `ReminderNotificationPayload`; `lib/main.dart` initializes the existing local-notification plugin with a response callback, resolves the canonical Task by ID, and opens `TaskDetailPage` while passing the Follow-up ID; `TaskDetailPage` highlights that Follow-up when present. Added `test/reminder_notification_payload_test.dart` for structured payload, task-only and legacy compatibility, and expanded `test/follow_up_reminder_runtime_contract_test.dart` for wiring. Status: IMPLEMENTED / IN_PROGRESS pending fresh CI and device-level tap acceptance; no device-level acceptance claim.
- Backup/Restore SQL evidence is focused automated integration coverage, not a single accepted Task → Follow-up → Person → Reminder → Calendar → parent Task → Report → Backup → Restore → Integrity journey. Full journey remains NOT VERIFIED.

### PDF, Exact-SHA, official signing
- PDF source `lib/services/task_report_pdf_renderer.dart` loads bundled VazirHarf regular/bold fonts and uses `pw.MultiPage` with RTL, header/footer and page numbering. However, `test/task_report_pdf_renderer_test.dart` injects Helvetica and only asserts `%PDF` bytes; no current candidate PDF Preview artifact was available for inspection. Embedded Persian font, shaping, visual RTL, clipping, tables, multi-page output and preview/export parity remain NOT VERIFIED.
- `.github/workflows/build.yml` has `workflow_dispatch.inputs.target_sha`; checkout uses that input and the job checks `git rev-parse HEAD` then prints `EXACT_TARGET_SHA`. Connected GitHub tools expose no dispatch action. Exact-SHA remains BLOCKED until an authorized owner dispatches the existing workflow with the chosen exact SHA and preserves assertion/run/artifact provenance.
- `android/app/build.gradle.kts` still configures Release with `signingConfigs.getByName("debug")`. No authorized release keystore or independently approved certificate fingerprint was provided. Official signing remains BLOCKED; no official APK, tag or release is authorized.
- **Release decision: `BLOCKED — RELEASE: NO-GO`.** Keep PR #2833 OPEN / DRAFT / UNMERGED. Do not tag or release. Owner dependencies: authorized target-SHA dispatch; release key and approved certificate fingerprint; PDF artifact/device visual review; device-level notification-tap acceptance; integrated product acceptance.