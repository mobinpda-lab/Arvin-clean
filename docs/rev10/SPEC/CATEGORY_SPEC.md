# Category Specification
Category identity and storage are canonical and stable. Project↔Category is M2M; do not infer links or silently convert category scope. Task→Category remains optional 0..1. Preserve category IDs, names, links and Task assignments during edits and migrations. Acceptance: CRUD, M2M link/unlink, duplicate rejection, bidirectional lookup, close/reopen and A→B restore.
