# ARVIN GO Release Status
Updated: 2026-10-13
Working PR: [#2666](https://github.com/mobinPda-lab/Arvin-clean/pull/2666)
Observed head at assessment: `4b7d5e3d454d0e1204ed6702e5643c78be83eac5`

## Release decision
**NO-GO — do not publish or merge yet.** This is a live status snapshot, not a claim that all tests or device checks have completed.

## Gate status

| Gate | Status | Evidence / remaining work |
|---|---|---|
| Canonical Task architecture | 🟡 In progress | Existing Task is canonical; validate full Task/Checklist/Follow-up/Reminder round-trips on exact head. |
| Follow-up flag removal | 🟡 In progress | Compatibility reads remain by design; audit all active decision/write paths and legacy migration. |
| Multiple Follow-ups / history | 🟡 In progress | Child PR #2681 is Draft and not mergeable; reconcile structured waiting/person semantics safely. |
| Waiting for response + Person | 🔴 Blocked | PR #2681 not integrated; old PR #2679 has conflicting latest-result semantics. |
| Person directory | 🔴 Blocked | P1 [#2682](https://github.com/mobinPda-lab/Arvin-clean/issues/2682): standalone people are not yet in portable backup/restore rollback. |
| Multiple Task reminders | 🟡 In progress | Two migration/projection test assertions were corrected in commit `4b7d5e3`; exact-head Build still has failing test shards. |
| Legacy reminder migration/title | 🟡 Decision applied, validation pending | The current code preserves the legacy Calendar title/fingerprint (`یادآوری: <Task>`). User's latest GO command gives `<Task> — یادآور ۱` as the expected converted title. This conflicts with the existing compatibility contract and must be reconciled deliberately with stable external Calendar identity before changing runtime behavior; do not silently alter event identity. |
| Calendar | 🟡 In progress | Previous head's provider acceptance passed; acceptance for this exact head is still running. |
| Reports / Person filter | 🔴 Blocked | P1 [#2683](https://github.com/mobinPda-lab/Arvin-clean/issues/2683): per-Follow-up Person/waiting/next-action rows and Person filter incomplete. |
| Backup/restore | 🟡 In progress | Exact-head device lanes for migration/persistence are running; backup/restore lane queued at last poll. Person-directory integrity remains open. |
| Analyze | 🟢 Passed | Build run [38428476972](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38428476972), analyze job succeeded. |
| Automated tests | 🔴 Failed | Same run: test-2 failed two checklist UI assertions and missing all-day setting key; test-3 failed the waiting-list latest-result test. test-4/test-5 were still running at latest poll. |
| Debug/Release APK | 🟡 In progress | Both APK jobs still running at latest poll. |
| Device acceptance | 🟡 In progress | [Device Smoke run](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38428476964): Quick Capture and Home succeeded; SQL migration/persistence in progress; People and Backup/Restore queued. |
| Physical-device screenshots | 🔴 Missing | No verified screenshot set with device/model, app version, environment and acceptance results is recorded. |
| Handover documents | 🟡 In progress | Complete Release Notes, Installation Guide, User Guide, Known Issues, Architecture Summary and final Evidence Report after the release gates pass. |

## Exact-head CI snapshot

- Build: [run 38428476972](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38428476972) — overall not green at the last poll.
- Calendar Provider Acceptance: [run 38428476999](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38428476999) — in progress.
- Device Smoke: [run 38428476964](https://github.com/mobinPda-lab/Arvin-clean/actions/runs/38428476964) — in progress.
- Last observed parent PR head: `4b7d5e3d454d0e1204ed6702e5643c78be83eac5`, PR #2666 open and unmerged.

## Decisions and safety constraints

1. Task remains the sole source of truth; no parallel Task/reminder store.
2. `nextFollowUp` does not create notifications or external Calendar events by itself.
3. `FollowUp.reminderDate` and `nextFollowUp` remain independent.
4. Legacy Calendar identity must remain stable unless a migration explicitly preserves/reconciles existing external event links.
5. Do not delete assertions or weaken tests to obtain green CI.
6. Do not merge PR #2666/#2681/#2679 while required checks or branch reconciliation are unresolved.
7. Keep release **NO-GO** until every required gate has exact-head passing evidence, including backup/restore integrity, Person reports, Calendar, migration, and device acceptance.

## Next actions

1. Resolve the exact-head checklist/settings failures from the actual widget layout and test setup.
2. Resolve waiting-list expectations against the accepted per-Follow-up structured Person model, not legacy result text alone.
3. Poll the remaining test shards and APK jobs, then rerun the full Build after fixes.
4. Reconcile child PR #2681 with the latest parent without force-pushing or overwriting either branch.
5. Complete issues #2682 and #2683 within the existing backup/report systems.
6. Resolve the legacy reminder title request while preserving stable external Calendar identity.
7. Capture and record physical-device evidence; then generate final handover documents.

## Evidence policy

A green partial job is not a release pass. A capability is complete only when code, relevant tests, build, runtime/device validation and traceable evidence all agree.
