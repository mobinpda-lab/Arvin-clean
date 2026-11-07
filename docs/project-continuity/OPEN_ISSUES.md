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

## R6 — exact-SHA review APK and live smoke checkpoint (2026-11-04; source SHA: 1815ef72864f3e792661eee08cc932b29ff94c88)
- Review Staging APK run [41874160600](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160600) completed SUCCESS on the exact source SHA. Artifact [13345822544](https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/13345822544/zip), name `arvin-review-staging-apk-1815ef72864f3e792661eee08cc932b29ff94c88`, ZIP size 38,211,551 bytes, SHA-256 `0821c0b1749e5e852d68283eb5c4181bbb15877f9c701954f56e18db685a5ab1`, expires 2026-11-11 17:12:04 UTC. Direct ZIP: https://api.github.com/repos/mobinpda-lab/Arvin-clean/actions/artifacts/13345822544/zip
- Extracted APK: `Arvin-review-staging-1815ef72864f3e792661eee08cc932b29ff94c88.apk`, 76,822,515 bytes, SHA-256 `24295b19eea0300623167fbe400320a961feefbc3e6045e1015c43560a306e75`; application ID `com.example.arvin.staging`; `android_debuggable=false`; APK Signature v2/v3 verified. Signer certificate SHA-256 `f3c4ffe277b87daa789596ae3275fc8d9d59fc1d1236b83a7fa1190cb7a3d37b`. Ephemeral review-only test key; `publishable=false`, `release_created=false`. This artifact is for private review/install testing only, not production or release acceptance.
- Build #9553 run [41874160729](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160729): Analyze and all six test shards (0–5) SUCCESS on the exact SHA. Draft-guarded ordinary APK matrix job was SKIPPED as expected; this is not the Review Staging APK job.
- Device Smoke #6800 run [41874160773](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160773): matrix preparation SUCCESS. At the latest job-level poll: Boot IN_PROGRESS; Navigation IN_PROGRESS; Quick Capture QUEUED; Follow-up Persistence QUEUED; Task Lifecycle QUEUED; Calendar Segmented View QUEUED; Reminder/Vazirmatn QUEUED. Screenshot/evidence upload steps had not started. Seven-lane acceptance is NOT VERIFIED. The run-level API status was reported as queued while two lane jobs were already in progress; job-level states are recorded above.
- Calendar Provider Acceptance #1698 run [41874160623](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/41874160623): exact-SHA checkout and setup succeeded; real Provider instrumentation/acceptance step remained IN_PROGRESS; evidence publication pending. Final acceptance NOT VERIFIED.
- Repository cleanup audit on the same source SHA: complete recursive tree (790 entries, not truncated); no tracked APK/AAB, generated build/output/cache/temp directories, or safe deletion candidates found. No cleanup deletion or cleanup commit was made.
- PR #3052 remains OPEN / DRAFT / UNMERGED with head `1815ef72864f3e792661eee08cc932b29ff94c88`; branch is unchanged at this checkpoint. `main` remains `45e4202b03a434459e4c021a04efa7e8396359db`. No code changes, merge, release, or publication were made.
- **BLOCKED — RELEASE: NO-GO.** Physical tablet installation/behavior, seven-lane Device Smoke, Calendar Provider terminal result, and product-owner release acceptance remain separate gates. This evidence applies only to source SHA `1815ef72864f3e792661eee08cc932b29ff94c88`; any documentation commit creates a new HEAD and does not inherit these exact-SHA CI results.


## Backlog — تایپوگرافی برداری و بیلد پایدار (P0)
- [ ] حذف استثناهای serif/Naskh و هرگونه فونت ثانویه؛ تثبیت Vazirmatn به‌عنوان تنها فونت متنی.
- [ ] دریافت مرجع تصویری تأییدشده و ساخت SVG path-based بسم‌الله مطابق آن.
- [ ] ساخت SVG path-based دعای تفویض با نسخ اصیل و اعراب‌گذاری صحیح.
- [ ] افزودن semantics/accessibility labels و تست اندازه، تم روشن/تاریک و RTL.
- [ ] تست رندر در رزولوشن‌های گوشی و تبلت، overflow و عملکرد.
- [ ] رفع شکست‌های Analyze/Test/Visual از exact-head CI و اجرای مجدد همه تست‌ها بدون کاهش پوشش.
- [ ] اجرای Build APK و Device Smoke هفت‌مسیره روی یک SHA واحد و ثبت artifact/checksum.
- [ ] حفظ PR #3052 به‌صورت OPEN/DRAFT/UNMERGED؛ main بدون تغییر؛ Release NO-GO تا پذیرش نهایی.


