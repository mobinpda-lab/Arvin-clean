# Arvin RC acceleration plan — 2026-08-31

This document is intentionally evidence-driven and current-main-only.

## Already complete on main

- CI baseline is green; full analyze/tests, Debug APK, Release APK, Home Device Smoke, and People Device Smoke have recent current-main proof.
- Calendar canonical UI now includes the Jalali «برو به تاریخ» flow through PR #575 / issue #529.
- Backup is not a raw service only: `ArvinBackupManager` already serializes/restores canonical Tasks and Projects with validation and encrypted backup support.
- Notebook already has canonical repository-backed note/checklist editing, autosave, and categories.
- Projects already have a product page/launcher and canonical model integration.
- Work Agenda already has report adapter/PDF regression coverage.

## RC critical path

1. Harden the AI Worker so malformed model output cannot stall Production. Current slice: patch structure validation, provider timeout/budget, and bounded retries.
2. Re-prove the AI Worker against one real `arvin-auto` issue after the hardening merges.
3. Run a final current-main Release APK + Home/People Device smoke + critical E2E proof.
4. Close or supersede only stale historical items that are proven obsolete by current-main evidence.
5. Refresh the project completion/RC scorecard from repository evidence only; do not reuse historical percentages.

## Parallel non-conflicting lanes

- Product gap audit: Backup UI/scheduling, Calendar device sync settings, Work Agenda surface gaps.
- CI/automation: AI Worker reliability and Production feedback/orchestration contracts.
- Documentation: update only from merged code, exact-head validations, and confirmed issue/PR state.

Large architecture changes such as storage migration or model code generation are deferred until after RC unless a current-main blocker proves they are required.
