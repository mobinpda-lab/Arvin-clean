## 2026-11-05 — Home test-2 regression diagnosis

- Historical test-2 failure on SHA 9d073ad: Home owner-reference test used an exact finder for the Jalali date alone, but the active Home header renders weekday + date together in one Text widget. It also expected the superseded Category label «دسته‌بندی‌ها».
- Corrected test/home/home_owner_reference_test.dart to assert the full dynamic weekday + Jalali date and canonical «دسته‌ها» label. The assertion is more precise; no case was removed or weakened.
- test-0 historical failure was independently traced to the Task fixture title colliding with the «گذشته» group heading; the fixture title was disambiguated and test-0 passed on baseline c35929c.
- Historical Task Details visual failure is a separate 10-minute pumpAndSettle timeout before screenshot/golden capture. Available logs do not reveal the unsettled frame source; root cause remains NOT VERIFIED. No timeout change, settle bypass or golden update was made.
- Calendar Provider attempt 1 on c35929c failed before tests because Dart Development Service did not start; retry attempt 2 was still in progress at last poll.
- The new Home test correction and all documentation commits require fresh CI on the live HEAD. No historical PASS transfers.

## 2026-11-05 — Issue #823 UI/UX evidence audit and Home label correction

- Re-read the live PR, authorized branch and main refs before work. Audit baseline was c35929c1cc2022b8470cd86b6f6fe8e2ae771e5b; PR head and branch matched; main remained 45e4202b03a434459e4c021a04efa7e8396359db.
- Audited the active Home path in lib/main.dart rather than relying on the legacy home_filter_ui enum. Corrected the active Category chip label from «دسته‌بندی‌ها» to the approved «دسته‌ها» and added an exact widget assertion in test/home/home_filter_contract_test.dart. Existing five-chip structure, separate sort action and internal panel «همه» option remain intact.
- Added docs/audit/ARVIN_ISSUE_823_UIUX_EXECUTION_AUDIT_2026-11-05.md with evidence/status matrix for Home, templates/Drift, Calendar and Task Details. It distinguishes code presence from exact-SHA test and device acceptance.
- Task Template implementation remains blocked pending an owner-approved independent template-definition contract. Schema v8 currently contains Project Template tables but no independent Task Template model/table/store. No parallel store or speculative migration was added.
- Settings currently routes to ProjectTemplateManagementPage; no independent Task Template tab or Task Details conversion path was verified. Existing Project Template generation and Task clone service were preserved.
- Task Detail canonical reference defines eleven sections; current runtime inline editor is partial and no exact scroll-offset preservation test was established.
- Home filter OR/AND behavior is visible in the active implementation but combined end-to-end OR/AND assertions remain required. Full dynamic group-date acceptance is incomplete; Today/Tomorrow derive from Iran-local time, while aggregate Future has no date suffix.
- Product Decisions now records the sacred-phrase Naskh/Vazirmatn question as BLOCKED for explicit owner clarification. Preserve current rendering until the owner confirms the narrow exception policy.
- Baseline c35929 CI snapshot: Analyze, test-0, test-1, test-3, test-4, test-5 and Follow-up file-backed SQLite SUCCESS; test-2 and Visual IN_PROGRESS; Device Smoke incomplete; Calendar Provider first attempt failed before tests due Dart Development Service startup (0 tests passed), then was rerun. These results are baseline-only and do not transfer to this documentation/code commit.
- No tests/assertions/scenarios were removed, skipped, weakened or timeout-bypassed. No main edits, merge or release. PR #3052 remains OPEN / DRAFT / UNMERGED; BLOCKED — RELEASE: NO-GO.

## 2026-11-05 — TaskHomeScreen workflow and regression contract alignment

- Restored the exact seven-lane Build quality matrix: Analyze + test-0 through test-5. Moved `test/task_detail_visual_test.dart` and its artifact upload to a separate standalone `visual` job with exact-SHA checkout verification; visual coverage is retained.
- Synchronized existing Home regression expectations with the approved fourteen-point Home specification: fully vocalized Bismillah, no Home-header notification bell, general-filter/menu RTL positioning, the canonical Past heading «گذشته», and search hint «جستجو در کارها...».
- Updated the Task Details completion-action color assertion to the owner-approved shared primary token `#3F3D56`.
- Updated the Vazirmatn source contract to assert the actual single-source `ArvinTheme.fontFamily` wiring and canonical bundled-font token declaration.
- Test cases and behavioral coverage remain present. No test file or case was deleted, skipped, bypassed, weakened, or timeout-bypassed. No product runtime code was changed in this alignment pass.
- Build, standalone Visual, Parallel Wave contract, and seven-path Device Smoke must complete on the new exact HEAD before any PASS is recorded. PR #3052 remains OPEN / DRAFT / UNMERGED; `main` unchanged; release BLOCKED — RELEASE: NO-GO.

## Quick Capture tighter visual compression — 2026-11-04
- Follow-up UI-only pass on the existing compact Quick Capture form. No field order, row membership, widget keys, horizontal selector structure, selected values, priority enum, color palette, Vazirmatn font family, semantics, callbacks, validation, task construction or persistence behavior was changed.
- Compact ArvinRollBox and ArvinTagRollBox controls reduced from 42dp to 40dp; compact icons reduced from 18dp to 16dp, icon/text gap from 6dp to 4dp, horizontal inset from 10dp to 8dp, compact label size from 11.5sp to 10.5sp. The 40dp minimum touch target is retained.
- Quick Capture cards reduced from 8dp to 6dp padding; top/bottom sheet padding tightened; title/header and description TextFields use dense decoration and reduced vertical content padding; inter-card/row gaps and horizontal gaps tightened without changing order.
- Four priority controls remain 40dp with the same Persian labels, explanatory helper row, colors and selected enum values. Footer actions remain at least 40dp and aligned in their existing row.
- Inner vertical scrolling remains as a safety fallback for keyboard, short screens and text scaling. A claim of zero vertical scrolling on every device is not made until verified on the physical SM-A528B/DS.
- Updated geometry test from 42dp to 40dp; no test/assertion removed, weakened, skipped or bypassed. Fresh exact-SHA CI is required.
- Physical before/after screenshot: NOT VERIFIED in this environment.
- PR #3052 must remain OPEN / DRAFT / UNMERGED; main untouched; BLOCKED — RELEASE: NO-GO.

## Quick Capture priority helper row refinement — 2026-11-04
- Four canonical priority chips now show only «اولویت ۱» through «اولویت ۴» in 40dp-high controls; the four existing explanatory labels appear in a separate compact helper-text row immediately below.
- Existing priority enum values, ordering, selected-state animation, color mapping, tap callbacks and Semantics labels (including the explanatory text) remain unchanged.
- This refinement supersedes the in-flight CI started on prior SHA `d83683e47c0d3f6c3ca3fdf10504bc93aebd39d0`; its results are not acceptance evidence for the final SHA.

## Quick Capture compact layout — 2026-11-04
- Scope: UI/layout only. Current form field inventory, order, keys and selection flow are preserved. No Task model, validation, draft-building, persistence, field names, callbacks, center/project relationship, reminder synchronization, recurrence mapping or priority values were changed.
- The existing description TextField remains present (compressed from 2–3 visible lines to 1–2); title placeholder remains «عنوان کار را وارد کنید». Header title and full-form shortcut remain.
- Existing two horizontally scrollable selector groups remain in their current order so every selector remains reachable on narrow screens: center/project/category/tag, then due date/reminder/recurrence. No selector was removed or hidden; horizontal scrolling remains intentionally available for narrow widths.
- Added opt-in compact presentation to `ArvinRollBox` and `ArvinTagRollBox`: 42dp control height, 18dp icons, 6dp icon/text spacing, 10dp horizontal inset, compact Vazirmatn-inherited labels with ellipsis. Existing popup menu items and callbacks are unchanged.
- Priority remains the same four `TaskPriority.values` with Persian labels and helper descriptions, existing color mapping, Semantics labels and selected state; only chip/card vertical padding, font sizing and line height were compressed. No P1–P4 codes introduced.
- Reduced card padding/vertical gaps, compacted title/header/description, and aligned «ثبت کار» + «لغو» in a 44dp-height footer row. Touch targets are asserted >=40dp.
- Bottom sheet remains `isScrollControlled: true`, now capped at 66% of screen height. The inner vertical scroll view remains as a fallback for smaller screens, keyboard display and accessibility text scaling; the intended 7-inch view is tested for compact geometry rather than claiming physical-device proof.
- Added/updated widget assertions for 42dp selectors, 40dp minimum actions, same-row footer, all existing selector keys, four priorities and preserved description. No tests/assertions were removed, skipped, softened or timed out.
- Physical before/after screenshots from Samsung SM-A528B/DS are NOT VERIFIED / not captured by this GitHub-only execution environment.
- Fresh CI must run against the final documentation-synchronized SHA. No previous SHA's result transfers.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main unchanged; **BLOCKED — RELEASE: NO-GO**.

## Task Details UI — final verification checkpoint update — 2026-11-04
- Final focused test adjustment: bottom completion action assertion now checks canonical `ArvinColors.primary` (`#4A4CAB`), not the darker AppBar shade. Commit: `b511d51d172a57656fdae12dd15ed559a27fcfb7`.
- The Task Details redesign remains limited to `lib/task_detail_page.dart`, `test/task_detail_master_screen_test.dart`, and these three continuity documents. No Task model, repository, DAO, persistence, alarm, calendar, or backend source was modified.
- The exact current branch HEAD must be read after this documentation sync. No workflow result is currently verified for the new Task Details implementation SHA; do not infer CI success from earlier runs.
- PR #3052 must remain OPEN / DRAFT / UNMERGED; main untouched; **BLOCKED — RELEASE: NO-GO**.

## Task Details visual redesign — 2026-11-04
- `a654da9262004b57fab591fcd2a72e48481e57f7`: set Task Details canvas to `#F5F6FA`; round the indigo AppBar bottom corners and add a back action; convert shared cards to white 16px rounded cards with subtle shadow; explicitly style Delete red outlined, Complete indigo filled and Edit indigo outlined; remove the «افراد مرتبط» UI block only.
- `dc6e2aa6a3af26f474b9b02c1ccb24742228208b`: retain the existing checklist controller/callback but present «افزودن مرحله جدید» as a full-width outlined action after the checklist rows. Progress fraction and bar remain intact.
- `43813096e93abd31388e1eceeb8dfef3fb3d4aba`: update focused test to assert avatar/people UI absence while proving `Task.people` data remains, and verify page/card/action styling.
- `86c6c9bbaaa8bc83626effb9aa52f6e52c94a3d0`: assert checklist progress bar and add-stage label.
- No Task model, repository, DAO, database, persistence, callback or business-rule code changed. No destructive data operation. No test removed/skipped/weakened.
- Exact-SHA CI for this implementation has not yet completed; status remains NOT VERIFIED.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release **BLOCKED — RELEASE: NO-GO**.

## Quick Capture test reconciliation — 2026-11-04
- Build run `41834832972` on SHA `2549a98ab6d3de3498ab17fc007debf34f105055`: Analyze PASS; Shard test-1 FAILED with 174 passed / 1 failed.
- Exact failure: `test/quick_capture_dialog_test.dart:321`, test `canonical capture keeps title-only path and optional choices`; the old assertion expected the approved description field to be absent. A second obsolete absence assertion existed in the full-form handoff test.
- Updated both finders to assert the description field exists and added empty-description assertions for title-only / no-description handoff. No test was deleted, skipped, timed out or weakened; the assertion now checks the newly approved UI contract.
- Test correction commit: `fdbb6f10bb2fed4233384478c74c86c9778def90`. All workflows on SHA 2549 remain evidence only for that older SHA; the correction requires a fresh exact-SHA run.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.



## Quick Capture verification checkpoint — 2026-11-04
- Focused test geometry was aligned with the new full-width submit and vertical cancel placement; tests explicitly ensure the priority selector and submit action are visible before interaction. No acceptance condition was removed.
- Removed the now-unused ArvinColors import from the focused test.
- Latest code/test SHA before this documentation update: `2349dc2cdffeae440e525a89842912d681123b26`.
- GitHub Actions run query for this SHA returned zero runs; commit status has zero contexts and remains pending. Analyze and all tests are NOT VERIFIED. CI must run on the final documentation-synchronized SHA before acceptance.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.
# Implementation and Evidence Log
Chronological evidence index. Root CHANGELOG.md remains the canonical chronological changelog; docs/ARVIN_CONTINUATION_LEDGER.md remains the detailed historical execution record.

## 2026-11-04 — Continuity deployment checkpoint
- Branch: fix/recovery-calendar-device-smoke-2026-10-31
- Starting/current observed HEAD before this documentation deployment: 33f9489b4c7f3fa6173459b6994cea2a5469f500
- PR #3052: OPEN / DRAFT / UNMERGED; base main SHA 45e4202b03a434459e4c021a04efa7e8396359db.
- Continuity directory was absent at the inspected branch HEAD; these documents establish its navigation and status structure.
- No application source code was changed as part of this documentation deployment.

## SHA transition 93a7c2b → ec4f23e
- GitHub compare confirms exactly one commit: ec4f23e9a3745f1c924f8f75d84e0b943591a1d2, parent 93a7c2ba4526c782306e42b19ba3b159f7c8a738.
- Commit message: restore compact empty-title feedback and record owner decisions.
- Source at 93a7c2b had only inline empty-title feedback. Source at ec4f23e has the same inline error plus a floating SnackBar; the existing test expects two visible occurrences. The implementation and test are aligned on ec4f23e.
- Build run 41797850701: SUCCESS, Analyze plus all six test shards SUCCESS; APK matrix SKIPPED.
- Draft Review APK run 41797850581: SUCCESS on ec4f23e.
- Calendar Provider run 41797850592: SUCCESS on ec4f23e.
- Follow-up File Persistence run 41797850655: SUCCESS on ec4f23e.
- Device Smoke run 41797850589: CANCELLED; not a seven-lane acceptance.

## Current observed HEAD 33f9489
- Build run 41805555476: SUCCESS; Analyze and six test shards SUCCESS; APK matrix SKIPPED.
- Follow-up File Persistence run 41805555397: SUCCESS.
- Calendar Provider run 41805555462: FAILURE before test execution because Dart Development Service failed to start while loading integration_test/android_calendar_provider_acceptance_test.dart; zero tests passed. This is an execution blocker, not proof of a product regression.
- Device Smoke run 41805555579: QUEUED at last observation; boot/navigation completed, quick capture/calendar lanes in progress, other lanes queued. No final acceptance.
- Draft Review APK run 41805393577: CANCELLED on older SHA b85ed7b6ac5140e877ce1bd0ece6eef2d4819b43; not current-head evidence.

## Previously evidenced Report Center work — SHA 9b52d43
- Top-level separate completed-follow-up report action removed; report remains reachable from unified Filters.
- Relevant tests passed and screenshots were captured/visually inspected on that SHA.
- Evidence does not prove every filter section or every combination and does not transfer to 33f9489 without rerun.
- See docs/ARVIN_CONTINUATION_LEDGER.md for exact test names, screenshot descriptions and workflow references.

## Calendar and P2P boundaries
- Calendar Provider success on ec4f23e and earlier SHAs is historical evidence only; current HEAD Provider execution failed before tests.
- Calendar projected-event deletion and canonical Task survival were tested on an earlier SHA as recorded in the Ledger. Whole external-calendar deletion and full physical-device lifecycle remain NOT VERIFIED.
- P2P is not verified as implemented. QR/PIN and LWW/tombstones remain proposals; device-local clock winner selection is not approved.

## Evidence rules
Every new entry must include exact SHA, workflow/run IDs, terminal conclusion, and whether the tests actually executed. Never carry a PASS forward to a later SHA.


## Device Smoke terminal correction — 2026-11-04
- Run 41805555579 on SHA 33f9489 concluded CANCELLED (not merely queued/in progress).
- Preparation, Boot, Navigation and Quick Capture succeeded. Reminder/Vazirmatn, Follow-up Persistence, Calendar Segmented View and Task Lifecycle were cancelled.
- No complete seven-lane Device Smoke PASS exists for this SHA. A fresh run on the current candidate is required.


## 2026-11-04 — Parallel UI scope reconciliation (owner directive)

- Audited exact branch HEAD `957924cd67066db06abe5fd15df2c802729aa3bb` before making changes.
- Report Center already has no independent top-level completed-Follow-up action; the report is selected inside the unified Filters sheet (`report-filter-type-completed-follow-ups`). Existing widget coverage asserts the obsolete top-level key is absent and exercises the unified path. No duplicate control was introduced.
- Home's five top filters in RTL order are already Time → Center → Project → Category → Tags (`home-filter-card-time/center/project/category/tags`). Default labels are dimension names; no standalone «همه» chip is rendered. Existing filter sheets retain their internal reset/apply behavior; that is not a top-bar chip.
- Quick Capture already uses the compact single-line title, full-form shortcut, RTL Center → Project → Category → Tag row, priority/date-time/reminder/recurrence controls and submit/cancel actions. Empty-title behavior remains inline error + SnackBar; no test or assertion was changed. No description/checklist fields are exposed in this compact form.
- These requested UI behaviors were already present at the audited HEAD, so no redundant runtime edits were made. This is a source reconciliation, not a claim that the physical-device visual review is complete.
- Exact-head Draft Review APK run `41807761597` on the same SHA completed SUCCESS; artifact `13311083215` (`arvin-review-staging-apk-957924cd67066db06abe5fd15df2c802729aa3bb`) is available and not expired. It is a review/staging APK, not a production release APK.
- Exact-head Build run `41807761390`: SUCCESS (Analyze and six test shards); APK matrix SKIPPED by Draft guard. Calendar Provider run `41807761328`: SUCCESS; Follow-up Persistence run `41807761334`: SUCCESS. Device Smoke run `41807761329` has not reached a verified terminal seven-lane conclusion at this checkpoint; partial lane results are not overall acceptance.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Conflict audit and exact-SHA Device Smoke gate
- Audited PR #3052 live: OPEN / DRAFT / UNMERGED; GitHub reports mergeable=true (previous mergeable=false is no longer current).
- Live branch HEAD: 5923bc974592f9507b5424d4d03d679fbfca54e7. Live main: 45e4202b03a434459e4c021a04efa7e8396359db.
- GitHub compare main...branch: status ahead, ahead_by=624, behind_by=0, merge-base equals main SHA. No rebase or merge was performed; no main ref was modified. Current compare does not indicate a branch divergence. The historical reason for the earlier mergeable=false is NOT VERIFIED.
- Exact-SHA workflows started for 5923bc974592f9507b5424d4d03d679fbfca54e7: Build run 41810086500 IN_PROGRESS; Device Smoke run 41810086328 PENDING (no jobs published at observation); Calendar Provider run 41810086266 IN_PROGRESS; Follow-up File Persistence run 41810086231 IN_PROGRESS; Draft Review APK run 41810086294 IN_PROGRESS. Build APK matrix was SKIPPED by the Draft guard; this is not a build failure and no APK result is claimed from that matrix.
- Device Smoke has no published lane results yet. Boot, Navigation, Quick Capture, Task Lifecycle, Reminder/Vazirmatn, Calendar Segmented View and Follow-up Persistence are all NOT VERIFIED on this SHA. Do not infer results from prior SHAs.
- This entry is an interim checkpoint, not terminal acceptance. No source code, tests, or main branch were changed. PR remains OPEN/DRAFT/UNMERGED; release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Local P2P Phase 1 design specification (ARVIN-EXEC-1405/08/14-LOCAL-P2P-SYNC)

