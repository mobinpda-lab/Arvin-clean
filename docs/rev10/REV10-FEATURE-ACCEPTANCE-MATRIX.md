# REV10 FEATURE ACCEPTANCE MATRIX — COMMAND 124-R
**Candidate audited:** `c033513de5bd0067a093c59303c4071acf42f564`
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db`
**PR:** #3495 OPEN / DRAFT / UNMERGED
**Rule:** status describes the current candidate only. PASS requires feature-specific exact-SHA evidence, not a generic successful build.
| Feature / acceptance surface | Source / tracker | Implementation evidence | Candidate status | Remaining acceptance |
|---|---|---|---|---|
| Primary Blue #4169A1 | PRODUCT_DECISIONS.md; governance workflow | canonical color contract and governance validation run 44874825945/job 136757113713 PASS | INCOMPLETE EVIDENCE | Full source-consumer audit; keep owner decision immutable |
| Center Model | REV10 §5; Issue #3550 | lib/models/center.dart | INCOMPLETE EVIDENCE | Validation, immutable identity, full domain semantics |
| CenterStore CRUD/archive/restore | REV10 §5; Issue #3550 | lib/services/center_store.dart; run 44874825843/job 136757123714 PASS (file-backed persistence workflow) | INCOMPLETE EVIDENCE | Search, UI, full lifecycle, schema-contract review and dedicated acceptance |
| Center↔Project M2M | ADR 2026-11-14; Issue #3550 | schema-v9 center_projects; CenterStore link/unlink/replacement and lookup | INCOMPLETE EVIDENCE | transactional graph acceptance, backup/restore parity, Task graph validation |
| Project↔Category M2M | ADR 2026-11-14; Issue #3550 | schema-v9 project_categories | INCOMPLETE EVIDENCE | canonical Store, UI, explicit operations, persistence and backup tests |
| Task direct Center/Project/Category | REV10 relationship contract | schema-v9 optional columns exist | INCOMPLETE EVIDENCE | Editor/detail/projection validation and graph constraints |
| Center management page | REV10 §5 | no canonical management page found in audited tree | NOT TESTED | Implement full Persian RTL lifecycle UI |
| Task Editor Center selector | REV10 task capture/edit contract | no Center integration found in audited editor | NOT TESTED | Create/select/clear, graph validation and persistence |
| Quick Capture Center selector | REV10 Quick Capture contract | no Center integration found in audited dialog | NOT TESTED | Selector/create-new and persistence |
| Task Projection Center | REV10 Home/report contract | no Center projection integration found | NOT TESTED | Real SQL-backed projection and relationship-aware queries |
| Home Time filter | REV10 Home | current four-dimension filter implementation | INCOMPLETE EVIDENCE | independent selection/clear/combination/restart acceptance |
| Home Center filter | REV10 Home; Issue #3550 | absent from HomeFilterDimension and four visible cards | BLOCKED | add fifth real SQL-backed dimension and acceptance |
| Home Project filter | REV10 Home | existing card | INCOMPLETE EVIDENCE | exact OR/AND and combination acceptance |
| Home Category filter | REV10 Home | existing card | INCOMPLETE EVIDENCE | exact OR/AND and combination acceptance |
| Home Tags filter | REV10 Home | existing card | INCOMPLETE EVIDENCE | exact OR/AND and combination acceptance |
| Five due-date groups | REV10 Home | historical implementation/tests present | INCOMPLETE EVIDENCE | exact-Candidate regression and independent grouping proof |
| Home sorting | REV10 Home | not fully source-verified in this pass | NOT TESTED | independent sort field/direction and retained selection |
| Reminder Stop Bell | Issue #3646 | no accepted four-action controller/UI found | BLOCKED | stop audio only; preserve Task/Reminder state |
| Reminder Follow-up | Issue #3646 | existing follow-up scheduler foundation only | BLOCKED | invoke official flow with same Task identity and history |
| Reminder Snooze | Issue #3646 | existing scheduler foundation only | BLOCKED | replace active schedule; prove no duplicates |
| Reminder Complete | Issue #3646 | canonical TaskStore exists | BLOCKED | complete canonical Task and terminate active Reminder |
| Android reminder Activity / lifecycle | Issue #3646 | notification foundation and manifest permissions exist; dedicated accepted Activity not found | BLOCKED | permissions, background, process death, restart, reboot and visual acceptance |
| Schema v7→v20 migration | REV10 data safety; historical migration reports | v9 additive hierarchy migration and historical migration assets exist | INCOMPLETE EVIDENCE | complete sequential path, no skipped versions, parity, rollback/retry/idempotency |
| NULL / unknown fields / IDs / history | REV10 data safety | prior tests and migration code exist | INCOMPLETE EVIDENCE | full fixture parity on current candidate |
| Backup / Restore | REV10 backup contract; historical acceptance report | backup services/tests exist; Build and Device Smoke backup scenario passed | INCOMPLETE EVIDENCE | independent A→B file proof, tamper/corruption/wrong-key/SAF/repeated restore and snapshot parity |
| Project Management | REV10 §5 | ProjectStore and current project surfaces | INCOMPLETE EVIDENCE | full independent CRUD/archive/restore/search/relations/backup acceptance |
| Category Management | REV10 §5 | legacy taxonomy APIs and v9 category table | INCOMPLETE EVIDENCE | canonical category entity/store/UI and Project M2M |
| Tag Management | REV10 §5 | existing tag surfaces | INCOMPLETE EVIDENCE | full independent CRUD/search/filter/backup acceptance |
| Person Management | REV10 §5 | Person Directory persistence/migration foundation | INCOMPLETE EVIDENCE | independent management UI and exact candidate acceptance |
| Templates / Deep Clone | REV10 template contract | template contract and historical implementation assets exist | INCOMPLETE EVIDENCE | deep clone identity/relationship/metadata and lifecycle tests |
| Cross-Center Reports | REV10 §8 | Report Center exists | INCOMPLETE EVIDENCE | accurate aggregate projections and independent execution isolation |
| Persian PDF / RTL / Accessibility | REV10 UI charter | renderer, theme and tests exist | INCOMPLETE EVIDENCE | full route inventory, visual and accessibility acceptance |
| Calendar / Persistence | REV10 Calendar | Device Smoke calendar scenario and generic persistence pass | INCOMPLETE EVIDENCE | dedicated full Calendar acceptance on this SHA |
| End-to-End | REV10 acceptance | no full product E2E acceptance attached | NOT TESTED | all P0 feature flows on one exact candidate |
| Release signing | owner delivery gate | release APK artifact exists | NOT TESTED | owner-controlled signing proof and APK SHA-256 |
| Physical phone | owner delivery gate | emulator Device Smoke only | NOT TESTED | install and test on real device with OS/API evidence |
## Exact-SHA CI evidence
- Governance: run 44874825945, job 136757113713 — SUCCESS.
- Build/Analyze: run 44874825859, jobs 136757140333, 136757140450, 136757140455, 136757140477, 136757140501, 136757140513, 136757140570, 136757140580, 136757140611 — all SUCCESS.
- Device Smoke: run 44874825857, jobs 136757115412, 136757134517, 136757134547, 136757134562, 136757134564, 136757134567, 136757134583, 136757134609 — all SUCCESS (CI/emulator scenarios, not a physical phone).
- COMMAND 20-E: run 44874825813, jobs 136757113613 and 136758814805 — SUCCESS.
- Follow-up File Persistence: run 44874825843, job 136757123714 — SUCCESS.
- Zero Dollar Environment Smoke: run 44874821618 — PENDING; no jobs exposed.
- Build artifacts: debug artifact 14695861569 (archive digest sha256:80aa8052a482183f40e6849be113672adb8c5d732d5e5cb8468288a2b63b948c); release artifact 14695327649 (archive digest sha256:074f2d5414233a611e3508450c4468528e556b738e1580d3f7859a93a890a479). These are artifact archive digests, not APK file SHA-256.
