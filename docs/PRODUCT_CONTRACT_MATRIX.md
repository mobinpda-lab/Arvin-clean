# Arvin Product Contract Matrix

## Purpose

This matrix prevents accepted product behavior from disappearing when implementation is split across migration, parallel or infrastructure slices.

It is a **discovery and acceptance registry**. It does not replace detailed contracts. GitHub reality, the most specific owner-approved contract, canonical code, tests and exact-head/device evidence must still be checked before claiming completion.

Audit baseline when this file was created: `main` `df325a42523ef657344bb5173b32ae5e6b8c8221` on 2026-08-27.

## Status meanings

- **Missing** — accepted behavior is not implemented on current main.
- **Partial** — foundation or part of the user path exists, but accepted interaction/evidence is incomplete.
- **Implemented** — user path exists; final regression/device/visual acceptance is still open.
- **Validated** — applicable automated + exact-head/device evidence exists; only wider roadmap/handoff closure may remain.
- **Done** — detailed contract Definition of Done is closed and current handoff/status agrees.

## Matrix

| Surface / capability | Binding behavior | Binding source | Canonical foundation | Current main entry point | Acceptance evidence required | Current status | Owner issue / next gap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Home visual identity | Bismillah + centered product title, approved utility icons, rounded search, four tappable stat cards, task cards, compact circular `+`, bottom nav | `docs/HOME_STYLE_LOCK.md` | canonical Task projections | `lib/main.dart` | widget filters + short/normal viewport + real screenshot comparison | **Partial** | compact `+` and final visual closure remain |
| Task create/edit | title, description, tags; explicit `کار پیگیری‌دار` control for follow-up-enabled work | Issue #357 | `Task`, `TaskStore/arvin.tasks` | `lib/task_editor_dialog.dart` | toggle regression + migration/history preservation | **Partial** | #357 — explicit toggle missing |
| Ordinary Task detail | tapping Home card opens read/view detail; edit is a separate action | Issue #357 | canonical Task | Home currently routes card tap to edit dialog | widget navigation + device flow | **Missing** | #357 |
| Follow-up-enabled Task detail | normal back + history/detail + round bottom `+` for a new FollowUp | Issue #357 | `Task + followUps[] + TaskTimelineService` | `lib/task_timeline_page.dart` reusable history page exists | detail navigation + add button + device viewport | **Partial** | #357 — detail composition/+ missing |
| Add FollowUp | optional text + date + time; system current date/time prefilled and editable; blank text saves as `پیگیری` | Issue #357 | `FollowUp`, `FollowUpRepository` | `lib/follow_up_entry_page.dart` | fixed-clock widget tests + blank/default + persistence append | **Partial** | #357 — blank→`پیگیری` and compact flow |
| FollowUp history | every save appends; previous history never erased | Issue #357 + canonical timeline docs | `followUps[]`, `FollowUpRepository.add`, `TaskTimelineService` | repository + timeline | persistence regression + chronological UI | **Implemented** | #357 final user-flow closure |
| Home latest FollowUp | follow-up-enabled card shows latest canonical FollowUp Jalali date + Persian time | Issue #357 | `Task.legacyHomeFollowUpDate` compatibility projection preferring `followUps[]` | `lib/main.dart` | multiple FollowUps regression + visual check | **Implemented** | #357 final acceptance styling |
| Simple Note creation | explicit `یادداشت ساده` mode, simple text-focused editor, autosave/read-only/edit | `docs/SIMPLE_NOTEBOOK_PRODUCT_CONTRACT.md` | `Task.isSimpleNote`, `CanonicalNotebookRepository` | `lib/notebook_page.dart` | mode-specific widget test + autosave/persistence | **Partial** | simple editor still shows checklist block |
| Checklist creation | explicit separate `چک‌لیست` mode; presets allowed; reuse `Task.checklist` | `docs/SIMPLE_NOTEBOOK_PRODUCT_CONTRACT.md` | `Task.checklist`, canonical repository | `lib/notebook_page.dart` | create/add/toggle/edit/remove + persistence | **Implemented** | separate visual editor/mode refinement |
| Notebook persistence | no `arvin.simple_notes`; use canonical `TaskStore/arvin.tasks` only | Notebook contract + `docs/NOTEBOOK_COMPLETION_LANE_2026-08-26.md` | `CanonicalNotebookRepository`, `TaskStore` | services + notebook | repository key regression | **Validated** | keep duplicate-storage guard |
| Search | Persian search uses one canonical Task search path; no second engine/UI | roadmap + semantic search docs | `TaskSearchService` / Home projection | Home search | focused + exact-head + device | **Validated** | final roadmap DoD only |
| Follow-up Calendar | Persian RTL, Jalali header, day/week/month behavior per approved contract | `docs/FOLLOWUP_CALENDAR_UX_CONTRACT_2026-08-27.md` when merged/current | canonical Calendar/FollowUp projections | Calendar page/launcher | navigation/count/viewport + exact-head/device | **Partial** | active PR #352 requires reconciliation/merge evidence |
| Reminder | preserve timed/all-day semantics; no fabricated all-day time | `docs/ARVIN_UI_CANONICAL.md` + reminder contracts | canonical Reminder/FollowUp foundation | reminder/calendar surfaces | regression + notification/device | **Implemented** | roadmap/device closure varies by slice |
| Waiting for response | explicit FollowUp state and latest-state user filter | feature contract/evidence in scorecard | canonical FollowUp result/state | FollowUp entry/office | regression + exact-head | **Validated** | final roadmap closure |
| Automatic FollowUp | due projection, scheduling/rescheduling/background delivery reuse same canonical data | feature evidence in scorecard | FollowUp + scheduler | due office/background services | exact-head + APK/device/post-merge | **Validated** | final roadmap closure |
| Timeline | one read-only chronological projection from canonical timestamps/history; no second history store | `docs/CANONICAL_TASK_TIMELINE_2026-08-26.md` | `TaskTimelineService` | `lib/task_timeline_page.dart` | regression + real entry point/device | **Implemented** | #357 detail integration improves original product path |
| People / Contacts | relation stays on canonical Task; no standalone CRM/storage | People contract/evidence | `PersonReference` on Task | `lib/task_people_page.dart` | Android E2E + exact-head/post-merge | **Validated** | final roadmap handoff closure |
| Next Action | deterministic canonical ranking, no duplicate task store | Next Action contract | canonical Task/FollowUp | `lib/task_next_action_page.dart` | UI + device/roadmap closure | **Implemented** | final feature DoD |
| Widget / Lock Screen | same Task identity/source; no widget database; graceful platform behavior | canonical Android widget docs | `arvin.tasks` + widget bridge | native provider + Flutter bridge | real launcher/keyguard/resize/row-tap | **Implemented** | physical-device acceptance remains |
| PDF / Print | shared canonical projection, RTL Persian output, no data fork | PDF/Print docs | task report projection | report page/renderer | physical print/share/device | **Implemented** | physical acceptance remains |
| Backup / Restore | portable versioned canonical bytes; safe validation before mutation; same Task data | backup portability/security contracts | existing backup service/manager | Backup UI/services | corruption/wrong-passphrase/no-mutation + cross-device | **Implemented** | final physical/recovery closure |
| Encrypted backup | versioned authenticated envelope; no passphrase persistence; legacy plaintext read | privacy/encryption contracts | canonical backup bytes | backup/security surfaces | exact-head/device + tamper/wrong passphrase | **Validated** | final roadmap closure |
| System/Google Calendar | only approved events; avoid duplicates in real sync; manual export remains separate | Calendar sync contracts | canonical FollowUp revision/link plan | system calendar bridge / active sync lanes | permission/revocation/idempotency/E2E | **Partial** | active PR #346 and later provider integration |
| Multi-device Sync | deterministic revision/merge/conflict/apply; no last-write-wins or second Task model | Sync contracts | canonical Task revisions/TaskStore | sync services/active lanes | remote transport + durable state + user conflict UI + E2E | **Partial** | #345/#351 stack and follow-on lanes |
| Navigation / More | one approved primary navigation model; no duplicate/debug destinations | Home/UI contracts | existing shell/navigation | `lib/widgets/arvin_primary_navigation.dart` | widget/device navigation regression | **Implemented** | keep aligned with Home style lock |

## Mandatory use rule

Before a meaningful product/UI change:
1. locate the row here;
2. read the binding source and current code;
3. verify whether a newer owner decision exists in GitHub;
4. update the row when acceptance status or owning Issue/PR changes;
5. do not mark **Done** until the detailed contract, tests, exact-head evidence and applicable device/visual acceptance agree.

If an accepted behavior is deferred to a later slice, the row must remain **Missing** or **Partial** and must name an owning issue. A deferred requirement may not silently disappear from the project because its foundation was merged.

## Historical-document rule

Older snapshots and superseded design/architecture proposals remain useful evidence, but they cannot override this matrix, a newer explicit product decision, current canonical contracts or verified GitHub reality.