- Added `docs/project-continuity/LOCAL_P2P_SYNC_SPECIFICATION.md` as a Phase 1 design-only specification for direct local Wi-Fi / hotspot synchronization between explicitly paired Arvin devices.
- Pairing UX records the requested one-time QR or four-digit PIN paths. The document explicitly treats a four-digit PIN as low entropy and requires short expiry, strict rate limiting, authenticated encrypted key establishment, peer confirmation and security review; QR/PIN alone is not treated as secure authentication.
- Defined privacy boundaries, no Internet/cloud/relay dependency in Phase 1, and a separate deferred Cloud/Dropbox Phase 2.
- Documented canonical entity boundaries, a conceptual versioned operation envelope, durable journal, idempotent receive/apply, acknowledgement/cursor rules, transactional writes, non-destructive SQLite/Drift migration, conflict visibility, revocation, retry/resume and two-device acceptance criteria.
- No application source code, database schema, tests, workflow configuration, font assets or runtime behavior was changed. No test was removed, weakened or skipped. Vazirmatn remains the official font.
- QR/PIN cryptography, discovery/transport implementation, exact schema and conflict algorithm remain design decisions requiring security/technical review. Local P2P implementation and physical acceptance remain NOT VERIFIED. LWW, tombstone policy and device-clock winner selection are not approved by this document.
- Starting branch HEAD: b299c5ccddf9123a661e8a5c52dc3b0548265d35. This is a documentation-only commit; all existing CI/device evidence remains bound to its original SHA and must not be transferred to the new documentation SHA.
- PR #3052 must remain OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Task Details UI evidence audit
- Audited PR #3052 live on exact SHA 0f2977a26d76fbe301b27aef05270b2d7568f4d2; PR OPEN / DRAFT / UNMERGED, base main SHA 45e4202b03a434459e4c021a04efa7e8396359db.
- Identified TaskDetailPage in lib/task_detail_page.dart and app route _openTaskDetail in lib/main.dart. Read-only audit confirmed current order, duplicated priority/due-date/category/tag presentation, fixed bottom actions, and existing description inline edit.
- Task model has people references but no dedicated assignee field in the inspected canonical model; people are not treated as assignee. Task due date, independent TaskReminder, recurrence and FollowUp history remain separate.
- The two comparison images were not available in the audit input. Pixel-level visual comparison remains NOT VERIFIED; no runtime UI change was made rather than guessing at the reference.
- Exact-SHA Build run 41815969951 SUCCESS (Analyze + six test shards); focused Task Details master screen cases logged PASS. APK matrix SKIPPED by Draft guard.
- Calendar Provider run 41815969715 SUCCESS; Follow-up File Persistence run 41815969772 SUCCESS; Draft Review APK run 41815969817 SUCCESS with review-only artifact 13314402997.
- Device Smoke run 41815969732 had six successful lanes at last poll; Calendar Segmented View job 126526712495 remained IN_PROGRESS. No complete seven-lane PASS is claimed.
- Full findings and staged visual correction plan: docs/audit/ARVIN_TASK_DETAILS_REFERENCE_COMPARISON_2026-11-04.md.
- No test/assertion/scenario was removed, weakened, skipped or bypassed. No main write, merge or release. PR remains OPEN / DRAFT / UNMERGED; Release BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Task Details UI reference execution checkpoint
- Exact live PR #3052 source HEAD: 940b22f4dc30aef083e5116843ac9457bd1bd37a; OPEN / DRAFT / UNMERGED; base main SHA 45e4202b03a434459e4c021a04efa7e8396359db.
- Re-read TaskDetailPage, _openTaskDetail route and Task model on this exact HEAD. Source blobs: lib/task_detail_page.dart 269a48aee948d00ab453d1d4e82b2b9e2510d4b9; lib/main.dart 97e2f872e69b24dd47ffe936e921c8001ace9388; lib/models/task.dart d5ba37c5bdac479b5c3381fea30f5ea510b64d51.
- Model has people but no assignee field; people are not treated as assignee. Code confirms repeated due date, priority, category/tags; no runtime cleanup was made without accessible screenshots and product approval.
- Named screenshots photo_1793790367954.webp and photo_1793790413647.webp were absent from current conversation and not found in Library search. Image comparison and visual acceptance remain NOT VERIFIED.
- Build run 41819344155 SUCCESS (Analyze + six test shards); focused Task Details tests and RTL/Vazirmatn contracts logged PASS. No Task Details golden/screenshot acceptance evidence found.
- Follow-up persistence run 41819344361 SUCCESS. Draft Review APK run 41819344101 SUCCESS, artifact 13316861010 (review-only).
- Calendar Provider run 41819344729 IN_PROGRESS at last poll. Device Smoke run 41819344258: Boot/Navigation PASS; Quick Capture/Calendar IN_PROGRESS; Reminder/Vazirmatn/Follow-up Persistence/Task Lifecycle QUEUED.
- Full findings: docs/audit/ARVIN_TASK_DETAILS_REFERENCE_COMPARISON_2026-11-04.md. No test weakening/skip/timeout bypass, main write, merge or release. Release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Task Details reference-driven UI implementation checkpoint
- Product owner supplied the desired Task Details reference image in the conversation. Its visual structure was translated into a UI-only implementation; the separate installed-app comparison image is still not available as a runtime file, so pixel comparison is NOT VERIFIED.
- Source changes on code checkpoint d7ae03c8cc74e9f38c739cd84dba77606acc56ff: compact title + status/priority summary; status and priority appear together without duplicate presentation; separate description card retains its editor/save flow; metadata follows RTL order (execution-time placeholder, available center, project, category, tags); template-source card is conditional; due date is presented once in its own card; reminders, checklist, follow-up history/timeline and recurrence remain in the scrollable page.
- Model audit confirms Task has no execution-time field and no independent assignee/responsible field. UI states execution time as not recorded; it does not mislabel createdAt as execution time. Task.people remains labelled only as related people and is shown only when present.
- AppBar is unified indigo; existing calendar, inline/full edit, clone, report, delete, complete/reopen actions are retained. Scroll content bottom padding was increased so the fixed action bar does not cover the final content. Vazirmatn remains the only font.
- Added focused widget tests for section order, single due-date presentation, RTL, related-people semantics and bottom action accessibility. No existing test/assertion was removed, weakened, skipped or bypassed.
- Screenshot/Golden output for the actual revised page has NOT been generated in this execution environment; pixel-perfect acceptance is NOT VERIFIED. The supplied reference image is the target, not a screenshot of the new build.
- Current branch update was committed through the authorized branch only. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; no merge or release. Release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Exact-SHA CI failure and review APK evidence (a85145de7be4b0d23854e320885f665d50eb35cc)
- Build run 41823721080: FAILURE. Analyze failed at lib/task_detail_page.dart:1158:30 with unnecessary_string_interpolations. APK matrix was SKIPPED by the Draft guard.
- Test shards: test-4 SUCCESS; test-0, test-1, test-2, test-3 and test-5 FAILURE. Do not report the suite as passing.
- Task Details evidence from task_detail_master_screen_test.dart: PASS — clone action invokes canonical handler; title and multiline description save inline; summary/metadata/due date appear once in RTL order; related people are not presented as assignees and bottom content remains clear.
- Task Details failures: independent Reminder toggle could not find key task-detail-reminder-reminder-toggle-1 (line 83); ordinary-task smart visibility could not find task-detail-add-reminder (line 110); rich-section visibility could not find task-detail-independent-reminders (line 163). Related checklist failures: task_detail_checklist_flow_test could not find task-detail-checklist (line 29), and task_detail_checklist_crud_test could not find task-detail-add-checklist (line 72). These are real assertion/finder failures, not skipped tests.
- Related Task Details flow failures: add Follow-up key task-detail-add-followup absent (task_detail_followup_flow_test lines 58 and 193); existing FollowUp edit path raised StateError: No element in ensureVisible at line 252; Today action vertical-order assertion expected >520.5 but observed 478.0 (line 403; same 478.0 vs >520.5 in task_detail_due_date_action_test line 62).
- Calendar Provider run 41823721063: SUCCESS; artifact 13318164013.
- Draft Review APK run 41823721031: SUCCESS; artifact 13317704369, 38,206,200 bytes ZIP. Extracted review APK: 76,806,159 bytes, SHA-256 f3f3efdf74bff2b239f24145c69bbd98fbcf2ac0e2f3bb043e70c6f8d9dcea57. Manifest: applicationId com.example.arvin.staging, android_debuggable=false, v2/v3 signature verified, ephemeral test-only signing key, publishable=false, release_created=false. Review/install testing only; not a production/release APK.
- Device Smoke run 41823721013: still incomplete at last poll. Boot, Navigation, Quick Capture and Task Lifecycle SUCCESS; Reminder/Vazirmatn and Calendar Segmented View IN_PROGRESS; Follow-up Persistence QUEUED. No seven-lane PASS.
- No tests/assertions were modified, removed, weakened, skipped or bypassed during this audit. No timeout workaround was applied. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Task Details CI regression repair (implementation pending exact-SHA CI)
- Fixed analyzer lint by removing redundant string interpolation around the priority label; no lint suppression was added.
- CI log review identified lazy ListView child construction as the common reason several off-screen reminder/checklist/Follow-up controls were not discoverable at test time. Existing product keys and capabilities were retained. Widget tests now scroll the actual detail-page Scrollable until each target is built, then assert and interact with it.
- Checklist CRUD test now explicitly scrolls to the empty-state add CTA before tapping it. Follow-up tests assert the add/edit controls exist before scrolling and tapping; the existing Follow-up edit test targets the canonical timeline edit key.
- Existing relative Today-vs-due-date geometry assertions are retained; no fixed pixel threshold, assertion deletion, skip, weakened expectation or timeout workaround was introduced.
- Local Flutter/Dart execution is unavailable in this runtime; flutter analyze and complete flutter test are NOT VERIFIED here. Exact-SHA GitHub Actions results are required for acceptance.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release remains BLOCKED — RELEASE: NO-GO.


## Follow-up correction after first CI feedback — 2026-11-04
- The first regression-repair commit's Analyze job found a duplicate local declaration of `detailScrollable` in the smart-visibility test (not a product-code lint). Removed only the duplicate declaration and reused the existing page Scrollable finder.
- Made the non-empty checklist fixture explicitly set `checklistEnabled: true`; this documents the intended canonical fixture state instead of relying on constructor inference.
- New exact-SHA CI is required; prior run 41827206935 Analyze FAILURE is superseded only after the correction commit passes.


## 2026-11-04 — Quick Capture UI redesign (owner-approved)
- Product owner explicitly approved the Quick Task Registration redesign and selected four canonical priority levels; no priority data remapping or enum change is authorized.
- Source commits on authorized branch: `bd849800d524289aa555264e8db61e3423066b7f` (card-based UI / priority chips), `ccda9440a6f63439cb9171ac9bfd06ffb7d8c1d6` (card nesting correction), `9aaa51dea8957a8f755e57f6d9bb05724a6f00f1` (description reset behavior). Focused test commit: `e837f0959aff06e0a2727b8564a11b361d903cda`.
- UI scope: #F5F6FA canvas, dark indigo header with close and full-form actions, white 16px rounded cards, title and multiline description inputs, RTL four-chip priority selector with pastel semantic colors and Persian helper text, and full-width primary submit. Existing Center / Project / Category / Tag, due-date, independent reminder and recurrence controls remain wired to their prior flows.
- Canonical priority mapping remains unchanged: high=1, medium=2, low=3, none=4; stored TaskPriority value is still assigned directly. No English P1–P4 text is rendered by the new selector.
- Description writes to existing Task.description and is cleared after successful capture or successful full-form handoff; failed capture preserves input.
- Focused tests were updated, not removed: the priority test now checks all four labels/helper descriptions, absence of P1–P4 display strings, canonical priority persistence and description persistence. The compact RTL test now expects the description field.
- The initial UI source commit had a card-nesting sequence corrected in a follow-up commit before final review. Analyze, widget tests, all six Build shards, Device Smoke, Provider, persistence and review APK are NOT VERIFIED on the final docs-synchronized SHA until corresponding workflows finish.
- No main edits, merge, Draft transition or release. PR #3052 remains OPEN / DRAFT / UNMERGED; release BLOCKED — RELEASE: NO-GO.


## 2026-11-04 — Quick Capture compact selector compile correction
- The compact sizing changes use a `compact` constructor parameter in `ArvinTagRollBox`; its widget class was missing the matching stored field even though `build()` referenced `widget.compact`.
- Added `final bool compact;` to the widget in commit `642a4016cbaa1994b4dfe2d278066941ef8a65c2`. This repairs the compile contract and preserves the existing selector behavior.
- Build run `41842459267` on pre-fix SHA `c918f2bb8ce73ffa82dd601ab30eb077b9d49fa4` failed in `compileFlutterBuildStaging` with the missing-field error. Follow-up persistence run `41842459045` passed on that pre-fix SHA; Device Smoke and Calendar Provider were not terminal at inspection; Draft Review APK run `41842459134` failed at Staging assemble for the same compile error.
- The new fix and all subsequent documentation commits require fresh exact-SHA validation. No test/assertion was deleted, skipped or weakened.


## 2026-11-04 — Exact-SHA CI follow-up for compact Quick Capture (`a657691`)
- Build run `41843444962`: Analyze failed only on `unnecessary_const` at `lib/quick_capture_dialog.dart:587:42`; six test shards remained in progress; APK matrix skipped. The previous missing `ArvinTagRollBox.compact` declaration was no longer the reported failure.
- Device Smoke `41843451312`: matrix prepared; boot/navigation active, other five smoke lanes queued at last inspection.
- Calendar Provider `41843445191`: real Provider acceptance still active.
- Follow-up Persistence `41843445148`: SUCCESS exact SHA.
- Draft Review APK `41843444971`: staging assembly active; artifact list empty and upload step pending. APK not yet confirmed.
- Quick Capture test source includes compact RTL and 40dp dimension checks; exact shard result not yet available. A SingleChildScrollView remains in the dialog; no-scroll acceptance is NOT VERIFIED.
- No test edits, skips, weakened assertions or timeout extensions were made during this check.


## ممیزی زنده CI — ۱۴۰۵/۰۸/۱۳ (2026-11-04)

- SHA ممیزی: `3f849eefed2afe08c3d3662cf66d9c488388e737`؛ شاخه مجاز PR #3052.
- Build & Analyze [41852047631](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047631): Analyze PASS و شش شارد test-0 تا test-5 همگی PASS؛ test-3 نیز PASS. فقط برای همین SHA معتبر است.
- Follow-up file-backed SQLite [41852047684](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047684): PASS، شامل persistence و close/reopen diagnostic.
- Device Smoke [41852048093](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852048093): Preparation PASS؛ Boot و Navigation در حال اجرا؛ Quick Capture، Reminder/Vazirmatn، Follow-up Persistence، Calendar Segmented View و Task Lifecycle در صف. هفت سناریو تکمیل نشده؛ نتیجه نهایی NOT VERIFIED.
- Calendar Provider [41852047809](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047809): اجرای instrumentation/provider acceptance در حال انجام؛ نتیجه NOT VERIFIED.
- Review APK [41852047701](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41852047701): ساخت staging APK در حال انجام؛ Artifact هنوز موجود نیست، پس لینک دانلود/تأیید APK NOT VERIFIED.
- اصلاح test-3 در این SHA: scrollUntilVisible قبل از pumpAndSettle و assertion اجرا می‌شود؛ Finder و assertion حفظ شده و تست تضعیف نشده است.
- PR #3052 هنگام ممیزی OPEN / DRAFT / UNMERGED؛ main تغییر نکرد؛ Vazirmatn و فیلدهای canonical Task حفظ؛ Release: BLOCKED — RELEASE: NO-GO.
- این snapshot فقط وضعیت runهای SHA ممیزی‌شده را ثبت می‌کند؛ commit مستندات SHA تازه‌ای می‌سازد و PASSهای قبلی را به SHA تازه منتقل نمی‌کند.

## R6 — exact-SHA review APK and live smoke checkpoint (2026-11-04; source SHA: 1815ef72864f3e792661eee08cc932b29ff94c88)
- Review Staging APK run [41874160600](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160600) completed SUCCESS on the exact source SHA. Artifact [13345822544](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/13345822544/zip), name `arvin-review-staging-apk-1815ef72864f3e792661eee08cc932b29ff94c88`, ZIP size 38,211,551 bytes, SHA-256 `0821c0b1749e5e852d68283eb5c4181bbb15877f9c701954f56e18db685a5ab1`, expires 2026-11-11 17:12:04 UTC. Direct ZIP: https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/13345822544/zip
- Extracted APK: `Arvin-review-staging-1815ef72864f3e792661eee08cc932b29ff94c88.apk`, 76,822,515 bytes, SHA-256 `24295b19eea0300623167fbe400320a961feefbc3e6045e1015c43560a306e75`; application ID `com.example.arvin.staging`; `android_debuggable=false`; APK Signature v2/v3 verified. Signer certificate SHA-256 `f3c4ffe277b87daa789596ae3275fc8d9d59fc1d1236b83a7fa1190cb7a3d37b`. Ephemeral review-only test key; `publishable=false`, `release_created=false`. This artifact is for private review/install testing only, not production or release acceptance.
- Build #9553 run [41874160729](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160729): Analyze and all six test shards (0–5) SUCCESS on the exact SHA. Draft-guarded ordinary APK matrix job was SKIPPED as expected; this is not the Review Staging APK job.
- Device Smoke #6800 run [41874160773](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160773): matrix preparation SUCCESS. At the latest job-level poll: Boot IN_PROGRESS; Navigation IN_PROGRESS; Quick Capture QUEUED; Follow-up Persistence QUEUED; Task Lifecycle QUEUED; Calendar Segmented View QUEUED; Reminder/Vazirmatn QUEUED. Screenshot/evidence upload steps had not started. Seven-lane acceptance is NOT VERIFIED. The run-level API status was reported as queued while two lane jobs were already in progress; job-level states are recorded above.
- Calendar Provider Acceptance #1698 run [41874160623](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160623): exact-SHA checkout and setup succeeded; real Provider instrumentation/acceptance step remained IN_PROGRESS; evidence publication pending. Final acceptance NOT VERIFIED.
- Repository cleanup audit on the same source SHA: complete recursive tree (790 entries, not truncated); no tracked APK/AAB, generated build/output/cache/temp directories, or safe deletion candidates found. No cleanup deletion or cleanup commit was made.
- PR #3052 remains OPEN / DRAFT / UNMERGED with head `1815ef72864f3e792661eee08cc932b29ff94c88`; branch is unchanged at this checkpoint. `main` remains `45e4202b03a434459e4c021a04efa7e8396359db`. No code changes, merge, release, or publication were made.
- **BLOCKED — RELEASE: NO-GO.** Physical tablet installation/behavior, seven-lane Device Smoke, Calendar Provider terminal result, and product-owner release acceptance remain separate gates. This evidence applies only to source SHA `1815ef72864f3e792661eee08cc932b29ff94c88`; any documentation commit creates a new HEAD and does not inherit these exact-SHA CI results.


