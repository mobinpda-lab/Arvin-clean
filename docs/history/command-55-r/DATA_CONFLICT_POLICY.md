# Data Conflict Policy

## Guiding rule
No source or destination value is silently preferred. Conflicts are observable, explainable and fail closed.

## Conflict classes
1. IDENTITY_CONFLICT: same primary or natural key points to different owner or scheduled timestamp.
2. CONTENT_CONFLICT: same identity but status, timestamps, result, ordinal, checklist content or opaque payload differs.
3. NULL_PRESENCE_CONFLICT: SQL value matches but presence bit differs.
4. UNKNOWN_FIELD_CONFLICT: opaque key overlaps with different value or a newly known field collides.
5. SOURCE_SOURCE_CONFLICT: multiple legacy sources for the same semantic field disagree.
6. RECEIPT_CONFLICT: receipt, definition hash, schema fingerprint or data fingerprint disagrees.
7. RELATIONSHIP_CONFLICT: missing parent, orphan edge, duplicate membership or changed ordinal.
8. SCHEMA_SHAPE_CONFLICT: unknown columns, indexes, triggers, constraints or unsupported schema version.
9. CORRUPT_SOURCE: malformed JSON, duplicate keys, wrong types, invalid timestamps or invalid enum.
10. AMBIGUOUS_HISTORY: source removed without a verifiable receipt or independent snapshot.

## Decision table
| Condition | Decision |
|---|---|
| Target empty and source valid | insert-only transfer inside transaction |
| Target row exactly matches source | treat as existing matching data; no write |
| Target row differs in any protected field | abort |
| Same occurrence ID but different Task/time | abort |
| Same natural key but different deterministic ID | abort |
| Same unknown key and same semantic value | retain one identical value and record source provenance |
| Same unknown key with different value | abort |
| Explicit null vs absent | distinct; abort if presence evidence disagrees |
| Invalid/unknown status | abort; never coerce to pending |
| Malformed JSON | abort; retain source/backup |
| Source absent without receipt | ambiguous; abort |
| Receipt mismatch | abort and recover from verified backup |

## Forbidden conflict handling
- INSERT OR IGNORE;
- REPLACE;
- blind ON CONFLICT DO UPDATE;
- delete-and-reinsert;
- trimming or regenerating IDs;
- selecting a winner based on newer timestamp without an approved domain rule;
- converting unknown enum to a default;
- replacing null/missing with defaults;
- dropping unknown fields or schema objects.

## Resolution record
A manually resolved conflict requires an explicit issue/decision record, source and destination snapshots, chosen value and rationale, identity/relationship impact, owner approval, a new migration definition hash, and a fixture regression test. The migration must not self-resolve.
