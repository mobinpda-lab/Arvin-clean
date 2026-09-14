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
