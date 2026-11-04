# Product Roadmap
This roadmap orders work by release risk and verified dependencies. It does not authorize scope expansion beyond the owner-approved PR/issue scope.

## P0 — Release and reliability gates
1. Complete all seven Device Smoke lanes on one exact candidate SHA.
2. Diagnose and rerun Calendar Provider Acceptance after the Dart Development Service startup failure; preserve the test and assertions.
3. Obtain exact-SHA Build, Follow-up Persistence, Calendar Provider and Device Smoke evidence; do not combine results across SHAs.
4. Complete the required physical-device startup/install/runtime acceptance and record evidence. Any unverified device behavior remains open.
5. Obtain product-owner acceptance and close all governing release blockers before considering release.

## P1 — Product correctness and usability
1. Resolve the Quick Capture empty-title feedback decision with the product owner; preserve compact layout and validation.
2. Retain unified Report Center Filters and verify all filter dimensions and combinations with focused tests and fresh screenshots.
3. Audit Center > Project > Category > Task terminology and behavior across every relevant creation, edit, selection, report and filter flow.
4. Continue only explicitly authorized Task Details / inline-edit / clone work under the current PR scope and its acceptance requirements.
5. Preserve Reminder, Follow-up, recurrence and calendar independence; no legacy-field removal or destructive migration without real-data inspection and a safe migration plan.

## P2 — Future architecture
1. Local P2P phase 1: threat model, data ownership, protocol contract, pairing security, durable operations, idempotency, acknowledgements, recovery, conflict handling and physical-device tests. QR/PIN and LWW are not implementation approvals.
2. Cloud / Dropbox phase 2: separate future design; not a dependency for phase 1.

## Explicitly not promoted from examples
A feature mentioned only as an illustrative example (such as periodic tasks or a particular edit screen) is not automatically an approved backlog item. Require prior evidence or an explicit owner directive.


## Task Details visual acceptance — blocked checkpoint (2026-11-04)
- Authorized Task Details redesign remains in scope, but image-to-image comparison is blocked until both named screenshots are actually accessible.
- Do not guess layout, color, spacing or remove repeated metadata without reference and product approval.
- After screenshots arrive: build approved visual matrix, make UI-only changes preserving all canonical actions/data pathways, add focused RTL widget and golden/screenshot acceptance, then run exact-SHA Build, Calendar Provider and all seven Device Smoke lanes.
- Current exact-SHA evidence and blockers are tracked in OPEN_ISSUES.md and docs/audit/ARVIN_TASK_DETAILS_REFERENCE_COMPARISON_2026-11-04.md.
