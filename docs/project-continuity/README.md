# Arvin Project Continuity
Last reviewed: ۱۴۰۵/۰۸/۱۴ — 2026-11-05 02:38 Asia/Tehran
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
5. task_home_screen_spec.md — canonical fourteen-point approved Home screen contract.
6. task_detail_ui_ux_spec.md — canonical eleven-section unified Task Details form.
7. TASK_TEMPLATE_DATA_CONTRACT.md — canonical G1 v11 Task Template transfer and migration contract.
6. task_detail_ui_ux_spec.md — canonical unified Task Details form and eleven-section contract.
7. TASK_TEMPLATE_DATA_CONTRACT.md — canonical Task and Project Template data, migration and interaction contract.
5. ROADMAP.md — ordered product work.
6. IMPLEMENTATION_LOG.md — dated changes and exact-SHA evidence.
7. Root CHANGELOG.md — chronological repository history.
8. docs/ARVIN_CONTINUATION_LEDGER.md — detailed historical execution ledger.
9. ARVIN_AI_CONTEXT.md — broad product and architecture context.

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
