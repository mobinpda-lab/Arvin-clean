# REV10 Wave Dependency DAG — Waves 0–12
Status: dependency map only; no wave completion implied.

| Wave | Scope | Prerequisites | Blocking decisions | Required entities / tests | Acceptance evidence | Downstream |
|---|---|---|---|---|---|---|
| 0 | Governance/live baseline | Canonical PR | None | Repo, PR, ledger, decisions | Exact SHA; Main unchanged | 1–12 |
| 1 | SQLite schema/identity | W0 | ID strategy, schema lineage | Entities, migrations, FKs, rollback | Sequential migration and parity | 2–12 |
| 2 | Stores/relationships | W1 | Shared activity identity; ProjectExecution reconciliation | M2M, optional Task links, transactions | File-backed CRUD, FK, rollback | 3–8,10 |
| 3 | Task editor/detail/Quick Capture | W2 | None for optional Center UX | Task, Center, Project, Category, Tag, Person | Create/edit/clear/reopen | 4,8,11 |
| 4 | Entity management | W2 | Category scope only where relevant | Center/Project/Category CRUD and relations | Related lists and persistence | 5,8,11 |
| 5 | Home filters | W2–4 | None for independent filters | Five dimensions/five time groups; SQLite query tests | OR within dimension, AND across | 8,11 |
| 6 | Search/diagnostics | W1–2 | Tokenizer, privacy retention | Persian fixtures, FTS5, redaction | Normalization and privacy proof | 8,11 |
| 7 | Reminder/recurrence/Waiting For | W2 | Recurrence, Waiting For, activity identity | Reminder, Follow-up, occurrence, scheduler | Permissions, Doze, reboot, identity | 8,9,11 |
| 8 | Backup/Restore/encryption | W1–7 as payload requires | Key management/encryption boundary | All accepted entities/edges; A→B/rollback | Independent DB, tamper, repeat, destination preservation | 9,11 |
| 9 | Calendar/provider | W7–8 | Activity identity for affected projections | Reminder/Calendar/provider links | No duplicates, restart, device proof | 11 |
| 10 | Design/accessibility | W3–9 | Only owner-approved visual changes | TalkBack/contrast/200% tests | Automated and device evidence | 11 |
| 11 | Slice-0 E2E | W3–10 | Decisions on Slice-0 path only | Task, relations, Reminder, Follow-up, report, backup | One exact SHA, restart and A→B parity | 12 |
| 12 | Release readiness | W0–11 | All release gates + explicit owner approval | Full regression, artifacts, device/data safety | Same-SHA acceptance and owner approval | separately authorized merge/release |

Independent paths continue when a decision is unrelated. Shared source files require serialized integration and exact-head revalidation. Documentation or APK alone is not acceptance.
