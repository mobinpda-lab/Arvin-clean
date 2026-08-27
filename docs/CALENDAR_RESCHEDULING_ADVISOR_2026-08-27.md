# Calendar Rescheduling Advisor — 2026-08-27

Refs #301 #92 #195 #284 #285 #288 #291 #293 #294.

## Purpose
Connect Arvin's already-merged calendar projection, schedule conflict core and safe rescheduling planner into one read-only advisory path.

## Composition
`CalendarReminder` -> `CalendarScheduleProjection` -> `ScheduleConflictService` -> `ReschedulingPlanner`

The selected reminder is identified only through the existing canonical reminder id. Completed and all-day reminders remain excluded by the merged projection. If the selected reminder has no conflict, the advisor returns `noConflict` and does not invent a replacement. If the selected reminder is unavailable, it returns `targetUnavailable`. Only a real selected-reminder conflict produces replacement-time suggestions.

## Safety boundary
- no Task, FollowUp or Calendar mutation;
- no repository, storage, schema or migration;
- no notification or background scheduler write;
- no duplicate overlap detection;
- no duplicate rescheduling algorithm;
- suggestions preserve the existing projected duration;
- the selected reminder is removed from the busy set before searching, so it cannot conflict with itself;
- any later write requires explicit user confirmation through the existing canonical path.

## Validation
Focused tests cover:
- real conflict -> deterministic replacement times;
- duration preservation;
- no-conflict behavior;
- missing/completed/all-day target behavior;
- filtering conflict evidence to the selected reminder;
- invalid empty id.

This lane remains Draft until exact-head Parallel Fast CI is green. Heavy Build/Device validation follows only after current-main ancestry is confirmed.