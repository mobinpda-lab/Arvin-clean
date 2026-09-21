# ARVIN Final UI and Behavior Contract

## Authority
This document is the final owner contract for the current Arvin product completion work. It supersedes conflicting older UI, interaction, test and documentation wording while preserving the existing architecture, canonical data and user information. It is indexed by `docs/ARVIN_UI_CANONICAL.md` and must be read before product-surface changes.

## 1. Non-negotiable implementation rules
- GitHub is the source of truth. Before product changes inspect `main`, open PRs and Actions, then inspect the relevant models, stores, services, pages and tests.
- Preserve Task, FollowUp, Project, Category, Tag, Notebook, Calendar, backup, archive and trash data.
- Reuse canonical storage and services. No parallel Task model, repository, database or storage key.
- Any data migration must be backward-compatible and tested.
- A feature is not complete merely because hidden logic exists; the visible user path, tests, Android evidence and build evidence are required.

## 2. Visual identity
Persian RTL, calm, minimal and professional. Primary `#4A4CAB`; soft primary `#E9EAFF`; background `#F8F8FB`; card `#FDFDFE`; border `#E5E7ED`; main text `#232433`; secondary text `#80829C`. Public application font is VazirHarf v34.003; Vazirmatn is not the application default. Keep spacing, radii, heights and touch targets consistent. Device frames and external advertising/shadow composition are not product UI.

## 3. Home
Required order: centered `بسم الله الرحمن الرحیم`, centered `مدیریت کارها و پیگیری آروین`, notification on physical left, menu on physical right, search, four grouping buttons, mode-specific selector/filter, real task groups/cards, floating `+`, five-item bottom navigation.
Old statistic cards `کل`, `فعال`, `انجام‌شده`, `عقب‌افتاده`, visible `کارهای من`, old `مشاهده همه`, `گروه‌بندی:` dropdown and crowded primary sort dropdown are forbidden on Home. Their useful filters may remain under «بیشتر/کارهای من».

## 4. Four Home grouping buttons
Exactly four equal icon-led modes directly below search, RTL order: زمان, پروژه‌ها, دسته‌ها, برچسب‌ها. زمان uses an orange calendar icon/soft peach; پروژه‌ها blue folder/soft blue; دسته‌ها purple four-grid/soft lilac; برچسب‌ها teal tag/soft mint. No counters. Selected state uses Arvin primary border/surface while the mode keeps its own icon color. Switching is immediate and uses real `HomeGroupingService` projections.

## 5. Time mode
Use only `Task.dueDate`: عقب‌افتاده، امروز، آینده، بدون موعد. Reminder and FollowUp never replace due date. Completed Tasks are not overdue. Future may be subdivided. No-due tasks always have access. Prayer, official-calendar and device-calendar entries do not change ordinary Task counts.

## 6. Projects
Use real ProjectStore data and «بدون پروژه». A Task belongs to at most one project. Each project has folder icon/color and a `+` that opens canonical Task creation with that project preselected. Create/rename/edit/archive/safe-delete reuse existing management. Deleting a project never deletes its Tasks and projections never duplicate Tasks.

## 7. Categories
Categories are independent of projects. Provide «بدون دسته», safe create/edit/rename/delete, independent icon/color, project filtering and management. Icons are functional visual identifiers.

## 8. Labels
Tasks may have multiple labels. Multi-label projection may show one Task in multiple label groups but must never duplicate persisted Tasks or inflate global counts. Provide «بدون برچسب», tag icon/colors, create/rename/recolor/safe-delete and project/category restrictions where supported.

## 9. Home Task card
Show completion control, title, project/category, due date when present, meaningful status and restrained labels. Tap opens detail, not direct edit. Secondary text is exactly one line: latest FollowUp note when a FollowUp exists; otherwise one line of task description. Truncate with ellipsis. Latest FollowUp date/time is separate, lighter metadata. Edit/complete never erases FollowUp history.

## 10. Quick Capture
Quick Capture is a real bottom sheet, not an ordinary AlertDialog. It opens from the bottom above the keyboard, RTL, titled `ثبت سریع کار`, with prominent focused title field and `ثبت کار` / `فرم کامل`. Optional quick metadata: date, time, project, category, label, reminder, recurrence. A normal Task receives no automatic date/time/reminder/priority.
Sequential save uses canonical TaskStore; sheet stays open; task-specific input clears; reusable selections may remain; title refocuses; keyboard stays open; Home refreshes; brief `کار ثبت شد`; empty/double save blocked; failed saves preserve input.
Android Back closes an open sub-selector first; empty draft closes to Home; non-empty draft shows exactly `ثبت و خروج`, `خروج بدون ثبت`, `ادامه نوشتن`. Close button uses the same protection. Full form continues the same draft/id; cancel preserves it; save creates no duplicate Task.

