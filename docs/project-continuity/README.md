# Arvin Project Continuity — REV10 / ONE PATH

**Last consolidation review:** 2026-11-17  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Product Owner:** Mobin  
**Only active development PR:** #3495  
**Canonical branch:** `recovery-02/main-based-integration`

This README is the navigation index. Live GitHub state is authoritative for branch heads, PR status, workflow runs and test evidence. Never reuse a stale SHA or report a PASS from another commit.

## The eight authoritative documents

Only these eight files are active project authority:

1. [MASTER_GOVERNANCE.md](MASTER_GOVERNANCE.md) — governance, permissions and safety.
2. [PRODUCT_DECISIONS.md](PRODUCT_DECISIONS.md) — current approved product and architecture decisions.
3. [CURRENT_STATE.md](CURRENT_STATE.md) — live repository and exact-SHA status.
4. [ROADMAP.md](ROADMAP.md) — unified delivery sequence.
5. [OPEN_ISSUES.md](OPEN_ISSUES.md) — verified blockers and unresolved work.
6. [IMPLEMENTATION_LOG.md](IMPLEMENTATION_LOG.md) — dated implementation and evidence record.
7. [HANDOFF.md](HANDOFF.md) — next safe actions.
8. [README.md](README.md) — this navigation index.

All other specifications, ADRs, audit files, ledgers, root agent files and historical snapshots are supporting references only. Historical PR #3448 continuity documents are preserved under `archive/pr-3448-source-2026-11-13/`; the REV9 governance archive is under `archive/`. These copies preserve evidence and do not create additional active documents. They cannot create a competing policy or override these eight documents. If a decision remains active, its current form must be recorded in PRODUCT_DECISIONS.md.

## REV10 architecture packet — MASTER EXECUTION 162-R
The mission-specific architecture packet is maintained under [docs/rev10](../rev10/CONSTITUTION.md): [Constitution](../rev10/CONSTITUTION.md), [Agent Card](../rev10/AGENT_CARD.md), [State snapshot](../rev10/STATE.md), [Specification index](../rev10/SPEC/README.md), [Wave dependency DAG](../rev10/REV10-WAVE-DEPENDENCY-DAG.md) and [Open Decisions](../rev10/REV10-OPEN-DECISIONS.md). These are supporting, traceable architecture artifacts only; they do not override the eight continuity authorities, approved Product Decisions or permanent Requirement Ledger. Technical registrations are appended to the canonical [REV10 Requirement Ledger](REV10-MASTER-REQUIREMENT-LEDGER.md).

## Current governance boundary

- Main remains read-only for development.
- All new development belongs in PR #3495; no parallel feature PRs or revived historical branches.
- Merge, release, deployment and production-user-database operations require explicit Product Owner approval.
- Preserve valid history, IDs, relationships, backups and user data.
- Never weaken tests or report PASS without exact-SHA evidence.
- NIRA remains an independent repository and is not modified by this Arvin mission.

## Live consolidation checkpoint

