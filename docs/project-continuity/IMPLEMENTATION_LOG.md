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
