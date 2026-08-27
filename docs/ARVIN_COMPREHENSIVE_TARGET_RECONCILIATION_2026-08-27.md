# Arvin Comprehensive Target Reconciliation — 2026-08-27

Issue #344. Live baseline: `main` at `74931a205f10f252e181d6fb2bf5d8a41eb3b6d0` when this lane was opened.

## Purpose

This document reconciles the comprehensive Arvin v1 target with the real production repository. It separates **product acceptance requirements** from **implementation choices** so future work does not rewrite working foundations only to match an older technology proposal.

GitHub remains the operational source of truth. Live SHA, PR, CI and scorecard evidence must always be refreshed before merge or progress claims.

## Product capability reconciliation

| Capability | Live status | Product decision |
| --- | --- | --- |
| Task create/edit/complete/archive/trash | Delivered user path | Keep canonical Task path |
| Reminder / timed reminder | Delivered foundation and user path | Continue regression/device closure |
| FollowUp engine | Advanced; background notification/reschedule evidence exists | Keep canonical FollowUps[] path |
| Jalali calendar / RTL | Delivered user path | Continue device/UI refinement |
| Day/week/month calendar modes | Merged on current baseline | Keep |
| Timeline | Delivered user path | Keep canonical Task timeline |
| Home / Dashboard | Delivered and actively refined | Do not fork UI foundation |
| Notification delivery | Delivered through current Android scheduler stack | Product requirement satisfied independently of WorkManager choice |
| Backup / Restore | Delivered portable path | Continue device/recovery hardening |
| Encrypted backup | Advanced implementation and validation evidence | Keep; extend security only through canonical byte path |
| Reports | Delivered user path | Keep shared projection |
| PDF / Print | Delivered user path | Continue physical print/share acceptance |
| Android Widget | Delivered canonical foundation | Physical launcher/keyguard/resize evidence remains |
| System Calendar export | Delivered user-approved ACTION_INSERT path | Keep as safe manual export |
| Real idempotent Google/system Calendar sync | Partial gap | Build stable mapping + provider adapter in small slices |
| Offline basic operation | Delivered by local-first product behavior | Keep internet-independent core operations |
| Multi-device conflict decision core | Delivered foundation | Continue through canonical apply/provider/UI lanes |
| Real multi-device cloud transport | Not complete | Priority product gap |
| Offline sync queue / durable remote state | Not complete | Priority product gap after provider boundary |
| User-facing cross-device conflict resolution | Not complete | Required before full Sync DoD |
| Local data-at-rest encryption | Partial gap | Separate from already-delivered encrypted portable backup |
| Google account/provider integration | Not complete | Required for real calendar sync, but tokens must not enter portable backup |
| Golden visual tests | No dedicated completion evidence on baseline | Optional quality lane if it provides value beyond current widget/device evidence |

## Implementation choices: current reality vs older target

The following items are **not product capabilities by themselves** and must not be treated as automatic blockers or mandatory rewrites.

| Area | Older target | Current production choice | Rule |
| --- | --- | --- | --- |
| Persistence | SQLite | Canonical TaskStore over `SharedPreferences` / `arvin.tasks` | Migrate only with measured scale/query/sync need and an incremental no-data-loss plan |
| State management | Riverpod 3.x+ | Existing explicit services/pages/state | Do not rewrite solely for framework conformity |
| Background execution | WorkManager + MethodChannel | `android_alarm_manager_plus`, notifications and native boundaries | Preserve proven alarm/reboot behavior unless a concrete requirement needs replacement |
| Architecture folders | strict feature folders | mixed `lib/`, `services/`, `models/`, `core/` boundaries | Refactor incrementally only when it reduces real coupling/risk |
| Unified model | one large Unified Item risk | canonical Task + composition/additive relations | Continue composition; do not create a giant catch-all entity |

## Canonical foundations that must not be duplicated

- `TaskStore.key = arvin.tasks` remains the canonical Task persistence path until an approved migration replaces it.
- `Task / FollowUps[]` remains the product history/follow-up foundation.
- Calendar projections consume canonical Task/FollowUp data rather than creating another event database.
- Backup/Restore consumes the canonical serialized data path.
- Widget consumes canonical Task identity/storage rather than a Widget database.
- Reports/PDF/Print share read-only canonical projections.
- Sync must consume canonical `Task.toJson()` revision evidence and explicit conflict decisions; no last-write-wins shortcut.

## Highest-value remaining product gaps

### P0 — Multi-device Sync completion

Current core can derive Task revisions and deterministic merge plans. Remaining vertical path:

`provider transport -> remote snapshot -> merge plan -> explicit conflict choice -> canonical TaskStore apply -> durable sync metadata -> retry/offline queue -> multi-device E2E`

The provider must not create a second Task model or silently overwrite divergent data.

### P0 — Real Google/system Calendar synchronization

Current System Calendar export is manual and user-approved. Real sync requires:

`canonical FollowUp revision -> stable external event link -> create/update/no-op/delete plan -> Android Calendar Provider/account adapter -> permission/revocation handling -> idempotency/E2E`

Repeated sync must update the same event rather than create duplicates. Official holiday/prayer rows stay outside this sync path.

### P1 — Physical-device closure

Several gates are user-facing but remain below full DoD because physical-device/launcher/print/visual/E2E evidence is intentionally stricter than unit/build evidence.

### P1 — Security completion

Encrypted portable backup is not equivalent to full local-store or sync-channel security. Any next security lane must identify the exact asset/threat and avoid credential leakage into backup/settings.

## Progress interpretation

Do not use historical manual percentages as current truth. The repository contains separate scorecards for canonical A-H delivery gates and the extension roadmap. A capability reaches 100 only when its own Definition of Done, validation and handoff closure are satisfied.

A technology migration (SQLite/Riverpod/WorkManager) earns no product progress by itself unless it closes a measurable acceptance gap.

## Maximum Parallel execution rule

Independent lanes may run concurrently when they do not modify the same foundation. The preferred pattern is:

1. fresh GitHub audit;
2. one Issue per narrow acceptance slice;
3. branch from current main;
4. focused implementation + tests + boundary documentation;
5. Draft Fast validation when appropriate;
6. full exact-head Build/APK/device gates before product merge;
7. post-merge current-main validation;
8. score/status promotion only from earned evidence.

Active UI/device/E2E lanes must not be blocked by independent Sync/Calendar/Documentation work.

## Current reconciliation decision

The comprehensive Arvin vision remains valid as a **product direction**. The following wording should be considered superseded as hard requirements: “must use SQLite”, “must use Riverpod 3.x+”, and “must use WorkManager”. They are implementation options subject to an evidence-backed migration decision.

The following remain hard product outcomes: reliable local operation, Task/Reminder/FollowUp/Calendar/Timeline integration, notifications, reports, backup/recovery, security, Widget, PDF/Print, real multi-device synchronization, conflict safety, and real idempotent external calendar synchronization.
