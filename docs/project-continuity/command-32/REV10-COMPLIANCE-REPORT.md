# COMMAND 32 — REV10 Compliance Report
Checkpoint SHA: `ed93d6ad30bfe4e75199f297efda0a2b8099ce49`

REV10 is active authority in `docs/project-continuity/MASTER_GOVERNANCE.md`. Historical REV9 and earlier docs are subordinate where conflicting.

## Compliance decisions applied
- One canonical delivery path: PR #3495 only.
- Main remains read-only.
- Local-first data ownership remains in force; no sync or NIRA runtime dependency introduced.
- Vazirmatn remains the sole official/default product font; System Default may remain optional. VazirHarf is not promoted to active branding.
- Follow-up records remain historical; legacy Next Follow-up metadata is inert and is not reactivated as an independent scheduler.
- Person IDs remain Arvin-owned stable identifiers. Same-name people are not merged automatically.
- Historical person IDs may remain in Follow-up records when absent from active directory.
- Center↔Project and Project↔Category M2M remains approved architecture; implementation acceptance is separate.
- Schema changes must be additive, idempotent, transactional and file-backed tested.
- Validation must not mutate production user data.

## Open compliance gates
- M2M migration and sequential v7→v20 parity.
- Full Backup/Restore including Calendar links, unknown metadata and historical Person IDs.
- Five-filter Home (Time / Center / Project / Category / Tag) and full RTL/UI acceptance.
- Typography weight and PDF validation.
- Workflow security review and exact-SHA evidence.
- H01 real Android process-restart proof.

Status: PARTIAL COMPLIANCE — NOT RELEASE ACCEPTED.
