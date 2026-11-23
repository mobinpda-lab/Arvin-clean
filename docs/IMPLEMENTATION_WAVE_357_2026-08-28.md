# Follow-up Task UX — implementation wave #357

Status: active product code lane.

This branch starts the owner-approved follow-up-enabled task UX without waiting for Home, Widget, Notebook, Sync or documentation lanes.

Delivered in the merged first slice:
- explicit `کار پیگیری‌دار` control in task create/edit;
- ordinary tasks keep follow-up date/time controls hidden;
- enabling follow-up uses the same canonical `Task` and pre-fills a current device date/time value;
- disabling future follow-up does not erase canonical `followUps[]` history;
- task edit preserves unrelated canonical fields such as category, checklist, reminder, completion/archive/trash state, recurrence and people references instead of rebuilding a lossy partial Task;
- focused widget regression tests cover ordinary/enabled/history-preservation flows.

Delivered in this second slice:
- Add FollowUp keeps system/current date-time prefill behavior;
- date and time remain editable;
- title is explicitly optional;
- a blank title saves canonically as `پیگیری`;
- entered title remains unchanged;
- Android smoke coverage follows the merged rule that ordinary Tasks do not expose follow-up date/time controls until `کار پیگیری‌دار` is enabled.

Still open under Issue #357:
- Home card tap -> read/detail page rather than direct edit;
- follow-up-enabled detail round bottom `+`;
- final latest-follow-up Home visual acceptance and device evidence.

Delivery rule: mergeable slices stay small and non-blocking. No second Task/FollowUp storage or model is introduced.
