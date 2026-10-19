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
