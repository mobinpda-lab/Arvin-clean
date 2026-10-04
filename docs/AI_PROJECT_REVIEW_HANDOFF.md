# Arvin — AI Project Review & Continuity Handoff

> This document is the authoritative handoff for any AI that receives an exported ZIP of this repository and must independently audit the whole project.
> PRODUCT FIRST: the factory is a tool; Arvin is the product.

## 1. Review protocol
- Read this file first, then analyze the entire ZIP, not only named files.
- Treat code/tests as evidence, not proof of product completion.
- Classify every area as Implemented / Partial / Missing / Contradictory-Stale / Untested on real device / Architecture Risk.
- Never create parallel Storage, Model, Repository, Recurrence, Search, or Calendar engines when a canonical path exists.
- Architecture, migration, storage, or Calendar identity/sync changes require independent architecture review before implementation.
- End with a product-first prioritized action plan and explicit duplicate-work warnings.

## 2. Product definition
Arvin is a Persian RTL personal organizer centered on Tasks and Follow-ups.
A Task is composable and may contain any combination of Date+Time, Reminder, Recurrence, Follow-up, Checklist, Project, Category, Tags, Priority, People, and Calendar integration.

### Authoritative Checklist decision
Checklist is a GENERAL FEATURE OF EVERY TASK. It is not a Task type.
School checklist is only a use case of the same Checklist + daily recurrence.

Example Task: آماده‌سازی بچه‌ها برای مدرسه
- Time: today 06:00
- Recurrence: every day
- Reminder: 05:50
- Follow-up: enabled
- Checklist: کیف / خوراکی / لباس / بطری آب / کفش / بررسی تکالیف

## 3. Checklist — final product contract
Required MVP:
1. Fast add: type item and press Enter.
2. Independent checked/unchecked state for every item.
3. Edit item text.
4. Delete item.
5. Reorder items; final preferred UX is real Drag & Drop.
6. Progress on Task card/Home, at minimum 4 از 6.
7. Recurring Task support.
8. Checklist definition and occurrence execution are conceptually separate.
9. Today and tomorrow must not share completion state.
10. Previous occurrence history must be preserved.
11. Works with Date + Time + Reminder.
12. Works with Follow-up.
13. Uses canonical Project/Category/Tag.
14. Backup/Restore and migration preserve Checklist and relevant occurrence history.
15. RTL, Persian text/digits, reload/restart persistence, and real-phone acceptance.

Current main already has a substantial Checklist foundation:
- Task.checklist
- Task.checklistOccurrences
- Checklist editor in lib/task_editor_dialog.dart
- fast add, checkbox toggle, edit/delete, arrow reordering
- recurring occurrence support in TaskRecurrenceRepository
- TaskStore serialization/preservation
- persistence tests

Therefore: DO NOT rebuild Checklist from scratch.

Remaining Checklist work:
- Replace arrow-only ordering with final Drag & Drop.
- Complete item touch UX for edit/delete/move.
- Prove independent daily occurrence behavior through UI/product flows.
- Show progress on Task card/Home.
- Verify Checklist + Date/Time/Reminder.
- Verify Checklist + Follow-up.
- Verify Checklist + Project/Category/Tag.
- Verify Backup/Restore and migration.
- Verify RTL/Persian digits.
- Define behavior when the Checklist definition changes after prior occurrences exist; architecture review first if model/storage changes are needed.
- Exact-head Analyze + full Test + Debug/Release Build + Device Smoke, then real-phone acceptance.

Out of MVP: Template Library, Template sharing, separate school system, parallel Checklist storage/model/repository, parallel recurrence engine.

## 4. Product areas for full ZIP audit
### Home
- Persian RTL; title: مدیریت کارها و پیگیری آروین.
- Main groups: زمان / پروژه‌ها / دسته‌ها / برچسب‌ها; no legacy counter cards.
- Home Search must search all Tasks: active, completed, archived, deleted.
- Cards must remain readable and multiline with semantic status/priority/taxonomy.
- No parallel search engine/storage.

### Quick Add
- Persian Jalali date; time input; reminder presets: on time, 15m, 1h, 1d, 1w, custom.
- Full custom date/time path; recurrence; Project/Category/Tag RollBoxes.
- Create/select must refresh immediately; existing tags selectable; no blank selectors.