## 11. Swipe
Swipe is true RTL and Android-tested. Required operations: complete, move/change date to today, move to project/category, trash. Left/right are configurable. Normal delete is Trash, not permanent delete; Trash supports Undo; permanent delete requires explicit confirmation. Existing archive/trash/move-to-today behavior is retained while complete/date-change actions are added where supported. Final report states actual left/right defaults.

## 12. FollowUp Task detail
Detail shows title, project, category, status, description, due date, reminder, labels, latest FollowUp card, count, newest-to-oldest history, edit, complete and round `+`. Empty history: `هنوز پیگیری ثبت نشده است`.
New FollowUp defaults to current date/time, both editable. Blank text becomes `پیگیری`. Entries append; previous history is never overwritten. Successful save closes entry and refreshes detail/Home; errors preserve input; rapid duplicate save is blocked. Future follow-up appears only when real data/logic exists.

## 13. Notebook
«دفترچه» provides notes/checklists with title/subtitle, search, category filter, type selection, cards, `+`, Trash/recovery and safe category moves. Simple Note is a calm full-screen/near-full-screen editor with title/date/category/body and top save/back/move/delete. Checklist is a separate mode with title/category, real completed/total count and progress, item add/edit/delete/check. Category movement preserves id. Both reuse CanonicalNotebookRepository and TaskStore; no parallel storage.

## 14. Calendar
Use real Jalali dates with daily/weekly/monthly views and annual view when healthy. Support navigation, today, direct date selection and long-press task creation with selected date. Distinguish Task, FollowUp, Reminder, official occasion and device event. Use real data. Device-calendar synchronization is optional through settings; device events may be read when enabled and edit/conversion requires confirmation. Existing healthy prayer/calendar capabilities are preserved.

## 15. Primary navigation
Exactly five destinations: خانه، تقویم، دفترچه، اقدام بعدی، بیشتر. No sixth destination for project/category/tag. Floating `+` stays above bottom navigation without overlap.

## 16. Next Action
Suggestions come only from real Tasks, show a comprehensible reason and open that Task detail. No fake/placeholder AI suggestions. Completed, archived and trashed Tasks are excluded.

## 17. More
Provide paths to کارهای من and filters, کارهای امروز, فاقد موعد, projects, categories, labels, follow-up/waiting-for-response, reports, archive, trash, backup/restore, settings, help and about. Reuse existing pages; no parallel versions.

## 18. Settings
Real settings only: system/light/dark theme, VazirHarf default, text size when supported, Persian dates, configurable left/right swipe, notifications/permissions, automatic follow-up only if real, calendar/sync, backup/restore, privacy, help/about, project management and category/label management. Do not show inert controls.

## 19. Documentation
Register this contract at `docs/ARVIN_FINAL_UI_AND_BEHAVIOR_CONTRACT.md`. `docs/ARVIN_UI_CANONICAL.md` must explicitly identify it as newest owner authority. Do not create `docs/ui-reference/` if absent and never invent screenshots. If reference images exist, map each to its screen here.

## 20. Mandatory tests
Home: old stat cards absent, Home `کارهای من` absent, four grouping modes with icon/selection state, real projection switching, multi-label storage remains one Task, unassigned paths exist, one-line secondary text.
Quick Capture: three sequential saves without closing, clear/refocus/keyboard persistence, empty/double-save protection, error preservation, full-form cancel preservation, no duplicate Task, correct Back, Android keyboard/Back integration evidence.
FollowUp: blank canonicalization, append/history order/history preservation, Home latest text.
Notebook: independent note/checklist UI, canonical storage, same-id category moves, correct progress, trash/recovery.
Calendar/Swipe: dueDate-only time grouping, RTL swipe mapping, trash Undo, Jalali views and long-press task creation.

## 21. Quality gates
On the final commit run:
```
flutter pub get --enforce-lockfile
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```
Use the repository's pinned VazirHarf workflow/commit. Old green results do not count for a new commit. Verify Home in all four modes, Quick Capture with keyboard, three sequential captures, Android Back, FollowUp detail, Notebook note/checklist, Swipe, Jalali Calendar, Settings, RTL/truncation/FAB/bottom navigation.

## 22. Delivery evidence
Final report includes branch, final SHA, PR link, changed files, exact change summary, analyze, complete tests, debug/release builds, same-commit Actions links, real Android screenshots, sequential-capture evidence, limitations and documented-but-not-coded/coded-but-not-Android-verified items. Status values: مستندشده، پیاده‌سازی‌شده، دارای آزمون، تأییدشده روی Android، کامل. Nothing is «کامل» without code + tests + build + Android evidence for the same commit.

## 23. Execution order
1. Contract and conflict cleanup
2. Home/four grouping buttons
3. Task card/latest FollowUp text
4. Quick Capture bottom sheet
5. Focus/keyboard/Back
6. Swipe
7. FollowUp detail
8. Notebook/note/checklist
9. More/Settings
10. Tests/Android/screenshots
11. Final debug/release build and PR delivery

This is a completion contract, not a mock, proposal or disabled implementation.
