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
