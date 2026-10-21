
## 2026-10-21 — Wave 5.48: CI evidence is not user acceptance

- CI-only commit [52781290a159f1836ebe23d719a8856408c3e52f](https://github.com/mobinpda-lab/Arvin-clean/commit/52781290a159f1836ebe23d719a8856408c3e52f) does not modify application behavior and is not a product fix.
- Previous seven-lane success [39530698590](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39530698590) omitted Task lifecycle and Checklist evolution; it cannot prove restart persistence or checklist-history preservation.
- Owner-reported Calendar actions, Repeat occurrence coverage, Checklist interaction/labels, notification tap/cold-start and Persian RTL/PDF visual quality remain unresolved until the relevant SHA-bound evidence is reviewed.
- No installed-device Golden Flow or physical file-provider Backup/Restore evidence was collected in this wave.
- Status: NOT VERIFIED / BLOCKED as appropriate. Release remains `BLOCKED — RELEASE: NO-GO`.


# Arvin User Experience Log

## 2026-10-09 — Calendar task actions reported missing
- Date: 2026-10-09 (conversation date; exact report time not established here)
- Context: User installed/used an Arvin build and inspected the Calendar task view.
- User Feedback: «در تقویم کارهای آروین دکمه ثبت در تقویم گوشی و دکمه ویرایش حذف شده است»
- Problem: The user reported that “add/register in phone calendar” and “edit” actions were missing from the Arvin Calendar task UI.
- Solution: No verified fix is recorded in this entry. Recheck live issues/PRs and test the actual UI before claiming resolution.
- Status: UNVERIFIED / acceptance evidence required.

## 2026-10-11 — Backup/restore acceptance boundary
- Date: 2026-10-11
- Context: Release-readiness and autonomous execution planning.
- User Feedback: The owner requires real installation/device experience to be retained and treated as product evidence.
- Problem: Emulator smoke cannot prove actual Android file-picker/provider behavior or physical-device data integrity.
- Solution: Require a documented physical-device export/restore round-trip and record device/OS, steps, backup artifact or screenshots/logs, and before/after data checks.
- Status: BLOCKED pending physical-device evidence.

## 2026-10-11 — Repeat Tracking Level owner contract
- Context: Owner supplied RTLC to strengthen important recurring commitments without introducing separate loan/debt/habit/payment/contract/customer-follow-up systems.
- Product expectation: Task form places «نوع پیگیری» after Repeat; «عادی» is the default and «مهم و قابل پیگیری» reveals advanced information progressively. Home uses only a restrained «تعهد مهم» / action-needed cue. Report Center offers «همه»، «عادی»، «مهم و قابل پیگیری» filters and accurate tracking metrics.
- Data expectation: existing Task identity, Repeat, occurrence history, per-occurrence checklist state, and backup/restore remain safe; past history immutable and future settings adjustable.
- Implementation status: decision recorded in [#2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605); first-pass source audit found model/persistence foundations already exist. Main-form/Home/report integration and end-to-end evidence remain pending. No UI screenshot or physical-device result was produced by this audit.




## 2026-10-11 — Owner installed-product feedback
- Environment: installed Android app (version/device not supplied in this report).
- Feedback: recurring Tasks fail to generate the promised 7 occurrences; recurrence activation should automatically fill today's date and current time but allow edits; automatic Calendar sync still has problems after changing a Task.
- Action: opened Draft PR #2606 for safe recurrence-editor defaults and regression coverage; recorded Calendar recurrence identity/projection defect in existing architecture issue #2248.
- Device reproduction/result: not yet captured in this session. Do not mark the user-facing defect resolved until exact-head CI and appropriate Android Calendar Provider validation are complete.

## 2026-10-11 — Calendar sync scope and state-change boundary
- Environment: product-owner clarification; device/build not specified.
- Decision: sync only Task title, date, time, description, recurrence details and reminder to the phone calendar. Marking Done or moving to Archive alone does not require calendar synchronization.
- Existing owner record: [#2248 comment](https://github.com/mobinpda-lab/Arvin-clean/pull/2248#issuecomment-6111402411).
- Acceptance: update the same linked external event; no duplicates; do not trigger calendar work solely for Done/Archive. Device/provider validation remains pending.

## 2026-10-11 — Report Center bottom navigation correction
- Environment: owner inspected the installed Arvin UI.
- Feedback: the Reports icon already exists; the missing change is placement in the bottom navigation row.
- Acceptance: move/reuse the existing icon and route to the existing Report Center. Do not create another reports screen, renderer, model or store.
- Record: [#2385](https://github.com/mobinpda-lab/Arvin-clean/issues/2385#issuecomment-6111105369). Code/device acceptance remains pending.

## 2026-10-11 — Notebook toolbar and checklist interaction defect
- Environment: owner inspected Notebook UI; exact device/build not provided.
- Feedback: labels associated with numbered-list, tick and checklist icons are clipped/incomplete; checklist appears as literal `[ ]` and tapping does not toggle it.
- Acceptance: full labels visible in supported RTL phone widths; render a real compact interactive checkbox; toggle and persist state after save/reopen through canonical Task.checklist/Notebook path.
- Records: [#850](https://github.com/mobinpda-lab/Arvin-clean/issues/850#issuecomment-6111078741), [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139#issuecomment-6111079224).
- Status: reported defect, not fixed or accepted yet.

## 2026-10-11 — Pastel visual language expansion
- Environment: owner requested extending the soft, color-coded Home/Calendar experience to every existing Arvin section, explicitly including Notes/Notebook and Reports.
- Work staged in [PR #2607](https://github.com/mobinpda-lab/Arvin-clean/pull/2607): consistent rounded card style and form-field shape; soft status colors in Calendar, Reports and Next Action; lavender note cards and green checklist cards in Notebook.
- Expected outcome: one coherent personal-assistant visual language, semantic color meaning, compact cards, readable RTL labels, and no clipping at small phone widths.
- Acceptance: compare Home, Calendar, Notebook list/editor, Report Center, Next Action, Task details/forms, settings and other card-based surfaces on an installed Android build. Ensure text remains readable and existing interactions/data remain unchanged.
- Status: code staged; CI was pending and Device Smoke skipped at last check. No owner/device acceptance claimed. Separate Notebook checklist toggle defect remains open.

## 2026-10-11 — Report filter usability and Persian date correction
Owner requirements:
- Report filter dates must use the Jalali/Persian calendar, not Gregorian calendar UI.
- Replace the long crowded filter sheet with collapsible roll-box sections for Time, Project, Category, Tag, Note, Task Status, Tracking and Follow-up.
- Show each section's icon, title, selected count, expand/collapse indicator, selected chips and multi-select options.
- Use Arvin's soft semantic pastel palette to distinguish project, category, tag, note and status filters.
- Multi-select must support several projects, categories, tags, task statuses and note kinds at once.
- Notes are reportable through the existing canonical Task/Notebook representation, including title/text and created/updated dates; no separate note/report data store.
Current implementation pointer: PR #2607. Automated validation, small-screen RTL visual check, and owner acceptance are still pending. Note-to-another-Task linkage and external-calendar-only report ingestion remain explicit model/integration gaps, not claimed as implemented.


## 2026-10-11 — Exact-main Device Smoke screenshot review
- Environment: GitHub Actions Device Smoke artifacts for exact `main` SHA `d8afc717eaf02d6d0bedf92e800c7f93209c97bd`; screenshots are automation/emulator captures, not a user-reported physical-device session.
- Home screenshot: primary task card, pastel quick filters and bottom navigation appear legible in the captured RTL viewport.
- People screenshot: empty-state message and add-person action are visible; no user data is shown.
- Quick Capture screenshot: selection controls use a compact three-column layout; several Persian labels are visibly clipped/truncated (e.g. project/category/tag and date/time-related chips). This is a P2 readability/UX issue to fix or explicitly validate at small phone widths.
- Status: screenshot review completed for these three artifacts only. Backup/Restore and People jobs were not yet complete at the checkpoint; full exact-main Device Smoke and physical-device acceptance remain pending.


## Live checkpoint 2026-10-12
No new owner installation, physical-device result, screenshot, or acceptance was supplied in this execution. Do not fabricate an installation/version/device record. Exact-main emulator runs are stale/incomplete; Calendar, Backup/Restore, RTL/compact-screen and golden-flow acceptance remain open.


## Wave 4.16 — Follow-up Reminder contract regression coverage — 2026-10-19

Added repository-level regression cases in PR #2833 for Persian Reminder title fallbacks and title-only Follow-up edits preserving the linked Reminder identity and scheduled time. This change is test coverage, not yet a verified user-facing acceptance result; wait for Build and Device Smoke runs on the resulting candidate SHA. Existing UI and ownership decisions remain unchanged.


## Wave 4.17 UX regression note — 2026-10-19

The Reminder runtime had a lifecycle mismatch: completed FollowUps were excluded from future alarm planning but could still be selected for delivery when their scheduled time had passed. A focused guard now prevents stale notifications while preserving the completed FollowUp and its history; a regression test was added in commit `9b7386dd32dc545b20a1b9a267cbbb1e8cc7490b`. User-visible behavior is not marked verified until the post-fix CI test passes. Release remains **BLOCKED — RELEASE: NO-GO**.


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


## 2026-10-19 — Wave 4.18 Calendar Provider acceptance failure

- Evidence: [Provider run 39245131251](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39245131251) failed during event UPDATE with a native Calendar Provider write exception.
- User impact: automatic Calendar synchronization cannot be considered accepted until update-by-stable-event-identity succeeds and the complete lifecycle is demonstrated.
- Change: native update now verifies calendar ownership and targets the exact event URI without an extra selection, commit [3cc2b4551ea5c30903a697cdff3b3450e6bf609f](https://github.com/mobinpda-lab/Arvin-clean/commit/3cc2b4551ea5c30903a697cdff3b3450e6bf609f).
- Status: IMPLEMENTED_NOT_VERIFIED; fresh CI and real Provider lifecycle evidence required. No claim of physical-device acceptance.


## Wave 4.19 execution update — 2026-10-19

- PR #2833 remains OPEN / DRAFT / UNMERGED. Source head at evidence collection: `0b1a97c4a71dd95b0cf4c59a265b8928a217cb70`; Build and Calendar Provider Actions checkout SHA: `bf4f1a94f515c213f0630b6c642451d73ab17a4c`, the synthetic PR merge of the source head into base `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. These are merge-candidate results, not Exact-SHA proof for the branch head.
- Build [39252493984](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252493984) completed SUCCESS, 9/9 jobs (Analyze, test shards 0–5, Debug APK, Release APK). Debug artifact [12186790429](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12186790429), digest `sha256:baa2062d28c7f685447dd0fb5ca20a00958aaee26d8c760aa00627867540f87b`; Release artifact [12185434678](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/12185434678), digest `sha256:b4683f64eb5c8e2c170f33f4cb9c9995c854cfe160e0463672099d8f435ee7df`. The Exact-SHA step was skipped.
- Calendar Provider Acceptance [39252494348](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494348) completed SUCCESS on the merge SHA. Artifact [12186224225](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494348/artifacts/12186224225), digest `sha256:7b2dbaeee8ad6caccca1d9438808af289e7960fb1f42c8f6ee5d35e59a7ee911`. Its `environment.txt` confirms Android API 35, CalendarProvider2 installed, seeded writable calendar ID 1 (access level 700), `CHECKOUT_SHA=bf4f1a94f515c213f0630b6c642451d73ab17a4c`, and `PR_HEAD_SHA=0b1a97c4a71dd95b0cf4c59a265b8928a217cb70`. The real-provider test emitted `RESULT=PASS_REAL_PROVIDER_CREATE_NOOP_UPDATE_DELETE`; one writable calendar was available, so two-calendar destination migration was explicitly limited, not passed.
- Device Smoke [39252494030](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39252494030) was still in progress at last poll: Home, Quick Capture, SQL Persistence and SQL Migration SUCCESS; People and Backup/Restore IN_PROGRESS; Calendar QUEUED. This is not a 7/7 pass and may be superseded by the next candidate update.
- Review found a test-coverage gap in the existing provider acceptance: NO-OP counters were asserted without re-querying the real provider for event uniqueness/identity; the multi-calendar cleanup path did not query final provider state. The existing test is being strengthened to assert exactly one event after CREATE and NO-OP, preserve event ID, and verify provider absence after DELETE in the migration path. Fresh CI validation is required.
- Exact-SHA remains BLOCKED: no authorized workflow-dispatch action is exposed in connected GitHub tools; normal PR workflows checkout the merge ref and skip `Verify exact requested revision`. Official signing remains BLOCKED: `main/android/app/build.gradle.kts` configures Release with the Debug signing key and no approved certificate fingerprint/authorized key has been verified. Release remains `BLOCKED — RELEASE: NO-GO`; no merge, tag, or release.

User-facing contract status: Follow-up Reminder Repository/Projection/model/migration/Backup-restore tests passed on the Build merge candidate. End-to-end scheduling behavior and integrated device acceptance remain subject to fresh CI and completion of the smoke lanes.


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

## Wave 4.25 — live GitHub verification checkpoint (2026-10-19)

- Live PR #2833 remains OPEN / DRAFT / UNMERGED. Source branch HEAD verified as `8e0e36eb4fda7bd45f45c463a1092d79c56f4e9`; base SHA `49910e585ee73afcf56a7f8d927b9c69e763c5c5`.
- Current-head Build [39279795513](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39279795513), Device Smoke [39279795764](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39279795764), and Calendar Provider Acceptance [39279795585](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39279795585) are still returned by GitHub run metadata as `queued` with no conclusion. Do not mark Analyze, six test shards, Debug/Release build, any of seven device lanes, or Provider lifecycle PASS on the strength of these run summaries.
- Artifact API nevertheless reports artifacts linked by `workflow_run.head_sha=8e0e36eb4fda7bd45f45c463a1092d79c56f4e9`: Build Release artifact ID `12200766920`, archive digest `sha256:32621f1871b44231a98b1fc1f1c21592e6c9238c37f714421a4590b4ccb099f5`; Build Debug artifact ID `12198609222`, archive digest `sha256:5f46381a29cab192ac4ed07aa830f81d29a2fe9b3e38df844c2d55c099a8dc59`; Provider evidence artifact ID `12199769292`, archive digest `sha256:9e66a1ab0bfb7818af81b09a74d10fff08d5b25f5ce5787ec2ab5faa849a02f6`. Device Smoke artifacts linked to the same run: People ID `12201786697`, digest `sha256:7f5749ddb566d2261264c6ba5b69b9a7d3a51bd859839192be78b465aa9766ac`; Quick Capture ID `12200436029`, digest `sha256:a3f1fd398f8a49f3839d0e2246542f89dbbadb1da285fb022a0b2292b2aef251`; Home ID `12200371212`, digest `sha256:ee4016473c500ae44f94080316bc439291d940f0a2bcf1df41a18efdd7da5286`; Persian time picker ID `12199867439`, digest `sha256:9b259b150700d8a0d467d5e6761eb0fc3a7a1d9451261eb4c5f8f882c21676c1`. These digests identify artifact ZIP archives, not extracted APK bytes. The mismatch between queued run state and artifact presence is unresolved; treat all test/build outcomes as NOT VERIFIED until terminal job logs are available.
- Reminder payload and parent-Task routing changes in `8e0e36e` have not yet obtained verifiable terminal Build/test or device-tap acceptance. Existing notification service classes also call `initialize` without a tap callback; whether that reinitialization overrides the app callback must be checked against actual plugin behavior and tested, not assumed.
- Exact-SHA remains BLOCKED for this HEAD: `.github/workflows/build.yml` has a `workflow_dispatch.target_sha` checkout/assertion path, but connected GitHub actions expose no workflow-dispatch operation. Owner must dispatch the existing workflow with the exact current SHA and provide run logs showing checkout and `EXACT_TARGET_SHA`.
- PDF acceptance remains NOT VERIFIED: the existing renderer uses VazirHarf and `pw.MultiPage` with RTL, but the current test injects Helvetica and only checks PDF bytes. No visually reviewed multi-page PDF artifact is confirmed. Official Release signing remains BLOCKED because `android/app/build.gradle.kts` still uses `signingConfigs.getByName("debug")`; no authorized keystore or independently approved fingerprint was supplied.
- No source-code regression was confirmed from the queued workflow metadata alone; no unverified fix is being claimed. Next action is to restore/obtain terminal CI job evidence for this exact SHA, verify notification callback initialization behavior, then run focused tests and device-tap acceptance. Keep release `BLOCKED — RELEASE: NO-GO`.


## Wave 4.25 — live evidence reconciliation (2026-10-19; parent SHA 4875d93f03d3afb21f888a0873021b5b4abba943)

- PR #2833 remains OPEN / DRAFT / UNMERGED; base `fix/follow-up-record-authority-20261019` at `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. This entry is tied to parent SHA 4875d93f03d3afb21f888a0873021b5b4abba943; this documentation commit creates a new candidate SHA and requires fresh validation.
- Historical baseline runs: Build [39279795513](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39279795513) has 9/9 jobs SUCCESS, but the exact-target assertion was SKIPPED. Its Release APK artifact is ID `12200766920` (ZIP digest `sha256:32621f1871b44231a98b1fc1f1c21592e6c9238c37f714421a4590b4ccb099f5`) and Debug artifact ID `12198609222` (ZIP digest `sha256:5f46381a29cab192ac4ed07aa830f81d29a2fe9b3e38df844c2d55c099a8dc59`). These belong to old source SHA `8e0e36eb4fda7bd45f45c463a1092d79c56f4e9`; ZIP digests are not extracted APK SHA-256 values.
- Historical Device Smoke [39279795764](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39279795764) is not a full pass: Home, Quick Capture, SQL Persistence, SQL Migration and Backup/Restore are reported SUCCESS; Calendar is CANCELLED; People job API state remains inconsistent with its successful test log/artifact. Historical Calendar Provider [39279795585](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39279795585) has direct log assertions for CREATE count=1 event 3, NO-OP same event 3, UPDATE same event 3, migration to calendar 2 creating event 4, DELETE target absent, unrelated events 1 and 2 preserved, and `CALENDAR_PROVIDER_ACCEPTANCE=PASS`. Run conclusion says success, but evidence is still for old SHA `8e0e36e`, not the current candidate.
- Fresh runs for candidate `4875d93f03d3afb21f888a0873021b5b4abba943`: Build [39282588754](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39282588754), Device Smoke [39282588770](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39282588770), and Provider [39282588748](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39282588748) have run/job metadata still showing QUEUED/IN_PROGRESS while job logs/artifacts exist. Treat this GitHub status/log inconsistency as unresolved and do not claim overall terminal PASS.
- Fresh Build logs include `No issues found!`; Debug APK artifact ID `12201152707` (ZIP digest `sha256:1113be566b8daa5c72dfd451ea27a753aed39f3ab0aa91ac879afc5e71cc8c61`) and Release APK artifact ID `12200834485` (ZIP digest `sha256:54ce12bfeedd4a14ee9c4fa1121181e07296aba69674313baf0b59e41e460016`) were uploaded. Six test-shard terminal conclusions are not returned by the run/job API; keep the complete Build gate NOT VERIFIED. Exact-target assertion was SKIPPED on this PR-triggered run.
- Fresh Device Smoke log evidence: Quick Capture test PASS (artifact IDs `12202885348`, ZIP digest `sha256:3f22ade766b1bbcaf24fe5971d3b297578f2f521310d48fea8f9e4d4055886f8` and Persian time-picker ID `12201182565`, ZIP digest `sha256:979bf6eb90c5b820c76e8ff163134378f8b28857b4df8b46bcb4c334dcf74fd6`); SQL Persistence PASS; SQL Migration PASS; Backup/Restore PASS; People PASS (artifact ID `12201378970`, ZIP digest `sha256:10642bf5a83451631b9bacadc82f6a169bbeb62d2f6e7962cc7d1d7a78c69b72`). Home failed before the smoke test because Android SDK system-image download reported `Error on ZipFile unknown archive`; this is an infrastructure failure, not evidence of an app assertion failure. Calendar lacks complete acceptance evidence; expected screenshot artifacts were not produced and the lane is NOT VERIFIED. Do not transfer these PR-run results to a later SHA.
- Fresh Provider log for run [39282588748](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39282588748) directly prints the same CREATE/NO-OP/UPDATE/DELETE and two-calendar migration assertions with `CALENDAR_PROVIDER_ACCEPTANCE=PASS`; artifact ID `12201482721`, ZIP digest `sha256:1b357462abbc2fdc9442e6a1272faa338d278a1887e8233226ff5237cb706503`. Because GitHub still reports the job/run QUEUED, classify formal Provider gate as IN_PROGRESS/NOT VERIFIED until terminal status reconciles, while retaining the direct test output as provisional evidence.
- Exact-SHA remains BLOCKED: existing `.github/workflows/build.yml` supports `workflow_dispatch.target_sha`, but no dispatch action is exposed in the connected GitHub tools. The PR-triggered run skipped `Verify exact requested revision`; the owner must dispatch the existing workflow for the final SHA and preserve `git rev-parse HEAD` / `EXACT_TARGET_SHA` logs.
- Reminder/notification tap, cold-start destination, deleted/missing record handling and full end-to-end product acceptance remain NOT VERIFIED. Existing service classes initialize local-notification plugins without a tap callback; inspect/test callback ownership rather than assuming it is a confirmed defect. PDF visual acceptance remains NOT VERIFIED: the current renderer uses VazirHarf and RTL MultiPage, but the existing test substitutes Helvetica and checks only PDF bytes; no reviewed multi-page PDF artifact exists. Release signing remains BLOCKED because `android/app/build.gradle.kts` still selects the Debug signing config for Release and no authorized keystore/approved fingerprint is available.
- Decision: `BLOCKED — RELEASE: NO-GO`. Keep PR Draft; no merge, tag or release. Next: reconcile/poll run/job conclusions, rerun only failed infrastructure lanes if GitHub permits, then dispatch exact SHA and complete notification-tap, PDF visual, and signing gates.


## Wave 4.50 — Repeat Checklist Evolution (2026-10-20)

- **Contract:** checklist template edits preserve all occurrence snapshots before the effective local calendar day. For a recurring Task, stored checklist snapshots on the effective day and later are rebuilt from the changed template with all items unchecked. Existing occurrence keys, Task identity, and independent `occurrenceHistory` lifecycle state (`completed`, `cancelled`, etc.) must remain unchanged.
- **Code audit on PR #2833 head `f492f03a579bce9032520d2b5534f63a4eec46d5`:** `TaskEditApplyService.apply` updates `Task.checklist` but does not rebuild `checklistOccurrences`; `TaskRecurrenceRepository.checklistForOccurrence` returns an existing stored snapshot before consulting the template. This is a confirmed implementation gap, not a runtime acceptance result.
- **Occurrence identity:** the current model uses ISO-8601 scheduled datetime strings as `checklistOccurrences` keys; Checklist Items are strings without independent item IDs. Malformed legacy keys are conservatively preserved because their date boundary cannot be established safely.
- **Live CI before Wave 4.50 changes:** Build run [39374346739](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39374346739) completed success, but `Verify exact requested revision` was skipped and checkout was synthetic merge SHA `046c832656469f0c17da88c5885fa11dc023a797`; it is not exact-head evidence for `f492f03a579bce9032520d2b5534f63a4eec46d5`. Device Smoke run [39374346710](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39374346710) was queued at the latest poll. Do not commit to this branch while its `cancel-in-progress: true` Device Smoke concurrency group is active/queued.
- **Acceptance status:** checklist regression, canonical-storage reload, real process restart, repeat idempotency, and backup/restore remain **NOT RUN / NOT PROVEN** until the new source SHA has terminal test evidence. No real seven-day Task or physical-device data was created by this audit.
- **Release:** `BLOCKED — RELEASE: NO-GO`. No merge, tag, or release authorized.


## Wave 4.50 — additional live gate reconciliation (2026-10-20 05:39 UTC)

- **Build:** Run [39374346739](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39374346739) is `completed/success`; its Release APK job and test jobs skipped `Verify exact requested revision`. Job log checkout was synthetic merge SHA `046c832656469f0c17da88c5885fa11dc023a797`, not the PR head SHA. Artifacts include Debug APK ID `12242608232` and non-official Release APK ID `12242917172`; neither establishes official signing or exact-head acceptance.
- **Calendar Provider:** Run [39374346742](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39374346742) completed success on the same synthetic merge checkout. Job log directly records CREATE count 1, UPDATE, destination-calendar migration PASS, and DELETE target absent. This is valid provider-lifecycle evidence for that checkout only and is unrelated to Checklist acceptance.
- **Device Smoke:** Run [39374346710](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39374346710) remains non-terminal. As of this checkpoint, Home, Quick Capture, SQL Persistence and SQL Migration jobs succeeded; Backup/Restore and Task Lifecycle were in progress; People and Calendar were queued. The workflow concurrency is `group: arvin-device-smoke-${{ github.event.pull_request.number || github.ref_name }}` with `cancel-in-progress: true`; do not move PR #2833 head while this run is active.
- **Independent release gates:** Live `main` `android/app/build.gradle.kts` blob `aaeea7506885814cc4c4a65ac6559872a80146a8` still sets Release `signingConfig = signingConfigs.getByName("debug")`. Official signing is BLOCKED. Exact-SHA remains BLOCKED because the successful PR Build did not execute its exact-requested-revision assertion; no exact target-SHA dispatch result is available here.
- **Checklist acceptance:** No dedicated seven-occurrence checklist fixture, real app-process restart of checklist state, or checklist backup/restore result exists for this pre-fix checkout. The source gap above remains open until the patch is committed and new exact-source tests are terminal.
- **Release:** `BLOCKED — RELEASE: NO-GO`; no merge, tag, or release.


## Wave 4.50 — legacy release path audit

- Live `main` workflow `.github/workflows/release.yml` (blob `c5f45b9b1d66db22a585b0637a24537aeb95d098`) still has `contents: write` and invokes `softprops/action-gh-release@v2` with caller-provided `inputs.version`. The fail-closed replacement exists only in draft PR #2817 head `5b5d83e75499cd3b890c06835d1c90220c2b65de`; it is not merged. This legacy mainline path is an independent release-governance blocker.
- Do not run or promote the legacy release workflow. Keep PR #2817 draft/unmerged until its hardening and independent owner approval are reviewed. **RELEASE: NO-GO.**

## ARVIN WAVE 5.11 — Checklist UX checkpoint (2026-10-20)
- The repeating Task Checklist is now presented by the same `OccurrenceChecklistEditor` in Task Details and Repeat. The user explicitly selects the occurrence date before its checklist is loaded, avoiding a guessed date/key. Dates use the existing Persian/Jalali formatter.
- Saving a tick goes through the canonical TaskRecurrenceRepository and reloads that occurrence's persisted checklist. The shared generic checklist template is not changed by the repeating Task detail interaction.
- Implemented commits: `8f1efd1de21c0954fa14bd66ce5a487814dec891`, `2780e8902a4fddf444c2135f537b821e32d3e73a`, `7eb93299cb425597aab1ebb227e898c32793b327`, `ba206df93f57846179291be81efbffdc0f6b0023`, `202639c132a50ea3b0025b82b68562e395c55f61`; test commits `f8fabc8aba08aa54ce146851e17853326880c794`, `08f610f5442aa9c822e0645458d0ef438f7321ef`.
- UX status: implementation recorded; runtime behavior, screen-reader/RTL overflow, selected-date reopen, independent sibling occurrence state and actual storage round-trip are NOT PROVEN until current-head tests/device acceptance run.
- No product release or approval was made. **BLOCKED — RELEASE: NO-GO**.


## Wave 5.14 user-experience acceptance checkpoint — 2026-10-20
### Product behavior being verified
- A Checklist tick belongs to one selected Repeat occurrence and must not mutate the shared Task template.
- Saving an occurrence updates the canonical Task in the Detail and Home in-memory states. This prevents a later template edit from overwriting occurrence-specific snapshots with stale Task state.
- After changing the shared template from A/B/C to A/B/D, the mounted occurrence editor reloads the selected occurrence from canonical storage.
- The Android acceptance scenario creates the Task through UI, anchors it four local days in the past, saves seven snapshots through the UI, gives four past occurrences distinct tick patterns, and checks that those four snapshots remain unchanged while today/future become unchecked A/B/D.
- Lifecycle history is tested separately from checklist state; the same Task ID, full Task JSON, relationships, record count and occurrence history are saved before process restart and compared by the second integration test after force-stop and relaunch.

### Evidence state
The new scenario and restart-snapshot comparison are committed, but they are NOT RUN on the current HEAD. Existing Device Smoke evidence belongs to a stale PR head commit and cannot be used as current product acceptance. The official backup/restore test is still NOT VERIFIED because the current harness injects a file-backed service rather than using the real SAF/provider path.

### User-facing outcome
Do not mark Checklist/Repeat as accepted until the current-head Device Smoke run passes, all seven occurrence rows show the expected before/after data, no duplicate records appear, and the real restart verifier proves the same Task ID and full store snapshot survived. Do not describe the temporary-file backup harness as official backup/restore.


### Checkpoint correction
The full snapshot/restart-verifier code is present in the source chain through `b15b0c0...`. A Build Run for that prior source SHA exists but is only QUEUED. The live PR HEAD is now the docs-only commit `49f69caf...`; no exact-head Build or Device Smoke acceptance is confirmed. The user-visible Checklist/Repeat behavior remains NOT VERIFIED until current-head Device Smoke passes.


## Wave 5.14 final documentation checkpoint — 2026-10-20 13:47 UTC
Immediately before this documentation-only append, live PR HEAD was `7828b825d8e9fb50b0fe0b41a239c140454b3dd0`; base SHA remained `49910e585ee73afcf56a7f8d927b9c69e763c5c5`. Build Run `39432745217` for prior source SHA `b15b0c0...` was QUEUED, and Run `39432344723` for `0b42e588...` was IN PROGRESS. Recovery Dispatcher job `118663216037` was QUEUED; no exact-SHA result for the live HEAD was confirmed. Treat these as separate revisions and do not convert any queued/in-progress run into PASS. The resulting documentation-only HEAD also requires its own exact-SHA Build if exact revision closure is claimed.


### Revision provenance correction
The previous Build and Device Smoke run used an old PR source commit `6d78b1cba4d0ec829fe26325c9233cd30100d766`, not a synthetic merge commit. It was 23 commits behind `266b2a58...` at this correction checkpoint; none of its device results prove the updated Checklist/Repeat flow.


## Post-run evidence update — 2026-10-20 13:55 UTC
- Build Run [39432745217](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39432745217) completed SUCCESS on exact source target `b15b0c09ec718459b3702e63b2c38701f0291293`. Every Job's `Verify exact requested revision` step passed. Analyze, Test shards 0–5, Debug APK, and Release-variant APK all passed.
- Job IDs: Analyze `118661728356`; Test-0 `118661728445`; Test-1 `118661728687`; Test-2 `118661728428`; Test-3 `118661728375`; Test-4 `118661728381`; Test-5 `118661728619`; APK Debug `118661728193`; APK Release-variant `118661728559`.
- Release-variant artifact: [Run 39432745217 / artifact 12269333049](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39432745217/artifacts/12269333049). Downloaded APK SHA-256: `0e13c02e50d1f6871758fe47d82cf4921da15b87b9aabbb6d77970c280b032a2`; uploaded artifact ZIP SHA-256 from the Job log: `c26189789f50da7cec6bd8b086d726ce369b54013f3e260554edf235f29761e6`. This is a non-official Release-variant artifact using Debug signing because `ARVIN_OFFICIAL_RELEASE` was not enabled; do not publish it.
- Important workflow provenance: this Run was dispatched by the default-branch recovery dispatcher, so its workflow definition came from main SHA `d9fb7a247037762216662a20fb32028ecc8a0f6b`, while its source checkout was exact target `b15b0c0...`. The PR branch's `.github/workflows/build.yml` contains an additional fail-closed signing test and non-official artifact naming not present in the main workflow version. Therefore the branch's own workflow definition still needs a manual branch-selected Build dispatch with `target_sha` equal to the live PR HEAD.
- At this update, Run [39433741028](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39433741028) for previous docs HEAD `266b2a58...` was still QUEUED. The Recovery Dispatcher job `118667403566` was QUEUED to scan live PR heads. No terminal Build result for the then-live docs HEAD `bfc499fc...` was confirmed.
- The code/source validation at `b15b0c0...` is PASS; current-head Device Smoke, Calendar Provider, official SAF Backup/Restore, official signing/fingerprint/apksigner, and release approval remain open.


## Wave 5.17 — user experience / design reference note (2026-10-20)

### Repeat and occurrence semantics
- The seven-occurrence UI scenario (four past, one current, two future; baseline A/B/C and updated A/B/D) was **not executed**. No Task ID, seven actual occurrence keys, checklist state, history rows or record counts were captured. Product acceptance remains BLOCKED.
- Joplin Repeating To-Dos documents configurable intervals (minute/hour/day/week/month/year), weekday and month-day selection, stop conditions, overdue policies, and a startup sweep to recover missed alarms. Its completion flow advances the same to-do, unmarks it complete and resets subtasks; this differs from Arvin's requirement to retain separate occurrence history/checklists. Treat only as a UX reference.
- TimeJot's help page explains that OS-level device backup can omit photos and recommends daily export/import for a more complete, user-controlled backup. Its changelog describes ZIP export containing the database and photos. Arvin should distinguish device backup from an independently exportable, restorable archive and prove that restore retains Task/Occurrence identity and relationships.
- Persian Calendar is an Android app under GPL-3.0. Use it only to compare Persian calendar UX and boundary behavior; do not copy implementation code without a license-compatibility review.

### Calendar and local-time acceptance
- No real writable Calendar Provider CREATE → NO-OP → UPDATE → calendar transfer → DELETE sequence was executed on this HEAD. Mock/provider harness success is not user-facing acceptance.
- No Restart/PID test or real Backup/Restore of the same Task was executed because this environment has no attached Android/ADB device.
- No new UX behavior is accepted in Wave 5.17. Do not change the product contract or mark the release ready based on these reference comparisons.


## Wave 5.21 — user-facing acceptance status (2026-10-20)

- Build evidence is strong but narrow: exact target `3ce1d46b80d4842890b6759583dbf685deaeafde` passed all 9 jobs in Run [39445690981](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39445690981). This does not mean the UI flow, persisted occurrence history, or restore path was exercised on a device.
- No current-head Device Smoke was found. The latest returned PR-branch smoke run #39416899883 was cancelled on an older SHA. Do not present its partial lane results as current acceptance.
- The required A/B/C → A/B/D Checklist scenario was not driven through the real UI. No seven occurrence keys, checkmark snapshots or duplicate counts were captured; product behavior remains unaccepted.
- Restart and Backup/Restore were not run against the same real Task. No PID transition or post-restore snapshot exists.
- Calendar Provider lifecycle is not accepted without a writable provider and observed CREATE, NO-OP, UPDATE, calendar transfer and DELETE while preserving unrelated events. A green workflow harness alone is insufficient.
- Official signing is not verified. APK build/upload success is not proof of trusted signing; ZIP digest must not be represented as APK SHA-256.
- Design reference review: [Persian Calendar](https://github.com/persian-calendar/persian-calendar) declares GPL-3.0-or-later, so use only as behavior/UX reference unless license compatibility is approved. [Joplin Repeating To-Dos](https://joplinapp.org/plugins/plugin/com.github.TheScriptingGuy.joplin-plugin-repeating-todos/) resets the same to-do on completion and clears subtasks, unlike Arvin's independent occurrence history; do not copy that state model. [TimeJot Help](https://timejot.app/help/) distinguishes OS device backup from daily export/import that includes entry photos; Arvin's own restore still requires empirical acceptance.
- Wave 5.20: no corresponding issue or commit record found in queried GitHub surfaces. No external execution is inferred.
- Release remains **BLOCKED — RELEASE: NO-GO**.


## Wave 5.21 — Calendar Provider artifact review (2026-10-20)

- Artifact [12262580173](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39416899861/artifacts/12262580173) was downloaded and its three files read. It confirms real Provider CREATE, NO-OP, UPDATE, calendar migration (source ID 1 to destination ID 2), DELETE, and retention of unrelated sentinel events in both calendars.
- Provenance is old: checkout SHA `2494062c1a1219276a3d97c799d1996990506716`, PR head `6d78b1cba4d0ec829fe26325c9233cd30100d766`. This is a positive historical integration result only; it does not close the final current-head Calendar Provider gate.
- Joplin's repeat model remains a reference only because it resets the same todo/subtasks; Arvin must preserve independent occurrence state. TimeJot's Help distinguishes OS backup from export/import. Persian Calendar declares GPL-3.0-or-later; do not copy code without license compatibility approval.
- Current-head acceptance and release remain blocked.


## Wave 5.22 — Canonical product vocabulary and UX contract (2026-10-20)

- Canonical product concept and acceptance reference: [ARVIN_PRODUCT_CONCEPTS.md](../product/ARVIN_PRODUCT_CONCEPTS.md).
- The reference distinguishes Task, occurrence, checklist template, occurrence checklist state, FollowUp action, reminder scheduling and notification delivery, external Calendar Event, and Backup versus Export/Restore. UX and copy must not collapse these concepts into one status.
- Persian UI expectations include Jalali display, Persian digits where configured, RTL, readable large text, explicit validation/error recovery, and safe date-only/all-day presentation. These are acceptance targets, not claims that all screens passed visual testing.
- Reference review notes: Joplin recurrence behavior is not to be copied because it reopens the same todo and resets subtasks; TimeJot documents a distinction between device backup and daily export/import; Persian Calendar is a behavioral reference only and no code/assets were copied. See the canonical document for access date and license caveats.
- No product UI/runtime change was made in this documentation task. RTL/device acceptance, notification routing, seven-occurrence checklist behavior, restore, PDF visual quality and Golden Flow remain NOT VERIFIED unless separate SHA-bound artifacts prove them.
- Release remains **BLOCKED — RELEASE: NO-GO**.

## Wave 5.35 — Live evidence checkpoint (2026-10-20)

- No new physical-device evidence was collected in this execution. The two cancelled emulator smoke scenarios do not establish whether Task lifecycle or Checklist evolution passes or fails on a physical device.
- **Checklist evolution:** NOT VERIFIED until one actual daily Task with seven Occurrences is edited A/B/C → A/B/D and canonical before/after snapshots prove historical occurrences and checkmarks are preserved, new/current/future checklist behavior is correct, Repeat creates no duplicate, and relationships/history remain stable.
- **Restart and backup/restore:** BLOCKED pending real Android process/PID evidence and a supported backup/restore round-trip on the same accepted Task. Generic emulator success is not a substitute.
- **Release:** BLOCKED — RELEASE: NO-GO.


## Wave 5.36 — User-experience acceptance checkpoint (2026-10-20)

- CI workflow changes improve revision traceability but do not demonstrate user-visible acceptance.
- Checklist evolution is still unverified: no same-Task evidence proves that changing A/B/C to A/B/D preserves the four historical occurrences and checkmarks, applies new options only to intended occurrences, and prevents duplicate occurrences on Repeat.
- Restart and restore are still blocked without an authorized device session and before/after canonical storage snapshots. No PID or Task-identity preservation claim is made.
- Persian RTL/date display, notification routing, PDF output and regression acceptance remain NOT VERIFIED for the current final revision until SHA-bound artifacts are reviewed.
- **Release:** BLOCKED — RELEASE: NO-GO.


## WAVE 5.53 — evidence update (2026-10-21)

- Live default branch `main`: `d9fb7a247037762216662a20fb32028ecc8a0f6b`. CI PR #2868 remains OPEN / DRAFT / UNMERGED; head branch `fix/exact-sha-dispatch-contract-20261021`, head SHA `315923c1cbf6bfb8f661949a4fca18e304ae51ea`, base `main` at `d9fb7a247037762216662a20fb32028ecc8a0f6b`. Product PR #2833 remains OPEN / DRAFT / UNMERGED; head branch `wave-4-10/follow-up-reminder-contract`, head SHA last reported by PR metadata `992699f87715db3642dfbc56ab3def32800e5104`. No PR was merged.
- Historical Build [39543365234](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39543365234), Job [119035976068](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39543365234/job/119035976068), failed in `test/device_smoke_workflow_contract_test.dart`: test `Build and Device Smoke enforce exact-SHA controls per runner job`, assertion at line 263 expected `officialReleaseRequested` in `android/app/build.gradle.kts`; 196 tests passed and 1 failed. The command was `flutter test --total-shards 6 --shard-index 4`. This is a missing-security-control assertion in the checked-out run revision, not a reason to weaken the test.
- The current CI PR head's `android/app/build.gradle.kts` contains an explicit `ARVIN_OFFICIAL_RELEASE=true` gate, nonblank validation for store file/password/key alias/key password, a dedicated `arvinProduction` signing config for explicit official builds, and a Debug signing path for non-production builds. This code-level inspection is not independent proof that any APK is officially signed; no approved certificate fingerprint has been verified.
- Current Build run [39547647963](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39547647963), associated with CI PR head `315923c1cbf6bfb8f661949a4fca18e304ae51ea`, finished successfully: Analyze, `test-0` through `test-5`, Debug Build and Release Build all passed. This was a pull_request event, not an Exact-SHA Dispatch.
- Current Device Smoke run [39547648453](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/39547648453) had successful main emulator steps for `home`, `quick-capture`, `sql-persistence`, `sql-migration`, `backup-restore`, `people`, and `calendar`. The main steps for `task-lifecycle` and `checklist-evolution` were `SKIPPED`; their acceptance remains BLOCKED. Calendar smoke does not prove independent Calendar Provider lifecycle acceptance.
- Exact-SHA Dispatch remains `BLOCKED — DISPATCH UNAVAILABLE`: the connected GitHub tools expose no workflow_dispatch action. PR CI must not be represented as exact-SHA dispatch evidence. APK signature verification and independent certificate fingerprint matching remain `NOT VERIFIED`. Release remains `BLOCKED — RELEASE: NO-GO`.
- Product capability rule: code existence and successful unit/device smoke are distinct from acceptance. Preserve Task/Repeat/Occurrence, Checklist history, SQL persistence/migration, Restart, Backup/Restore, notifications, Calendar Provider, Persian PDF/RTL, Golden Flow and P0/P1 regressions; do not infer removal from missing evidence. Unknown acceptance and product trade-offs remain **نیازمند تصمیم مبین**.


## WAVE 5.54 — Product Acceptance Notes (2026-10-21)
- Device Smoke Run `39547648453` gives primary-step success for Home, Quick Capture, SQL Persistence, SQL Migration, Backup/Restore, People and Calendar. Task Lifecycle and Checklist Evolution were explicitly skipped by the workflow guard; their user-visible behavior is not newly accepted by this run.
- Task Lifecycle source uses the actual Arvin UI and checks a single identifiable Task through creation, edit and completion. The runner's restart path force-stops the app, records the old PID, verifies process absence, launches the package, requires a different new PID, and starts a separate persistence verifier. These runtime steps have not been observed in a successful device run yet.
- Checklist Evolution source exercises the actual UI and checks A/B/C → A/B/D, seven occurrence snapshots, history preservation, idempotent Repeat evaluation, backup/restore and a saved pre-restart snapshot. The after-restart verifier has not run in an accepted exact-SHA dispatch.
- Preserve existing capabilities; mark these scenarios `IMPLEMENTED — ACCEPTANCE BLOCKED`, not removed and not PASS. Fresh CI Build/Device Smoke remained in progress at the time of this note. No product capability inventory is implied by these two scenarios.


## WAVE 5.55 — Acceptance Notes
- Build and Fast Lane passed. Seven device smoke scenarios passed their main emulator step on merge SHA `6040ca631cd3ed9dab9dcdafb55816bddc01990a`.
- Task Lifecycle and Checklist Evolution remain `IMPLEMENTED IN SOURCE — ACCEPTANCE BLOCKED`; their primary emulator steps were skipped. No actual PID values, post-restart Task state, or checklist occurrence snapshot comparisons were produced.
- Do not infer product regression or removal. Preserve current product implementation; exact-SHA authorized dispatch is the next acceptance action.
