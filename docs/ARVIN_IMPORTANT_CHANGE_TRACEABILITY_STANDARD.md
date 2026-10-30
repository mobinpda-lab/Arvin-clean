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
