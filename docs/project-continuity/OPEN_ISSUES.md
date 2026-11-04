# Open Issues and Blockers
Snapshot: 1405/08/13 — 2026-11-04 12:53 Asia/Tehran. Recheck live GitHub before acting.

| Item | Status | Evidence / next action |
|---|---|---|
| Build / test evidence on current HEAD 33f9489 | VERIFIED | Run 41805555476 SUCCESS; Analyze and six shards pass. APK matrix skipped under Draft guard. |
| Calendar Provider on current HEAD | BLOCKED | Run 41805555462 failed to start Dart Development Service; zero tests executed. Diagnose runner/emulator/DDS startup, then rerun unchanged acceptance test on a new exact SHA. |
| Seven-lane Device Smoke on source baseline 33f9489 | BLOCKED | Run 41805555579 is now CANCELLED. Preparation, Boot, Navigation and Quick Capture succeeded; four acceptance lanes were cancelled. A fresh complete seven-lane run is required on the current candidate SHA. |
| Current-SHA Review APK | NOT VERIFIED | Run 41805393577 was cancelled on older SHA b85ed7b. Obtain a current-SHA review artifact only through the approved Draft workflow. |
| Quick Capture feedback acceptance | BLOCKED | Owner must decide one versus two visible feedback presentations. Preserve test and current behavior until then. |
| Full Report Center filter coverage on current HEAD | NOT VERIFIED | Earlier tests/screenshots passed on 9b52d43. Re-run on current candidate and capture a fresh screenshot; existing images do not prove every lower filter or combination. |
| Full hierarchy consistency across app | IN_PROGRESS | Hierarchy is approved; evidence currently proves only selected report controls, not every page/data path. |
| Calendar external-provider full lifecycle / physical-device acceptance | NOT VERIFIED | CI Provider CRUD on older SHA is not proof of full production calendar ownership or whole-calendar deletion behavior. Current HEAD Provider run did not execute tests. |
| Legacy schema/data migration safety | BLOCKED | Do not remove legacy fields or perform destructive DDL until real user DB contents, backup and a backward-compatible conversion plan are inspected. |
| Local P2P implementation and security | PROPOSED / NOT VERIFIED | No pairing/conflict implementation acceptance. QR/PIN, LWW and tombstones require security review and owner approval. |
| Local working tree status | NOT VERIFIED | GitHub API exposes committed branch state, not the operator's local uncommitted files. |

## Governance dependencies
- Governing product/release issues: #823 and #2102; confirm their live state before closing any gate.
- PR #3052 remains OPEN / DRAFT / UNMERGED.
- main must remain unchanged; no merge or release.


## 2026-11-04 — Task Details visual acceptance blocked
| Item | Status | Evidence / next action |
|---|---|---|
| Exact-HEAD Task Details source audit (940b22f4) | VERIFIED | TaskDetailPage, entry route and Task model re-read on current PR HEAD; see docs/audit/ARVIN_TASK_DETAILS_REFERENCE_COMPARISON_2026-11-04.md. |
| Two named UI screenshots | BLOCKED / NOT AVAILABLE | Current conversation file search returned no files; Library search did not find either filename. Reattach both images before visual comparison or design changes. |
| Task Details duplicate metadata cleanup | PROPOSED / NOT APPROVED | Code confirms repeated due date, priority, category/tags. Decide final grouping from reference image and owner approval; do not guess. |
| Assignee display | NOT SUPPORTED BY CURRENT TASK MODEL | Task.people is related people; no dedicated assignee field found. Do not infer assignment. |
| Task Details screenshot/golden acceptance | NOT VERIFIED | Add RTL screenshot/golden after reference viewport is available; retain existing widget assertions. |
| Build exact HEAD 940b22f4 | VERIFIED | Run 41819344155 SUCCESS; Analyze + six shards SUCCESS. |
| Device Smoke exact HEAD 940b22f4 | IN PROGRESS | Run 41819344258: Boot/Navigation success; Quick Capture/Calendar in progress; remaining three lanes queued at last poll. Require all seven terminal successes. |
| Calendar Provider exact HEAD 940b22f4 | IN PROGRESS | Run 41819344729 in progress at last poll. |
| Follow-up Persistence exact HEAD 940b22f4 | VERIFIED | Run 41819344361 SUCCESS. |
| Review APK exact HEAD 940b22f4 | VERIFIED — REVIEW ONLY | Artifact 13316861010; not a release APK. |


## Task Details reference implementation checkpoint — 2026-11-04
### Done (implementation; acceptance still pending)
- [x] Refactored Task Details layout into compact summary, independent description, ordered metadata, conditional template source and one due-date card.
- [x] Consolidated status and priority into the summary and removed P1–P4 code labels from this screen.
- [x] Preserved existing reminder, checklist, follow-up, recurrence, calendar, clone, report, edit, delete and complete/reopen entry points.
- [x] Increased scroll bottom inset for fixed bottom actions; related people remain distinct from assignee.
- [x] Added focused widget contracts for RTL order, due-date non-duplication, related people and bottom action visibility.
### Proposed / pending
- [ ] Generate and attach an actual screenshot of the revised Task Details page from a built app/emulator.
- [ ] Add a golden baseline only after a real reviewed rendering is generated; do not synthesize or claim a golden from the reference image.
### Blocked / NOT VERIFIED
- [ ] Pixel comparison against installed-app screenshot; installed-app image file is not available in the execution environment.
- [ ] Actual revised-page screenshot and visual acceptance by product owner.
- [ ] Final exact-SHA Build, all seven Device Smoke lanes, Calendar Provider, Follow-up Persistence and review APK results.
- [ ] Execution-time display: canonical Task model currently has no execution-time field; UI displays “زمان اجرا: ثبت نشده”. Do not infer it from createdAt.
- [ ] Independent assignee display: canonical Task model has no assignee/responsible field; Task.people must remain “افراد مرتبط”.


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


## Remaining after Task Details regression repair attempt
- [ ] Exact-SHA Build must prove flutter analyze exit 0 and all six test shards successful.
- [ ] Exact-SHA Device Smoke must complete all seven lanes successfully; prior cancelled/partial results do not count.
- [ ] Exact-SHA Calendar Provider and Follow-up Persistence must be terminal SUCCESS.
- [ ] Actual revised Task Details screenshot and owner visual approval remain NOT VERIFIED; no pixel Golden claim without an actual rendering and approved baseline.
- [ ] Execution-time and independent-assignee model concepts remain unresolved; do not infer either from unrelated fields or Task.people.


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
