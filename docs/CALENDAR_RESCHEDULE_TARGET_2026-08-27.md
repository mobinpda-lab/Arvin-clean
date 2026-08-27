# Calendar reschedule canonical target — 2026-08-27

Refs #311 #308 #302 #285 #195.

## Purpose
Prepare the next safe rescheduling slice by resolving a projected calendar reminder back to the exact canonical Task + FollowUp identity without parsing the reminder id in UI code.

## Boundary
`FollowUpCalendarProjection` remains read-only and owns the reminder-id convention it already emits. The new resolver compares projected identities directly against canonical Task/FollowUp objects, including ids that themselves contain `:`.

## Safety
- no Task or FollowUp mutation;
- no persistence or repository write;
- no new storage/model/schema;
- no scheduler or Android platform call;
- trashed tasks cannot resolve as writable targets.

## Next slice
A future Apply action may use this resolver only after explicit user confirmation. The actual update must preserve the existing FollowUp id/metadata and go through the already-merged `FollowUpWriteCoordinator`, which persists canonically and requests alarm rescheduling after a successful write.

## Validation
Focused tests cover normal target resolution, colon-containing ids, unknown ids, trashed targets, and the existing projection behavior.