## Module-Core-Logic v1.0 — source and CI audit (۱۴۰۵/۰۸/۱۴ — 2026-11-05 02:38 Asia/Tehran)
- PR #3052 live at audit start: OPEN / DRAFT / UNMERGED; authorized branch exists; reviewed HEAD `4021c84ceb14faf4f6559379cf67dd94955bffe4`; base `main` SHA `45e4202b03a434459e4c021a04efa7e8396359db`.
- Exact verbatim Module-Core-Logic v1.0 text was not available in the retrieved conversation context. The crosswalk was therefore limited to the named core invariants; no claim of verbatim module review is made.
- Source findings: Due Date and TaskReminder are distinct; FollowUp.dateTime is persisted as `date_time` and completedAt is an alias; legacy Task and FollowUp scheduling fields remain in model/SQL; Alarm scheduler uses fixed ID 42002 while notification IDs are stable-key hashes (42002 only fallback); Stop cancels notification only; Snooze mutates the selected Reminder; Alarm Follow-up shortcut suppresses Reminder creation.
- Confirmed implementation gap: `FollowUpReminderDeliveryService.due` does not check `TaskReminder.isEnabled`; `TaskStore.addTaskReminder` appends a new ID and has no idempotency guard. Delivery-state prevents repeat delivery of an already-recorded stable identity but is not a general duplicate-record constraint.
- Persistence: Follow-up File Persistence Run [41918593732](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41918593732), Job `126884771276`, SUCCESS. Both repository file-backed persistence and Alarm Overlay SQLite close/reopen diagnostic steps succeeded on the reviewed SHA.
- Calendar Provider: Run [41918593589](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41918593589), Job `126884770799`, SUCCESS; emulator CREATE / NO-OP UPDATE / duplicate prevention / UPDATE / DELETE assertions passed. This is not physical-device acceptance.
- Build: Run [41918593631](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41918593631): Analyze Job `126884771994` PASS; test-0/1/3/5 PASS; test-2 and test-4 FAIL; visual lane `126884772198` FAIL. test-2/visual logs report `task_detail_visual_test.dart` timeout after 10 minutes; test-4 fails `contextual_guide_test.dart` because it expects the former seven-lane matrix and does not account for the added visual lane. Ordinary APK matrix SKIPPED by Draft guard (not a build PASS).
- Device Smoke: Run [41918593360](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41918593360): Quick Capture, Follow-up Persistence, Task Lifecycle and Reminder/Vazirmatn PASS; Boot, Navigation and Calendar Segmented View CANCELLED. Seven-lane acceptance is not complete.
- PR diff review: 86 test/integration-test files have patches. No new explicit `skip:` / `skipReason:` / artificial timeout addition was detected in the inspected test diff. However, multiple previous test declarations/assertions were removed or rewritten to reflect changed product contracts (including Calendar Follow-up card/action tests, inbound calendar mutation tests, and Quick Capture legacy controls). Therefore the blanket assertion “all prior scenarios preserved and no assertions skipped” is NOT VERIFIED; the deleted/rewritten scenarios need an explicit owner-approved replacement map. No tests were changed by this audit.
- No product logic, source code, schema, migration, test, assertion, or workflow was changed in this checkpoint.
## Uniform UI design-token implementation — 2026-11-05 09:56 Asia/Tehran — ۱۴۰۵/۰۸/۱۴
- Owner-directed palette registered in `PRODUCT_DECISIONS.md`; older #4A4CAB / #F8F8FB / #FDFDFE values are superseded for active design-token use, while historical records are retained.
- Added `lib/core/theme/arvin_theme.dart` with the primary/header/background/card/radius/shadow/Vazirmatn tokens. Routed `ArvinColors` aliases and global light ThemeData CardTheme/AppBar styling through the new tokens.
- Updated shared Home shell, primary navigation, Home add action, radio/project selector and recurrence chip to consume the central palette. Priority/status semantic colors and existing enum/data semantics remain unchanged; visible priority labels remain Persian.
- Added `test/arvin_theme_tokens_test.dart` for exact token values and semantic priority/taxonomy palette invariants. No existing test or assertion was removed, skipped, weakened or timed out.
- **Scope limitation:** the central ThemeData affects Material Card widgets app-wide, but this commit does not claim every custom Container/BoxDecoration on every screen has been converted to a shared card component. Full screen-by-screen custom-surface inventory, visual screenshot acceptance and physical-device review remain NOT VERIFIED.
- CI is triggered by this code commit; Analyze and widget tests are NOT VERIFIED until the final SHA's workflow results complete. No local Flutter execution is claimed.

### Target-screen card alignment follow-up — 2026-11-05 10:03 Asia/Tehran — ۱۴۰۵/۰۸/۱۴
- Routed Task Details `_card`, Task Editor reminder/checklist panels, Quick Capture `_surfaceCard` and sheet canvas, and Calendar reminder cards through shared card radius/surface/shadow tokens.
- No field order, keys, callbacks, task data, reminder semantics, calendar projection, navigation, persistence or validation behavior was changed. No existing tests/assertions were removed, skipped or weakened.
- Whole-repository custom-card inventory and physical visual comparison remain NOT VERIFIED; exact-SHA CI on the final commit is required.

 
## TaskHomeScreen implementation — 2026-11-05 13:02 Asia/Tehran — ۱۴۰۵/۰۸/۱۴
**Product specification:** `docs/project-continuity/task_home_screen_spec.md` (fourteen approved requirements).  
**Authorized branch:** `fix/recovery-calendar-device-smoke-2026-10-31`; PR #3052.
- Source commits: `65122e4936002b5ca8687ffa2fb8d65ac5c78841` (Home header, general filter, sort row/sheet, dynamic weekday dates, group order); `e89ee5fad057bbc70406b475db1511166c615740` (Center metadata chip); `0ad42cb67cca0851c3d7d60ed1a5e5918aa87b63` (canonical Center supplied to task card metadata); `da311c2f7e4ef9b96fc20a26e31eca996fa63d50` (Follow-up Date promoted to primary comparator for the default sort).
- The existing primary navigation widget was inspected and already contains exactly five visible destinations; no redundant navigation edit was made. The internal `nextAction` destination remains available to existing routes, but is not rendered as a sixth primary tab.
- Home header now uses the hamburger drawer on the right and general filter funnel on the left; bell removed. The existing search-focus test key was moved into the search-field affordance so the search box remains independently testable without restoring a header search icon.
- Five filters remain Time / Center / Project / Category / Tag. Sort control is appended after them in the RTL row. The existing filter matcher preserves OR within categories and AND across categories.
- Default sort now uses Follow-up Date first; missing Follow-up dates remain last, followed by priority and stable Task ID. The Past group retains the pre-existing `sortPast` behavior and its existing test contract.
- Home groups are ordered Past / Today / Tomorrow / Future / Timeless. The group classifier is based only on Due Date; completed past-due tasks are kept in Past and remain excluded from active-overdue semantics. Today/Tomorrow headers now include weekday and full Jalali date.
- Center chip is derived from the canonical Project's `centerId`; no Task model field or parallel storage was added.
- No existing test file or assertion was modified, removed, skipped, weakened, bypassed or timed out.
- The Bismillah uses a system serif fallback and full Arabic diacritics. No bundled Naskh font asset was located in the inspected paths; actual device glyph appearance remains NOT VERIFIED pending physical screenshot review.
- Exact-SHA CI must be checked after the final documentation commit. No earlier SHA's workflow results transfer. PR #3052 remains OPEN / DRAFT / UNMERGED; main untouched; release BLOCKED — RELEASE: NO-GO.

 
## TaskHomeScreen analyzer correction — 2026-11-05
- An intermediate Analyze run on source checkpoint `da311c2f7e4ef9b96fc20a26e31eca996fa63d50` found the plugin import had also been removed even though the app-level notification tap handler still uses `NotificationResponse`, and found an orphan private `_openPendingReminder` helper after removing the Home bell.
- Corrected in `c0766a5e602d04426486816e95cad4038b667fa7`: restored the plugin type import for the retained notification-response path and removed the now-unreferenced pending-notification helper. The Home header remains bell-free.
- No test files or assertions were changed. Analyze and widget tests on the corrected/final SHA remain NOT VERIFIED until a fresh exact-SHA run completes.

 
## TaskHomeScreen final source delta — 2026-11-05
- Added an explicit accessible semantic label to the independent Home sort action: `72e6779f268bb0ca971b651ad0228604b504f4c8`.
- Ensured the Past group heading also uses the calendar icon when Past is selected directly from the Time filter: `460a40b6411c6c63691817e45ef00aab61544bd8`.
- These are source-only follow-ups; no test file or assertion was changed. The latest exact-SHA Build and Device Smoke runs must complete before any PASS is recorded.


