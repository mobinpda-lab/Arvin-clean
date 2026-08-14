# Follow-up feature

The Arvin task list should show the **last follow-up date and time**. Follow-up history belongs to the task and must not appear as a separate task status/filter.

## Planned UI

- Last follow-up date/time on each task card when available.
- Add a follow-up action from task details.
- History list ordered by timestamp.
- Optional note/result and next follow-up time.
- Calendar consumes the same FollowUp data instead of maintaining duplicate reminder state.

## Compatibility

Legacy `followUpDate` data is migrated automatically by `ArvinTask.fromJson`.
