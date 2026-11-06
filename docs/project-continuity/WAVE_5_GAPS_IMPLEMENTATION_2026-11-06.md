# ARVIN — Implementation checkpoint for the five open gaps
Date: ۱۴۰۵/۰۸/۱۵ — 2026-11-06 (Asia/Tehran)
Repository: mobinpda-lab/Arvin-clean
Authorized branch: fix/recovery-calendar-device-smoke-2026-10-31
Starting branch HEAD: 4e3136e4dde44bd0b41896265d6ddc6423845046
PR: #3052

## Changes committed
- `957f18bf2e5fe8a6f91e950cd963b2a1d03344dd` — `feat(task): add independent center and explicit all-day flow`
  - Added optional canonical `Task.centerId` with backward-compatible JSON serialization/deserialization.
  - Task edit application now preserves the independent Center reference.
  - Full Task Details now has a Center selector and Inline Add backed by `CenterStore`.
  - Quick Capture writes its selected Center into the canonical Task model.
  - Full Task Details uses a chained Jalali date → time flow for both create and edit.
  - Both full form and Quick Capture expose the explicit «بدون ساعت» action, including when no date has yet been selected; Quick Capture can open a Jalali date-only picker directly. The canonical Task persists `allDay=true`; automatic due-time reminder is cleared for all-day tasks.
- `eaddf66fd512e11a1e16bb0e056dac4824699d54` — `feat(report): reuse Home filters and match direct Center IDs`
- `286485ad1d73231dfb2b7f891803026cf190fd87` — `fix(forms): allow date-only selection before choosing a time`
- `1db75c307f357d50d3e5af5fa8c47666ed8d53f5` — `fix(task): preserve independent center semantics and form state`
- `3ac5e55841de027b18b8b2daa8f843fde1cae60a` — `fix(report): scope person filter to active waiting follow-ups`
  - Extracted the Home filter chip presentation into reusable `HomeFilterPill`.
  - Home and Report Center use the same component, with Report Center exposing the five dimensions in Home order: Time, Center, Project, Category, Tags.
  - Home and Report Center matching now recognizes the direct Task Center ID as well as the legacy Project Center association. Direct Task Center takes precedence; when absent, any linked Project Center can match.
  - Person filtering in Report Center now requires an active, incomplete waiting Follow-up carrying the selected stable person ID; a Task-level person relation or an ordinary/non-waiting Follow-up no longer creates a false match.

## Five-gap status
| Gap | Implementation status | Acceptance still required |
|---|---|---|
| 1. Follow-up person → Report Center | Existing Follow-up editor already supports selecting existing people, inline creation through the canonical directory callback, and stable `personIds`. Existing widget tests cover create/edit and person ID persistence. Added a report-projection regression test in this wave. | Exact-head widget/unit CI and verification of canonical directory write path. |
| 2. Chained date/time + no-time | Chained date → time enabled in full form for both new and existing Tasks; Quick Capture custom date selection already chains to time. Added explicit «بدون ساعت» controls and all-day semantics in both entry surfaces. | Exact-head tests, serialization checks and visual/device acceptance. |
| 3. Center selector + Inline Add | Added direct optional `Task.centerId`, JSON persistence, full form selector and canonical CenterStore Inline Add; Quick Capture now persists its selected Center. | Exact-head analyze/tests, existing-task round-trip and backup compatibility tests. |
| 4. Shared five filters | Extracted shared `HomeFilterPill` and reused it in Report Center in the same five-filter order; direct Task Center IDs participate in Home and Report Center matching. | Widget tests for navigation, filter selection and combined AND semantics. |
| 5. Tests, analyze and continuity | Added focused regression tests for Task Center/all-day serialization, edit application, direct Center report filtering, personId report projection, Quick Capture's explicit all-day action, full-form Center selection, and Report Center's waiting-only person match. | Flutter analyze and complete test suite must pass on the final exact HEAD; no local Flutter SDK was available in this execution environment. |

## Validation and governance
- The source commits above were pushed only to the authorized branch.
- `flutter analyze` has **not** been claimed as passed; exact-head CI is the validation gate.
- Do not reuse earlier workflow results from older SHAs.
- PR #3052 must remain OPEN / DRAFT / UNMERGED.
- No main-branch edit, merge, publication or release is authorized.
- Release remains **BLOCKED — RELEASE: NO-GO** until exact-head CI and owner device acceptance pass.

## Latest exact-head checkpoint
- Latest code/test HEAD at this documentation update: `3ac5e55841de027b18b8b2daa8f843fde1cae60a`.
- `flutter analyze` and full test suite: pending GitHub Actions for this exact HEAD; do not mark PASS until the Build workflow completes.
- The current change explicitly narrows Report Center's selected-person filter to active waiting Follow-ups and has a regression test distinguishing waiting from ordinary Follow-ups.
- PR #3052 must remain OPEN / DRAFT / UNMERGED. No main edit or merge is authorized.
