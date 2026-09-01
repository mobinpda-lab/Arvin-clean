# Arvin Decisions

## Purpose
Record important decisions so development can continue after interruption. Decisions here must be traceable to GitHub state, merged code, workflow evidence, or explicit project Issues.

## Decision: PR Handling
Old PRs must not block production progress. Historical evidence may be kept, but active work follows one canonical promotion path after current-main reconciliation.

## Decision: RC Feature Freeze
Issue #612 establishes the RC rule:
- finalized product decisions are not reopened during stabilization;
- one canonical delivery/promotion path is used;
- remaining RC work is validation, testing, build verification, device proof, and release evidence.

## Decision: Parallel Production
Issue #614 establishes RC Closure as Priority 0 while independent Post-RC preparation continues in parallel. Parallel work must not change or stale the active release candidate.

## Decision: Evidence Semantics
- Exact-head successful CI/Build/Device evidence is preserved as historical proof for that exact SHA.
- If `main` advances and a feature branch diverges, prior successful runs do not automatically prove the reconciled candidate.
- Skipped, stale-head, failed, or unrelated workflow runs never count as passing evidence.
- Healthy validation runs are not restarted solely to refresh documentation.

## Decision: Current Calendar Promotion
At the 2026-09-01 checkpoint:
- `main` is `2ee2adc22a45ab5fda1dcd548672ddaf77717afc` after #605.
- PR #604 and PR #607 share feature head `6cdd6cd49ecb038851cce76a2a37e9c499f139fb`.
- #607 identifies that SHA as the fresh Fast-proof path while #604 identifies a serial promotion lane.
- compare evidence shows the feature branch is behind current main by one commit, so final promotion requires reconciliation rather than redesign.

## Decision: Calendar Architecture
Continue through the existing Android Calendar Provider / `arvin/system_calendar` architecture tracked by #516/#348. Do not introduce a second Google/Samsung-specific calendar engine without a new proven requirement.

## Decision: Backup Safety
The current verified main includes #582 requiring confirmation before replacement of local data during restore. Future Backup work must preserve non-destructive behavior unless an explicit product decision changes it.

## Decision: Automation
Repeated checks and reporting should move to automation whenever possible. Main contains Worker reliability hardening from #601; Issue #610 remains a roadmap for additional factory layers and must not be described as fully implemented without merged/runtime evidence.

## Decision: Documentation
- GitHub is the source of truth.
- Use periodic checkpoints and important-event updates without unnecessary commits.
- Preserve historical documents and append/reconcile rather than delete or rewrite history without reason.
- Documentation must stay isolated from active validation branches when changing docs would invalidate healthy evidence.

## Decision History
- Initial PR-handling, release-speed, automation, and documentation principles established with resilient production checkpoint PR #609.
- 2026-09-01: added evidence semantics, RC freeze #612, execution mode #614, current Calendar promotion state, and verified Backup/Automation boundaries.
