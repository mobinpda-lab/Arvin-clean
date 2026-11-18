# ARVIN Changelog — 2026-10-30

## Issue #823 — canonical product contract registration

This entry records the governing product decisions for Reminder-only scheduling, Follow-up history, gestures, Calendar actions, and typography. Registration of the contract is not, by itself, evidence that every legacy consumer has been removed or that release acceptance has passed.

### Canonical model and scheduling

- Retire **Next Follow-up** and the **`followUpEnabled`** column from active schema, models, DTOs, persistence, UI, queries, APIs, tests, and documentation. Retained historical compatibility data must not be read as active scheduling state.
- Use **Reminder-only** scheduling for all future actions. A Follow-up Record represents only a real action completed in the past and must carry its actual `completedAt` timestamp. Opening the Add Follow-up form must not create a record until the user saves it.
- Do not reintroduce future scheduling through Follow-up fields, aliases, or projections.

### Canonical gestures

- **Task-list swipe:** `ثبت پیگیری` opens the Add Follow-up form; it does not immediately create a Follow-up Record. Task-list swipe choices must not contain `انتقال به تقویم گوشی`.
- **Calendar swipe/gesture actions:** Edit, Trash/Delete, and Device Calendar Sync belong exclusively to Calendar items and remain isolated from Task-list swipe choices.

### Typography

- **Vazirmatn** is the exclusive application UI font. It must be registered and bundled inside every distributable APK.
- **System Default** and legacy font-family fallbacks/options are prohibited.
- CI Font Gate must inspect the built APK for Regular, Medium, and Bold Vazirmatn assets and fail if legacy font or System Default source references remain.
- PDF output must use Vazirmatn assets and retain the separate PDF embedding and Persian shaping acceptance checks.

### Acceptance status

- This changelog entry registers the canonical contract; it does not certify a repository-wide Next Follow-up / `followUpEnabled` purge.
- Exact-head Analyze, all six test shards, Debug/Release APK Font Gate, Calendar Provider CRUD, and remaining Issue #823 acceptance gates must pass with retained artifacts before release consideration.
- **Release:** `BLOCKED — RELEASE: NO-GO`.