## AIPOS v1.0 live blockers — 2026-11-05
- P0: approved calligraphy reference images not found in accessible records; both SVG files are absent. Exact matching artwork is BLOCKED pending reference.
- P0: replace the two sacred phrase Text widgets with path-only SVG assets and accessible single-announcement semantics; not yet verified.
- P1: Build/Analyze run 42090629467 pending; Analyze and full flutter test NOT VERIFIED.
- P1: Device Smoke run 42090629594 preparation passed; boot/navigation in progress, other lanes queued.
- P1: Calendar Provider 42090629465 in progress; Follow-up persistence 42090629520 success.
- P1: Draft Review APK 42090629583 in progress; artifact not yet verified.
- No test may be deleted, skipped, weakened or bypassed. Release remains BLOCKED — RELEASE: NO-GO.


## Live open items — ۱۴۰۵/۰۸/۱۵ — ۱۰:۰۱ (Asia/Tehran) / 2026-11-06
| Item | Status | Evidence / next action |
|---|---|---|
| Device Smoke Boot and Navigation lanes | BLOCKED / INCOMPLETE | Run `42169009238`: both jobs ended CANCELLED; inspect job logs/cancellation cause and obtain complete lane execution on a fresh exact SHA. Do not mark as skipped or passed. |
| Device Smoke Calendar Segmented View | IN_PROGRESS | Same run `42169009238`; wait for terminal result and inspect artifact. A still-running lane does not make the whole workflow complete. |
| Quick Capture empty-title feedback | IMPLEMENTED / VERIFICATION PENDING | Inline error + floating SnackBar exist; original test asserts both. Run is green for the Quick Capture Smoke lane, but retain as open until the focused test and full Smoke gate are confirmed on the final post-commit SHA. |
| Report completed Follow-ups placement | IMPLEMENTED | Separate top-level action absent; report type is in unified filter sheet; widget test asserts both. Fresh post-commit exact-SHA test evidence is still required. |
| Navigation test-driver timing/interruption | OPEN / ROOT CAUSE NOT VERIFIED | Inspect navigation lane logs, emulator readiness, driver waits and app transitions. Do not add artificial timeout, skip, retry masking, or weakened assertions. |
| Local working tree and local test run | NOT VERIFIED | Remote GitHub audit cannot report a workstation's uncommitted state or claim locally executed tests. |

All tests and assertions remain protected: no deletion, skip, weakening, or fabricated timeout is authorized.


## Device Smoke and canonical product gaps — 2026-11-06 (۱۴۰۵/۰۸/۱۵)

### Device Smoke run 42175115690
- **BLOCKED / INCOMPLETE:** exact checkout SHA `49401bd4fcfa5622282d0fd80ec607d12daf467a`.
- Preparation SUCCESS; Boot and Navigation IN_PROGRESS; Calendar Segmented View, Quick Capture, Task Lifecycle, Reminder/Vazirmatn and Follow-up Persistence QUEUED at the latest job-level poll.
- No final lane conclusions and no uploaded artifacts. Boot/Navigation log download returned 404; root cause and test outcome NOT VERIFIED.
- Next action: continue polling the same run; collect each lane's terminal conclusion and screenshot/artifact evidence. Do not cancel, rerun, skip, or mark incomplete lanes as PASS.

### Product deviations requiring a future implementation/verification slice
1. **Quick Capture:** remove the description field from the quick form while preserving description entry in the full form. Existing source still renders the description field; the quick-capture test currently asserts its presence.
2. **Reports filters:** implement the visible RTL five-filter row in the Reports page, in the canonical order Time → Center → Project → Category → Tag; no «همه» chip.
3. **Calendar triple date:** show Jalali, Gregorian and Hijri lunar dates according to the approved calendar specification.
4. **Calendar swipe/export:** retain period navigation only where intended; implement and verify the approved swipe-to-phone-calendar transfer behavior without duplicate events or data loss.
5. **Tafweez exact phrase:** align SVG semantics/accessible label and any visible text with exact owner wording «وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ»; inspect artwork/diacritics visually before acceptance.
6. **Physical-device typography:** verify Vazirmatn and both sacred SVGs on the target Android device in light/dark themes, RTL and supported text scales. Source configuration alone is insufficient.

- These are open findings from source/spec audit; they are not claimed as Device Smoke failures. Add focused tests and exact-SHA evidence after owner-approved implementation.
- Governance: PR #3052 OPEN / DRAFT / UNMERGED; main untouched; **BLOCKED — RELEASE: NO-GO**.


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
