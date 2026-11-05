# Arvin Repository Map
**Audit snapshot:** 2026-10-11  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Audited base:** `main` at `72a2f4cc24df7a38eff9856ce403461615db5280`  
**Scope:** read-only inspection of repository structure, selected canonical source files, tests, workflows and architecture documentation. This audit branch changes documentation only; no app code, schema, migration, workflow or user data is changed.

## Repository shape
The recursive Git tree shows a Flutter/Dart Android application with application code in `lib/`, unit/widget tests in `test/`, Android integration smoke tests in `integration_test/`, Android host/widget code in `android/`, automation in `.github/workflows/`, and a large set of product/architecture records in `docs/`. The repository also includes orchestration/runtime tooling under `.github/arvin/` and `execution_stream/`.

## Component inventory

| Component | Location | Purpose | Owner layer | Audit status |
|---|---|---|---|---|
| App entry / Home | `lib/main.dart` | App composition, Home, canonical TaskStore and ProjectStore wiring | Presentation / composition | PARTIAL — primary wiring exists; Home still has a legacy-compatible Task path in surrounding services |
| Canonical Task model | `lib/models/task.dart` | Task identity, title, dates, priority, Category, Tags, checklist, recurrence, FollowUps, history and people | Domain model | PASS for one model; persistence completeness assessed separately |
| Task persistence | `lib/services/task_store.dart` | SQLite/Drift reads/writes, mutation boundary, legacy migration and Task relation persistence | Data / repository boundary | PARTIAL — canonical SQL exists alongside legacy SharedPreferences migration/write compatibility |
| Storage contract | `lib/core/storage/task_store.dart` | Generic load/save abstraction | Core boundary | PARTIAL — generic interface exists; main TaskStore is a separate concrete class, so do not mistake this interface alone for the active repository |
| SQL schema | `lib/services/g1_drift_schema.dart` | Tasks, follow-ups, projects, project membership, category/tag catalogs, task-tags, checklist rows, people and metadata | Persistence schema | PARTIAL — recurring occurrence state and some Task fields remain in preserved JSON envelope rather than dedicated relational tables |
| Task migration | `lib/services/task_migration_reader.dart`, `task_migration_adapter.dart`, `task_migration_writer.dart`, `sql_task_migration_writer.dart` | Read legacy JSON, preserve unknown fields, migrate records into SQL | Migration boundary | PARTIAL — source-preservation and identity checks exist; full cutover/rollback and all-version device evidence still required |
| Project model / store | `lib/models/goal_project.dart`, `lib/services/project_store.dart` | Project metadata and links to canonical Task IDs | Domain + data | PASS/PARTIAL — Project owns membership references, not duplicate Task payload; category scoping remains unresolved |
| Category catalog | `Task.category`, `taxonomy_categories` in `lib/services/g1_drift_schema.dart`; catalog methods in `lib/services/task_store.dart` | One primary classification per Task | Domain + data | PARTIAL — separate catalog exists; physical Project ownership/foreign-key is not present in inspected schema |
| Tag relations | `Task.tags`; `tags` and `task_tags` SQL tables; `lib/services/tag_store.dart` | Multi-valued Task labels | Domain + data | PARTIAL — canonical SQL relation exists, but a legacy SharedPreferences `TagStore` also exists; active call-site/unused catalog reconciliation should be confirmed |
| Checklist | `Task.checklist`, `checklistEnabled`, `checklistOccurrences`; `checklist_items` table | Task checklist and per-occurrence checklist state | Domain + persistence | PARTIAL — UI/service/tests exist; checklist rows are relational, while per-occurrence state is preserved in Task JSON envelope |
| Repeat / Occurrence | `lib/models/recurrence.dart`, `lib/services/task_recurrence_repository.dart` | Recurrence rule and per-occurrence execution state | Domain service | PASS for no Task cloning; PARTIAL for durable history model and end-to-end acceptance |
| Follow-up / Tracking | `FollowUp` in `lib/models/task.dart`; `lib/services/follow_up_repository.dart`, `follow_up_write_coordinator.dart` | Follow-up history and reminder projection on Task | Domain + service | PARTIAL — attached to Task, but release acceptance across create/edit/reminder/backup needs end-to-end proof |
| Calendar projection | `lib/services/calendar_schedule_projection.dart`, `follow_up_calendar_projection.dart`, `lib/calendar_page.dart` | Projects canonical Tasks/FollowUps into calendar UI | Application projection | PARTIAL — projection is present; it is not the owner of Task data |
| External Calendar sync | `calendar_outbound_sync_service.dart`, `calendar_inbound_sync_service.dart`, `calendar_sync_plan_service.dart`, `calendar_provider_sync_executor.dart`, `external_calendar_link_store.dart`, `system_calendar_bridge.dart` | Idempotent external event create/update/delete and link tracking | Integration boundary | PARTIAL — stable links/fingerprints and update path exist; provider/device and restore conflict cases need evidence |
| Backup / Restore | `lib/backup_manager.dart`, `lib/backup_service.dart`, `lib/services/project_backup_bridge.dart`, `external_calendar_link_store.dart` | Portable Task/Project/settings/calendar-link backup and candidate restore | Data safety | PARTIAL — canonical and legacy backup implementations coexist; tests exist but actual user-data round-trip is not proven by source alone |
| Search / reports | `lib/services/task_search_service.dart`, `task_report_projection.dart`, `task_report_pdf_renderer.dart`, `lib/report_center_page.dart` | Query and report projections over Task data | Application services / UI | PARTIAL — implementation and focused tests exist; cross-surface semantic consistency requires broader matrix evidence |
| Android host / widget | `android/app/src/main/`, `lib/services/widget_task_bridge.dart`, `lib/widgets/` | Native bridge, reminders/widget integration | Platform integration | PARTIAL — source and smoke tests exist; actual physical-device validation is not implied |
| Unit/widget tests | `test/` | Domain, persistence, UI and workflow contract tests | Verification | PARTIAL — many focused test files exist; presence is not proof all current-main tests passed in this audit |
| Android integration tests | `integration_test/` | Home, quick capture, SQL persistence/migration, backup/restore, Calendar Provider and People flows | End-to-end verification | PARTIAL — tests/workflows exist; emulator success is not physical-device acceptance |
| Build / smoke / release workflows | `.github/workflows/build.yml`, `device-smoke.yml`, `calendar-provider-acceptance.yml`, `final-head-release-validation.yml`, `release.yml`, `release-closure.yml` | Analyze, sharded tests, APK builds, Android smoke and release evidence | CI / release gate | PARTIAL — automation is configured; latest main final-head validation was still in progress at snapshot time |
| Product/architecture records | `docs/ARVIN_MASTER_EXECUTION_PROTOCOL.md`, `docs/DEVELOPMENT_RULES.md`, `docs/PRODUCT_CONTRACT_MATRIX.md`, `docs/ADR/`, `docs/DATA_MODEL_PROJECT_CATEGORY_TAG.md` | Product rules, architecture decisions, acceptance matrix | Governance | PARTIAL — current ADR exists; `docs/ARVIN_STATUS.md` contains stale historical pointers and must be reconciled with current main |

## Architecture facts evidenced in source
- `Task` is the canonical domain object in `lib/models/task.dart`; `TaskStore` reads/writes SQL tables while preserving an original JSON envelope for fields not fully represented in relational columns.
- `ProjectPlan.itemIds` refers to existing canonical Task IDs. Project data is stored separately from Task payloads.
- Category and Tag are separate fields/catalogs. The accepted ADR explicitly says Category and Group are synonyms, not separate entities.
- `TaskRecurrenceRepository` updates recurrence and occurrence history through the same TaskStore; recurrence calculation does not create cloned Tasks.
- Calendar sync stores external identifiers separately and uses revision fingerprints and explicit update operations.
- Two backup APIs exist: canonical `ArvinBackupService`/`ArvinBackupManager` and a simpler `BackupService` that exports/imports SharedPreferences. The active product wiring should remain the canonical path; legacy implementation removal or retirement requires call-site confirmation.

## Audit limits
This is a source/documentation inspection, not a complete dynamic audit. No application tests, APK builds, emulator runs, or physical-device actions were executed by this documentation-only pass. No claim of release readiness is made. The domain-wide Project/Category/Tag issue #2580 remains open; this report does not replace its full UI/help/docs term-by-term audit.