## TaskHomeScreen exact-SHA CI verification — 2026-11-05
- Candidate SHA audited: `8a7aa309576131efa60b7f0745b452da32f1c64c`. Build run `42005232517` completed with overall FAILURE on this exact SHA. Analyze passed; test-0, test-1, test-2, test-4 and test-5 failed; test-3 passed; the independent Task Details visual-golden job failed after its 10-minute test timeout. Draft-PR APK matrix jobs were skipped by workflow condition and are not build evidence.
- Exact shard outcomes from job logs: test-0 — 210 passed / 3 failed (legacy Home header Bismillah text expectation, old “تاریخ گذشته” label expectation, and Home header/search-shell expectation); test-1 — 174 passed / 3 failed (two legacy Home layout/header expectations including unmarked Bismillah, and old notification-control positioning/reachability expectations); test-2 — 285 passed / 4 failed (two old Home notification-key expectations, Vazirmatn theme source-shape expectation, and an additional Home-header contract failure); test-3 — PASS; test-4 — 223 passed / 2 failed (Past group label expectation and old Build matrix literal expectation); test-5 — 164 passed / 1 failed (Task Details expected primary color #4A4CAB but actual sampled color was #3F3D56). These failures remain unmodified; no test file or assertion was changed.
- Visual golden job `127170879015` timed out after 10 minutes with 0 tests passed. No golden PASS is recorded.
- Parallel Wave run `42005232506` failed in `contract`. Exact validator output: `Fast Lane contract missing in .github/workflows/build.yml: lane: [analyze, test-0, test-1, test-2, test-3, test-4, test-5]`. Current Build workflow adds `visual` to that matrix, while the validator and an existing test expect the seven-lane matrix without `visual`. This is a workflow-contract expectation mismatch, not evidence that the Flutter test assertions should be changed. To preserve both the existing test assertion and visual coverage, the safe structural correction is to keep the seven-lane `quality` matrix and move the visual golden step/artifact upload into a separate independent job; do not remove or skip the visual test.
- Device Smoke run `42005232867` is not complete in the inspected snapshot. All seven canonical scenario jobs were created on the same candidate SHA; `smoke-boot` and `smoke-navigation` were in progress, while `smoke-calendar-segmented-view`, `smoke-quick-capture`, `smoke-task-lifecycle`, `smoke-reminder-vazirmatn`, and `smoke-follow-up-persistence` were queued. The parent run response still reported queued while two child jobs reported in progress. No seven-path PASS is claimed; screenshot artifacts are not yet verified.
- Bismillah source currently renders `بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ` with `fontFamily: 'serif'`. This selects a platform serif fallback, not a bundled Naskh font. Automated source inspection cannot establish clean shaping or consistent glyph appearance across Android devices. Physical screenshot assessment remains NOT VERIFIED. For uniform Android rendering of this fixed decorative phrase, a bundled, properly licensed Arabic Naskh font asset is preferable to relying on OEM fallback; an SVG/vector is a viable fixed-art alternative only if text scaling/accessibility requirements are intentionally waived.
- PR #3052 remained OPEN / DRAFT / UNMERGED at this audit; branch head and PR head matched the candidate SHA. `main` remained at `45e4202b03a434459e4c021a04efa7e8396359db`. No main edit, merge, release, test modification, test skip, or assertion weakening occurred. Release remains BLOCKED — RELEASE: NO-GO.

- Device Smoke follow-up poll (same run `42005232867`, same candidate SHA): `smoke-boot` and `smoke-navigation` remained IN_PROGRESS; the other five canonical scenario jobs (`smoke-calendar-segmented-view`, `smoke-quick-capture`, `smoke-task-lifecycle`, `smoke-reminder-vazirmatn`, `smoke-follow-up-persistence`) had transitioned to CANCELLED. This is not a seven-lane pass; the run is incomplete/invalid for acceptance and must not be promoted to PASS.


## Calendar UI/UX specification registration — 2026-11-05 — ۱۴۰۵/۰۸/۱۴
- Registered the owner-approved fourteen-section Calendar UI/UX contract at `docs/project-continuity/calendar_ui_ux_spec.md`.
- Updated Product Decisions, Current State, Roadmap/backlog, this Implementation Log, the continuity index, and the root continuation Ledger with the canonical reference and its boundaries.
- Locked the header placement: centered «أُفَوِّضُ أَمْرِي إِلَى اللَّهِ», search right, full Persian Today-date pill plus adjacent «برو به تاریخ» picker at top-left; Help removed.
- Locked the selected-date bar: Jalali bold center, Gregorian right, Hijri lunar left.
- Locked four view modes above the seven-column Saturday–Friday RTL grid; default weekly. Each cell shows Jalali primary and Gregorian/Hijri lunar secondary values.
- Locked five content filters below the grid and above the selected-day agenda; Task/Event/Reminder cards must not overlap.
- Registered Hijri offset options (+1 day, −1 day, Official Iranian Calendar Match).
- This is documentation-only. No runtime source, test, workflow, schema, migration, calendar provider, or persistence code was changed. No test was added, removed, skipped, weakened, or rerun.
- This documentation commit sequence creates a new HEAD. Build/Device Smoke results below remain evidence only for SHA `5bea1ed67549e26aa2ceeb0882477d4cfc2c1f53`; they do not verify the new documentation HEAD. Fresh exact-SHA CI is required before acceptance.
- On the audited SHA, Build #42011495370 = FAILURE (Analyze PASS; test-0/test-2/Visual FAILURE; test-1/test-3/test-4/test-5 PASS; APK SKIPPED by Draft guard). Device Smoke #42011495381 = CANCELLED (Quick Capture, Task Lifecycle, Reminder/Vazirmatn, Follow-up Persistence PASS; Boot, Navigation, Calendar Segmented View CANCELLED).
- Calendar Provider #42011495562, Follow-up Persistence #42011495565 and Parallel Wave Contract #42011495436 = SUCCESS on the audited SHA.
- PR #3052 remains OPEN / DRAFT / UNMERGED; main unchanged; **BLOCKED — RELEASE: NO-GO**.


### Exact failure-log extraction and Device Smoke cancellation diagnosis — 2026-11-05
- Shard 0 job 127191744252, test/home/home_filter_contract_test.dart:30: Expected exactly one matching candidate; actual finder returned two Text("گذشته") widgets: the Past group heading and task-card title keyed task-card-title-past. This is a test-fixture/Finder collision in the available evidence; no change made.
- Shard 2 job 127191744137, test/home/home_owner_reference_test.dart:47: expected at least one widget with text ۱۴۰۵/۰۸/۱۴; actual finder returned zero. The log does not establish why the rendered date differs or is absent. Root cause NOT VERIFIED.
- Shard 2 also reports task_detail_visual_test.dart TimeoutException after 0:10:00.000000; the shard ended with 287 passed / 2 failed.
- Independent Visual job 127191743762: the same Task Details visual test timed out after 10 minutes; 0 passed / 1 failed. Upload step found no test/failures/task_detail_visual_actual.png; no visual artifact was produced.
- Device Smoke Boot job 127191526180, Navigation job 127191526487, and Calendar Segmented View job 127191526055 each ended CANCELLED after approximately 30 minutes. Logs show emulator API 35 reached sys.boot_completed=1, ADB reported the emulator as ready, and the script entered before-flutter-drive; no completed Flutter-driver result was captured. Logs contain bad color buffer handle and no PNG screenshot artifacts were produced. The logs do not prove that this warning caused the stall; exact stalled test operation/root cause remains NOT VERIFIED.
- Boot/Navigation logs also show transient adb: device offline during emulator startup before later reporting the device ready. This does not identify the subsequent Flutter-driver stall.
- Quick Capture, Task Lifecycle, Reminder/Vazirmatn and Follow-up Persistence Device Smoke lanes are SUCCESS; they do not compensate for the three cancelled lanes.
- No assertion was changed, removed, skipped, weakened or bypassed. No timeout was increased. No runtime/product change was made.


### اجرای مهندسی موازی طبق دستور تجمعی مالک محصول — 2026-11-05

**دامنه اجرا:** Issue #823 / PR #3052؛ فقط شاخه مجاز `fix/recovery-calendar-device-smoke-2026-10-31`. این اجرا جایگزین ممیزی قبلی نشد و کارهای مستقل بدون انتظار CI پیش رفتند.

#### Task Template / Project Template
- قرارداد انتقال/حذف داده در `docs/project-continuity/TASK_TEMPLATE_DATA_CONTRACT.md` ثبت شد.
- `lib/services/g1_drift_schema.dart`: G1 schema به v11 ارتقا یافت؛ جدول Task Template در همان SQLite/Drift ایجاد می‌شود؛ ستون `checklist_enabled` به‌صورت non-destructive برای داده‌های قدیمی اضافه شد؛ نصب schema به‌ازای هر executor serialize شد تا درخواست هم‌زمان دو تب وارد nested BEGIN نشود.
- `lib/models/task_template.dart` و `lib/services/task_template_store.dart`: تعریف مستقل الگوی کار، اولویت، دسته، برچسب، Checklist و فعال‌بودن Checklist، People references، ساعت Reminder بدون تاریخ اجرا، Recurrence بدون anchor/end date اجرایی و snapshotهای مرکز/پروژه را ذخیره می‌کنند.
- `lib/task_template_management_page.dart`: فهرست Taskهای موجود، تبدیل با نام‌گذاری و تأیید، نمایش الگوهای ذخیره‌شده و ساخت Task جدید از الگو به Store واقعی متصل شد. Task جدید شناسه و Reminder ID جدید می‌گیرد؛ checklist progress و تاریخچه/موعد قبلی منتقل نمی‌شود.
- `lib/project_detail_page.dart` و `lib/projects_page.dart`: انتخاب Project از فهرست، صفحه جزئیات، تأیید تبدیل و ذخیره از مسیر ProjectTemplateService/ProjectTemplateStore متصل شد؛ منبع اصلی فقط خوانده می‌شود.
- `lib/settings_page.dart` و `lib/task_template_management_page.dart`: دو تب «الگوهای کار» و «الگوهای پروژه» در ورودی تنظیمات قرار دارند.
- تست‌های داده/مهاجرت/تعامل اضافه یا گسترش یافتند: `test/services/task_template_store_test.dart`, `test/services/g1_drift_schema_test.dart`, `test/task_template_management_page_test.dart`, `test/project_detail_page_test.dart`, `test/settings_template_tabs_test.dart`.

#### Home
- مسیر فعال Home در `lib/main.dart` با پنج فیلتر و sort مستقل حفظ شد.
- `test/home/home_filter_contract_test.dart`: سناریوی ترکیبی OR در چند دسته و AND با فیلتر زمان، Past و تقدم کارت Past فعال نسبت به Past تکمیل‌شده پوشش داده شد.
- نتیجه تست روی HEAD فعلی هنوز NOT VERIFIED است.

#### Task Detail — فرم واحد ۱۱ بخشی
- `lib/task_detail_page.dart`: ترتیب ۱۱ بخش حفظ شد؛ عنوان/توضیح/دسته/برچسب، وضعیت/اولویت، Due Date/تمام‌روز/پاک‌کردن موعد، Reminderهای مستقل، Recurrence شامل تاریخ پایان، و Checklist در همان فرم draft می‌شوند.
- Checklist در حالت ویرایش به‌صورت draft اتمیک تغییر می‌کند؛ افزودن، تغییر متن، حذف و جابه‌جایی بالا/پایین به ذخیره نهایی متصل شد؛ لغو، تغییرات draft را کنار می‌گذارد. در حالت نمایش، checkboxهای پیشرفت همچنان تعاملی‌اند.
- کارت آخرین پیگیری و تایم‌لاین عنوان و یادداشت واقعی را از FollowUp می‌خوانند؛ وضعیت انتظار پاسخ از مقدار canonical FollowUp نمایش داده می‌شود؛ ترتیب timeline بر اساس `FollowUp.dateTime` نزولی است.
- metadata «زمان اجرا» چون منبع canonical ندارد «نامشخص» نشان می‌دهد؛ Task.people به‌عنوان مسئول تعبیر نمی‌شود.
- ScrollController در ListView واحد حفظ شد و تست صریح ورود/خروج از ویرایش با scroll offset اضافه شد.
- تست‌های `test/task_detail_master_screen_test.dart` برای Checklist اتمیک، حفظ scroll، Due Date، Recurrence end date، waiting-for-response و timeline توسعه یافتند.

#### Visual
- لاگ تاریخی job 127329168780 نشان می‌دهد `flutter test test/task_detail_visual_test.dart` پس از ۱۰ دقیقه timeout شده و پیش از تولید `test/failures/task_detail_visual_actual.png` شکست خورده است.
- در `lib/task_detail_page.dart` هیچ AnimationController، Ticker، Timer.periodic یا انیمیشن تکرارشونده‌ای یافت نشد؛ CircularProgressIndicator تنها در حالت busy و در fixture خاموش است؛ LinearProgressIndicator چک‌لیست determinate است.
- `test/task_detail_visual_test.dart` از انتظار نامحدود pumpAndSettle به pump قطعی ۳۵۰ms و assertion نبود frame معلق تغییر کرد. این اصلاح، حذف تست یا افزایش timeout نیست؛ اما تا اجرای واقعی روی exact SHA، NOT VERIFIED است.
- فایل Golden مرجع `test/goldens/task_detail_visual_test.png` در branch و main موجود نیست. Golden جدید بدون screenshot واقعی و بازبینی بصری ساخته/تأیید نشد؛ visual acceptance همچنان BLOCKED است.

#### شواهد و محدودیت CI
- commitهای کد و تست روی شاخه مجاز ایجاد شدند؛ commitهای سند نیز پس از آن ثبت شدند.
- در poll زنده آخرین HEAD قبل از این checkpoint، check-runs و workflow-runs خالی بودند. برای HEAD نهایی این اجرای تجمعی نیز تا زمانی که run exact-SHA ظاهر نشود، Analyze، test-0 تا test-5، Visual، Calendar Provider، Device Smoke و Follow-up Persistence همگی NOT VERIFIED هستند.
- عدم دسترسی به عملیات workflow_dispatch در ابزار متصل، مانع اجرای دستی run از این محیط است؛ این محدودیت، مجوز انتظار منفعلانه یا ادعای PASS ایجاد نمی‌کند.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.


## 2026-11-05 — تصمیم قطعی تایپوگرافی مالک محصول
- Vazirmatn فونت رسمی تمام اجزای رابط، متن‌ها، اعداد، دکمه‌ها و سربرگ‌هاست.
- فقط دو عبارت «بسم‌الله الرحمن الرحیم» و «أُفَوِّضُ أَمْرِی إِلَى اللَّهِ» (یا نگارش UI بدون اعراب «افوض امری الی الله») مجاز به رندر با خط نسخ هنری هستند؛ هیچ متن یا جزء دیگری استثنا نیست.
- تصمیم در `docs/project-continuity/PRODUCT_DECISIONS.md` ثبت شد.

## 2026-11-05 — Owner typography decision and parallel implementation follow-through
- Owner decision recorded in `PRODUCT_DECISIONS.md`: Vazirmatn is universal; only the two explicitly named sacred phrases may use the scoped Naskh treatment.
- `AppFonts.familyForText` is an exact-text whitelist; Home and Calendar phrase widgets call it. A regular Persian phrase resolves to Vazirmatn in the typography test. Calendar spelling uses the approved Persian yeh variant to match the whitelist.
- Task Details has a dedicated successful-save scroll-offset widget test in addition to existing entry/cancel coverage.
- Visual root cause is evidenced by job log `127329168780`: `pumpAndSettle` timed out after 10 minutes, before actual screenshot creation. Deterministic pumping at 350ms plus a scheduled-frame assertion addresses the unbounded wait; the actual test and Golden acceptance remain unverified on the final SHA. The canonical Golden is still absent.
- No device glyph fallback or device smoke result is claimed.


## 2026-11-05 — پیاده‌سازی استثنای تایپوگرافی و تست اسکرول
- `lib/theme/app_fonts.dart` فهرست دقیق دو عبارت مجاز را در `familyForText` تعریف می‌کند؛ متن فارسی عادی به Vazirmatn بازمی‌گردد.
- `lib/main.dart` و `lib/home/home_visual_integration.dart` عبارت بسم‌الله را از whitelist عبور می‌دهند؛ `lib/calendar_page.dart` عبارت تفویض را با همان تابع رندر می‌کند.
- `test/home/home_visual_integration_test.dart`, `test/home/home_sacred_phrase_test.dart` و `test/calendar_page_test.dart` استثنا و مرز Vazirmatn را assert می‌کنند.
- `test/task_detail_master_screen_test.dart` حفظ offset را در ورود، لغو و ذخیره موفق inline بررسی می‌کند؛ تست مستقل scroll-save در commit `a652c1ca7237a9e06431060a6bbf95dc321046c2` در همین فایل ادغام و فایل جداگانه حذف شد.
- `test/task_detail_visual_test.dart` از pump قطعی ۳۵۰ms و assertion `hasScheduledFrame == false` استفاده می‌کند؛ ریشه timeout، انتظار نامحدود `pumpAndSettle` برای idle scheduler در fixture ثابت بود، نه ticker تکرارشونده اثبات‌شده. Golden مرجع همچنان غایب است؛ Visual acceptance BLOCKED.
- این تغییرات تا اجرای موفق تست‌ها روی exact final SHA «پیاده‌سازی‌شده اما تأییدنشده» هستند.

- `test/home/home_filter_boolean_logic_test.dart` اکنون OR درون Category/Tag و AND میان این دو بُعد را به‌صورت تعاملی پوشش می‌دهد؛ commit `f6e1f38f93279621716a5734f8ea763a2cd19a2e`. نتیجه اجرای exact-SHA هنوز تأیید نشده است.


## ۱۴۰۵/۰۸/۱۴ (2026-11-05) — ممیزی قرارداد نهایی تایپوگرافی و رفع موانع CI
- HEAD ممیزی‌شده پیش از این بسته: `ea77f423c07c6978e8d62ab271d8906c89ff8824`؛ SHA مبنا `f44fb03fbc3a5b7b8e995dd861a9585aed36b0cc` قدیمی است و به‌عنوان HEAD جاری استفاده نمی‌شود.
- بررسی نشان داد pubspec فقط Vazirmatn را به‌عنوان خانواده bundled ثبت کرده اما AppFonts هنوز serif/Naskh fallback را برای عبارات مقدس فعال می‌کند؛ دو SVG path-based در کد فعلی قابل تأیید نبودند.
- در کد این بسته: const نامعتبر در Home visual integration حذف شد؛ fixture PersonReference غیر const اصلاح شد؛ محتوای کارت Task Details اکنون Material شفاف برای tileهای تعاملی فراهم می‌کند؛ Layout Smoke ابعاد width/height را finite نیز بررسی می‌کند.
- Build run `42072261154`: FAILED؛ Analyze به const invocation در `lib/home/home_visual_integration.dart:68` و fixture در `test/task_detail_template_conversion_test.dart:26` برخورد کرد. Visual run همان SHA به ListTile/Material FlutterError برخورد کرد. چند test shard نیز assertion/compile failures داشتند.
- Draft APK artifact روی SHA قدیمی موجود است اما build پایدار یا release artifact محسوب نمی‌شود. APK matrix در PR Draft اجرا نشده است.
- تصمیم جدید supersedes هر استثنای فونتی قبلی: Vazirmatn تنها فونت متنی؛ دو عبارت فقط SVG واقعی path-based.
- مرجع تصویری دقیق خوشنویسی در منابع قابل بازیابی این ممیزی پیدا نشد؛ طراحی دقیق تا دریافت مرجع NOT VERIFIED است.
- این اصلاحات و اسناد هنوز باید روی exact final SHA اجرا و تأیید شوند. PR #3052 OPEN/DRAFT/UNMERGED؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.


## به‌روزرسانی اجرای قرارداد نهایی — ۱۴۰۵/۰۸/۱۴ (2026-11-05)
- در کد، AppFonts به یک خانواده متنی واحد Vazirmatn محدود شد؛ serif سیستم، Naskh fallback و هرگونه fontFamilyFallback از Home و Calendar حذف شد.
- تا زمان ثبت SVGهای path-based، دو عبارت به‌طور موقت در Text widget با Vazirmatn رندر می‌شوند؛ این وضعیت فقط گذار ایمن است و پذیرش نهایی vector typography محسوب نمی‌شود.
- تست Home/Calendar برای نبود fallback و یگانگی Vazirmatn به‌روزرسانی شد؛ تست HomeVisualIntegration نیز دیگر انتظار فونت ثانویه ندارد.
- موانع exact-head قبلی در کد اصلاح شدند: const نامعتبر در HomeVisualIntegration، fixture غیر const در Task Template Conversion، Material surface در کارت‌های Task Details، و finite width/height در Layout Smoke.
- HEAD کد پس از اصلاحات: `2a50457cde537ca02544839397c88c998153f5b4`. پس از آن، این ثبت مستندات SHA را تغییر می‌دهد و تست‌های exact-SHA باید روی آخرین HEAD جدید اجرا شوند.
- GitHub workflow API برای HEAD کد فعلی اجرای جدیدی گزارش نکرد؛ بنابراین نتیجه اصلاحات و Layout Smoke روی این HEAD هنوز **NOT VERIFIED** است. هیچ نتیجه قدیمی به این SHA منتقل نمی‌شود.
- مسیر SVGها، dependency رندر SVG و تست روشن/تاریک/چندرزولوشن تا دسترسی به تصویر مرجع و پیاده‌سازی واقعی باقی است.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ **BLOCKED — RELEASE: NO-GO**.


## AIPOS v1.0 execution checkpoint — 2026-11-05
- PR #3052 branch HEAD observed: 7327c4e0f472e52b12ecd330cb0331132d8aa396; PR OPEN/DRAFT/UNMERGED.
- flutter_svg ^2.3.2 is declared and pubspec.lock resolves 2.3.2. G1 lock sync run 42090629531 SUCCESS.
- Follow-up file-backed persistence run 42090629520 SUCCESS. Calendar Provider 42090629465 IN_PROGRESS; Build/Analyze 42090629467 PENDING; Device Smoke 42090629594 preparation SUCCESS with lanes incomplete; Draft Review APK 42090629583 IN_PROGRESS.
- Earlier test corrections aligned Home font contract, Calendar header keys and Task Details inline-edit behavior; template dialog controller lifetime and three analyzer cleanup issues were also corrected. These changes still require exact-final-SHA verification.
- Both SVG assets are absent. Approved reference image was not found. No path-artwork or Text-to-SVG replacement is claimed.
- Documentation commits create new HEADs; all checkpoint CI results must be rerun on final documentation SHA. No local Flutter command output or APK build is claimed here.
- PR #3052 OPEN/DRAFT/UNMERGED; main untouched; release NO-GO.


## SVG sacred branding implementation — 2026-11-05 (۱۴۰۵/۰۸/۱۴)
- Product assets received from the product owner and validated as single-path SVGs: one `path` element per file, no background/image/text/gradient elements, path fill `#1A2B4C`.
- Added `assets/images/branding/bismillah.svg` and `assets/images/branding/tafweez.svg`; registered `assets/images/branding/` in `pubspec.yaml`. Existing `flutter_svg: ^2.3.2` dependency and lock resolution were retained.
- Home header now renders the Bismillah SVG at width 210; Calendar header renders Tafweez SVG at width 240. Both use the approved navy color filter and one outer Semantics label; the inner SVG excludes duplicate semantics.
- Updated Home/Calendar sacred-phrase widget tests to assert SVG keys, dimensions, semantics labels and absence of duplicate Text widgets. Existing Vazirmatn-only text family remains the only declared text family in `pubspec.yaml` and `AppFonts`.
- Source/test implementation commit (before continuity-doc sync): `507503611b08d2cfdfbee7d37c05e4fbd72ad85e`.
- `flutter pub get`, `flutter analyze`, and full `flutter test` have not been run locally in this GitHub connector environment. Exact-SHA CI is required; do not claim test success until its jobs finish.
- PR #3052 remains OPEN / DRAFT / UNMERGED; no main changes; **BLOCKED — RELEASE: NO-GO**.


## Exact-SHA CI result — 2026-11-05 — target d57a6b572ef14361f5354fa1840d950bf01e9506
- Build run 42094217896 completed with FAILURE on the requested exact SHA. `quality (analyze)` SUCCESS; all six test shards FAILED. Shard totals: test-0 210 passed / 7 failed; test-1 172 / 7; test-2 293 / 7; test-3 133 / 5; test-4 227 / 1; test-5 163 / 5. Aggregate: **1,198 passed / 32 failed** (1,230 executed test cases across the six shards).
- Failed tests, by shard:
  - test-0: `test/task_detail_followup_flow_test.dart` (Task detail removes redundant status badge / description placeholder); `test/backup_page_encryption_ux_test.dart` (encrypted backup confirmation); `test/widget_test.dart` (canonical centered Home identity); `test/home/home_filter_contract_test.dart` (five collapsible time groups); `test/home_settings_integration_test.dart` (font-size preference); `test/task_detail_master_screen_test.dart` (due time/all-day pickers; add reminder).
  - test-1: `test/task_detail_followup_flow_test.dart` (inline description edit); `test/project_template_service_test.dart` (Project-to-template conversion); `test/device_feedback_home_regression_test.dart` (canonical Home identity); `test/task_detail_master_screen_test.dart` (edit reminder title; remove selected reminder; edit reminder date/time); `test/home_stat_filters_test.dart` (short Android viewport).
  - test-2: `test/alarm_overlay_page_test.dart` (snooze exact Reminder); `test/task_detail_master_screen_test.dart` (recurrence; Follow-up presentation; checklist staging/reorder); `test/task_detail_checklist_crud_test.dart` (checklist CRUD); `test/home_today_about_test.dart` (Today empty state); `test/task_template_management_page_test.dart` (Task Template conversion).
  - test-3: `test/alarm_overlay_page_test.dart` (explicit Follow-up Save); `test/home/home_filter_contract_test.dart` (Home card expansion/history); `test/task_detail_master_screen_test.dart` (scroll offset; independent Reminder; compact visibility).
  - test-4: `test/task_detail_master_screen_test.dart` (rich-section visibility).
  - test-5: `test/alarm_overlay_page_test.dart` (all-day Reminder Snooze); `test/widgets/home_page_test.dart` (complete Task from Past); `test/task_detail_master_screen_test.dart` (summary/metadata/due date RTL; add Checklist); `test/canonical_calendar_launcher_test.dart` (repeat occurrence action).
- Exact failure signatures visible in job logs include: `pumpAndSettle timed out` in `test/alarm_overlay_page_test.dart`; `Bad state: No element` from `ensureVisible` in `test/home/home_filter_contract_test.dart` and `test/task_detail_checklist_crud_test.dart`; expected one Scrollable but found two in `test/task_detail_master_screen_test.dart`; missing key `task-detail-checklist`; missing key `task-detail-description-input`; missing key `task-template-confirm`; and a 66px bottom RenderFlex overflow at `lib/main.dart:1277` in `test/home_today_about_test.dart`. The exact source file/test names above are preserved from the failed-test log headers.
- APK matrix inside Build run: Debug and Release APK jobs SUCCESS; Staging APK job FAILED during Gradle distribution download with `java.net.SocketException: Broken pipe`; staging APK file was absent and no staging artifact was uploaded by this job.
- Draft Review APK run 42094218155: SUCCESS. Review-only APK artifact exists: ID 13447431967, name `arvin-review-staging-apk-d57a6b572ef14361f5354fa1840d950bf01e9506`, 39,103,986 bytes, SHA-256 `d4b1de0f3a21a0292759bf49ed1847824491b429ac5c135bedf5b7ab044961ec`, expires 2026-11-12. This is a review/staging artifact, not a production release.
- Calendar Provider run 42094217973: SUCCESS.
- Device Smoke run 42094217975: NOT COMPLETE at last poll; preparation job SUCCESS, navigation and boot lanes IN_PROGRESS, remaining five lanes QUEUED. No seven-lane PASS is claimed.
- Follow-up Persistence run 42094218060: SUCCESS. G1 lock sync run 42094218111: SUCCESS.
- `flutter analyze`: PASS on target SHA. `flutter test`: FAIL, aggregate 1,198 PASS / 32 FAIL. Do not mark the test suite green.
- PR #3052 governance remains OPEN / DRAFT / UNMERGED by instruction; no main write, merge, or release is authorized. **BLOCKED — RELEASE: NO-GO**.


## ۱۴۰۵/۰۸/۱۵ — ۱۰:۰۱ (Asia/Tehran) / 2026-11-06 — cumulative mission audit and implementation checkpoint
- Confirmed live PR #3052 head equals `105737b1e4d5f9e2d6e35dfc7c9f4bfd5b1cbdda` on the authorized branch; PR remains OPEN / DRAFT / UNMERGED and release NO-GO.
- Device Smoke `42169009238` / #7146 is IN_PROGRESS. Preparation, Quick Capture, Follow-up Persistence, Reminder/Vazirmatn and Task Lifecycle lanes reported SUCCESS; Calendar Segmented View remains IN_PROGRESS; Boot and Navigation jobs are CANCELLED. This is incomplete evidence, not a seven-lane PASS.
- Build `42169009592` / #9904 reported SUCCESS on the same SHA.
- Audited report behavior: `lib/report_center_page.dart` routes completed Follow-up reporting through `_ReportFilterSheet` and the chip `report-filter-type-completed-follow-ups`; no independent top-level report action exists. `test/report_center_page_test.dart` explicitly asserts the old standalone action is absent and the unified path opens the report.
- Audited Quick Capture behavior: `lib/quick_capture_dialog.dart` renders inline `errorText` and floating SnackBar feedback for an empty title. `test/quick_capture_dialog_test.dart` retains the named test and its two-visible-feedback assertion. No source/test modification was necessary for these two already-present behaviors at this checkpoint.
- Exact blob references: report source `0459fc0a1cfe239eb09fecdd7dd5d42c6ec0845d`; report test `18d5b59fae5d3f127d4ccaedb2963b55b0ad781b`; Quick Capture source `a6b0fa76cd1fed494b0e72d8f66e7db3e47e2a85`; Quick Capture test `875bac562caa55b60bfa2e3871f1e2e2b3ae6abf`.
- No runtime code or test files were changed in this documentation checkpoint. The new commit is documentation-only and requires fresh exact-SHA CI; earlier PASS results do not transfer automatically.
- Local working-tree status and local test execution: NOT VERIFIED.


## Device Smoke final recheck — 2026-11-06 (۱۴۰۵/۰۸/۱۵)
- Audited source/branch checkpoint: `49401bd4fcfa5622282d0fd80ec607d12daf467a`; Device Smoke run [42175115690](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42175115690) checks out this exact SHA on `fix/recovery-calendar-device-smoke-2026-10-31`.
- Latest GitHub run metadata remains `status=queued`, `conclusion=null`, updated at `2026-11-06T06:32:55Z`. Job-level state is authoritative for this snapshot: Preparation SUCCESS; Boot IN_PROGRESS; Navigation IN_PROGRESS; Calendar Segmented View QUEUED; Quick Capture QUEUED; Task Lifecycle QUEUED; Reminder/Vazirmatn QUEUED; Follow-up Persistence QUEUED.
- Seven requested product lanes are therefore **NOT COMPLETE / NOT ACCEPTED**. No lane has a terminal result available in this poll; do not convert IN_PROGRESS/QUEUED into PASS or FAIL.
- Artifact list for this run is empty. Screenshot upload steps have not completed. Fetching logs for Boot and Navigation returned HTTP 404 (BlobNotFound); this is unavailable log evidence, not proof of a product failure.
- No code, tests, workflow definitions, run state, or main-branch content was changed to obtain this report. No rerun, cancellation, retry, or fabricated device evidence was performed.
- Previous UI/source audit findings remain open until corrected and independently retested: Quick Capture description field remains present; Reports uses a filter sheet rather than the required visible five-filter row; Calendar does not render the required three-calendar date display; horizontal swipe changes the displayed period rather than transferring the event to the phone calendar; the Tafweez phrase/accessible label does not yet exactly match the newly mandated «وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ» wording. These are source-inspection findings, not outcomes of this Smoke run.
- Global Vazirmatn configuration and the two standalone SVG assets were observed in source; this does not establish physical-device glyph/rendering acceptance.
- PR #3052 remains OPEN / DRAFT / UNMERGED. Main remains `45e4202b03a434459e4c021a04efa7e8396359db`. Release remains **BLOCKED — RELEASE: NO-GO**.
- This entry is documentation-only. The active Smoke run remains bound to SHA `49401bd4fcfa5622282d0fd80ec607d12daf467a`; its results do not automatically transfer to a later documentation HEAD.

## Documentation synchronization — 2026-11-06 (۱۴۰۵/۰۸/۱۵)
- Updated continuity evidence only: CURRENT_STATE, IMPLEMENTATION_LOG, OPEN_ISSUES and the root continuation Ledger.
- No runtime source, tests, workflows, database schema, migration, Android package, or product behavior changed. The Smoke run remains associated with its original checkout SHA; no claim is made that the new documentation commit was device-tested.


## Device Smoke subsequent poll — 2026-11-06 (۱۴۰۵/۰۸/۱۵)
- A later GitHub job poll supersedes the earlier QUEUED snapshot in this document. Run `42175115690` remains on exact SHA `49401bd4fcfa5622282d0fd80ec607d12daf467a`; run-level status is `in_progress`, conclusion null.
- Preparation: SUCCESS. Boot: IN_PROGRESS. Navigation: IN_PROGRESS. Reminder/Vazirmatn: CANCELLED. Task Lifecycle: CANCELLED. Calendar Segmented View: CANCELLED. Quick Capture: CANCELLED. Follow-up Persistence: CANCELLED.
- Thus 0/7 product lanes have a terminal PASS; 5/7 are CANCELLED and 2/7 remain IN_PROGRESS. This is an incomplete/blocked run, not a seven-scenario success. Cancelled jobs expose no step summaries in the available endpoint; root cause NOT VERIFIED.
- Artifact list remains empty. Boot and Navigation are still inside the canonical smoke execution step; screenshot uploads remain pending. No final screenshot or device proof is available.
- Do not cancel or retry the two active jobs solely to manufacture a green matrix. Wait for their terminal results, then investigate cancelled lanes from available workflow/job diagnostics. No acceptance claim is permitted meanwhile.
- The documentation branch HEAD has advanced to include this note; the run is still bound to the pre-documentation code SHA above. PR #3052 remains OPEN / DRAFT / UNMERGED; main remains `45e4202b03a434459e4c021a04efa7e8396359db`; release remains **BLOCKED — RELEASE: NO-GO**.


## Device Smoke terminal result — 2026-11-06 (۱۴۰۵/۰۸/۱۵)
- Final poll of run [42175115690](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/42175115690): `status=completed`, `conclusion=cancelled`, checkout SHA `49401bd4fcfa5622282d0fd80ec607d12daf467a`.
- Preparation job SUCCESS. All seven product lanes ended CANCELLED: Boot, Navigation, Calendar Segmented View, Quick Capture, Task Lifecycle, Reminder/Vazirmatn and Follow-up Persistence. Final acceptance: **0/7 PASS; 7/7 CANCELLED; Device Smoke FAILS THE COMPLETION GATE / NOT ACCEPTED**. Cancellation is not evidence that product behavior failed; it is evidence that the scenarios did not complete.
- Artifact endpoint returned an empty list; no screenshot/device evidence was uploaded. Job-step summaries for cancelled lanes were empty. Earlier log retrieval attempts returned 404; cancellation initiator/root cause is **NOT VERIFIED** from the available evidence.
- Do not relabel cancelled lanes as skipped/pass, and do not infer a device test failure from cancellation alone. A fresh authorized run is required after investigating why this run was cancelled; preserve all tests/assertions and do not add timeout/skip/retry masking.
- Run is pinned to code SHA `49401bd4fcfa5622282d0fd80ec607d12daf467a`. Continuity docs were subsequently synchronized on the authorized branch; those documentation commits do not retroactively change the run's checkout SHA or make its result apply to the new HEAD.
- PR #3052 remains OPEN / DRAFT / UNMERGED. Main remains `45e4202b03a434459e4c021a04efa7e8396359db`. Release remains **BLOCKED — RELEASE: NO-GO**.


## ممیزی و اصلاحات UX / Home و فرم‌ها — ۱۴۰۵/۰۸/۱۵ (2026-11-06)

**Code checkpoint SHA:** `f614fab584cd149db7aa9234dbe825b14198c292`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR #3052:** OPEN / DRAFT / UNMERGED  
**main:** untouched  
**Release:** BLOCKED — RELEASE: NO-GO.

### Commits روی شاخه
- `6d7a48de45a4fc07a5f1c6dd70455e3484218ec8` — توکن‌های برند اصلی از بنفش/سرمه‌ای به آبی‌فیروزه‌ای تغییر کردند: primary `#087F8C`، header `#075E66`، soft `#DDF7F5`. رنگ‌های معنایی اولویت و taxonomy در تست توکن‌ها بدون تغییر باقی ماندند؛ رنگ SVG بسم‌الله `#1A2B4C` دست‌نخورده است.
- `1e63de1b39327ca569283a7bf6ea0cea9d328917` — ردیف انتخاب مرکز/پروژه/دسته/برچسب و ردیف موعد/یادآور/تکرار در ثبت سریع از اسکرول افقی به Wrap چندردیفی تغییر کرد؛ تست اندازه‌های 320 و 1024 پیکسل، نبود اسکرول افقی فرم را بررسی می‌کند.
- `c3e2b522ee72b74a4366648d09f19fc847a791f3` — نسخه اولیه Wrap برای taxonomy فرم کامل ثبت شد؛ ساختار این نسخه در کامیت بعدی اصلاح شد و این SHA به‌تنهایی مبنای پذیرش نیست.
- `5164319f5262e458ee85af127c83d3fc5bdd0d08` — ساختار Wrap فرم کامل اصلاح و برای Category / Project / Tag کلیدهای آزمون‌پذیر اضافه شد؛ چیدمان در عرض باریک دو ستونه و در عرض عریض سه‌ستونه است.
- `670e092f2bc4a0b3220f58d449a825637c1ea880` — عبارت نمایش پروژه به APIهای سازگار Dart محدود شد؛ از extension غیرضروری استفاده نمی‌شود.
- `f614fab584cd149db7aa9234dbe825b14198c292` — اولویت ثبت سریع تا انتخاب صریح کاربر `TaskPriority.none` است؛ تاریخ موعد و یادآور نیز بدون انتخاب کاربر null می‌مانند. تست عدم‌تولید پیش‌فرض‌ها افزوده شد.

### مواردی که پیش از این وجود داشتند
- هدر اصلی Home با منوی راست، SVG بسم‌الله، عنوان و زیرعنوان مرکزی و فیلتر عمومی چپ؛ کادر جستجو زیر هدر؛ ردیف پنج فیلتر RTL با مرتب‌سازی مستقل؛ پنج گروه زمانی؛ FAB و پنج مقصد Bottom Navigation از قبل در `lib/main.dart` وجود داشتند.
- مرتب‌سازی پیش‌فرض در Home از قبل `TaskListSort.lastFollowUp` با جهت صعودی بود. طبق قرارداد، موارد فاقد Follow-up پس از موارد تاریخ‌دار می‌آیند و تساوی با اولویت و سپس شناسه Task شکسته می‌شود. گروه‌بندی پنج‌گانه از Due Date استفاده می‌کند.
- فیلترهای Home از قبل منطق OR داخل بُعد و AND بین ابعاد را پیاده کرده بودند؛ آزمون موجود ترکیب Category و Tag را پوشش می‌دهد، اما پوشش کامل پنج بُعد و تمام ترکیب‌ها هنوز اثبات نشده است.
- مدل `PersonReference`، سرویس `TaskPeopleService`، فیلد `Task.people` و `FollowUp.personIds` و فیلتر اشخاص در Report Center از قبل وجود دارند؛ این به‌معنای وجود انتخاب/افزودن شخص در فرم Follow-up نیست.
- `allDay` برای Due Date از قبل وجود دارد؛ این وضعیت جایگزین پشتیبانی عمومی «بدون ساعت» در Follow-up و Reminder نیست.

### تطبیق Home و فرم‌ها — شکاف‌های باز
- **Home:** هدر، جستجو، فیلترها، گروه‌ها و navigation از نظر ساختاری موجودند. گروه «آینده» در کد عنوان تجمیعی دارد و نمایش تاریخ کامل برای آن هنوز نیازمند تطبیق دقیق با بند ۱۰ سند است. آزمون Home موجود viewport 320×640 و 390×844 را پوشش می‌دهد؛ آزمون DPR کسری 0.333px، بزرگ‌نمایی فونت و صفحه‌کلید برای Home هنوز اضافه/اجرا نشده است.
- **فرم کامل Task:** کنترل‌های Category / Project / Tag اکنون Wrap می‌شوند؛ انتخاب‌گر Center در این فرم هنوز وجود ندارد. Project دارای `centerId` است و نباید بدون انتخاب/رابط صریح، Center مستقل جعل شود.
- **اشتراک فیلترها:** ردیف Home از `ActionChip` و Report Center از بخش‌های مستقل `_Section` / `_MultiSelectChips` استفاده می‌کند. ادغام واقعی در یک جزء مشترک و یکسان‌سازی وضعیت/تعامل پنج فیلتر هنوز انجام نشده است؛ فیلتر شخص گزارش مستقل باقی می‌ماند.
- **Follow-up / Person:** فرم `FollowUpEntryPage` وضعیت «منتظر پاسخ» را ذخیره می‌کند، اما انتخاب شخص موجود/افزودن شخص جدید و تغییر/حذف پیوند شخص را در UI ارائه نمی‌کند. گزارش‌ها فقط از `personIds` موجود استفاده می‌کنند؛ آزمون ذخیره، بازگشایی و گزارش یک شخص واقعی هنوز انجام نشده است.
- **تاریخ/ساعت:** در چند فرم، انتخاب تاریخ و ساعت هنوز کنترل‌های جدا دارد. Due Date از `allDay` استفاده می‌کند، اما جریان واحد یک‌دکمه‌ای و گزینهٔ صریح «بدون ساعت» در همهٔ محل‌های اختیاری پیاده نشده است. پشتیبانی ذخیره/نمایش بدون ساعت برای Follow-up و عدم ساخت اعلان زمان‌دار بدون ساعت هنوز باز است؛ Due Date، Follow-up Date و Reminder Date مستقل باقی می‌مانند.
- **چیدمان تقویم:** تغییر قبلی به پیمایش عمودی و guard خطای startup در کد وجود دارد؛ این guard به‌تنهایی رفع منشأ RenderFlex را اثبات نمی‌کند. گزارش دستگاه با سرریز 0.333px در منابع قابل دسترس این ممیزی پیدا نشد؛ اصلاح منشأ و آزمون DPR کسری/فونت بزرگ/RTL هنوز NOT VERIFIED است.
- **SVG و فونت:** توکن رنگ بسم‌الله در Home حفظ شده است. وجود دو asset بسم‌الله و تفویض در مخزن به‌تنهایی اثبات path-only بودن، نبود عنصر text/raster، و render صحیح روی دستگاه نیست؛ این گیت‌ها باید با آزمون asset و screenshot تأیید شوند. Vazirmatn تنها فونت متنی مجاز باقی می‌ماند.

### وضعیت شواهد روی Code SHA بالا
- Build run `42261229876`: PENDING؛ در آخرین بررسی هنوز job آغاز نشده بود. بنابراین `flutter analyze` و مجموعه کامل تست‌ها روی این SHA نتیجه ندارند.
- Device Smoke run `42261230051`: PENDING؛ هنوز job و مدرک دستگاه/اسکرین‌شات ارائه نشده است.
- Follow-up File Persistence run `42261230162`: SUCCESS؛ checkout SHA دقیق تأیید شد؛ تست file-backed Repository و diagnostic بستن/بازگشایی SQLite هر دو SUCCESS شدند. این گیت محدود، جایگزین آزمون شخص/گزارش یا Device Smoke نیست.
- Calendar Provider run `42261229778`: IN_PROGRESS؛ آزمون instrumentation/provider در حال اجرا بود.
- Draft Review APK run `42261229806`: IN_PROGRESS؛ ساخت Staging APK در حال اجرا بود؛ در لحظه بررسی هیچ artifactی بارگذاری نشده بود. APK Debug مستقل ساخته/تحویل نشده است.
- نتیجهٔ orchestration/factory SUCCESS جایگزین Analyze، تست، APK، Device Smoke یا پذیرش مالک محصول نیست.

هیچ تست یا قابلیتی حذف، skip یا تضعیف نشده است. هیچ تغییر روی `main`، Merge، Release یا انتشار انجام نشده است. این ثبت مستندات، نتیجهٔ CI را به PASS ارتقا نمی‌دهد.


## آخرین اصلاح منبع چیدمان و آزمون‌های اندازه‌ناپذیر — ۱۴۰۵/۰۸/۱۵ (2026-11-06)

**Parent code SHA:** `9e1c9f3e4e52f5168fb3749195b32926fa28bc0a`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR #3052:** OPEN / DRAFT / UNMERGED  
**Release:** BLOCKED — RELEASE: NO-GO.

- Home header، search، filter row و active-filter chips اکنون داخل یک viewport عمودی قابل پیمایش با `FlexFit.loose` قرار می‌گیرند؛ در viewport کوتاه یا هنگام بازبودن صفحه‌کلید، محتوای کنترل‌ها به‌جای فشرده‌سازی اجباری و سرریز، در همان ناحیه پیمایش می‌شود. لیست کارها همچنان viewport مستقل Expanded دارد.
- آزمون‌های جدید منبعی برای Calendar و Home عرض منطقی 360.333px (1081 physical px در DPR=3)، فونت بزرگ 1.4، RTL و inset صفحه‌کلید Home اضافه شده‌اند. آزمون‌های Quick Capture و Task Editor نیز با بزرگ‌نمایی فونت اجرا می‌شوند.
- این‌ها آزمون‌های منبعی هستند؛ تا نتیجهٔ exact-SHA Build، هیچ‌کدام PASS محسوب نمی‌شوند و جای نصب روی دستگاه واقعی را نمی‌گیرند.
- گزارش دقیق مالک محصول از دستگاه فعلی (مدل دستگاه، مقیاس، مسیر صفحه، و screenshot مربوط به overflow 0.333px) در PR comments/Issue #823 comments و فایل‌های فعلی مخزن قابل بازیابی نبود. این خلأ به‌عنوان NOT VERIFIED ثبت می‌شود؛ گزارش قدیمی نصب APK از 2026-08-14 مربوط به PR دیگر است و مبنای این پذیرش نیست.
- Home spec چهارده‌بندی در منبع خوانده شد. بخش‌های ساختاری موجود (header، Bismillah SVG، search، پنج فیلتر و sort مستقل، گروه‌بندی Due Date، navigation پنج‌تب) از قبل پیاده بودند؛ تست‌ها و پذیرش بصری کامل هنوز لازم‌اند. شکاف‌های Center در فرم Task، یکپارچه‌سازی جزء فیلتر Home/Report، انتخاب Person در Follow-up و مدل/جریان بدون ساعت همچنان بازند.
- وضعیت runهای دقیق parent SHA `9e1c9f3`: Build `42261916395` PENDING بدون job؛ Device Smoke `42261916305` PENDING بدون job؛ Draft Review APK `42261916169` IN_PROGRESS؛ Calendar Provider `42261916279` IN_PROGRESS؛ Follow-up Persistence `42261916393` IN_PROGRESS. نتایج این runها فقط به همان SHA تعلق دارند.
- آزمون‌های قبلی روی SHA `f614fab` برای file-backed Repository و SQLite close/reopen هر دو SUCCESS بودند؛ نتیجه به SHA جدید منتقل نمی‌شود.

هیچ تستی حذف، skip، bypass یا تضعیف نشده است. main دست‌نخورده، PR OPEN/DRAFT/UNMERGED و انتشار NO-GO باقی می‌ماند.


## اصلاح خطای تحلیل و ساخت Quick Capture — ۱۴۰۵/۰۸/۱۵ (2026-11-06)

**Parent SHA:** `1c14c801a2b04cc70a4a617e2e7626d6c35d4331`  
**Evidence run:** Build `42262323182` on SHA `b5c8892a7aa5dad5d83abbf717bc19ea5c63140c`; Draft Review APK `42262323487` on the same SHA.

- Analyze در SHA `b5c8892` با سه خطای syntax در `lib/quick_capture_dialog.dart` شکست خورد: دو خطای positional arguments و یک پرانتز بسته‌نشده (log lines around 762, 833, 863). Staging APK نیز در مرحلهٔ compile Flutter با همان دو parenthesis mismatch شکست خورد؛ هیچ APKی upload نشد.
- علت: در تبدیل دو ردیف ثبت سریع به Wrap، یک لایهٔ بسته‌شدن `_surfaceCard` از هر بلوک جا افتاده بود. این مورد پنهان یا skip نشد؛ در این commit دو closure مربوط به هر دو Wrap کامل می‌شود.
- این اصلاح فقط syntax را ترمیم می‌کند؛ پذیرش layout هنوز منوط به Analyze و آزمون‌های exact-head است.
- SHA `b5c8892` همچنان FAIL برای Analyze و Review APK ثبت می‌شود؛ نتیجه به SHA جدید منتقل نمی‌شود.
- برای parent SHA `1c14c80`: Build `42262966593` PENDING، Device Smoke `42262966560` PENDING، Draft Review APK `42262966666` IN_PROGRESS، Calendar Provider `42262966580` IN_PROGRESS، Follow-up Persistence `42262966838` IN_PROGRESS. Artifactی هنوز ثبت نشده بود.

PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ هیچ merge یا release انجام نشده است؛ **BLOCKED — RELEASE: NO-GO**.


## Exact HEAD continuation — 2026-11-06 22:24 Asia/Tehran
- Authorized branch advanced through df5295fe2464d99cc5b2abe83515822ee7c136af and 5f8cfefcb849816f3d16936f4b6bbb0f77c4cf68.
- df5295fe: preserve Home no-Center matching, make full-form taxonomy controls responsive at larger text scale, keep Quick Capture priority unset by default, and omit the Gregorian year in the selected-day summary.
- 5f8cfef: align focused regression tests for date-only/time affordance, Semantics time label, RTL wrapping, unset Quick Capture priority, vertical scrollable discovery, scoped Home chip styling and Report Center filter-sheet scrolling.
- These are follow-up hardening/test-contract commits; they do not by themselves close all five gaps or prove device acceptance.
- Exact-HEAD workflows: Build 42274180002 pending; Draft Review APK 42274179979 in progress; Calendar Provider 42274179939 in progress; Device Smoke 42274179896 pending. No PASS is recorded before completion on this exact SHA.
- A prior assistant message showed a sandbox APK path for SHA 7644fc08; that path was not verified in this execution context. Do not treat it as a valid downloadable artifact. New-head APK and APK SHA-256 remain pending artifact publication and verification.
- PR #3052 verified OPEN / DRAFT / UNMERGED at HEAD 5f8cfefcb849816f3d16936f4b6bbb0f77c4cf68. No main update or merge.
- Release remains BLOCKED — RELEASE: NO-GO pending exact-head CI, verified APK artifact and owner physical-device acceptance.


## ۱۴۰۵/۰۸/۱۶ — ریشه‌یابی شکست‌های CI و اصلاحات پاسخ‌گو به لاگ (checkpoint)

- مبنای این ثبت: Build run `42335681385` روی SHA دقیق `d2e27baea747ddedf42f744297be09ab86753294`. مجموع شش شارد: ۱۲۳۴ تست موفق و ۲۴ تست ناموفق؛ شاردها به‌ترتیب `test-5: 2`، `test-4: 3`، `test-3: 7`، `test-2: 2`، `test-1: 9` و `test-0: 1` شکست داشتند. Analyze و Visual موفق بودند؛ شکست شش شارد، نتیجه Build را FAIL کرد.
- تفکیک علت‌ها از لاگ: کلید قدیمی Scroll در تست‌های Home، برچسب قدیمی ساخت پروژه، جست‌وجوی متن Tooltip به‌جای Tooltip finder، انتظار یک ردیف ثابت برای اولویت‌ها و نوع دکمه ذخیره قدیمی، ناسازگاری قرارداد آزمون با رابط فعلی بودند. سرریز ۴ پیکسلی سلول ماه Calendar و سرریز ۵۳ پیکسلی فرم Task Editor خطاهای واقعی layout بودند. خطاهای `No element` و `Too many elements` جداگانه ثبت شدند و تا اجرای مجدد exact-head PASS فرض نمی‌شوند.
- اصلاحات ثبت‌شده روی شاخه مجاز: `84aa643` افزایش ارتفاع سلول ماه به ۴۸dp و هم‌ترازسازی آزمون ایجاد پروژه؛ `8ada195`، `fc5debd` و `f965448` اصلاح قراردادهای آزمون Home/Calendar/Task Editor؛ `9b8e4cd` چیدمان عمودی کنترل تاریخ/ساعت در عرض بسیار باریک یا مقیاس متن بزرگ؛ `79fee1b` کلید پایدار ساخت مرکز/دسته؛ `2a777fe` هم‌ترازسازی آزمون‌های ایجاد درون‌فرمی؛ `52ecbef` افزودن راهنمای زمینه‌ای Calendar و اصلاح finder آزمون رنگ.
- این اصلاحات هنوز PASS محسوب نمی‌شوند؛ اجرای Build جدید برای SHA نهایی لازم است. هیچ تست یا قابلیت حذف، Skip یا عمداً تضعیف نشده است.
- شواهد SHA قدیمی `d2e27ba`: Calendar Provider run `42335681413` SUCCESS؛ Draft Review APK run `42335681420` SUCCESS؛ Device Smoke run `42335681478` CANCELLED. Artifactهای Staging/Debug از Build همان SHA موجودند؛ digest گزارش‌شده GitHub مربوط به ZIP آرشیو است و **SHA-256 خود APK نیست**.
- SHA فعلی این ثبت: `52ecbef18d7bbc26d2915270e28297d272342634`. Build `42336933347` و Device Smoke `42336933508` در صف و بدون Job؛ Draft Review APK `42336933225` در حال اجرا؛ Calendar Provider `42336933308` در حال اجرا پس از تأیید SHA؛ Follow-up Persistence `42336934664` در حال اجرا. هیچ‌یک هنوز PASS نیستند.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ Merge و انتشار انجام نشده؛ **BLOCKED — RELEASE: NO-GO** تا قبولی همه دروازه‌ها روی یک SHA، Device Smoke کامل و پذیرش روی گوشی واقعی.


## اصلاحیه وضعیت exact-HEAD — ۱۴۰۵/۰۸/۱۶

- پس از ثبت checkpoint قبلی، دو اصلاح تکمیلی آزمون ثبت شد: آزمون تاریخ تقویم تعداد دو نمایش معتبر تاریخ را صریحاً می‌سنجد؛ آزمون رنگ Home تمام لایه‌های AnimatedContainer کارت را بررسی می‌کند، نه یک لایهٔ تصادفی.
- آخرین SHA کد/آزمون پیش از همگام‌سازی اسناد: `0d6ac9f44debc6ca6955f8940826979604f3636b`. این ثبت اسناد، commit بعدی و فقط مستندسازی است؛ هیچ نتیجه CI از SHA قبلی به HEAD مستندات منتقل نمی‌شود.
- برای HEAD نهایی پس از این ثبت، Build شش‌شارد، Draft Review APK، Calendar Provider، Follow-up Persistence و Device Smoke باید دوباره اجرا و جداگانه بررسی شوند.
- اصلاحات کد و آزمون تا این نقطه ثبت شده‌اند؛ **رفع‌شدن شکست‌ها هنوز تأیید CI ندارد**. آزمون گوشی واقعی و پذیرش مالک محصول نیز انجام/اثبات نشده‌اند.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched؛ بدون Merge و انتشار؛ **BLOCKED — RELEASE: NO-GO**.


## اصلاحیه تکمیلی Home — ۱۴۰۵/۰۸/۱۶

- commit کد/آزمون بعد از checkpoint قبلی: `467e7f76aced41a123f00a99dd334f32f09ad70c`.
- آزمون Quick Capture اکنون رفتار واقعی محصول را بررسی می‌کند: پس از ثبت، فرم عمداً باز می‌ماند؛ ابتدا ذخیره و حفظ تاریخچه از Store بررسی می‌شود، سپس فرم بسته و نمایش Task در Home تأیید می‌شود.
- Finder پیمایش آزمون کارت Home به Scrollable داخل `home-task-list-viewport` محدود شد تا به Scrollable نامرتبط/غایب در بخش‌های دیگر وابسته نباشد.
- این تغییرات فقط اصلاح آزمون بر اساس قرارداد فعلی‌اند؛ بررسی ذخیره واقعی، حفظ تاریخچه و نمایش Home همچنان باید با اجرای تازه Build روی HEAD نهایی تأیید شوند.
- آخرین نتایج قبلی Build متعلق به SHA `d2e27ba` هستند و برای این commit یا HEAD بعدی اعتبار ندارند. وضعیت انتشار همچنان **BLOCKED — RELEASE: NO-GO** است.


## اصلاحیهٔ هدف لمس Quick Add — ۱۴۰۵/۰۸/۱۶

- آخرین commit کد/آزمون: `c0b3715f16b4fd46e67a2c157559f1de71e2d812`.
- چهار گزینهٔ اولویت Quick Add از ارتفاع ۴۰dp به ۴۸dp رسیدند تا حداقل هدف لمس ۴۸dp رعایت شود.
- ماتریس آزمون Quick Add اکنون عرض‌های ۳۶۰، ۳۹۰ و ۴۱۲dp را با مقیاس متن بزرگ بررسی می‌کند و برای هر چهار گزینه، عرض و ارتفاع حداقل ۴۸dp را assert می‌کند.
- این تغییر به‌همراه اصلاحات قبلی Calendar و Task Editor هنوز در انتظار اجرای مجدد روی HEAD نهایی است؛ تا دریافت نتیجه، PASS محسوب نمی‌شود.
- وضعیت انتشار: **BLOCKED — RELEASE: NO-GO**؛ PR #3052 OPEN / DRAFT / UNMERGED؛ main untouched.


---

## ابلاغ Master و وضعیت اجرایی — ARVIN-DIR-1405/08/16-02-MASTER
**ثبت: ۱۴۰۵/۰۸/۱۶ | شاخه مجاز PR #3052**

- PRODUCT FIRST: نقص محصول در کد محصول رفع می‌شود؛ هیچ آزمونی حذف، Skip یا تضعیف نمی‌شود. اصلاح Finder فقط برای قرارداد واقعاً منسوخ و با حفظ پوشش رفتاری مجاز است.
- فونت یگانه رابط: **Vazirmatn**؛ بررسی `pubspec.yaml`، `lib/theme/app_fonts.dart` و `lib/theme/font_registry.dart` فقط همین خانواده را نشان می‌دهد.
- تم روشن فیروزه‌ای: Primary `#078B91`، Header `#066F75`، Soft `#DDF7F5`، Background `#F0FAF9`، Border `#D9ECEA`. رنگ‌های خطا/اولویت و وضعیت برای معنای وضعیت حفظ می‌شوند.
- SVG بسم‌الله با عرض نمایشی `210dp` حفظ شده؛ آزمون عرض ۲۱۰dp اضافه شده است.
- ترتیب فیلترهای Home: زمان ← مرکز ← پروژه ← دسته ← برچسب؛ مرتب‌سازی جدا و پس از پنج فیلتر است؛ Wrap راست‌به‌چپ و بدون پیمایش افقی.
- «پیگیری‌های انجام‌شده» فقط از بخش «نوع گزارش» در پنل فیلترها انتخاب می‌شود؛ دکمهٔ بالای صفحه وجود ندارد و آزمون آن را کنترل می‌کند.
- Calendar: محتوای سلول ماه درون سلول مقیاس می‌شود و هدف لمس حداقل ۴۸dp حفظ می‌شود؛ ارتفاع اضافهٔ نمای هفتگی کاهش یافته است.
- Task Editor و Quick Capture برای ۳۶۰/۳۹۰/۴۱۲dp، کیبورد باز/بسته و متن بزرگ پوشش آزمون دارند؛ کنترل‌های اولویت Quick Add حداقل ۴۸dp هستند.
- ایجاد مرکز/دسته/برچسب در Quick Capture دیگر کنترل متن موقت را پیش از پایان انیمیشن Sheet آزاد نمی‌کند؛ Sheetها قابل پیمایش‌اند.
- کامیت‌های کد/آزمون: `9de8f221`, `7125e828`, `895c7ad`, `21606a9`, `9946f15`, `4a64d50`, `4f65800`.
- Build روی SHA قبلی `21606a9f3050337d57c0ada2ca4c14c2febe907f` به‌علت توکن تعریف‌نشدهٔ `ArvinTheme.primarySoft` در Analyze/Visual و شاردها شکست کامپایل داشت؛ Follow-up Persistence run `42339727992` نیز به همان علت شکست خورد. توکن مرکزی در commit `4a64d50` تعریف شد؛ نتایج SHA قدیمی به SHA جدید منتقل نمی‌شوند.
- آخرین کد/آزمون پیش از این ثبت: `4f65800612bd0cce95448f39eee67d683e0e6504`. اجرای اختصاصی این SHA هنوز در فهرست GitHub ظاهر نشده؛ هیچ PASS برای آن ادعا نمی‌شود.
- فایل مستقل Master در پیوست‌های این گفتگو یا جست‌وجوی Library پیدا نشد؛ این یادداشت بر متن ابلاغ‌شده در گفتگو متکی است، نه بر ادعای مطالعهٔ فایل پیوست‌نشده.
- PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ `main` بدون تغییر؛ Merge و انتشار ممنوع. Device Smoke و پذیرش نصب واقعی هنوز مانع‌اند.
- **BLOCKED — RELEASE: NO-GO** تا Build، تمام شاردها، Provider، Persistence، Device Smoke و پذیرش گوشی واقعی روی یک SHA واحد PASS شوند.


## پیوست اصلاحیه Master — ۱۴۰۵/۰۸/۱۶

- کامیت تکمیلی محصول پس از ثبت قبلی: `f255dfdf9e25a600886c5ff07b990f20c3fa6475`.
- سطح خالی کارت‌های فیلتر و لهجهٔ سربرگ پنل فیلتر نیز به توکن فیروزه‌ای/سطح خنثی مشترک منتقل شد؛ رنگ‌های برند غیر فیروزه‌ای در کنترل‌های فیلتر باقی نماند.
- آخرین کد پیش از این به‌روزرسانی اسناد: `f255dfdf9e25a600886c5ff07b990f20c3fa6475`. نتیجهٔ CI این SHA تا لحظهٔ ثبت این پیوست هنوز قابل تأیید نیست؛ PASS از SHAهای قبلی به آن منتقل نمی‌شود.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ بدون Merge/انتشار؛ **BLOCKED — RELEASE: NO-GO**.


## 2026-11-07 — ادامه اصلاح تجربه کاربری تم و کنترل‌های زمان (شواهد پذیرش در انتظار)

**Source checkpoint before documentation sync:** `9e66820d161131b947bcc91cf333b3acf426a51c`  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31` · **PR #3052:** OPEN / DRAFT / UNMERGED  
**Release:** BLOCKED — RELEASE: NO-GO

### تغییرات ثبت‌شده
- پالت انتخابی کاربر در `AppThemeManager` بدون تغییر باقی مانده است: گزینه ۸ و پیش‌فرض `#3A86EF`. توکن‌های پایهٔ فیروزه‌ای رابط (`#078B91`، `#066F75`، `#DDF7F5`) از رنگ انتخابی کاربر جدا شده‌اند؛ این کار پیش‌فرض پالت را تغییر نمی‌دهد و سطوح روشن/فیروزه‌ای را از accent انتخابی مستقل نگه می‌دارد. Source: `lib/core/theme/arvin_theme.dart`، commit `a58098c0a6a6afcc55ec194a751961fd1bad9848`.
- رنگ زندهٔ Theme به Home filter pill/card/chip و sheet، پوستهٔ Home، دکمهٔ افزودن، انتخاب‌گرهای taxonomy، Quick Capture، Task Details و کنترل‌های Report Center متصل شد. Source commits: `93d4cf75`, `a133fa8a`, `1e9db5fe`, `f7f3ceca`, `901078af`, `7932da2e`, `2261d28d`, `a2d54f27`, `fb47dfba`, `62b82598`, `89e7e914`, `01caa0d4`, `561a8b2e`, `dd968b25`, `9e66820d`.
- ترتیب پنج فیلتر Home در ردیف RTL از راست به چپ به زمان، مرکز، پروژه، دسته و برچسب تنظیم شد و کل ردیف کلید آزمون پایدار گرفت. Source: `lib/main.dart`, commit `dffefdd1bd0e32e1405f3c7a95fa405263eafd3d`.
- کنترل موعد Task Editor و Quick Capture از فهرست میانی انتخاب‌ها خارج شد: لمس کنترل مستقیماً تقویم شمسی را باز می‌کند و پس از تأیید تاریخ، ساعت‌گرد باز می‌شود. انتخاب «بدون ساعت» همچنان فقط داخل ساعت‌گرد است؛ لغو انتخاب ساعت، تاریخ نیمه‌کاره را ثبت نمی‌کند. Source commits: Task Editor `5650c5e152465c6df557739a130c42a887f5eb6d`، Quick Capture `65c319f2cf265dc4e6a06d88fa97ed18b0a5b198`.
- رنگ برند Task Details و Task Editor به Theme زنده متصل شد. Source commits: `6cff0d92`, `aff66d4e`.
- آزمون Home برای ردیف پنج‌فیلتر از انتظار Wrap قدیمی به قرارداد تک‌ردیفهٔ بدون پیمایش افقی در ۳۶۰/۳۹۰/۴۱۲dp و کیبورد باز تغییر کرد؛ حداقل عرض/ارتفاع ۴۸dp و نبود overflow بررسی می‌شود. Test commit: `ce0c68097d2bc183785c755aa5c6b2a27bb20e8f`؛ import test: `ed7a4c7f0735f1f703d5650819cdd4f4a272c069`.
- آزمون Theme filter به‌جای ActionChip قدیمی، رنگ زندهٔ Theme و هدف لمس ۴۸dp را برای کامپوننت واقعی می‌سنجد. Test commit: `d9b2df3ab6e5cdf5cb0588b8abc729ee5a2e6797`.
- آزمون‌های Task Editor و Quick Capture برای جریان تک‌لمسی تاریخ ← ساعت‌گرد و «بدون ساعت» به‌روزرسانی شدند؛ test commits: `8235c5142ff94205a484054caae62538ca6cda54` و `0ebf6790579caaec031ffed38324975b087b45e8`.

### وضعیت پذیرش و موارد باز
- Analyze روی SHA پیشین `8300e473a49c4e0b574cfd764ba31baf0ee472e3` PASS بود؛ هر شش Shard همان SHA FAIL بودند. این نتایج برای source checkpoint حاضر معتبر نیستند.
- Build/Review/Device Smoke برای source checkpoint حاضر در لحظهٔ ثبت هنوز نتیجهٔ نهایی نداشتند؛ اجرای بعدی پس از این ثبت اسناد باید روی SHA نهایی خوانده شود. هیچ PASS به این SHA منتقل نمی‌شود.
- رنگ زنده در تمام مصرف‌کننده‌های اختصاصی، Report Center و سایر فرم‌ها هنوز نیازمند ممیزی/آزمون کامل است؛ وضعیت را «اتصال بخش‌های نام‌برده‌شده انجام شده، پذیرش سراسری تأییدنشده» نگه دارید.
- آزمون‌های person-specific FollowUp/Report، category clear، Reminder All-Day، ردیف Home و چند تست Quick Capture/Task Editor در Run قبلی شکست داشتند؛ علت‌ها و اصلاحات باید با Run تازه بررسی شوند. تست‌های مربوط به زمان و تمام‌روز فقط روی SHA دقیق خودشان معتبرند.
- همگام‌سازی محلی P2P همچنان در حد طراحی/برنامه است؛ امنیت جفت‌سازی، لغو دسترسی، تعارض و انتقال دوسویه روی دو دستگاه اثبات نشده است. فاز ابری برنامهٔ آینده است.
- Device Smoke فیزیکی و تصویر نصب/تعامل روی Samsung SM-A528B/DS تأییدنشده است.

PR #3052 باید OPEN / DRAFT / UNMERGED بماند؛ main دست‌نخورده؛ بدون Merge یا انتشار؛ فونت Vazirmatn و قرارداد SVG عبارات مقدس حفظ شود. **BLOCKED — RELEASE: NO-GO**.


## 2026-11-07 — اصلاح اعتبارسنجی یادآور تمام‌روز در پیگیری
- در `lib/follow_up_entry_page.dart` اعتبارسنجی یادآور تمام‌روز از ساعت مصنوعی ۹ صبح به مقایسهٔ تاریخ تقویمی تغییر کرد؛ یادآور تمام‌روز برای امروز صرفاً به‌دلیل سپری‌شدن ساعت ۹ رد نمی‌شود. زمان‌دارها همچنان باید در آینده باشند.
- Source commit: `0e63449dd122065314c97f7d81f320dfccca3460`.
- آزمون مرتبط `test/follow_up_entry_page_test.dart` از قبل حالت تمام‌روز و ذخیرهٔ Reminder را پوشش می‌دهد؛ اجرای exact-SHA این اصلاح هنوز در انتظار نتیجه است. Run Build `42361252514`، Draft Review APK `42361252886`، Device Smoke `42361252423` و Persistence `42361252554` در زمان ثبت Pending/Queued هستند؛ هیچ‌کدام PASS محسوب نمی‌شوند.
- PR #3052 OPEN / DRAFT / UNMERGED؛ main بدون تغییر؛ **BLOCKED — RELEASE: NO-GO**.


## 2026-11-07 — تثبیت تست‌های شش‌شارد و شناسنامه APK بازبینی (abecec1)

- شاخه مجاز: `fix/recovery-calendar-device-smoke-2026-10-31`.
- Source commit: `abecec1ec895e6c7df83913247c1cc9ecc083d02` — اصلاح Finder تست `issue 1891 tag roll box` بدون حذف یا تضعیف assertionها.
- Build run `42370095017`: نتیجه کلی SUCCESS؛ Analyze و Visual نیز SUCCESS.
- شمارش قطعی شش شارد از لاگ‌ها: Shard 0 = 224، Shard 1 = 185، Shard 2 = 308، Shard 3 = 145، Shard 4 = 236، Shard 5 = 173؛ جمع 1,271/1,271؛ ALL SHARDS PASSED = YES.
- تست `issue 1891 tag roll box supports multi-select with apply/cancel` در Shard 4 موفق شد.
- Staging review artifact: Run `42370095057`، Artifact ID `13573433210`. APK استخراج و هش روی خود فایل اجرایی محاسبه شد:
  - File: `Arvin-review-staging-abecec1ec895e6c7df83913247c1cc9ecc083d02.apk`
  - SHA-256: `6e259567386481fa14621bd35d133a4d7f1959bb9ff6a0820ac4a994c583cbc2`
  - Size: 79,120,215 bytes = 75.455 MiB (79.120 MB decimal).
  - applicationId: `com.example.arvin.staging`; `android_debuggable=false`; V2/V3 signature verification passed.
  - Signing key is ephemeral/review-only; `publishable=false`. This is not a release APK.
- Device Smoke Run `42370095088` targets the exact source SHA above but remains PENDING; latest job query returned zero jobs. The workflow definition has `pull_request` triggers (opened/synchronize/reopened/ready_for_review) and `workflow_dispatch`; its matrix jobs run on GitHub-hosted `ubuntu-latest` and provision Android API 35 emulator through the emulator-runner action. Therefore no evidence currently indicates a dedicated self-hosted emulator runner is the blocker. The run appears not to have progressed to job creation; the exact scheduler/approval/concurrency cause is not exposed by available run/job evidence and remains UNKNOWN.
- A manual workflow-dispatch / full-run rerun was not issued: the available GitHub actions expose job-level rerun and failed-job rerun only; this pending run has no jobs to rerun. Do not report a retry as triggered. Manual `workflow_dispatch` with `target_sha=abecec1ec895e6c7df83913247c1cc9ecc083d02` remains the supported workflow-level route when an authorized GitHub Actions dispatch control is available.
- PR #3052 must remain OPEN / DRAFT / UNMERGED. main remains at `45e4202b03a434459e4c021a04efa7e8396359db`; no merge or main update. Release remains **BLOCKED — RELEASE: NO-GO** until Device Smoke and all remaining acceptance gates pass on one exact candidate SHA.


## Parallel execution checkpoint — 2026-11-07 — source 6fa57ce

- Source fix: removed the unused `_dateRollBox` declaration from `lib/task_editor_dialog.dart`; source commit `6fa57ce5231f73d67304bed46263a02af1e1cb90`, exact message: `fix(analyzer): remove unused _dateRollBox in task_editor_dialog`. No tests were changed, deleted, skipped, or weakened by this source commit.
- Exact-SHA GitHub Actions run: `42406373769`; Analyze job `128504856906` completed **SUCCESS**. The Flutter Analyze step itself is **SUCCESS**. This confirms the prior unused-element warning is resolved on source SHA `6fa57ce5231f73d67304bed46263a02af1e1cb90`.
- Test shards are independent. At this checkpoint, Shard 1 job `128504856909` is still `IN_PROGRESS`; Shard 2 is `IN_PROGRESS`; Shard 3 and Shard 4 have completed with `FAILURE`; Shard 5 test step has failed while its job is still finishing. Do not treat the earlier completed Shard 1 run as current-SHA acceptance evidence.
- Latest completed Shard 1 evidence available at checkpoint: run `42405042863`, job `128500803200`, source SHA `44f4dfbbb3db846765d4ea2e67dffa263aa4cac2`; result **173 passed / 14 failed**. Analyze in that shard was skipped by workflow design; the dedicated Analyze job is the authoritative check.
- Previous Shard 1 failures, exact test titles and failure messages:
  1. `test/task_detail_followup_flow_test.dart:151` — `inline description edit updates updatedAt and preserves completion and Follow-up history`: expected `DateTime(2026-11-02 12:00:00)`, actual `null`.
  2. `test/integration_task_reminders_migration_backup_test.dart:36` — `deleted migrated legacy reminder does not return after SQL and backup restore`: expected ID `legacy-task-reminder-task-reminder-integration`, actual ID `legacy-task-reminder-deleted-legacy-reminder`.
  3. `test/widgets/home_page_test.dart:193,198,200` — `Home uses the five checkbox filters as combined filters and preserves time grouping`: horizontal `RenderFlex overflowed by 158 pixels on the right`; interaction assertions failed.
  4. `test/services/task_migration_writer_test.dart:122` — `Home snapshot deletes omitted items and serializes new items canonically`: expected `true`, actual `null`.
  5. `test/services/home_today_projection_test.dart:55` — `legacy scheduling fields alone never create a Home FollowUp entry`: expected `DateTime(2026-08-27 08:00:00)`, actual `null`.
  6. `test/services/g1_drift_schema_test.dart:132` — `materializes multiple Task reminders, historical Follow-ups and Persons canonically`: SQLite error `Invalid argument (parameters): Expected 3 parameters, got 2`.
  7. `test/services/calendar_inbound_sync_service_test.dart:54` — `retired inbound reconciliation never mutates native Task ownership`: expected ID set containing `legacy-task-reminder`, actual contains `legacy-task-reminder-task-1` instead.
  8. `test/follow_up_repository_test.dart:48` — `appends a FollowUp while preserving the task envelope`: expected `DateTime(2026-08-14 09:30:00)`, actual `null`.
  9. `test/task_editor_dialog_test.dart:220` — `Task editor saves a new follow-up record with separate title and note`: expected `false`, actual `true`.
  10. `test/task_detail_metadata_selector_test.dart:42,45,48` — `Task Details category and tags use shared filter selectors`: expected category `شخصی`, actual `کاری`; also horizontal overflow by 158px.
  11. `test/follow_up_reminder_projection_test.dart:51` — `only independent TaskReminder records enter the projection`: expected collection length 1, actual length 2.
  12. `test/reusable_multi_select_filter_bottom_sheet_test.dart:50,53` — `multi-select sheet persists inline-created option and auto-selects it`: expected set `['new-شخصی', 'work']`, actual `null`; also horizontal overflow by 158px.
  13. `test/report_center_page_test.dart:246,253,256` — `Report Center shows separate person-specific active waiting rows`: expected text `نتیجه: 1 پیگیری` not found; also horizontal overflow by 158px.
  14. `test/task_edit_apply_service_test.dart:100` — `metadata edits preserve completion timestamp without future follow-up schedule`: expected `true`, actual `false`.
- Initial root-cause grouping (diagnostic hypotheses, not yet proven): (a) 158px horizontal overflow and resulting unreachable controls in shared filter/UI layout; (b) null/mismatched timestamp or snapshot values in Task/Follow-up editing and projection; (c) legacy reminder identity/migration normalization mismatch; (d) Drift insert SQL placeholder/bind count mismatch; (e) multi-select inline-created value not persisted/selected; (f) report projection missing the expected person-specific row. Fix production behavior and retain all regression tests; do not weaken assertions to match defects.
- Universal filter contract: `ReusableMultiSelectFilterBottomSheet`; checkbox multi-select; OR within a dimension and AND across dimensions; inline creation auto-selects the new value; active-selection count badges; dimensions Time, Center, Project, Category and Tag where applicable.
- Typography contract: **Vazirmatn**. Default accent color: **#3A86EF** (palette option 8); do not confuse this dynamic accent with legacy semantic teal tokens.
- Governance: PR #3052 remains **OPEN / DRAFT / UNMERGED**; `main` remains `45e4202b03a434459e4c021a04efa7e8396359db`; release remains **BLOCKED — RELEASE: NO-GO**. No merge, publication or release.
- Documentation synchronization itself changes the branch SHA; all exact-SHA acceptance gates must be checked again on the resulting documentation commit. Current physical Samsung SM-A528B/DS Device Smoke is not claimed as passed.


## CI completion addendum — Run 42406373769 — 2026-11-07

- This addendum supersedes the in-progress Shard 1 status above. On source SHA `6fa57ce5231f73d67304bed46263a02af1e1cb90`, Shard 1 job `128504856909` has now completed with **FAILURE: 173 passed / 14 failed**. The 14 failed test titles and failure messages are the same 14 listed above; no new failure category appeared in this shard. Analyze job `128504856906` on the same SHA completed **SUCCESS**.
- The Shard 1 UI overflow is now directly localized in the reusable filter sheet: the log for `test/reusable_multi_select_filter_bottom_sheet_test.dart` identifies `Row` at `lib/widgets/reusable_multi_select_filter_bottom_sheet.dart:206:17` and reports `A RenderFlex overflowed by 158 pixels on the right`. This is confirmed for that test. Other UI tests report missed hit-tests at filter/apply controls; verify each affected screen against the shared component before assigning a common cause.
- Shard 1 is therefore **not green**. The source Analyze fix is verified, but the full quality gate remains failed until all 14 regressions are fixed without weakening tests.
- Documentation commit `cb89261753adc2d935798e85d0a3ed8b9ef66b37` was created after the source run; no workflow run for that documentation SHA was visible at the time of this addendum. Re-check exact-SHA CI for the documentation commit; do not transfer PASS from source SHA `6fa57ce` to the documentation SHA.


## REV7.2 documentation and live audit checkpoint — 2026-11-10

- Audited live GitHub refs for Main, authorized branch and PR #3052. Main SHA 45e4202b03a434459e4c021a04efa7e8396359db; branch/PR head b789343c9699ca440d043d71d47db3dcdfafa57c. PR remains OPEN/DRAFT/UNMERGED; compare 2,129 ahead / 0 behind.
- Confirmed active Main protection ruleset main-protection; Main remains read-only. No local working-tree evidence is available from GitHub.
- Reconciled source-of-truth authority: live GitHub is operational truth; historical ZIP is archive-only and not a prerequisite.
- Read all seven existing continuity documents. MASTER_GOVERNANCE.md was absent; MASTER_CHARTER.md was also absent at the checked canonical path. No history was deleted; existing docs receive this checkpoint addendum.
- Audited Task/Reminder/Follow-up, Drift schema v16, TaskStore, recurrence/checklist history, filters, Home grouping/sorting, Notebook, Task Templates, Calendar Provider and reports on exact SHA b789343c9699ca440d043d71d47db3dcdfafa57c.
- Key gaps: no four-state Reminder semantics in TaskReminder; TaskTemplate omits Task dueDate and reviewed instantiation does not assign center/project membership; Notebook hard-delete/unlink and first-save auto-title not proven; app-wide 48dp compliance not proven; complete Home sort surface not proven; actual user DB migration/backup not inspected.
- Registered owner decision ARVIN-DEC-2026-11-10-001: Task Details always-editable auto-save, APPROVED. Implementation and verification remain PARTIAL pending exact tests.
- Build run 42763952581: Analyze, Visual, Debug APK, Release APK build, Staging APK audit PASS; all six test shards FAIL, 1,295 passed / 79 failed. Exact failures listed in OPEN_ISSUES.md.
- Follow-up Persistence 42763952346 PASS; Calendar Provider Acceptance 42763952813 PASS; Device Smoke 42763952498 incomplete (Preparation PASS, Boot IN_PROGRESS, six lanes queued).
- NIRA: main SHA 7a27ee63b65d343e45c5786f782f2567611722dc; Main Closure 42777826931 PASS; Queue Scheduler 42777810609 FAIL; L10 remains UNVERIFIED per NIRA README.
- No executable code, test, schema, migration, workflow or security configuration changed. This record is documentation-only.
- Release remains BLOCKED — RELEASE: NO-GO.


## REV8 — Repository-wide forensic inventory and documentation consolidation — 2026-11-10

- Source SHA before this audit documentation commit: 9846f10850031c63964fdc81ae0ab1cdb3028517; Main SHA: 45e4202b03a434459e4c021a04efa7e8396359db.
- Enumerated all 1,412 Arvin branches, all 1,238 PRs, 1,812 Main-reachable commits, and 2,130 PR-ahead commits via GitHub pagination/Compare API.
- Inventoried 302 Arvin test files and 23 NIRA factory test files. Current Build exact-head result: 1,296 passed / 78 distinct failed labels.
- Reconciled 25 working-branch workflows vs 23 Main workflows; 259 docs files vs 209 Main; 33 continuity docs; 99 internal continuity links checked, zero broken.
- Registered 35 duplicate branch-head groups/109 refs, 33 reused PR-head branch groups/72 PR records, repeated commit subjects/tree-SHA candidates, legacy docs, and NIRA state-sync churn.
- NIRA: 112 branches, 7 open PRs, 381 closed PRs, 132 Main commits, 26 workflows, 23 factory tests; Queue Scheduler run 42777810609 failed on issue #162 comment limit; L10 remains UNVERIFIED.
- Documentation-only audit artifacts are stored under docs/project-continuity/audit/. No executable source, tests, schema, migrations, workflows, security settings, branch/PR metadata, Main, merge, release or user data were changed.
- Exact current CI evidence is in audit/CI_HISTORY_AUDIT.md; all SHA references and their scope are in audit/SHA_RECONCILIATION.md.


## WAVE 4 REV8 implementation entry — 2026-11-10

Owner authorization: AUDIT + IMPLEMENTATION + TESTING; prior read-only Wave 4 status superseded.

Implementation checkpoint SHA: `dbfcdb02879ed3939cb6a69d3a150e2237283a51`.

Changed source areas:
- `lib/services/sql_task_migration_writer.dart`: pre-COMMIT row/field/relation/envelope/foreign-key parity and same-ID conflict rejection.
- `lib/services/task_store.dart`: removed post-COMMIT ID-only validator; relational Recurrence and Occurrence reads/writes; retained legacy recurrence payloads during the retirement gate.
- `lib/services/g1_drift_schema.dart`: Recurrence/Occurrence tables and legacy migration; disabled unproven table drops/rebuilds.
- `lib/services/project_store.dart` and `sql_project_migration_writer.dart`: unified migration writer, relational Project ordering, parity and unknown-field preservation.
- New `occurrence_sql_codec.dart` and `recurrence_sql_codec.dart`.
- Added/updated Task migration, Project migration, schema and round-trip tests.

Verification on the implementation checkpoint was pending at last lookup; no test PASS is claimed. Reports: P0_C_IMPLEMENTATION_REPORT, SQL_ONLY_CONSOLIDATION_REPORT, MIGRATION_PARITY_REPORT, OCCURRENCE_DATA_OWNERSHIP_REPORT, BACKUP_RESTORE_VALIDATION, TEST_VALIDATION_REPORT and LEGACY_RETIREMENT_REGISTER under `audit/`.


## 2026-11-12 — COMMAND 07-A.2.21 typography / SQLite checkpoint

- Canonical typography updated to VazirHarf v34.003 UI-Farsi-Digits, five approved weights, upstream pinned source and bundled SIL OFL 1.1 license. Historical Vazirmatn files were retained, not deleted.
- Commit 7ca218a8a533c4faf68a2895d7740b241535a447 restored canonical font assets/configuration and expanded D02 explicit-true coverage.
- Commit 907df7568bd9c1a46a6307e9a587d740a9f3afcb aligned remaining runtime font references and analyzer lint.
- Commit 3490d753d0bbbc87eef489e641ab8c9f46892197 adjusted Home, checklist and PDF test fixtures to the active product contracts.
- Commit a1e6ff7bfa0183983b63a6fc8e59b80f8c0b28f3 removed SQLite snapshot test lint without weakening assertions.
- Commit b9d88bf0381030b5d2fd21aa82436678a65b518a restored typed Snapshot C/D guards. On this SHA, the five-cycle SQLite snapshot workflow and file-backed Follow-up persistence workflow passed. Artifact digests are recorded in CURRENT_STATE.
- Build Analyze on b9 failed because Checklist test imports followed a declaration and the scroll helper was duplicated; Commit 9a48e1527e3180380982c4d9af2e1e2724d59f36 removed the duplicate and restored imports to the directive section. Fresh exact-SHA Analyze is pending.
- No Merge, Release or Deployment was performed. No production/user database was accessed; SQLite evidence uses isolated temporary file-backed fixtures.


## COMMAND 07-A.2.24 continuity audit — 2026-11-12

- Re-read live repository HEAD, branch refs, PR #3380/#3382/#3384/#3388, ruleset and exact-head workflows.
- Confirmed PR #3384 head `cbf7d241e588c6b4b6051dea5bb3d309a8c3cb05` and base `8c4c23f0c2a4f9b2374a2092c931782c4455fd41`.
- Confirmed VazirHarf runtime registration and PDF font loading on this branch conflict with the latest owner-approved Vazirmatn decision.
- Confirmed exact-head Build failure (43202151547), SQLite Snapshot success (43202151552), Follow-up File Persistence success (43202151499), Device Smoke queued (43202151481), Draft Review APK skipped (43202151478).
- No source-code remediation or SQLite acceptance is claimed by this log entry. Historical evidence preserved.


## COMMAND 07-A.2.25 — 2026-11-12

Canonical typography authority: `docs/architecture/ARVIN_TYPOGRAPHY_CONTRACT.md` (recorded on documentation PR #3388). Vazirmatn is the sole official/default family; System Default is the only optional preference. This entry supplements historical records and does not erase them.

Live checkpoint at this entry: PR #3384 HEAD `2ac3580985a23e6ac5342d49c33343c8b4f01816`; PR remains OPEN / DRAFT / UNMERGED. Main remains `45e4202b03a434459e4c021a04efa7e8396359db`. PR #3388 remains OPEN / DRAFT / UNMERGED.

Implementation changes on PR #3384: corrected Alarm Overlay and Calendar font-family references; removed their local family overrides so the root Theme controls Vazirmatn/System Default; aligned Device Smoke scenario `smoke-reminder-vazirharf` with `smoke-reminder-vazirmatn`; aligned its workflow contract test. Related commits include `415cb976ad280f28ff8b780ffe6b4d3a6a8ff17b`, `951d5bd1b359d59ec84662ededcd2f1515083d70`, `8f159f5597a020b3d1e06665c5c123b686872162`, `8127c7a3bc85e9d155ec7131cec25b570eaa787f`, `fbf1b6502a7baed655a9a479fbc28abc6789be3b`, `6fe8a2fbdbb47c6cac402b4d0cf61eb75c23043c`, `83208c93d06ac42b478d0f46212338873f5c7e95`, `a3001d2ac5f81ef44b12514f1f90418f283b9409`, `f63f38b332df68ddc2588eb256378842f9705cfd`, `195e8a9e3802c8637b597c23245dbe86561791ee`, `e8c27100ffa70ebe183e66975380d861d34cb973`, `bcb2d24f94f6c23a8f3131aa5853ad8afb6bf507`, and final `2ac3580985a23e6ac5342d49c33343c8b4f01816`.

Exact-head CI at `2ac3580985a23e6ac5342d49c33343c8b4f01816`: Build run `43217473284` PENDING; Device Smoke `43217473090` QUEUED; SQLite Snapshot `43217473138` QUEUED; Follow-up File Persistence `43217473064` IN_PROGRESS. No outcome is claimed. Older Snapshot run `43212724352` passed on `e94105443e7516ed38eda6feaaee125d92fabaf4` only and cannot be transferred to the current SHA.

The active `main-protection` ruleset remains insufficient: zero required approvals and `require_code_owner_review=false`. CODEOWNERS is present on PR #3388 but effective enforcement is not yet enabled. Release remains NO-GO; no merge, release, deployment, data-destructive operation or history rewrite is authorized.


## COMMAND 07-A.2.55 — LIVE RECOVERY CHECKPOINT (2026-11-13 17:42 Asia/Tehran)

- Live Main HEAD: `45e4202b03a434459e4c021a04efa7e8396359db` (unchanged during this checkpoint).
- Execution branch: `feature/command-07-a-sqlite-contract-remediation`.
- PR #3384: OPEN / DRAFT / UNMERGED; base `fix/wave3-cycle3-calendar-product-repair` at `8c4c23f0c2a4f9b2374a2092c931782c4455fd41`.
- Current code-only remediation commit: `32159f4f2ca13e78bcd2a383c5f384a1a4bd3905`; changed only `test/services/g1_hierarchy_candidate_schema_test.dart` to replace three string-concatenated file paths with interpolation after exact-SHA analyzer output identified three lint findings. Assertions and test semantics were unchanged. The new commit was re-fetched and confirmed; no workflow run or status was yet returned for this SHA, so the change is IMPLEMENTED, NOT RETESTED.
- Main-to-candidate comparison is not a valid PR diff: PR #3384 is intentionally based on the separate Wave 3 repair branch. Exact PR-base comparison before the lint-only commit was 167 commits ahead / 0 behind; after it, 168 ahead / 0 behind. Do not retarget or merge as part of this checkpoint.

### Exact-SHA CI evidence observed on predecessor candidate

Candidate `e017eeadf85f3043fb3fdfbb456486fd8e07bc10`:
- Run `43438369612`, SQLite A-D snapshots: SUCCESS; artifact `14044636632`, digest `sha256:025dcd3113669574f49c2605c228be55bcc61987e9c9c4b203c327a45c4c605b`.
- Run `43438369355`, optional Task links / G1 hierarchy candidate: SUCCESS; artifact `14045530922`, digest `sha256:5a1e5030bfcf9494f79608cc86a798f1d42f4aa3eb4ff4734d9e89c551c7c45e`.
- Build run `43438369432`: analyzer job failed with three info-level interpolation lints in the candidate-schema test; test shards reported 9, 7, 8 and 10 failures respectively (34 shard-reported failures; unique count not established). At observation, release APK was IN_PROGRESS and one test shard QUEUED. Device Smoke run `43438369594` was QUEUED. These are observations for `e017...`, not results for the new commit.
- Failure log examples include Home filter/layout assertions, Task Details/Person UI expectations, calendar interactions, recurrence and reminder behavior. Each failure remains UNRESOLVED pending root-cause and current-contract review; no assertion was weakened.

### Recovered source architecture facts (execution branch)

- Production `G1DriftSchema.version` is 19. It remains an additive/idempotent installer, not a sequential migration ledger.
- The production schema still has nullable `projects.center_id`; Categories remain global `taxonomy_categories(name)`; Task Center is in `legacy_payload_json`; Project membership is many-to-many through `project_items`; Task Category is legacy nullable text. These do not yet satisfy the approved Center → Project → Category → Task ownership/cardinality contract.
- `G1HierarchyCandidateSchema` is isolated and explicitly not called by production startup. Its passing test workflow and file-backed test artifact validate only the candidate fixture/test scope, not production migration acceptance.
- Existing source includes CenterStore/CenterManagementPage, ProjectStore, TaskStore, TagStore as a TaskStore facade, ProjectTemplateStore/ProjectTemplateService and TaskTemplateStore. A `task_template_service.dart` path was not present on this branch; broader history/consumer search is still required before classifying a TaskTemplateService as NOT FOUND.
- The REV10 migration inventory's earlier inspected SHA `34f6fb1a42e5adb6255a1d56ce8c07ac7567ead2` is historical and must not be treated as current. Current checkpoint supersedes its live-state pointers only; its source findings remain useful pending re-audit.

### Acceptance boundary

D01–D05 remain NOT ACCEPTED. No production startup switch, destructive migration, Main write, merge, release, deployment, branch deletion or history rewrite occurred. Cross-Center reporting and complete Deep Clone acceptance remain unverified. Continue from the exact branch HEAD and re-run targeted analyzer/schema tests before any broader acceptance claim.


## 2026-11-13 — COMMAND 07-A.2.57 live recovery and evidence reconciliation

- Re-fetched Main, execution branch and PR refs before any modification. Main remained `45e4202b03a434459e4c021a04efa7e8396359db`; execution branch remained `13a09af3815d7271ffb11e67eeac7b2592eb18bd`, identical to the reported checkpoint.
- Reconfirmed PR #3380/#3382/#3384/#3388/#3340/#3448 states, bases and heads. Preserved all open PRs and branch relationships.
- Inspected current-SHA Actions. G1 candidate and Device Smoke remain queued; Build pending; SQLite A-D snapshot and Follow-up persistence succeeded. No duplicate workflows were launched.
- Downloaded artifact 14046601552. Verified ZIP SHA256 `da890a5b7fbc5b8da0f4dbf86103b6671f35e8fe037cccaa5b192dcaf8f074c1` against GitHub digest. Verified embedded JSON SHA256 `6ee103c73c74ace68bbc208af7c765e5f5ae81c81c97290ad33febb01af301fb`.
- Snapshot evidence confirms five reopen cycles on one file-backed DB and equality of the recorded Task compatibility metadata, reminders, follow-up records/order, Person links/identities, schema catalog, FK declarations and FK checks across A/B/C/D. It does not test independent physical backup/restore and does not prove production migration acceptance.
- Source review reconfirmed production G1 schema v19 and isolated Candidate schema. Production ownership and Task relationship storage still diverge from the owner-approved Center → Project → Category → Task contract.
- Recovered existing taxonomy mutation/lifecycle services, reporting filter/projection, ProjectTemplateStore, TaskTemplateStore, ProjectTemplateService and template application infrastructure. No third template engine or activity identity was created.
- Current branch path lookup found no CategoryStore/CategoryRepository or PersonStore/PersonRepository file. Historical absence is not asserted. Both taxonomy services have consumers/tests requiring a complete reference audit before consolidation.
- No code, test, schema, workflow or runtime file was changed in this checkpoint. No tests were weakened or deleted. Documentation updates are append-only and preserve prior evidence.


## COMMAND 07-A.2.57 — G1 Candidate Completion Update (2026-11-13 14:34 UTC)

This section supersedes the earlier QUEUED observation for the G1 candidate run only. The execution source SHA remains `13a09af3815d7271ffb11e67eeac7b2592eb18bd`; documentation-only HEAD may be newer.

- Workflow run: `43441067534` — SUCCESS.
- Job: `131938477824` — Optional Task links and database-level integrity — SUCCESS.
- Artifact ID: `14047546927`.
- Artifact name: `arvin-command-07-a2-50-g1-hierarchy-13a09af3815d7271ffb11e67eeac7b2592eb18bd`.
- Artifact ZIP SHA256 (GitHub digest and local downloaded file): `cfedf1fd850f50ee7f36204ac4dd26b3e95ec20ed0baf3bde0e98334a333faf7`.
- Artifact evidence manifest SHA256: `ed4cd57bd6fa02fd5239e47299db960db9fec40786cbc65504b7fc495db1f2c6`.
- Legacy optional-relationship SQL test log SHA256: `83c6c073d2ba9bbafd84ba19a038ec616f7eba3090ef18c2e90d5537c1fbe726`; 19 tests passed. Coverage includes independent optional Task links, clearing to NULL after reopen, mismatch rejection, dependent-owner change/delete restrictions, nullable FK columns and clean integrity.
- Real G1 hierarchy candidate test log SHA256: `ac713a170fcc9fabe89e717c0411f983ab624a35ba14017a8183c8d8a87d3625`; 13 tests passed. Coverage includes all-null/partial/full optional links, SQL ownership mismatch rejection, required Project/Category owners, idempotency/five reopen cycles, Tag/Person/Follow-up identity preservation, update triggers, dependency restrictions, injected migration rollback/retry, independent-file backup/restore, indexes and triggers.
- Target SHA file confirms `13a09af3815d7271ffb11e67eeac7b2592eb18bd`.

Interpretation: the G1 candidate and legacy optional-link test suites are TESTED and pass on the exact source SHA. This is strong candidate-level evidence for hierarchy constraints, optional links, rollback/retry and a narrow independent-file restore scenario. It does NOT switch the candidate into production startup, prove migration of actual user databases, prove full D01–D05, prove four-state Missing/NULL/FALSE/TRUE semantics, or constitute final acceptance.

### Build and Device Smoke remain open
- Build run `43441067582` is still QUEUED at workflow level. Jobs include release/staging/debug APK QUEUED; quality shards 0,1,3,4,5 and visual/analyze were CANCELLED; shard 2 was observed IN_PROGRESS then CANCELLED. No overall Build PASS or FAIL is claimed; analyze did not complete.
- Device Smoke run `43441067685`: job `131938478429` remains QUEUED. No device scenario or APK acceptance is claimed.
- SQLite snapshot run `43441067604` remains SUCCESS with artifact `14046601552`; same-file five-reopen scope as recorded above.
- Follow-up persistence run `43441067590` remains SUCCESS.
- Do not duplicate these runs while they remain queued or until a final conclusion is returned.


## COMMAND 07-A.2.57 — Historical implementation recovery map (2026-11-13)

The current execution branch is not the only source of valid work. The following historical PR evidence must be reviewed before implementing equivalent functionality. No historical branch is deleted or merged by this record.

| Area | Historical source | Actual state | Reuse / restriction |
|---|---|---|---|
| Person directory UI | PR #2745, branch `feat/person-directory-settings-current-main-20261016`, head `01a905ed6543bdd6f73cd0e4044b65fc6cf0bc29` | OPEN / DRAFT / UNMERGED; based on Main SHA `d2267190ee83b7e462483f5d114395626c55e150` | Adds PersonDirectoryPage and reuses TaskStore.loadPeopleDirectory/savePeopleDirectory for create/edit/search/confirmed delete. Recover UI and tests only after diffing against current TaskStore and current Main; it is not a new PersonRepository. |
| Person SQL + backup/report integration | PR #2695, branch `integration/person-directory-safe-port-20261014-v2`, head `44810fcf5bb96db8c028a1574889e3f2d45af75f` | OPEN / DRAFT / UNMERGED; stacked on PR #2666 at base `ad762774009e5b5c7ee341146a8160c52e2b9bb2` | Contains Person directory CRUD, structured Follow-up waiting/person IDs, backup/restore, report filters/projection. Do not port wholesale: same-name projection conflict with existing mainline projection is explicitly documented. |
| Person persistence slice | PR #2696, branch `integration/person-directory-persistence-slice-20261014`, head `94f47f5c70558c6ff250ec1989bdcde761d04df5` | OPEN / DRAFT / UNMERGED; stacked on older parent SHA `e626daeecb3851024f2ceab820d1868ba582c860` | Earlier G1 v6 people_directory and TaskStore APIs. Overlaps with later Person integration; use as history, not a second table/repository. |
| Deleted Person history | PR #2744, branch `fix/report-preserve-deleted-person-history-20261016`, head `31b9cfa61efc1323f10e038be22efa1226c4d8ad` | CLOSED / NOT MERGED | Contains stable deleted-person placeholder/report projection behavior. Verify whether equivalent fix reached current Main before reuse. |
| Notebook canonical taxonomy | PR #2037, merge commit `36f05599e17ea5359f92ad62667aac76abccb301` | MERGED | Reuses TaskStore canonical Category/Tag catalogs from Notebook. Preserve; do not build Notebook taxonomy storage. |
| Shared taxonomy UI | PR #2185, merge commit `4816b9e121ca856828efdb37da6eab0c7a39f195` | MERGED | Shared taxonomy icon row. Preserve and reconcile with new Home/Task Details layout, not replace blindly. |
| Report Center filters | PR #2406, merge commit `d34dc6be87d702c0c3769482586862d7c0e1416b` | MERGED | Existing Report Center and AND filter surface. Reuse for current report requirements. |
| Canonical navigation/reports/calendar polish | PR #2751, merge commit `9e30d508f778f7ea91a44168b99098755b8c4934` | MERGED | Reuse current Main implementation; exact current behavior still needs test/device acceptance. |
| Earlier Home contract | PR #2319 | CLOSED / NOT MERGED | Historical Home implementation and tests; superseded by later Home work. Recover tests/ideas only after current Main diff. |

### Recovery decision
- Do not create a new Person directory UI before reviewing PR #2745 against current Main and current execution branch.
- Do not create a Person SQL table or independent store before reviewing #2695/#2696 and current G1 schema. Current Person tables/relations are already present.
- Do not create a second Notebook taxonomy or Report Center.
- The existence of merged historical PRs proves prior implementation lineage, not present-day acceptance of the new five-entity management center or Cross-Center reporting.
