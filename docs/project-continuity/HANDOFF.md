# HANDOFF — 2026-11-28

- Repository: mobinpda-lab/Arvin-clean
- Branch: recovery-02/main-based-integration
- Candidate SHA at checkpoint: a420c89f06c598ed17b9def38efebd9108618c90
- Main: 45e4202b03a434459e4c021a04efa7e8396359db (read-only)
- PR #3495: OPEN / DRAFT / UNMERGED.
- Product acceptance: NOT ACCEPTED. Release: NO-GO.

## Verified source changes (verification still pending unless stated)
1. fff59f6b3c5bad6746e271ef42d2c505cce1b368: ProjectStore is sole writer of project_items; TaskStore's full Task rewrite no longer mutates the join table; deferred FK validation protects referenced Task identities. Trigger-guarded file-backed test added.
2. a48488ff89ec01d880548d267b66389c28c13d00: Project restore upserts matching Project IDs in place and guards deletion against Task/Center/Category edges; file-backed graph test added.
3. a420c89f06c598ed17b9def38efebd9108618c90: canonical insert helper reused for new Projects; deletion-block message generalized.

## Current exact-SHA workflows
- Build: 46116776194 — in progress.
- COMMAND 20-E: 46116776165 — storage-persistence in progress.
- Device Smoke: 46116776170 — in progress.
- Follow-up File Persistence: 46116776176 — SUCCESS.
- Governance Validation: 46116776167 — SUCCESS.
- Parent fff59f6... Device Smoke 46115088811 completed 7/7, but is not evidence for this SHA.

## Next actions — one lane, no duplication
1. Poll all current-SHA runs. Inspect exact failed/passed jobs and the two new ProjectStore regression assertions. Do not infer PASS from queued/in-progress or parent-SHA runs.
2. Resolve the async runner root cause from completed exact-SHA logs; keep timeouts and assertions intact.
3. Continue ARC-M2M-001: inventory every Project/Category consumer and find the single missing/approved project_categories owner before implementation. CenterStore already owns center_projects; do not create duplicate Center storage.
4. Continue D01–D05 data preservation and physical backup/restore acceptance on disposable file-backed databases; never experiment destructively on user DBs.
5. Update this handoff and registry after each meaningful commit; all final gates must match one exact SHA.

## Protected boundaries
- No writes to Main; no merge/release/deployment.
- No production database mutation, branch deletion, history rewrite or force push.
- No duplicate store/repository/registry/test inventory.
- Preserve IDs, unknown metadata, graph edges, reminders, follow-up history and backups.
