# Product Owner Directive — Unified Work Time, Canonical Schema, Filters and Engine
Date: 2026-11-07
Repository: mobinpda-lab/Arvin-clean
Authorized branch: fix/recovery-calendar-device-smoke-2026-10-31
PR: #3052 (must remain OPEN / DRAFT / UNMERGED)
Governing issue: #823
Release gate: BLOCKED — RELEASE: NO-GO

## Governance and evidence
- Inspect live GitHub state before each execution batch and attach every result to the exact source SHA.
- Keep PR #3052 OPEN / DRAFT / UNMERGED. Do not modify main, merge, publish or release.
- Do not delete, skip, bypass, or weaken tests.
- Zero production end-users are declared by the Product Owner. Structural clean-slate Drift/SQLite refactoring is authorized; this does not authorize modifying real user data outside the internal staging/test environment.
- Release remains NO-GO until physical Samsung SM-A528B/DS acceptance evidence is verified.

## Unified Work Time / Due Date
- Quick Add, Task Details and Edit use one field named «زمان کار / موعد» for date and optional time. Remove parallel/redundant Date, Time and Due Date controls after migrating all consumers to the canonical value.
- A specific time becomes overdue immediately after its datetime passes. An all-day/no-time item becomes overdue only after its local calendar day ends (23:59:59). Completed tasks are never overdue.
- Picker sequence: Persian calendar first; after date selection/confirmation open the round time picker automatically.
- The round time picker must contain a dedicated «بدون ساعت» action. Choosing it closes the picker and persists a true all-day/floating state without synthetic 00:00.
- Cancel at either stage preserves the previously persisted valid value.
- Reminders use the same sequential date-then-time/no-time interaction, but each reminder retains an independent alert datetime.

## Canonical schema and entities
- Remove legacy/dead columns follow_up_enabled, follow_up_date and next_follow_up.
- Canonical relational tables: tasks, task_reminders (multiple independent reminders per task), follow_up_records (historical only, completedAt-driven, no future scheduling), persons (unified person entity).
- Bump schema version and ensure fresh database creation is stable and crash-free.
- Follow-up records are historical records only; future scheduling belongs exclusively to TaskReminder.
- Preserve valid task, reminder, follow-up and person relations while refactoring. No synthetic assignee/person may be invented.

## Universal five-way filters
- Shared RTL order: زمان، مرکز، پروژه، دسته، برچسب. No «همه» chip.
- One compact row, no horizontal scrolling, minimum 48dp touch target, responsive at 360/390/412dp.
- Every chip opens ReusableMultiSelectFilterBottomSheet with checkboxes and inline creation. Newly created items persist and are selected automatically.
- OR logic within a dimension; AND logic between dimensions. Active count badge appears on close.
- Reuse the exact component and inline creation behavior in Home, Quick Add, Task Details, and Reports. Task Details applies it to Center, Project, Category and Tag.

## Theme and vector branding
- Apply palette: #078B91, #066F75, #DDF7F5, #F0FAF9, #D9ECEA across navigation, FAB, headers and active chips.
- Preserve Vazirmatn typography.
- Calendar top phrase must use assets/images/branding/tafweez.svg and read exactly «أُفَوِّضُ أَمْرِي إِلَى اللَّهِ» (no leading waw).
- Preserve assets/images/branding/bismillah.svg at fixed 210dp width.

## Person and follow-up binding
- Enabling «منتظر پیگیری دیگران» immediately enables selecting/entering the associated Person in that flow.
- Reports Person filter filters tasks and follow-up records linked to the unified Person entity.

## CI, APK and device evidence
- Run full CI on the updated exact HEAD and produce a Staging APK artifact.
- Calculate SHA-256 over raw .apk bytes, not ZIP bytes; report exact byte size and artifact/download link.
- Run all seven Device Smoke paths and identify whether each is emulator or physical device.
- Physical Samsung SM-A528B/DS evidence is mandatory for release; emulator success is not a substitute.
- Record work in docs/project-continuity/ and update CHANGELOG.
- Until all physical-device smoke paths pass on a single exact candidate SHA, retain BLOCKED — RELEASE: NO-GO.

## Initial live checkpoint (2026-11-07)
- PR #3052 live: OPEN, draft=true, merged=false. Head branch: fix/recovery-calendar-device-smoke-2026-10-31. Head SHA: a10d3f3ed0a4a815ca88b4e7622e07921e7c2290.
- Build run 42381286917 completed success; Analyze, six test shards, Visual, Debug/Release/Staging APK jobs succeeded.
- Calendar Provider run 42381286878 succeeded; Follow-up SQLite run 42381286871 succeeded.
- Device Smoke run 42381286898: boot job in progress, six other smoke lanes queued. Job steps explicitly run the selected canonical smoke on an Android emulator. This is not physical Samsung evidence.
- Staging APK extracted from artifact 13577824216. Raw APK size 79,120,216 bytes; SHA-256 8f253be983cbc2db4f6bc51ad261f1983573396c284b823184d89e20a38bafde. Android debuggable=false, v2/v3 signatures pass, release manifest pass, ephemeral test-only key, publishable=false.
- Source audit at this checkpoint still found legacy Follow-up scheduling fields/columns and no confirmed canonical independent task_reminders table in the inspected Drift schema. The directive is registered here; implementation is not implied by this record.
