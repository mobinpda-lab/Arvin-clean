# V9 LINEAGE COMPARISON — COMMAND 42-R
**Rule:** Version integer equality does not establish schema compatibility.
| Attribute | v9-A — Task Template | v9-B — REV10 hierarchy |
|---|---|---|
| Source lineage | Descends from Main v7 through v8 | Current canonical #3495 branch, separate lineage |
| Schema source | Commit `708c112a82c753f1dcdb77f1cf9712a6336a725d` / blob `617c05e4416bede903e78b65bd32a839d2d7c65a` | Canonical schema blob `3bd140f9a07b54c1e4a1dff26d64f965b437ec52` |
| Main addition | `task_templates` plus v8 Center/project-template structures | Center↔Project and Category hierarchy |
| Migration source | v9-A historical schema/installer line | `g1_rev10_hierarchy_v9_migration.dart`, blob `f9569182a1d79a116e1e1f4c400e69f7c47863b4` |
| Target | Historical v9-A line proceeds to v10–v20 | Declares source 8 and target 9 |
| Data behavior | Template structures and context evolve | Adds `center_projects`, `categories`, `project_categories`, exceptions and optional Task hierarchy FKs |
## Conclusion
v9-A and v9-B are structurally different. Do not chain v9-B into v10–v20 or infer compatibility from the version number. The v19→v20 migration is a separate edge and accepts only v19. Both v9 paths remain independently unaccepted for Main v7 physical upgrade until executed with their own exact source fixtures and code.
