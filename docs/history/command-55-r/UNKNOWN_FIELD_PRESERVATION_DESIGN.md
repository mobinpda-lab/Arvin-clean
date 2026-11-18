# Unknown Field Preservation Design

## Goal
Preserve future and vendor-specific fields nested inside each Occurrence state, including their key names, JSON types, values, nested maps, arrays and nulls.

## Storage
Each occurrence row gains:
- `unknown_fields_json TEXT NOT NULL`: a JSON object containing all unrecognized key/value pairs;
- `source_state_json TEXT NULL`: original serialized state object retained as migration evidence until separately approved retirement.

The canonical encoder separates known keys from unknown keys. The opaque object is recursively preserved. Arrays remain arrays; numbers remain numbers; booleans remain booleans; null remains null. No flattening or stringification of arbitrary values.

`source_state_json` protects source-level fidelity and makes recovery possible when canonical projection rules evolve. The receipt stores a digest of the original source bytes and the semantic unknown-fields object.

## Collision rules
- Known key appearing in `unknown_fields_json`: reject as a reserved-key collision.
- Duplicate JSON object key in raw source: reject before normal JSON Map decoding; do not accept last-key-wins behavior.
- Same unknown key in both an existing opaque payload and a new source state: accept only if values are semantically identical; otherwise record a conflict and stop.
- SQL column names and migration metadata keys are reserved and cannot be imported as user JSON fields.
- Malformed JSON, invalid UTF-8, non-object occurrence state, excessive nesting, or unsupported numeric range: fail closed and retain original bytes in the backup.

## Compatibility behavior
A future app version may promote an unknown field to a known field. On promotion, the adapter moves it from opaque payload to the typed column only if the source key is unique and valid; the value must be removed from opaque payload only in the same transaction, with a schema-versioned transformation receipt. Existing unknown keys not promoted remain untouched.

## Canonical comparison
Compare JSON values recursively, preserving type distinctions. Object key ordering may be normalized for semantic hashes, but raw source bytes remain available separately. Numeric representation must not collapse integer and floating-point types if the application treats them distinctly.

## Deletion policy
No unknown key may be discarded by a whitelist update, model constructor, codec rewrite, backup restore, or schema migration. Every intentional removal requires a documented field mapping, reason, source hash, target hash, and explicit migration approval.