### Task Editor
- Project / Category / Tag row; tag multi-select; Date + Time; Reminder; canonical recurrence RollBox; Priority; Done/Undone; Checklist; Follow-up.
- Audit narrow RTL/readability issues.

### Task ↔ Follow-up
- Conversion in both directions; history preserved; swipe behavior; Checklist can coexist; no data loss.

### Calendar / Defer / Auto Sync
Before fundamental changes, independently review stable Task↔Event identity, create/update/delete without duplicates/orphans, destination calendar, auto-sync on/off, completion/deletion, Defer, edit-from-calendar, Event-ID migration safety, and canonical storage.
Do not create a second Calendar engine.

### Recurrence
- Daily/weekly/monthly/yearly/custom; interval; occurrence behavior; past occurrences; Move to Today where applicable; occurrence reminders; Checklist independence.

### Notebook
- Persistence/autosave/reopen; Note vs Checklist UX; shared taxonomy; inline tools; filters; undo/redo; appearance; no parallel storage.

### Typography
- VazirHarf v34.003 baseline; app-wide consistency; RTL/Persian digits; size/preview/persistence.

### Reminder / Notification / Widget / Lock Screen
- Visual hierarchy, permissions, reboot/reschedule, launcher/keyguard, reminder correctness.

### Backup / Restore / Migration
- Preserve IDs, history, Checklist, occurrence state; no data loss; no parallel storage; old Home UI is not migrated as data.

### Release Gate
Release-Ready requires exact current HEAD evidence: Analyze green, full Test green, Debug APK, Release APK, available Device Smoke evidence, and real-phone acceptance on the same exact HEAD with no known P0 blocker.

## 5. GitHub continuity references
- #2224 permanent ادامه آروین execution cycle.
- #2233 canonical product remaining-work ledger.
- #2230 authoritative Checklist contract.
- #2234 / #2235 Home Search all Task states.
- #2238 Quick Add recurrence RollBox.
- #2240 / #2241 Task Editor recurrence RollBox.
- #2248 independent Calendar Task↔Event and Auto Sync architecture review.
- #2102 Release Gate.
- #1923 historical continuity reference.

Older Issues/PRs must be reconciled against these current contracts before reuse. Do not blindly revive legacy UI requirements.

## 6. Execution rules
1. PRODUCT FIRST.
2. Factory/CI is acceleration and evidence, not the product.
3. Real code: Issue → Branch → PR.
4. Prefer extending canonical existing paths.
5. No duplicate Storage/Model/Repository/Recurrence/Calendar/Search engines.
6. Parallelize independent work when safe.
7. Batch related P0 work when that reduces repeated phone cycles.
8. After the P0 wave, create one integrated exact-head APK for real-phone acceptance.
9. Never call a feature Done/Release-Ready without evidence.

## 7. Required external-AI report
Return:
1. Executive product verdict: usable today? Release-Ready? top 5 blockers.
2. Product matrix: status, what works, partial, missing, evidence, device uncertainty.
3. Architecture audit: duplicates, parallel engines, migration risks, Task/Checklist/Recurrence relationship, Calendar risks, legacy paths.
4. Checklist deep audit against Section 3 item by item.
5. Test gap analysis: unit/widget/integration/device gaps and stale tests.
6. UX audit: RTL, Persian digits, date/time, RollBoxes, clipping, accessibility, Home, Checklist interaction.
7. Data-safety audit: serialization, restore, migration, IDs, occurrence history, archive/delete semantics.
8. Prioritized P0/P1/P2 action plan with affected files/components and architecture-review requirement.
9. Duplicate-work warnings: explicitly flag anything already implemented or already tracked.
10. Shortest path from the ZIP to a real Release-Ready Arvin.

## 8. ZIP limitation
A ZIP is a snapshot. GitHub remains the live source of truth for issue/PR/history/CI status.
An AI reviewing only the ZIP must clearly mark what it cannot prove without GitHub or a real device and must not declare Release-Ready from source code alone.

## 9. Non-negotiable product decisions
- Checklist is a general Task capability.
- School checklist is only a use case.
- Recurring Checklist completion is independent per occurrence/day.
- Checklist progress belongs on Task/Home cards.
- Templates are future, not MVP.
- Calendar fundamental changes wait for architecture review.
- Success = usable, tested, Release-Ready Arvin, not a merely healthy factory.