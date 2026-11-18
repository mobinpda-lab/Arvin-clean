# Arvin — Canonical Completion & Execution Map

## 0. Authority and independence
- Reference HEAD for this map: `123b2f1f82638659754ec8e575dea09ef2312d0c` on `main`.
- This document covers **two separate lanes inside the same repository**: `Arvin-clean [PRODUCT]` and `Arvin_Factory [FACTORY]`.
- Factory completion is not product completion; product progress is not factory completion.
- No project-specific implementation, data, secret, dependency, roadmap or artifact may be imported from YadNegar, NIRA or Payesh. Only general engineering patterns may be learned and independently adapted.
- Old issues/PRs/branches are not gaps unless reconciled against the exact current HEAD.

## 1. Required lifecycle
For every capability: `Planned → Implemented → Executed → Verified → Proven`.
Code, issue, PR or test alone never equals production proof.

Required completion evidence:
`AC → exact HEAD → implementation → targeted test → CI → security → build → artifact → runtime/installability evidence → release evidence`.

## 2. PRODUCT — Arvin-clean
### P0 — Release blockers / foundation
1. **Unified product foundation / data compatibility** — protect the existing Task/Unified Item foundation; no competing model/store. Verify migrations and backward compatibility at exact HEAD.
2. **Sync Engine Foundation Core** — device sync, conflict resolution, versioning, offline queue, consistency and recovery. Treat as controlled foundation, not an ordinary feature.
3. **Notification reliability** — scheduled/local notifications, background execution, restart/overdue behavior and exact runtime evidence.
4. **Storage/backup/restore integrity** — canonical persistence, migration, backup/restore and recovery evidence.
5. **Release pipeline** — exact-head Analyze/Test/Build/Security/Artifact plus installability and release-delivery proof. A successful Release Closure that skips build/release stages is not fresh-release proof.

### P1 — Core product capabilities
6. **Task / Reminder / Follow-up** — canonical flows, persistence, recurrence, completion/edit behavior and regression tests.
7. **Jalali Calendar** — canonical RTL calendar, selected-day behavior, reminders/events integration and test coverage.
8. **Calendar integration** — current Android Calendar Provider discovery/read/selection boundaries are implemented; remaining work is end-to-end behavior and release-grade evidence, not creation of a second calendar engine.
9. **Canonical RTL UI** — Dashboard Timeline, ReminderCard, FollowUpCard, JalaliCalendar, reports/notifications and approved hierarchy; validate RTL and applicable golden/runtime tests.
10. **Widget / Lock Screen** — approved states and actions, runtime/device evidence and recovery behavior.

### P2 — Extended product capabilities
11. Google/system calendar synchronization where explicitly contracted.
12. PDF/Print/reporting.
13. Cloud/Dropbox synchronization where contracted.
14. Security hardening and data-safety verification.
15. Accessibility, edge cases, performance and low-value polish only after release blockers.

## 3. FACTORY — embedded Arvin_Factory
The factory lane is evaluated independently from product features.

### F0 — Control-plane stability
1. Queue and task intake.
2. Worker execution and bounded scope.
3. Orchestration / production loop.
4. Exact-head fencing and branch/PR governance.
5. Test worker / parallel wave behavior.
6. Release Closure and evidence publication.

### F1 — Factory proof gaps
7. Prove a reproducible end-to-end worker lifecycle on current HEAD: intake → queue → lease → worker → exact-head check → branch → code → test → PR → CI → security → build → evidence.
8. Prove recovery after worker/automation failure without unsafe duplicate execution.
9. Prove idempotency and stale-head rejection with machine-readable evidence.
10. Prove that factory automation can advance work without bypassing review, security, exact-head or promotion gates.

### F2 — Completion gate
Factory is `Proven` only when the above capabilities have reproducible exact-head evidence. Presence of workflows, workers, issues or PRs is not sufficient.

## 4. Parallel execution order
- Lane A: Product P0 foundation/release blockers.
- Lane B: Product P1/P2 independent capabilities.
- Lane C: Factory F0/F1 proof.
- Shared files/foundations are sequenced; independent lanes continue concurrently.
- A blocked factory lane must never stop an independent product lane.

## 5. Evidence ledger rule
At every meaningful change record: exact HEAD, source commit/PR, applicable test/CI run, security result, build/artifact, runtime evidence, and remaining gap. Revalidate whenever HEAD/PR/CI/artifact/evidence changes.

## 6. Anti-forgetting rule
This map is the ordered checklist. A capability may move to `Proven` only with evidence. A stale PR or historical report cannot reopen or close a capability. When this map changes, update this canonical document rather than creating a competing status document.
