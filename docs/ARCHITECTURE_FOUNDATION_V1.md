# Arvin v1 — Architecture Foundation

> بسم الله الرحمن الرحیم

## 1. Scope
This document records the architecture target for the v1 incremental migration. It is a foundation document, not a rewrite plan.

## 2. Authoritative target
- Clean Architecture
- Feature Based structure
- Riverpod 3.x for application/state orchestration
- `BaseEntity` + composition
- No `UnifiedItem` as the long-term domain abstraction
- Incremental migration with backward-compatible persistence

The approved UI contract is immutable during this migration: RTL, Persian, typography, colors, spacing, cards, navigation, Reminder, Widget and Lock Screen behavior.

## 3. Current baseline audit
At commit `55710e2240c2c30362c156acb1f9e3455f855642`:
- `lib/` is still largely flat/legacy-oriented.
- `lib/models/task.dart` contains `Task` plus the `FollowUp` model.
- `lib/models/follow_up.dart` is a compatibility export of `FollowUp` from `task.dart`.
- `Task` currently acts as the shared product model and contains reminder, recurrence, checklist, tags, category and follow-ups.
- No `lib/features/`, `lib/domain/`, or `lib/data/` structure was found at the audited baseline.
- `pubspec.yaml` does not yet contain Riverpod.
- Existing Calendar, Backup/Restore, Search and Android/CI foundations must be preserved and audited before migration.

## 4. Migration map
| Current area | Target boundary | Strategy |
|---|---|---|
| `lib/models/task.dart` | `domain/entities` | Extract `BaseEntity` and compose capabilities incrementally; keep legacy JSON compatibility. |
| `FollowUp` in `task.dart` | `domain/entities` / feature FollowUp | Keep value/entity semantics stable; remove duplicate ownership only after callers are migrated. |
| Legacy persistence / stores | `data` + repository interfaces | Define repository boundary first; adapters bridge old storage during migration. |
| UI pages in flat `lib/` | `features/<feature>/presentation` | Move only after dependency boundaries are proven; no UI redesign. |
| Providers/state holders | `application` / Riverpod 3.x | Introduce Riverpod at controlled seams; do not parallelize state systems unnecessarily. |
| Calendar | `features/calendar` | Preserve existing Calendar foundation; isolate provider/data boundary. |
| Reminder | `features/reminder` | Preserve canonical UI and existing persistence semantics. |
| Widget/Lock Screen | `features/widget` + platform adapter | Shared source of truth; no separate storage. |

## 5. Repository boundary — initial rule
The domain must not import Flutter UI, persistence implementations, platform APIs or concrete storage classes.

The intended dependency direction is:

`Presentation → Application → Domain ← Data/Infrastructure`

Repository interfaces belong at the domain/application boundary; concrete implementations stay in data/infrastructure. Migration adapters may temporarily wrap legacy stores, but they must not become a second source of truth.

## 6. Safety gates
Before each code migration:
1. Re-audit current `main`, commit, workflows, docs and relevant implementation.
2. Identify one concrete gap.
3. Check callers and persisted-data compatibility.
4. Make the smallest reversible change.
5. Run focused tests, quality and relevant workflows.
6. Record the result in project documentation.

## 7. DeepSeek consultation points
Consult DeepSeek before the first persistence/domain migration for:
- database/persistence compatibility,
- migration strategy and rollback safety,
- repository boundary and adapter ownership.

Do not block independent documentation, CI inspection or test preparation on that consultation.

## 8. Immediate next step
Do not introduce `BaseEntity` or Riverpod in this documentation commit. First complete the repository/call-site map and identify the smallest safe seam for the first code migration.

## 9. CI verification — 2026-08-16
PR #98 commit `6c69829b5b26db09d011ee9ba50bd7bbf24ba863` was validated by the `Arvin Parallel Wave` workflow (run #248). The run completed successfully with:
- quality: PASS — `flutter analyze --no-fatal-infos` and `flutter test`
- followup surface: PASS
- typography surface: PASS
- backup surface: PASS
- calendar surface: PASS
- android-release: PASS — release APK built and verified

No production code or UI was changed by this architecture-foundation change.

## 10. Canonical-state reconciliation gate
The existing `docs/ARVIN_PROJECT_STATE.md` still describes `Unified Item` as the primary architecture invariant. This foundation document records the newer v1 target in which `UnifiedItem` is not the long-term domain abstraction.

This is an architecture-governance conflict, not a reason to perform a code rewrite. Before updating the canonical project-state invariant or starting the first persistence/domain migration, obtain independent DeepSeek cross-review and make an explicit Architecture Decision Record. Until then, preserve the existing runtime/storage contract and do not introduce a competing model or repository.
