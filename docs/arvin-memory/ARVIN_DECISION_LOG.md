# Arvin Decision Log

## 2026-10-11 — Backup/restore dependency order
- Decision: prove restore rollback behavior first; validate physical-device/file-provider round-trip second; validate Calendar event identity after successful restore third.
- Parallel work: Issue #2580 may proceed as read-only audit and documentation-only fixes, provided backup semantics and data relationships are not changed.
- Guard: PR #2585 stays open/unmerged until exact-head CI, restore failure behavior, physical-device/file-provider acceptance, Calendar no-duplicate evidence, and remaining product acceptance are reviewed.
- Evidence: https://github.com/mobinpda-lab/Arvin-clean/issues/2585#issuecomment-6106883617

## Canonical taxonomy
- Product/domain concepts are Project, Category and Tag.
- Persian UI term for Category is «دسته». Group is not a fourth domain entity; display-only grouping and generic technical group terms are distinct.
- Do not infer a database Category-to-Project foreign key from semantic wording alone.
- Reference: https://github.com/mobinpda-lab/Arvin-clean/issues/2582 and https://github.com/mobinpda-lab/Arvin-clean/issues/2580

## Data and architecture guards
- Fix existing paths; do not add a parallel store, backup format, restore engine, taxonomy, or Task system.
- Preserve Task identity, Project membership, Category/Tag catalogs and assignments, settings, repeat/occurrence history, and Calendar-link metadata.
- Missing/null legacy Project fields preserve local Projects; an explicit empty list means restore an empty Project catalog.
- Never claim a gate is done without evidence. CI/emulator success is necessary but not physical-device acceptance.
