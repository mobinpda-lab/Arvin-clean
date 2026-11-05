# TaskHomeScreen — Final Product and UI Specification

**Status:** APPROVED — PRODUCT OWNER SPECIFICATION  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Authorized branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**PR:** #3052 — must remain OPEN / DRAFT / UNMERGED  
**Release:** BLOCKED — RELEASE: NO-GO  
**Language / direction:** Persian / RTL  
**App font:** Vazirmatn; the Bismillah calligraphy is a separate Arabic-script display treatment.

This is the canonical Home-screen contract. It records the fourteen approved requirements below. It does not replace architecture, persistence, alarm, calendar, or release contracts.

## 1. Header positions
- Right: hamburger menu button, opening the navigation drawer.
- Center: Bismillah calligraphy above the bold «آروین» title and subtitle «مدیریت کارها، یادداشت‌ها و پیگیری‌ها».
- Left: general filter funnel, opening the Today, Timeless, Archive, and Trash views.
- No notification bell in the Home header.
- No standalone search icon in the Home header.

## 2. Bismillah treatment
Display the fully vocalized phrase «بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ» above «آروین», using a restrained, elegant Naskh-style treatment. Keep it visually delicate and minimal; it must not compete with the product title. This treatment is separate from the app's Vazirmatn UI typography.

## 3. Independent search field
- Keep a dedicated search field immediately below the header.
- Exact placeholder: «جستجو در کارها...».
- The search affordance belongs inside the search field; it must not return to the header.
- Search must not clear or mutate active filters or sorting.

## 4. One unified filter-and-sort row
The row is horizontally scrollable on narrow screens and uses this strict RTL order:
1. زمان
2. مرکز
3. پروژه‌ها
4. دسته‌ها
5. برچسب‌ها
6. مرتب‌سازی icon

The sort icon is at the far-left/end of this row. It is not part of the five filters and is not placed beside the general header filter.

## 5. Filter selection semantics
- Each filter category supports checkbox multi-selection.
- Selections within the same category combine with OR.
- Different filter categories combine with AND.
- Applying or clearing sorting must not reset selected filter chips.
- Applying or clearing a filter must not reset the selected sort order.
- The five concepts remain distinct: Time, Center, Project, Category, Tag.

## 6. General filter menu
The funnel icon in the header is a separate general-view shortcut. It exposes:
- Today
- Timeless / کارهای فاقد زمان
- Archive
- Trash
Do not duplicate these general views inside the five quick-filter categories.

## 7. Default sort key
- Default sort key: Follow-up Date, sourced from the canonical latest Follow-up record date.
- Ascending order is the initial direction; the sort sheet may switch to descending.
- Tasks without a Follow-up date remain after dated tasks in either direction.
- When Follow-up dates tie (including both missing), priority order is the deterministic secondary key, followed by stable Task ID.
- The Past group retains its dedicated overdue ordering: incomplete tasks first, then the existing priority/date policy. This exception preserves the established Past-group behavior and its existing regression test.
- Available explicit sort choices: Follow-up Date, Due Date, Latest Changes, and Title.

## 8. Date triad
Keep these concepts independent:
- **Due Date:** task due date; exclusively determines the time group.
- **Follow-up Date:** default Home sorting key.
- **Reminder Date:** alarm/notification trigger time; excluded from Home grouping and sorting.

A Reminder must never be treated as a Due Date or Follow-up Date.

## 9. Home time groups and order
Render the five groups in this order:
1. گذشته
2. امروز
3. فردا
4. آینده
5. فاقد زمان

Classification uses Due Date only. Completed tasks with past Due Dates remain in the Past group but must not be labelled as overdue active work.

## 10. Dynamic Jalali group headings
- Dated group headings display the full Persian weekday and Jalali date.
- Example: «امروز — پنج‌شنبه ۱۴ آبان ۱۴۰۵».
- Example: «فردا — جمعه ۱۵ آبان ۱۴۰۵».
- Calculate these values dynamically from the Iran-local date; examples are not hard-coded.
- Past and Timeless groups must not receive fabricated dates.
- Group headings are collapsible and include a calendar icon and a count badge.

## 11. Task cards
- Clean, lightweight white card surface, consistent with the approved shared card tokens.
- Circular completion control on the right in RTL.
- Persian task title is the most prominent card content.
- Compact taxonomy metadata is shown when present: Center, Project, Category; Tags remain compact.
- Optional Follow-up badge/preview appears only when a real Follow-up record exists.
- Preserve existing task actions, checklist progress, Reminder presentation, and canonical persistence behavior.

## 12. Sorting behavior inside groups
- Sorting changes display order only; it must not modify Task data.
- Keep the five time groups intact when sorting changes.
- Apply the selected sort within each applicable group.
- Do not use Reminder Date to sort or group tasks.
- Past-group special ordering remains as specified in item 7.

## 13. FAB and bottom navigation
- Purple Add (+) Floating Action Button at the bottom-right in RTL, above the navigation bar.
- Exactly five bottom tabs, from right to left:
  1. خانه (active on Home)
  2. تقویم
  3. دفترچه
  4. گزارش‌ها
  5. بیشتر
- «اقدام بعدی» is not a sixth primary tab; it remains accessible from «بیشتر» where applicable.

## 14. Explicit Home prohibitions and invariants
- No KPI cards, statistical summary cards, or dashboard metrics on Home.
- No standalone «کارهای من» tab or Home header; its management options remain under «بیشتر».
- No notification bell or standalone search icon in the Home header.
- No combining the sort action with the general filter menu or counting it as a sixth filter.
- No parallel Task storage/model, no mutation of data from filter/sort operations, and no conflation of Due Date, Follow-up Date, and Reminder Date.
- Preserve all existing tests and assertions. Do not delete, skip, weaken, bypass, or artificially time out tests.

## Canonical implementation surfaces
- Home page implementation: `lib/main.dart` — `HomePage` / `_HomePageState`.
- Filter and sort service: `lib/services/task_list_sort_service.dart`.
- Taxonomy metadata chips: `lib/widgets/taxonomy_icon_row.dart`.
- Primary navigation: `lib/widgets/arvin_primary_navigation.dart`.
- Existing Home widget coverage: `test/widgets/home_page_test.dart`, `test/task_list_sort_service_test.dart`, and the existing Home filter contract tests.

## Verification status rules
- A code change is IMPLEMENTED only after it is present on the authorized branch.
- A test or analyzer result is VERIFIED only for the exact SHA on which it ran.
- Existing workflow results from earlier SHAs do not transfer to later commits.
- Physical-device visual acceptance of the Naskh treatment and the complete Home layout remains NOT VERIFIED until evidence is captured and reviewed.
- PR #3052 remains OPEN / DRAFT / UNMERGED; `main` must remain untouched; release remains BLOCKED — RELEASE: NO-GO.
