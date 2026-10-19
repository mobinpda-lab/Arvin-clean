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
