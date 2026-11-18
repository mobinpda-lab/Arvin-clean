# Occurrence Data Preservation Contract

## Scope
The contract covers Task-owned occurrence history and occurrence checklists carried in the legacy Task envelope and normalized by V19 into:
- `task_occurrences`
- `occurrence_checklist_items`

Pinned sources: V19 snapshot `310c0e20e3447c488c1e1c102c38bea5040708ca`; `OccurrenceSqlCodec` blob `ae9fb8548fa57a8a3a48e1faa2e98a44e636003e`; Task model blob `328c402318878717d9165bccf8303fa6674321bf`.

## Identity
Occurrence primary identity is the deterministic V19 identity:
`occ-${base64Url(UTF8(taskId + "|" + scheduledAt)) without padding}`.
The unique natural key is `(task_id, scheduled_at)`. Preserve both Task ID and Occurrence ID exactly. Do not normalize timestamp strings, trim IDs, or regenerate IDs for existing rows. A non-canonical but valid historical timestamp must be treated as source data and compared byte-for-byte unless an approved canonicalization rule is separately documented.

Checklist item identity is `(occurrence_id, ordinal)`; preserve ordinal order and exact string value, including empty strings if the source contract permits them.

## Source mapping
- Task `occurrenceHistory` object key → `scheduled_at`.
- State `scheduledDate` → must equal the map key if present; otherwise map key is the scheduled timestamp.
- State `status` → exact allowed enum name; invalid/unknown values block.
- State `completionDate` → nullable SQL value plus explicit presence bit.
- State `result` → nullable SQL value plus explicit presence bit.
- State unknown keys → opaque JSON payload, not discarded.
- Task `checklistOccurrences` map key → occurrence natural key.
- Checklist array → ordered checklist rows.
- A checklist-only occurrence may create a pending occurrence only under the exact V19 rule; the generated state must be recorded as a transformation in the receipt and compared on retry.

## Validation invariants
1. Every source Task exists in `tasks`.
2. Every occurrence maps to exactly one Task and one deterministic ID.
3. Duplicate scheduled keys after decoding are rejected.
4. `scheduledDate`, when present, equals the source map key.
5. Status is one of pending/completed/missed/skipped/cancelled.
6. Completion timestamp and result preserve missing/null/value distinction.
7. Every checklist row preserves its original ordinal and value.
8. SQL readback reconstructs a semantically equivalent JSON state, including unknown keys and explicit nulls.
9. Source and destination row counts, IDs, ordered checklist rows, presence bits and hashes agree.
10. No unrelated Task, Recurrence, Follow-up, Person, Project, Category or Tag identity changes.

## Read/write behavior
The compatibility adapter reads V19 legacy envelope data and emits a strict immutable transfer representation. The normalized SQL writer uses insert-only semantics for an empty destination. Existing rows are compared field-by-field; exact matches are accepted as already present, mismatches stop the migration. Runtime TaskStore writes after migration must use the same presence-aware codec and preserve opaque fields.

## No deletion rule
The forward migration must not remove source occurrence keys or overwrite `legacy_payload_json`. Source retirement, if ever required, is a separate migration after backup/restore acceptance and an explicit approval. This avoids making a successful copy dependent on destructive source cleanup.
