# Arvin Problem Register
**Checkpoint:** 2026-10-11  
**Status labels reflect observed evidence, not estimates.

| Priority | Problem | Evidence / tracking | Current status | Next action |
|---|---|---|---|---|
| P0 | Target phone-calendar selection may not control actual outbound sync | [#2248](https://github.com/mobinpda-lab/Arvin-clean/issues/2248) | Open; owner-reported post-install issue | Verify destination on installed device and preserve event identity |
| P0 | Calendar Task actions and recurrence days may regress in installed APK | [#2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535) | Open; owner-reported | Validate edit/phone-calendar actions and future recurrence dates on device |
| P1 | Report time filter still needs shared Persian-first time picker on combined branch | [#2607](https://github.com/mobinpda-lab/Arvin-clean/pull/2607), [#2591](https://github.com/mobinpda-lab/Arvin-clean/pull/2591) | Open; both Draft, Device Smoke skipped | Reconcile shared picker, add/retain regression coverage, validate exact head |
| P1 | Task Editor progressive disclosure broke existing tests that interact with collapsed advanced fields | [#2602](https://github.com/mobinpda-lab/Arvin-clean/pull/2602), run [38139809938](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38139809938) | Failure reproduced: test shard 5 reported 4 failures; two other shards still in progress at last check | Test changes now explicitly expand details; confirm fresh exact-head CI |
| P1 | Project settings and Notebook UX/persistence require post-install closure | [#2151](https://github.com/mobinpda-lab/Arvin-clean/issues/2151), [#850](https://github.com/mobinpda-lab/Arvin-clean/issues/850) | Open | Check existing branches/issues, fix without duplicate storage |
| P2 | Cross-screen pastel/compact UI needs owner/device acceptance | [#2607](https://github.com/mobinpda-lab/Arvin-clean/pull/2607) | Build succeeded; Device Smoke skipped | Validate RTL, contrast, clipping and interaction on installed build |
| P2 | Memory files need one authoritative, reviewed package | [#2608](https://github.com/mobinpda-lab/Arvin-clean/pull/2608) | Draft | Reconcile this package with existing operating docs before merge |

## Resolved items
Only list items here after linked code, tests and validation prove resolution. No new problem is classified as fully resolved by this checkpoint.
