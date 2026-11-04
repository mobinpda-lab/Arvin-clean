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