- Main SHA at the last verified comparison: `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3495 was Draft, 72 commits ahead and 0 behind at pre-documentation checkpoint `e0cf66d68776e913ab7e9c5236e2b184a5fbb70c`. The documentation updates below advance the branch; fetch the live PR head before acting.
- The canonical branch contains 9 workflows, compared with 23 on Main. The cleanup removes parallel PR-generating workers, automated merge, duplicate orchestrators and the release bypass. Main still has its old workflows until the owner-approved merge.
- The branch inventory returned 1,439 branch names. No branch deletion has been performed; every branch still requires PR association and unique-commit review.
- At the pre-documentation checkpoint, Build, Device Smoke, COMMAND 20-E and Follow-up File Persistence were queued on the exact head. The prior Follow-up File Persistence PASS on `2256ba8f7da806249fa6516c7afcca386430308b` is historical and does not transfer to a newer SHA.


Historical source material is retained under `archive/` and `reference/`, including selected PR #3340 REV9 product/governance contracts and PR #3448 REV10 source snapshots. These folders preserve evidence only; they do not add active authorities.

## Start here

1. Read MASTER_GOVERNANCE.md.
2. Read PRODUCT_DECISIONS.md.
3. Read CURRENT_STATE.md and verify its SHA against live GitHub.
4. Read OPEN_ISSUES.md and ROADMAP.md.
5. Read IMPLEMENTATION_LOG.md for evidence.
6. Read HANDOFF.md before taking the next action.

Do not treat historical REV8/REV9/REV10 checkpoints below as live status. They are retained for traceability only.

---

## Historical REV8 audit index (reference only)


- [COMMIT_AUDIT.md](audit/COMMIT_AUDIT.md)
- [BRANCH_AUDIT.md](audit/BRANCH_AUDIT.md)
- [PULL_REQUEST_AUDIT.md](audit/PULL_REQUEST_AUDIT.md)
- [SHA_RECONCILIATION.md](audit/SHA_RECONCILIATION.md)
- [TEST_INVENTORY.md](audit/TEST_INVENTORY.md)
- [CI_HISTORY_AUDIT.md](audit/CI_HISTORY_AUDIT.md)
- [DOCUMENTATION_AUDIT.md](audit/DOCUMENTATION_AUDIT.md)
- [ARCHITECTURE_CONSOLIDATION.md](audit/ARCHITECTURE_CONSOLIDATION.md)
- [CONFLICT_REGISTER.md](audit/CONFLICT_REGISTER.md)
- [CLEANUP_REGISTER.md](audit/CLEANUP_REGISTER.md)
- [NIRA_AUDIT.md](audit/NIRA_AUDIT.md)
- [FINAL_REPOSITORY_HEALTH_REPORT.md](audit/FINAL_REPOSITORY_HEALTH_REPORT.md)

## Historical records — preserve, do not treat as current authority
- DECISIONS.md is retained as a historical/technical decision archive. Active product decisions belong in PRODUCT_DECISIONS.md.
- CALENDAR_UIUX_SPEC.md is an older Calendar proposal. The dated owner-approved reference is calendar_ui_ux_spec.md.
- TODO.md is a working backlog snapshot; reconcile entries into OPEN_ISSUES.md/ROADMAP.md before treating them as current.
- Older root docs and prior checkpoints are historical evidence. References to ArvinTask/TaskRepository describe earlier migration stages; current implementation authority is Task + TaskStore/Drift.

## Evidence and status rules
- Every PASS/FAIL applies only to its exact SHA.
- Product approval, implementation and verification are separate axes.
- Do not infer verification from a file/class or from a green orchestrator workflow.
- Never delete, skip, bypass, weaken or artificially timeout tests.
- Preserve backward-compatible migrations and user data; no destructive schema action without a separate approved plan.
- Local working-tree state and physical-device state are NOT VERIFIED unless directly observed.

## Time convention
Project reports use Asia/Tehran time and Gregorian plus Hijri Shamsi dates. Last reviewed is a checkpoint, not continuous monitoring.

---

## Previous continuity README history (preserved)

# Arvin Project Continuity
Last reviewed: ۱۴۰۵/۰۸/۱۹ — 2026-11-10 (REV7.2 live GitHub checkpoint)
Repository: mobinpda-lab/Arvin-clean
Active branch: fix/recovery-calendar-device-smoke-2026-10-31
Related PR: #3052

## Purpose
This directory is the durable handoff index for the active Arvin delivery stream. It supplements, and does not replace, the repository's root ARVIN_AI_CONTEXT.md, root CHANGELOG.md, architecture specifications, QA evidence and continuation ledger.

## Start here
1. CURRENT_STATE.md — verified branch, SHA, gates and current limitations.
2. HANDOFF.md — the first action for the next operator.
3. OPEN_ISSUES.md — unresolved work and blockers.
4. PRODUCT_DECISIONS.md — approved decisions versus proposals.
5. task_home_screen_spec.md — canonical approved Home screen contract.
6. task_detail_ui_ux_spec.md — canonical unified Task Details form.
7. TASK_TEMPLATE_DATA_CONTRACT.md — canonical Task and Project Template data and migration contract.
8. ROADMAP.md — ordered product work.
9. IMPLEMENTATION_LOG.md — dated changes and exact-SHA evidence.
10. Root CHANGELOG.md — chronological repository history.
11. docs/ARVIN_CONTINUATION_LEDGER.md — detailed historical execution ledger.
12. ARVIN_AI_CONTEXT.md — broad product and architecture context.

## Evidence and status rules
- GitHub branch content, PR metadata and workflow evidence are authoritative for this active delivery stream. A report is valid only for its exact SHA.
- Distinguish four separate facts: proposal, owner-approved decision, code implementation, and successful test evidence.
- Use these statuses only: PROPOSED, APPROVED, IN_PROGRESS, IMPLEMENTED, VERIFIED, BLOCKED, SUPERSEDED, REJECTED.
- VERIFIED requires evidence tied to the exact commit under review. A green test on an older SHA does not verify the current branch.
- A workflow-level failure before any test executes is an execution/infrastructure failure, not proof that the product behavior failed.
- Mark unavailable facts NOT VERIFIED. Never infer a clean local working tree from GitHub branch metadata.
- Keep one canonical home for each fact. This directory links to root CHANGELOG.md and the existing Ledger; it does not duplicate their full history.

## Governance invariants
- PR #3052 stays OPEN / DRAFT / UNMERGED.
- Never edit, push, or merge main.
- Do not delete, skip, weaken, or artificially time out tests.
- Keep the official bundled font Vazirmatn.
- Preserve user data and backward-compatible migrations; no destructive schema migration.
- Preserve canonical separation among Task due date, independent TaskReminder, recurrence and historical FollowUp.
- Release status remains BLOCKED — RELEASE: NO-GO until all required gates pass on one exact candidate SHA and owner acceptance is recorded.

## Update protocol
1. Read live branch HEAD and PR state before editing.
2. Read the relevant canonical document and source files.
3. Record only evidence observed on the exact SHA.
4. Update the canonical file for the fact, then add a short pointer in other files if needed.
5. Append chronological events to root CHANGELOG.md and the detailed Ledger; do not create parallel changelogs.
6. Update CURRENT_STATE.md and HANDOFF.md after every meaningful checkpoint.
7. Re-read the changed files and confirm the resulting branch SHA.
8. Never claim tests validate a later documentation-only SHA unless rerun on that exact SHA.

## Time convention
Project reports use Asia/Tehran time and Gregorian plus Hijri Shamsi dates. Last reviewed timestamp above is the checkpoint time, not a claim of continuous monitoring.


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


Latest audit record: PRODUCT_DECISIONS.md → Module-Core-Logic v1.0 crosswalk; exact-SHA evidence and limitations are in IMPLEMENTATION_LOG.md and the root continuation Ledger.


## Canonical Calendar reference
- `calendar_ui_ux_spec.md` — owner-approved fourteen-section Calendar UI/UX contract, including exact RTL header zones, triple-date grid, separate view-mode/content-filter rows, agenda and Hijri offset choices.
- `PRODUCT_DECISIONS.md` records the decision summary; `ROADMAP.md` tracks implementation/acceptance work; root `docs/ARVIN_CONTINUATION_LEDGER.md` records exact-SHA CI evidence.


## Canonical three-screen UI/UX references — approved 2026-11-05
- `task_home_screen_spec.md` — Home: header, search, five quick filters + independent sort, date triad, five time groups, cards, FAB and five-tab navigation.
- `task_detail_ui_ux_spec.md` — Task Master-Detail: one inline View/Edit form, fixed 11-section order, canonical data boundaries, checklist and Follow-up timeline.
- `calendar_ui_ux_spec.md` — Calendar: sacred-phrase header, triple-date display, Day/Week/Month/Year modes, five agenda filters, Hijri adjustment and three-layer calendar architecture.
- Shared visual language: Microsoft To Do-inspired card surfaces, clean light background, rounded white cards, semantic color chips, Persian RTL and official Vazirmatn.
- Product approval is not implementation acceptance. Runtime, tests, Golden Tests and release remain outside this documentation-only registration.


### الگوهای کار و پروژه
- قرارداد داده و مرز تاریخچه اجرایی: `TASK_TEMPLATE_DATA_CONTRACT.md`
- مرجع پیاده‌سازی و وضعیت پذیرش exact-SHA: `IMPLEMENTATION_LOG.md` و `ROADMAP.md`


## STD-GOV-AIPOS-v1.0 — 2026-11-05
- این پوشه مرجع پایدار حافظه پروژه است؛ ترتیب شروع: CURRENT_STATE، HANDOFF، OPEN_ISSUES، PRODUCT_DECISIONS، ROADMAP و سپس IMPLEMENTATION_LOG.
- هر وضعیت باید به SHA دقیق، شاخه و شواهد GitHub متصل باشد. نتیجهٔ یک SHA به SHA بعدی منتقل نمی‌شود.
- تفکیک الزامی: تصمیم محصول، پیاده‌سازی، آزمون، پذیرش و انتشار پنج وضعیت مستقل‌اند.
- هیچ تغییری روی main، هیچ merge و هیچ خروج از Draft مجاز نیست؛ PR #3052 باید OPEN / DRAFT / UNMERGED بماند.
- تست‌ها حذف، skip، تضعیف یا با timeout مصنوعی سبز نمی‌شوند. خطای زیرساخت از شکست محصول تفکیک می‌شود.
- پروتکل: ابتدا HEAD/PR را بخوان؛ سپس تغییر محدود را روی شاخه مجاز ثبت کن؛ مستندات و Ledger را به‌روزرسانی کن؛ در پایان HEAD و CI تازه را دوباره بخوان.
- وضعیت انتشار تا پذیرش تمام دروازه‌ها روی یک SHA و تأیید مالک محصول: BLOCKED — RELEASE: NO-GO.


## Latest checkpoint


## Live execution checkpoint — ۱۴۰۵/۰۸/۱۵ — ۱۰:۰۱ (Asia/Tehran) / 2026-11-06
- Repository: `mobinpda-lab/Arvin-clean`; authorized branch: `fix/recovery-calendar-device-smoke-2026-10-31`; checkpoint parent SHA: `105737b1e4d5f9e2d6e35dfc7c9f4bfd5b1cbdda`.
- PR #3052 was verified OPEN / DRAFT / UNMERGED, based on `main`; do not merge, close, or mark ready.
- Release remains **BLOCKED — RELEASE: NO-GO**. No main-branch write is authorized.
- Device Smoke run `42169009238` (run #7146) is still `IN_PROGRESS` on exact SHA `105737b1e4d5f9e2d6e35dfc7c9f4bfd5b1cbdda`. The observed lane snapshot: Preparation SUCCESS; Quick Capture SUCCESS; Follow-up Persistence SUCCESS; Reminder/Vazirmatn SUCCESS; Task Lifecycle SUCCESS; Calendar Segmented View IN_PROGRESS; Boot and Navigation jobs CANCELLED. Therefore the seven-lane Smoke gate is NOT VERIFIED / incomplete. The cancelled lanes are not PASS and must not be treated as skipped acceptance.
- Exact-SHA Build run `42169009592` (#9904) reports SUCCESS; this does not replace the incomplete Device Smoke gate.
- GitHub exposes committed branch state only. Local working-tree status and local test execution are NOT VERIFIED from this remote audit.

For this checkpoint, the authoritative live files are the branch HEAD, PR #3052, exact-SHA workflow runs, and the canonical source/tests cited in IMPLEMENTATION_LOG.md. This continuity folder is a concise index, not a substitute for the root changelog or detailed execution ledger.


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


## REV7.2 — canonical authority update

- Start with MASTER_GOVERNANCE.md. It is the single canonical governance authority.
- GitHub live repository and exact branch SHA are the operational source of truth. Historical Source ZIP is archive-only and not a prerequisite.
- Current audited branch: fix/recovery-calendar-device-smoke-2026-10-31; SHA b789343c9699ca440d043d71d47db3dcdfafa57c; PR #3052 OPEN/DRAFT/UNMERGED; Main SHA 45e4202b03a434459e4c021a04efa7e8396359db.
- Release: BLOCKED — RELEASE: NO-GO.
- Status axes: Product Approval (APPROVED/SUPERSEDED), Implementation (IMPLEMENTED/PARTIAL/MISSING/BLOCKED), Verification (VERIFIED/PARTIAL/NOT VERIFIED).
- Read CURRENT_STATE.md for exact CI; OPEN_ISSUES.md for all 79 shard failures and blockers; PRODUCT_DECISIONS.md for Decision IDs; ROADMAP.md for Waves 0–5; HANDOFF.md for the next safe action.
- All previous history below remains retained.


## WAVE 4 REV8 execution reports

The latest owner authorization supersedes the earlier read-only Wave 4 checkpoint. Current implementation is PARTIAL; exact-SHA verification and release gates remain open.

- [P0-C Implementation Report](audit/P0_C_IMPLEMENTATION_REPORT.md)
- [SQL-ONLY Consolidation Report](audit/SQL_ONLY_CONSOLIDATION_REPORT.md)
- [Migration Parity Report](audit/MIGRATION_PARITY_REPORT.md)
- [Occurrence Data Ownership Report](audit/OCCURRENCE_DATA_OWNERSHIP_REPORT.md)
- [Backup/Restore Validation](audit/BACKUP_RESTORE_VALIDATION.md)
- [Test Validation Report](audit/TEST_VALIDATION_REPORT.md)
- [Legacy Retirement Register](audit/LEGACY_RETIREMENT_REGISTER.md)
- [WAVE 4 Final Report](audit/WAVE4_FINAL_REPORT.md)


## ONE PATH CONSOLIDATION — active document contract (2026-11-17)

This directory is the single active continuity location for Arvin. The only active reference documents are:

1. `MASTER_GOVERNANCE.md`
2. `PRODUCT_DECISIONS.md`
3. `CURRENT_STATE.md`
4. `ROADMAP.md`
5. `OPEN_ISSUES.md`
6. `IMPLEMENTATION_LOG.md`
7. `HANDOFF.md`
8. `README.md`

Other documents, ADRs, ledgers, reports and historical PR notes are evidence/archive material. They may be consulted to recover a contribution, but they do not independently authorize implementation when they conflict with these active documents or REV10.

**Canonical delivery candidate:** PR #3495 — `recovery-02/main-based-integration` → `main`. Re-fetch the live SHA before every operation. Main is read-only; merge, release and deployment require explicit owner approval.


## Latest owner-locked baseline — 2026-11-21

- Active product baseline: REV10.
- Immutable owner decision: ARVIN-DEC-OWNER-001.
- Canonical brand token: Primary Blue `#4169A1`, sourced from `lib/arvin_colors.dart`.
- Governance execution tracker: [Issue #3653](https://github.com/mobinpda-lab/Arvin-clean/issues/3653).
- Exact-SHA verification remains mandatory; implementation is not product acceptance.

- COMMAND 103-R Governance Validation exposed and drove correction of a duplicate hard-coded Home primary token; see `CURRENT_STATE.md` and `IMPLEMENTATION_LOG.md` for exact-SHA evidence.

## Final reconciliation checkpoint — 2026-11-27
- Last reviewed: 1405/09/06 — 2026-11-27 (Asia/Tehran).
- Reviewed base SHA: 5c8530d53632cffad778baf436d0e35c5eed08dc; Main SHA: 45e4202b03a434459e4c021a04efa7e8396359db.
- Product status: NOT ACCEPTED. Release: NO-GO.
- Live inventory: 1,483 branches, 1,299 PRs, 2,389 Issues; complete paginated CSVs and reconciliation ledgers are under audit/final-reconciliation/.
- Canonical route remains PR #3495, recovery-02/main-based-integration. Main remains read-only.
- Blockers: exact-SHA Build/test/Device Smoke; explicit v7→v9 migration; independent backup/restore; Home five filters; Issue #3646 Reminder window; APK provenance and device acceptance.
- Owner decisions: REV10 + COMMAND 103-R; Primary Blue #4169A1; Vazirmatn; Home filter order Time→Center→Project→Category→Tag; Schema target v7→v9; Reminder actions Stop/Follow-up/Snooze/Complete.
- Historical sources: REV7–REV12 records, #3052/#3384/#3463/#3470 and #3547–#3639 remain preserved; see GOVERNANCE_VERSION_LEDGER and HISTORICAL_RECOVERY_REGISTER.
- Next: continue source-level reconciliation and selective recovery on PR #3495; no merge/release/deletion.


## Product implementation checkpoint — 2026-11-27
- Last reviewed: 1405/09/06 (2026-11-27, Asia/Tehran). Reviewed base SHA: a05c74496f390038afb424e4cf7d53b4427ba648. Main SHA: 45e4202b03a434459e4c021a04efa7e8396359db.
- Product status: NOT ACCEPTED. Release: NO-GO. PR #3495 remains OPEN / DRAFT / UNMERGED.
- Home now has a committed Center filter implementation on the canonical branch: CenterStore load, multi-select OR within Center, no-Center option, Center chips, five horizontal RTL filter cards and a widget test. Commit: 9aa6d06ff7db974809e2871087f88ddbb577b6a9, with test correction a05c74496f390038afb424e4cf7d53b4427ba648.
- Verification: no Arvin Build run is associated with a05c744... at last poll. Zero Dollar Environment Smoke run 45915055641 is PENDING and is not product acceptance.
- Remaining Home gap: Project and Category still use single selection; full OR-within-dimension contract is not yet complete. Center migration/device behavior is not accepted.
- Blockers remain v7→v9 data proof, Backup/Restore, Reminder #3646, all CI shards, Calendar, PDF, typography and device acceptance. See audit/final-reconciliation/ for source evidence.
