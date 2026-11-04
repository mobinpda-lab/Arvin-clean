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
