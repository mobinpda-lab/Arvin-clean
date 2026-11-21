# ALL PAGES REDESIGN TRACKER — INITIAL
**Status:** IN PROGRESS. Page list is provisional until source-tree scan is complete.

| Surface | Audit | Redesign | Functional regression | Visual evidence | Acceptance |
|---|---|---|---|---|---|
| Home / Dashboard | IN PROGRESS | NOT STARTED | IN PROGRESS | NOT STARTED | NOT ACCEPTED |
| Calendar day/week/month | IN PROGRESS | NOT STARTED | IN PROGRESS | NOT STARTED | NOT ACCEPTED |
| Task list / CRUD / details | IN PROGRESS | NOT STARTED | IN PROGRESS | NOT STARTED | NOT ACCEPTED |
| Checklist / Occurrence / Recurrence | IN PROGRESS | NOT STARTED | IN PROGRESS | NOT STARTED | NOT ACCEPTED |
| Reminder | IN PROGRESS | NOT STARTED | IN PROGRESS | NOT STARTED | NOT ACCEPTED |
| Projects / Centers | IN PROGRESS | NOT STARTED | IN PROGRESS | NOT STARTED | NOT ACCEPTED |
| Categories / Tags | IN PROGRESS | NOT STARTED | IN PROGRESS | NOT STARTED | NOT ACCEPTED |
| People / Follow-ups | IN PROGRESS | NOT STARTED | IN PROGRESS | NOT STARTED | NOT ACCEPTED |
| Notebook / Note editor | IN PROGRESS | NOT STARTED | IN PROGRESS | NOT STARTED | NOT ACCEPTED |
| Quick Add / Search / Filters | IN PROGRESS | NOT STARTED | IN PROGRESS | NOT STARTED | NOT ACCEPTED |
| Reports | IN PROGRESS | NOT STARTED | IN PROGRESS | NOT STARTED | NOT ACCEPTED |
| Settings / Appearance | IN PROGRESS | NOT STARTED | IN PROGRESS | NOT STARTED | NOT ACCEPTED |
| Backup / Restore | IN PROGRESS | NOT STARTED | IN PROGRESS | NOT STARTED | NOT ACCEPTED |
| Navigation / sheets / dialogs / states | IN PROGRESS | NOT STARTED | IN PROGRESS | NOT STARTED | NOT ACCEPTED |

Each row must be split into actual route/screen files after the full source scan. Shared component owner and dependencies must be assigned before edits.



## Concrete source entry points found — 2026-11-19
| Screen / component | Source | Current disposition |
|---|---|---|
| Home / Dashboard | `lib/main.dart` / HomePage | REV10 Center filter missing; 4/5 filters |
| Primary navigation | `lib/widgets/arvin_primary_navigation.dart` | Shared-token refactor in PR #3548; tests pending |
| Calendar | `lib/calendar_page.dart`, `lib/official_calendar_page.dart` | Audit pending; day/week/month/year modes in CalendarPage |
| Notebook | `lib/notebook_page.dart` | Audit pending |
| Task details/editor | `lib/task_detail_page.dart`, `lib/task_editor_dialog.dart` | Audit pending |
| Task people / next action / recurrence | `lib/task_people_page.dart`, `lib/task_next_action_page.dart`, `lib/task_recurrence_page.dart` | Audit pending |
| Reports | `lib/report_center_page.dart`, `lib/task_report_page.dart`, `lib/prayer_completion_report_page.dart` | Audit pending |
| Settings | `lib/settings_page.dart` | Text-size slider exists; font-family selector absent |
| Projects / taxonomy | `lib/projects_launcher.dart`, Settings-routed taxonomy page | Project screen exists; Center management screen/store not found |
| People Directory | `lib/person_directory_page.dart` | Standalone management UI exists; deletion copy test corrected in PR #3547, CI pending |
| Backup / schedule | `lib/backup_page.dart`, `lib/backup_schedule_page.dart` | Full restore acceptance blocked |
| Calendar integration settings | `lib/calendar_integration_settings_page.dart` | Audit pending |
| Quick Add | `lib/quick_capture_dialog.dart` | Audit pending; historical blank date/time regression must be reproduced |
| Shared selectors | `lib/widgets/project_selector_field.dart`, `lib/widgets/arvin_roll_box.dart`, `lib/widgets/arvin_radio_box.dart` | Audit pending |

This list is verified but not yet exhaustive. Continue scanning imported dialogs, sheets, settings subroutes, widget/notification surfaces and all class declarations in the source tree. No visual acceptance until before/after screenshots and functional regression evidence exist.
