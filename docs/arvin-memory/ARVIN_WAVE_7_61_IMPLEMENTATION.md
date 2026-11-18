# ARVIN — Wave 7.61 implementation record

- **Date:** 2026-10-30
- **Branch:** `fix/wave-7-61-reminder-only-next-follow-up`
- **Base SHA:** `ed54ea8fc81caa365e0cc7eb1cf32badce0ab757`
- **PR:** #2995 — must remain OPEN / DRAFT / UNMERGED
- **Issue:** #2102 — must remain OPEN
- **Release:** **BLOCKED — RELEASE: NO-GO**

## Typography

- The Settings font picker and active font-family preference reads/writes are removed.
- The application theme is pinned to the bundled Vazirmatn family.
- PDF output continues to load bundled Vazirmatn Regular and Bold font assets.
- New portable settings omit `fontFamily`.
- Legacy backups may contain `fontFamily`; restore ignores that key and does not persist it. The app remains pinned to Vazirmatn.
- Calendar text that previously referenced the retired VazirHarf alias now uses the Vazirmatn family.

## Task completion

- `Task.completedAt` is nullable and participates in Task JSON serialization.
- SQLite schema version 7 adds nullable `tasks.completed_at`.
- The schema upgrade is additive and idempotent. Existing completed rows without a trustworthy timestamp remain NULL; migration does not invent historical completion times.
- First transition from incomplete to complete records the supplied/current timestamp. Repeated completion is idempotent. Reopening clears the timestamp; a later completion records a new timestamp.
- Task editor metadata updates preserve the existing timestamp when completion state is unchanged.
- Single and bulk completion use the same Task lifecycle helper. Bulk completion changes only completion metadata and preserves existing Follow-up history.
- Task SQL load/save, legacy migration, and Task JSON backup serialization carry `completedAt`.

## Reminder-only follow-up behavior and legacy preservation

- Quick Capture no longer offers the legacy `followUpEnabled` toggle or creates a Follow-up record from that flag.
- Task editor no longer reads or writes the legacy scheduled `followUpDate` / `followUpEnabled` controls.
- Follow-up repository mutations no longer set `followUpEnabled` as a side effect.
- The optional reminder form shortcut is labeled exactly **«افزودن یادآور»**.
- No synthetic Follow-up records are created.
- Historical `nextFollowUp` values are retained for compatibility. The repository's accepted historical decision distinguishes a future action date (`nextFollowUp`) from a notification time (`reminderDate`). Those values are not semantically interchangeable; automatic conversion would invent notification intent. Therefore no legacy value is copied into Reminder rows. This is the explicit unresolved migration boundary: legacy action-date data is preserved but is not migrated to reminders unless a future owner decision supplies an unambiguous mapping.
- Legacy `followUpEnabled` / `followUpDate` compatibility fields and their SQL columns are retained to avoid destructive data loss; product UI and mutation behavior no longer depend on them.

## Calendar gestures and isolation

- Separate local settings exist for left and right calendar-card swipes: Edit, Trash, Sync, or None.
- Settings default to None on both sides and are stored independently.
- Calendar-card swipes are scoped to Arvin task/follow-up identifiers. `external-calendar:*` items are explicitly excluded from internal edit, trash, and sync paths.
- Task Trash still passes through the existing confirmation path. Calendar callback failures are caught at the card boundary and report failure without local optimistic mutation.
- Follow-up card swipes only edit when an authorized edit callback exists; Trash and Sync are task-only because the current callback contract does not provide Follow-up deletion or a Follow-up sync target.
- Calendar swipe preferences currently live in local preferences; portable backup inclusion remains a follow-up limitation.

## Report Center

- Report Center exposes **«گزارش پیگیری‌های انجام‌شده»**.
- The selected Jalali date is converted to its corresponding local day interval `[startOfDay, startOfNextDay)`.
- Results require `completed == true` and a real `completedAt` inside that half-open interval. Due dates, reminders, legacy follow-up flags, and missing timestamps are never substitutes.
- Result rows use stable Task IDs and open the canonical Task detail/history route.

## Regression coverage added or updated

- Task JSON completion timestamp round-trip and completion/reopen/idempotence.
- SQLite schema upgrade from a pre-`completed_at` table, including proof that legacy completed rows remain timestamp-NULL.
- SQL migration and canonical TaskStore persistence with Follow-up history preservation.
- Task editor metadata preservation of completion timestamps and legacy compatibility values.
- Bulk completion idempotence and Follow-up history preservation.
- Legacy font backup restore behavior and removal of the font picker.
- Quick Capture retirement of the legacy follow-up toggle.
- Independent calendar swipe settings and external-calendar item isolation.
- Jalali daily completion report half-open boundary behavior.

## Validation and governance

This document records intended code and test coverage, not CI success. Exact-head Analyze, tests, acceptance workflows, APK jobs, and artifact verification must be recorded against the resulting commit SHA. Baseline results are not evidence for a new commit. Device sign-off remains an independent release gate.

**Release remains BLOCKED — RELEASE: NO-GO.**
