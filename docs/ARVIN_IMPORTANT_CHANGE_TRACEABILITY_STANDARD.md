# Arvin — Important Change Traceability Standard

**Status:** Proposed canonical governance addendum
**Issue:** #981
**Purpose:** Preserve development speed while ensuring every important change has a short, verifiable documentation trail.

## 1. Core rule
An important change is complete only when the repository can trace:

`Requirement/Problem → Issue or Request → Decision → Code Change → Commit → Validation → Result`

The trace must be discoverable from GitHub without relying on conversation memory.

## 2. Fast paths
### Small / low-risk change
`Issue/Request → Change → Commit → Focused Validation`

No additional manual report is required unless the change affects an important decision.

### Important change
`Issue/Request → Change → Commit → Validation → Evidence → Short Documentation`

The documentation should reuse GitHub metadata wherever possible.

### Architecture / migration / storage / security / major product decision
`Issue → Impact/Decision → Implementation → Validation → Evidence → ADR or equivalent decision record`

## 3. Speed protection
- Documentation must be lightweight and preferably generated from existing Issue, PR, Commit and CI information.
- Developers/AI must not write duplicate long reports after every change.
- Independent work continues in parallel when safe.
- Documentation is a control point, not a reason to serialize unrelated work.
- Only changes classified as important require the full trace.

## 4. Gate rule
An important change with a missing trace is **Documentation Incomplete** and must not be presented as fully complete.

This does not automatically block harmless small changes. The gate severity follows the change risk.

## 5. Minimum trace fields
For an important change, the repository should make it possible to answer:
1. What changed?
2. Why was it needed?
3. Which Issue/request and acceptance requirement does it serve?
4. Which Commit/PR contains it?
5. What validation was performed?
6. What was the result?
7. Was an architectural/product decision involved, and where is that decision recorded?

## 6. Factory responsibility
The Arvin factory should check this trace automatically at the appropriate gate and report missing links clearly. It should not create unnecessary manual work.

**Operating principle:** `Fast Documentation + Strong Traceability + Minimal Manual Overhead`


## 7. Wave 7.279 — exact main lease diagnosis (2026-10-31)

