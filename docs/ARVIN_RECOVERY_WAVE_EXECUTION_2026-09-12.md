# Arvin Recovery Wave Execution — 2026-09-12

Status: owner-directed recovery execution plan. Live GitHub reality always outranks stale snapshots.

Parent requirement ledger: #845.

## Why this plan exists
A fresh audit showed that many owner requirements had already been designed or partially implemented in Arvin, but some were hidden, incomplete, contradicted by stale documents, or missing from the installed UI. Recovery therefore follows **reuse → reconcile → implement → verify**, never a second architecture.

## Ordered waves

| Wave | Issue | Scope |
| --- | ---: | --- |
| W0 | #846 | Exact-main audit, contract reconciliation, anti-forgetting lock |
| W1 | #847 | Project + Category/Tag lifecycle + dependency-safe data rules |
| W2 | #848 | Home/More/Today + unified quick/full Task entry/edit |
| W3 | #849 | Calendar navigation + device two-way sync + action bugs + official events |
| W4 | #850 | Notebook full-screen UX + top category/actions + fast move/delete |
| W5 | #851 | Prayer completion state + separate reporting + counter isolation |
| W6 | #852 | Automatic Backup/Restore settings + font picker + grouped Settings |
| W7 | #853 | Final convergence + exact-head release proof + #845 closure |

## Five-minute autonomous cycle
Arvin already has the canonical `ARVIN Autonomous Task Queue` scheduled with `*/5 * * * *`.

This recovery plan adds `ARVIN Recovery Wave Controller`, also scheduled every five minutes. Its responsibilities are deliberately narrow:

1. inspect #846–#853 in order;
2. keep later waves dormant while an earlier wave remains open;
3. activate only the first open wave with `factory:ready`;
4. never duplicate an active worker lease or open `ai/issue-*` PR;
5. wake the existing canonical autonomous queue;
6. preserve all existing exact-head, CI, recovery and promotion gates;
7. report wave activation/completion back to #845.

The controller does **not** merge code, bypass checks, or create a second worker system.

## Latest owner decisions that must override conflicting older UI wording
- Keep Arvin's approved theme/color identity; do not redesign the whole app as Microsoft To Do.
- Remove the visible `کارهای من` title/options from Home and move those filters/categories into `بیشتر`.
- Add `کار امروز` as an automatic due-date projection; prayer entries and official events are excluded from Task counters.
- Correct no-follow-up work label `یادداشت` → `بدون پیگیری` without renaming the real Notebook/Note concept.
- Quick Add and full Task entry/edit use one canonical editor; title alone is enough to save, optional fields remain available in the same flow.
- Project is a first-class grouping concept containing canonical Tasks/FollowUps/Notes; Project/Category/Tag management must be dependency-safe.
- Device Calendar integration is continuous, bidirectional and idempotent through the existing provider-neutral foundation; Arvin can display/edit writable device events.
- Calendar supports previous/next navigation by swipe in day/week/month/year views and shows official occasions without counting them as Tasks.
- Notebook uses a content-first full-screen/near-full-screen editor, top category/actions, and very easy same-ID move/delete operations while preserving canonical Task/Notebook storage.
- Prayer completion/missed state and reports are separate from general Task statistics.
- Automatic backup settings and user-selectable Persian/Arabic UI fonts must be exposed in Settings through existing foundations.

## Non-negotiable architecture rules
- No parallel Task store.
- No parallel Notebook store.
- No second Calendar engine.
- No duplicate Project/Category/Tag database.
- No second Settings store.
- No second Backup model.
- Historical documents are preserved for traceability but cannot override current owner decisions or live code.

## Completion evidence
A Wave is not complete because a file/class/PR exists. It requires applicable exact-head implementation, focused tests, CI, release build/device-smoke/provider checks, data-safety evidence and final user-path verification.
