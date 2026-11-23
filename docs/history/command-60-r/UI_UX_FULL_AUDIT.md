# UI/UX FULL AUDIT — INITIAL INVENTORY
**Status:** IN PROGRESS — not exhaustive yet.

## Known page families to enumerate against source
- Home / Dashboard and five-filter surfaces
- Calendar: day, week, month, agenda and event details
- Task: list, create, edit, details, checklist, occurrence and recurrence
- Reminder and reminder scheduling
- Project and Center management/details
- Category and Tag management/selectors
- People directory and person details
- Follow-up list, create/edit and details
- Notebook / notes, note editor and taxonomy selectors
- Quick Add / quick capture
- Search, filters, sorting and selection sheets
- Reports and report filters
- Settings and appearance/typography
- Backup, restore and recovery/confirmation surfaces
- Navigation drawer, bottom navigation, dialogs, sheets, menus, empty/error/loading states, widgets and notification/lock-screen surfaces

## Confirmed known regressions from PR #1901
Home visual mismatch/clipped cards/missing filters; Calendar integration actions/settings missing; font picker and font-size control absent; Project/category/tag catalog management and immediate refresh issues; Notebook taxonomy mismatch and non-working tag flow; Quick Add date/time selectors blank; Task Edit date/time alignment; Checklist enable/disable issue; Date/Time picker clock-dial appearance regression.

## Audit dimensions per page
Current implementation, visual hierarchy, interaction, Persian RTL, typography, contrast, responsive behavior, repeated components, empty/error/loading states, accessibility, persistence, feature completeness, screenshot evidence.

## Limitation
This first pass lists known product surfaces from the command and live regression record. It does not yet claim every source route/widget has been enumerated. Lane B must perform a complete source-tree route scan and add discovered pages.



## Source-backed route and interaction audit — 2026-11-19
The following concrete screens/components were verified from the canonical branch source (this is a first route scan, not the final exhaustive inventory):
- Main shell / Home: `lib/main.dart` (`HomePage`), `lib/widgets/arvin_primary_navigation.dart`.
- Calendar: `lib/calendar_page.dart`, `lib/official_calendar_page.dart`, `lib/widgets/canonical_calendar_launcher.dart`.
- Notebook: `lib/notebook_page.dart`.
- Task: `lib/task_detail_page.dart`, `lib/task_editor_dialog.dart`, `lib/task_next_action_page.dart`, `lib/task_people_page.dart`, `lib/task_recurrence_page.dart`.
- Reports: `lib/report_center_page.dart`, `lib/task_report_page.dart`, `lib/prayer_completion_report_page.dart`.
- Settings/administration: `lib/settings_page.dart`, `lib/projects_launcher.dart`, `PersonDirectoryPage` in `lib/person_directory_page.dart`, `TaskTaxonomyManagementPage` routed from Settings.
- Backup and Calendar settings: `lib/backup_page.dart`, `lib/backup_schedule_page.dart`, `lib/calendar_integration_settings_page.dart`.
- Quick capture: `lib/quick_capture_dialog.dart`.
- Shared selectors: `lib/widgets/project_selector_field.dart`, `lib/widgets/arvin_roll_box.dart`, `lib/widgets/arvin_radio_box.dart`.

### Verified REV10 gap in Home
`HomePage._homeFilterCards()` currently renders four filter cards: Time, Project, Category, Tags. There is no Center filter state/card in the visible implementation or `_homeFilterActive`. The five due-date groups (overdue, today, tomorrow, future, no-date) are implemented separately. Therefore Home filter coverage is 4/5; the missing Center filter is a functional REV10 gap, not a cosmetic item.

### Dependency blocker
Schema 9 migration creates `centers`, `center_projects`, `categories`, and `project_categories`, plus optional Task foreign keys. However, canonical source lookup found no `CenterStore`, `centers_page.dart`, or dedicated CategoryStore at the audited paths. ProjectStore and ProjectPlan still expose legacy `project_items` membership and do not provide the complete M2M graph. The Home Center filter must wait for lane A's accepted persistence contract and lane C's store/model/UI integration.

### Corrected stale regression claims
Settings currently contains a text-size slider (12–24), so “font-size control absent” is not a current source fact. A user-selectable font-family picker is absent; the app theme is locked to Vazirmatn. Test and device behavior still require verification.

### Shared visual implementation
`lib/arvin_colors.dart` already centralizes primary/surface/text and semantic status colors. Some widgets still use raw color literals. Primary navigation duplicated three colors and radius/motion constants; lane B PR #3548 moves those to ArvinColors/shared tokens while preserving current values. Not yet tested or accepted.


## Home header redesign — lane B PR #3548
The baseline RTL header used a default RTL Row, placing the first child (notification control) physically on the right and the final child (menu) physically on the left. This contradicted the owner's explicit physical-side decision. Lane B now sets the header Row's layout direction to LTR while preserving RTL text direction inside children: notification physically left, menu physically right. The Bismillah label is wrapped in the approved soft-primary capsule. Widget tests assert both the capsule and physical control order. Status: IMPLEMENTED IN PR / exact-head CI pending; no visual acceptance yet.
