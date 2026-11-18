# COMMAND 35 — Historical Recovery
Date: 2026-11-18
Repository: mobinpda-lab/Arvin-clean
Canonical PR: #3495
Canonical branch: `recovery-02/main-based-integration`
Audit baseline HEAD: `ed4f1e0c0e01f186155b194b34212b7f2ffb584b`
Main base SHA reported by PR #3495: `45e4202b03a434459e4c021a04efa7e8396359db`

## Status
IN PROGRESS — forensic inventory and first-pass source comparison performed. No historical code was transferred, no PR was closed, and no branch was deleted. This is deliberate: no item with unique work may be discarded before its exact blob/dependency/test disposition is recorded.

## Live canonical state
- PR #3495: OPEN, DRAFT, UNMERGED; base `main`; head `recovery-02/main-based-integration`.
- Live head at audit start: `ed4f1e0c0e01f186155b194b34212b7f2ffb584b`.
- PR metadata: 175 commits, 141 changed files.
- Repository permissions: pull, push, maintain and admin are true.
- The historical SHA values supplied in the command are not used as current HEAD.

## Priority historical PR inventory
| PR | State | Head SHA | Commits | Files | First-pass finding |
|---|---|---|---:|---:|---|
| #3052 | Open/Draft | `aba68e44be0fcac7d4ad425b58fbe75e5aba264e` | 2,192 | 395 | Broad product/architecture lineage; schema v17; not safe to merge wholesale |
| #3384 | Open/Draft | `310c0e20e3447c488c1e1c102c38bea5040708ca` | 218 | 120 | SQL/migration foundation v19; non-Main stacked base |
| #3463 | Open/Draft | `812082964c649be7660c41213209ec34aea7167b` | 139 | 42 | v19→v20 M2M candidate and acceptance suites |
| #3380 | Open/Draft | `33a8fb14a9979d0d86775cb5457970c7e445077b` | 8 | 2 | Diagnostic-only SQLite harness recovery |
| #3382 | Open/Draft | `adee525e94fa2daec617255d57f9cfb65e3efe66` | 3 | 2 | Raw SQL evidence capture; test/workflow only |
| #3376 | Open/Draft | `d7191903af2ea2518f1fedc697d0f8090f780b3a` | 7 | 2 | Diagnostic SQL envelope interception; test/workflow only |
| #3470 | Open/Draft | `d7c9322afb9cb32e607f53e139f8bd82a984c805` | 24 | 21 | Vazirmatn weight normalization candidate |
| #1901 | Open, not merged | `ba8e26c2388c4b74bc0ecc40cf50b0fd0b02960a` | 86 | 27 | Product regression work: Home, Checklist, Notebook, Quick Add, taxonomy |

## Recovery rules applied
1. PR title, filename equality and commit count are not proof of transfer.
2. Blob SHA comparisons were made for the critical M2M files and selected #3052 architecture files.
3. The historical v20 M2M migration is not applied to the current v8 canonical schema.
4. The test-only diagnostics are not promoted into duplicate production workflows.
5. Typography is assessed against the owner-approved Vazirmatn family; VazirHarf is not adopted as a second UI family.
6. CI outcomes are attached to their exact historical SHA only.

## Incomplete work / blockers
- Full unique-commit and blob-by-blob comparison of all 395 #3052 files remains open.
- Full file/commit dependency closure of #3384 and all stacked ancestors remains open.
- Full PR inventory beyond the eight named sources is not yet certified complete.
- #1901 has no workflow runs returned for its inspected head; its product requirements and patches require exact-current-state comparison.
- Canonical M2M integration and sequential v8→v19→v20 migration are not accepted.

No merge, release, deployment, production database mutation, history rewrite, force-push or branch deletion was performed.