- **Request / governance:** Wave 7.279; governing Issue [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102); observed on Draft PR [#2995](https://github.com/mobinpda-lab/Arvin-clean/pull/2995).
- **Failure:** `.github/workflows/arvin-agent-worker.yml`, step `Validate exact main lease`, compares `git rev-parse HEAD` with `ARVIN_EXPECTED_MAIN_SHA` after the preceding checkout explicitly uses `ref: main`.
- **Incorrect dispatched lease value:** `f4c64704e514d34d1bc9afa070f0163774fc32d0`. This is the PR worker branch HEAD, not the live `main` HEAD.
- **Verified main commit:** [`18cbeecc95a03a3b301359ca5b96cfef175a3b15`](https://github.com/mobinpda-lab/Arvin-clean/commit/18cbeecc95a03a3b301359ca5b96cfef175a3b15).
- **Decision / resolution:** For a dispatch that checks out `main`, set input `expected_main_sha` to the exact main commit SHA captured immediately before dispatch: `18cbeecc95a03a3b301359ca5b96cfef175a3b15`. Keep the exact equality check fail-closed; do not weaken or bypass it. Re-fetch `main` immediately before any later dispatch and stop if it has moved.
- **Change scope:** Diagnostic and dispatch-input correction only. No workflow source, product source, schema, migration, or scheduler behavior is changed by this entry.
- **Validation evidence:** GitHub `refs/heads/main` returned the SHA above; GitHub `refs/heads/fix/wave-7-61-reminder-only-next-follow-up` returned `f4c64704e514d34d1bc9afa070f0163774fc32d0`; workflow source confirms `actions/checkout` uses `ref: main`. PR #2995 was observed OPEN/DRAFT/UNMERGED and Issue #2102 OPEN at audit time.
- **Execution result:** Lease diagnosis is resolved. A new worker dispatch and downstream CI validation have not yet been executed; no green status is claimed. Release remains `BLOCKED — RELEASE: NO-GO`.


## Wave 7.280 — Exact Main Lease Checkout and Calendar Conflict Fixture (2026-10-31)

**Request:** Prevent recurring worker lease mismatches and correct the failing unlinked-Reminder conflict test without weakening its product assertion.

### Decision and implementation

- The autonomous queue already obtains the live main commit SHA with the GitHub API and passes it as expected_main_sha when dispatching arvin-agent-worker.yml.
- The worker previously checked out the moving main branch and only then compared HEAD with the captured SHA. If main advanced between queue dispatch and worker checkout, this created a time-of-check/time-of-use race and a false lease mismatch.
- The worker now checks out the exact immutable SHA supplied by the queue (inputs.expected_main_sha), validates its 40-character hexadecimal form, compares git rev-parse HEAD with that same value, and emits explicit EXPECTED_MAIN_SHA, ACTUAL_CHECKOUT_SHA, and MAIN_LEASE_MATCH=PASS evidence. A malformed or mismatched lease still fails closed; no mismatch is silently replaced and no guard is weakened.
- The failing unlinked Reminder widget test reused _seedConflictTasks(), whose default fixture persisted a valid external-calendar link for reminder-a. That made the supposedly unlinked Reminder eligible for conflict checking. The fixture now supports linked: false, and this test explicitly uses it. The strict assertions that no Reminder card is shown and no conflict result is presented remain unchanged. Other tests retain the linked fixture by default.

### Validation status

- Source changes committed on the authorized PR branch.
- Runtime Flutter tests and workflow execution are pending CI on the new exact PR head. No test-pass or pipeline-green claim is made by this documentation entry.
- PR #2995 remains OPEN / DRAFT / UNMERGED; Issue #2102 remains OPEN.
- Release remains BLOCKED — RELEASE: NO-GO until all exact-head checks and acceptance gates are green.

### Operational standard

The queue is the sole autonomous worker dispatcher and must capture one live main SHA per lease. The worker must consume that immutable SHA rather than resolving the moving branch again. Empty, malformed, or mismatched lease data must never authorize execution. Manual dispatch is not a substitute for the queue's live-SHA lease contract.


## Wave 7.61 — Conflict advice finder isolation (2026-10-31)

- **Request / governance:** Wave 7.61; governing Issue [#2102](https://github.com/mobinpda-lab/Arvin-clean/issues/2102); Draft PR [#2995](https://github.com/mobinpda-lab/Arvin-clean/pull/2995).
- **Exact root cause:** The unlinked fixture removes the provider-link record but intentionally retains its canonical independent TaskReminder. FollowUpCalendarProjection.project() renders that reminder in the underlying calendar page. showModalBottomSheet() leaves the launcher route mounted, so the global Flutter find.text('یادآور جلسه مشتری') sees the background calendar card even though the empty conflict sheet contains no conflict entry. Filtering eligible candidates was correct for provider conflict evaluation but could not isolate a global finder from the underlying route.
- **Decision:** Preserve the canonical independent Reminder in the normal calendar projection. Do not delete it, suppress it permanently, or change the projection contract. While conflict advice is presented, place the obscured launcher body subtree Offstage; restore it in a finally block after the modal closes. This isolates the modal's rendered widget scope without changing stored data or ordinary calendar visibility.
- **Code change:** lib/widgets/canonical_calendar_launcher.dart adds modal-lifecycle state and wraps the calendar body in Offstage only for the duration of the conflict-advice modal. Existing linkedCandidates / eligible checks remain authoritative; unlinked or ineligible reminders cannot enter provider conflict evaluation or conflict entries.
- **Test preservation:** test/canonical_calendar_launcher_test.dart was read from the exact base SHA and is not modified. The strict empty-state title, absence-of-reminder, and tester.takeException() assertions remain intact.
- **Validation status:** New exact-head CI, all test shards, APK builds, Calendar Provider Acceptance, and Device Smoke must complete before acceptance. No green status is implied by this commit.
- **Release / governance:** PR #2995 remains OPEN / DRAFT / UNMERGED; Issue #2102 remains OPEN. Release remains BLOCKED — RELEASE: NO-GO until every required check and smoke lane is green.
