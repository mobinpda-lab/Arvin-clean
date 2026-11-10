## Post-audit exact SHA refresh — 2026-11-10

| Role | SHA / evidence | Status |
|---|---|---|
| Main HEAD / PR base | `45e4202b03a434459e4c021a04efa7e8396359db` | Current; protected |
| Working HEAD / PR #3052 head | `a934cabebc814aea13c1800ab151821d12714226` | Current; unprotected |
| a934 parent | `9846f10850031c63964fdc81ae0ab1cdb3028517` | Historical parent |
| Build | `42801502260` on a934 | FAILURE; 1,296 passed / 78 failed |
| Device Smoke | `42801502310` on a934 | PENDING |
| Calendar Provider | `42801502275` on a934 | SUCCESS |
| Follow-up Persistence | `42801502256` on a934 | SUCCESS |
| Draft Review APK | `42801502270` on a934 | SUCCESS |

No result from SHA 9846 or b789 is transferred to a934. The a934 commit is documentation-only; source tree is unchanged from its parent.

---

# Arvin SHA Reconciliation — REV8

**Snapshot:** 2026-11-10

## Canonical live SHAs

| Role | SHA | Status |
|---|---|---|
| Main HEAD | `45e4202b03a434459e4c021a04efa7e8396359db` | Current; protected branch |
| PR #3052 base | `45e4202b03a434459e4c021a04efa7e8396359db` | Matches Main |
| Working branch HEAD | `9846f10850031c63964fdc81ae0ab1cdb3028517` | Current |
| PR #3052 head | `9846f10850031c63964fdc81ae0ab1cdb3028517` | Matches working branch |
| Current HEAD parent | `b789343c9699ca440d043d71d47db3dcdfafa57c` | Historical parent |
| GitHub compare | 2,130 ahead / 0 behind | Main is merge base |

## Exact-head CI matrix

| Workflow | Run ID | SHA | Result |
|---|---:|---|---|
| Arvin Build | 42795405617 | `9846f10850031c63964fdc81ae0ab1cdb3028517` | FAILURE |
| Device Smoke | 42795405388 | `9846f10850031c63964fdc81ae0ab1cdb3028517` | PENDING |
| Calendar Provider Acceptance | 42795405362 | `9846f10850031c63964fdc81ae0ab1cdb3028517` | SUCCESS |
| Follow-up File Persistence | 42795405561 | `9846f10850031c63964fdc81ae0ab1cdb3028517` | SUCCESS |
| Draft Review APK | 42795404991 | `9846f10850031c63964fdc81ae0ab1cdb3028517` | SUCCESS |
| G1 Lock Sync | 42795405168 | `9846f10850031c63964fdc81ae0ab1cdb3028517` | SUCCESS |
| Parallel Wave | 42795405940 | `9846f10850031c63964fdc81ae0ab1cdb3028517` | SUCCESS |
| Production Loop | 42795405588 | `9846f10850031c63964fdc81ae0ab1cdb3028517` | SUCCESS; feedback-loop step skipped |
| Orchestrator | 42795404989 | `9846f10850031c63964fdc81ae0ab1cdb3028517` | SUCCESS |
| Orchestrator PR Wakeup | 42795405041 | `9846f10850031c63964fdc81ae0ab1cdb3028517` | SUCCESS |

## Historical CI — do not transfer to current HEAD

| Workflow | Run ID | Historical SHA | Historical result |
|---|---:|---|---|
| Arvin Build | 42763952581 | `b789343c9699ca440d043d71d47db3dcdfafa57c` | FAILURE; 79 failed test executions |
| Device Smoke | 42763952498 | `b789343c9699ca440d043d71d47db3dcdfafa57c` | Incomplete at last recorded poll |
| Follow-up Persistence | 42763952346 | `b789343c9699ca440d043d71d47db3dcdfafa57c` | SUCCESS |
| Calendar Provider | 42763952813 | `b789343c9699ca440d043d71d47db3dcdfafa57c` | SUCCESS |
| Draft Review APK | 42763952297 | `b789343c9699ca440d043d71d47db3dcdfafa57c` | SUCCESS |

The historical 79 failures are not the current failure count. Current Build on `9846f108...` has 78 distinct failing test labels.

## SHA references in the eight canonical documents

| File | SHA references | Unique SHA strings |
|---|---:|---:|
| MASTER_GOVERNANCE.md | 7 | 3 |
| PRODUCT_DECISIONS.md | 13 | 11 |
| CURRENT_STATE.md | 178 | 114 |
| ROADMAP.md | 10 | 9 |
| OPEN_ISSUES.md | 33 | 22 |
| IMPLEMENTATION_LOG.md | 127 | 94 |
| HANDOFF.md | 48 | 32 |
| README.md | 9 | 7 |
| **Total** | **425** | **292** |

- The current working HEAD `9846f108...` was not referenced in any of the eight canonical documents at the time of audit.
- The previous baseline `b789343c...` appears in several canonical files and must be retained as historical evidence, not treated as current.
- SHA strings in historical logs were not all individually checked for Git object existence. A SHA reference is not declared invalid merely because it differs from current HEAD.
- The current PR base/head relationship is internally consistent. The documentation checkpoint was stale until this REV8 addendum.

No Main ref was modified.


---

## REV9 deployment SHA reconciliation — 2026-11-10

| Role | Ref / SHA | Status |
|---|---|---|
| Main at deployment start | `45e4202b03a434459e4c021a04efa7e8396359db` | Live ref verified before branch creation. |
| Source PR #3052 | `fix/recovery-calendar-device-smoke-2026-10-31` / `aba68e44be0fcac7d4ad425b58fbe75e5aba264e` | OPEN / DRAFT / UNMERGED; unchanged. |
| New documentation branch | `docs/rev9-governance-continuity-2026-11-10` | Created from exact Main SHA above. |
| Documentation commit 1 | `1a849751b931028581f6ce721952aaa987474053` | REV9 master, REV8 archive, AI policy and adapters. |
| Documentation commit 2 | `4825e04335292dcc20dedbed39d614969a85f4cb` | Authority, state, decisions and product roadmap reconciliation. |
| Combined CI status queried on PR #3052 head | No status records returned by combined-status endpoint. | No PASS inferred; inspect workflow runs/checks directly before any gate change. |

The final documentation PR head and changed-file list must be added after the final commit and PR creation. Historical SHAs elsewhere in this file remain historical snapshots.
