# Arvin — Owner Product Decisions — 2026-08-29

This document persists the newest owner-approved product decisions from the active conversation. Live GitHub reality and newer explicit owner decisions still outrank this snapshot.

Owner issue: #524. Related existing contracts/issues include #8, #369, #371, #367, #375, #438, #516 and execution board #403.

## Home
- Permanent Archive and Trash controls must not remain on Home. Archive/Trash stay accessible from the application menu/drawer.
- Move the search field upward in the Home layout.
- The full title `مدیریت کارها و پیگیری‌ها` / Arvin identity must never be clipped on compact width.
- Home must preserve the approved colored visual hierarchy and must not fall back to a plain/uncolored layout.

## Notebook
- Notebook button/action placement must follow the owner-provided reference image.
- Undo and Redo belong at the top of the page.
- Creation records system date/time automatically; the user may explicitly correct the note date/time.
- The note list shows date/time above note content/title.
- Later edits must not silently rewrite original creation time.
- Phone numbers and web addresses may become local actionable links when the user enables the feature.
- Auto-link behavior must be switchable under Notebook settings.
- Canonical Notebook/Task persistence remains authoritative; no second note store.

## Category / Tags / Projects
- Category, Tags and Projects remain semantically distinct but behave consistently across applicable surfaces.
- Each must be manageable from the application menu: add, rename/edit and safe delete.
- Task create/edit presents Category, Tags and Project as compact roll/drop-down style selectors.
- Existing values can be selected; a genuinely new value entered inline is added to the canonical corresponding list and immediately selected.
- No duplicate taxonomy or project store is allowed and deleting taxonomy/project metadata must never silently delete Tasks.

## Calendar
- Tapping an Arvin Task/work item in Calendar opens edit for the same canonical Task.
- Official calendar events remain read-only by tap and are not auto-converted to Tasks.
- Calendar exposes a visible `+` action that opens the normal canonical Task creation path.
- Ordinary Tasks without FollowUp can still have their own date and time through canonical Task due-date/scheduling semantics.

## Prayer-time completion
Prayer-time entries gain a user completion state independent from the calculated prayer-time source:
- `ادا شد` → green visual state.
- `ادا نشد` → red visual state.

Required reports:
- `ادا نشده` entries.
- completed religious duties / `تکالیف شرعی انجام‌شده`.

The report entry belongs under the Calendar section of the application menu. Existing canonical report/PDF/text foundations must be reused where structurally applicable.

## Grouped menu / Settings
The application menu and Settings must be grouped into coherent sections instead of one flat list. At minimum:
- Calendar settings.
- Notebook settings.
- Appearance settings.
- Task/taxonomy management where appropriate.
- Backup/data.
- General settings.

The existing Settings architecture remains the single settings foundation.

Calendar integration remains under:
`Settings → تقویم و همگام‌سازی`

Notebook auto-link preference belongs under Notebook settings. Theme/font/appearance belongs under Appearance settings.

## Execution constraints
- Maximum Parallel remains the governing execution mode.
- Reuse before add; extend before replace.
- No healthy PR/workflow/Build/Device Smoke/Production Orchestrator is paused, cancelled or restarted for this work.
- No force push/merge/update.
- Independent lanes may run in parallel; shared-file collisions wait only at the integration point.
- CI evidence must match the exact head and current main; stale CI is not reused.
- Product merges remain serial and current-main-safe.
- Documentation updates run in parallel with production rather than blocking it.
