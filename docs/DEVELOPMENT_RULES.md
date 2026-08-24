# Arvin Development Rules
## Rule 1 — Audit Before Change
Before any meaningful change, inspect the canonical operating standard, current GitHub state, existing implementation, open PRs and relevant documentation. Do not start from memory alone.
## Rule 2 — Reuse Before Rebuild
Extend existing models, repositories, storage, workflows and components. Do not create competing implementations without an approved reason.
## Rule 3 — Parallel by Default
Independent work should proceed concurrently. Shared foundation, shared files and dependent work require coordination and explicit sequencing where technically necessary.
## Rule 4 — Foundation Protection
Architecture, database/migrations, Sync Engine, security-sensitive infrastructure and cross-feature contracts use controlled review, validation, recovery and rollback planning.
## Rule 5 — Quality Before Merge
Use the applicable validation chain: Analyze → Test → Build/Workflow → Evidence → Review → Merge. Never call a workflow green without exact-commit evidence.
## Rule 6 — Data Safety
Preserve existing data and backward compatibility unless an approved, tested migration changes the contract. No destructive migration without recovery/rollback planning.
## Rule 7 — UI Protection
Approved Arvin UI is a protected product contract. No redesign without explicit approval, UI review, RTL verification and documentation. The Reminder/Lock-Screen concept and Persian RTL hierarchy remain canonical.
## Rule 8 — Documentation
Every meaningful change updates the appropriate documentation. The single active governance authority is `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0. Historical documents remain historical evidence.
## Rule 9 — Communication
Reports and AI answers must be compact, non-technical where possible, copyable, free of unnecessary blank lines and clear about verified facts, blockers and next action.
## Rule 10 — Identity
`«بسم الله الرحمن الرحیم»` is an inseparable project principle and must remain in project identity and continuity context.
## Rule 11 — Continuation
The command `ادامه` means audit live state and continue the nearest real unfinished work. It never authorizes unsafe or unverified action.