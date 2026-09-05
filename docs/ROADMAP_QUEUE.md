# Arvin Roadmap Queue

## NOW — RC Closure
- Reconcile the Calendar provider-selection promotion lane with current `main` (`2ee2adc22a45ab5fda1dcd548672ddaf77717afc`) without reopening product design.
- Preserve existing exact-head evidence on `6cdd6cd49ecb038851cce76a2a37e9c499f139fb`:
  - Arvin Build run 1605 — success.
  - Arvin Device Smoke run 850 — success.
  - ARVIN Orchestrator runs 83/84 — success.
- After reconciliation, run only the required exact-head gates for the new promotion candidate.
- Keep RC feature freeze from Issue #612 and execution rules from Issue #614.

## PARALLEL — Safe While RC Continues
- Maintain resilient production checkpoints on PR #609 without touching active Calendar validation branches.
- Keep PR #611 as a Draft architecture/design track for future Multi Device Sync; do not claim it as implemented until code merges.
- Refine Issue #613 Smart Multi-Instance FollowUp as a Post-RC implementation queue item without adding it to RC.
- Continue automation/reliability work only when it is isolated from the active release lane.

## NEXT — After RC Promotion
- Smart Multi-Instance FollowUp Engine (#613).
- Productivity Layer (#608): Today Center, Next Action, Dashboard.
- Calendar target continuation under #516 only through the existing Android Calendar Provider architecture; no second calendar engine.
- Multi Device Sync implementation should begin from the approved architecture only after RC constraints permit it.

## LATER
- Knowledge Layer: Notebook connection, Decision History, Unified Search.
- Reporting: Smart Reports and activity timeline.
- Intelligence Layer: evidence-backed suggestions and AI assistant capabilities.

## Execution Rules
- GitHub is the source of truth.
- Small mergeable slices; serial merge promotion, maximum parallel preparation.
- Never use stale-head or skipped CI as passing evidence.
- Do not restart/cancel healthy validation merely to refresh documentation.
- Automation first for repeated production checks.
- Documentation updates only for meaningful state changes; preserve history and avoid duplicate checkpoint commits.

## Queue History
- Initial queue: RC first, productivity/knowledge/intelligence later.
- 2026-09-01: queue aligned with live main `2ee2adc...`, Calendar head `6cdd6cd...`, RC freeze #612, execution mode #614, Sync PR #611, and FollowUp #613.
