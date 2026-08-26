# Home Today + About Completion Lane — 2026-08-26

Issue #237. Refs #8 #231 #195.

## Purpose

Close the remaining approved Drawer gaps without a new router, task model, repository, event store, or storage path.

## Today

`HomeTodayProjection` is a pure projection over the canonical `Task` list. It selects only open, active tasks whose current Home follow-up date falls on the local current day. The current Home follow-up date remains `Task.legacyHomeFollowUpDate`, which already prefers canonical FollowUp history over the legacy field.

The projection owns no persistence and does not reorder or mutate the source list.

The canonical Home drawer now exposes `امروز`. Home obtains the IDs from `HomeTodayProjection` and intersects them with the existing search projection, then keeps the existing Home ordering and Task cards. There is no parallel Today task list or data store. An empty Today view has the dedicated message `کاری برای امروز وجود ندارد`.

## About

The canonical Home drawer now exposes `درباره آروین`. It closes the drawer and uses Flutter's built-in `showAboutDialog` with Arvin's application name and purpose. No second page or router foundation is created.

## Reference-project lesson applied

TimeJot is used as a product-reference example for fast time-centric navigation: a user should be able to reach items relevant to the current day from the main navigation without creating a separate event model. Arvin adapts that useful UX principle to its existing canonical `Task → FollowUps[]` data rather than copying an external implementation.

Joplin's general separation-of-concerns/testing discipline is also retained: the Today selection is isolated as a pure projection with focused tests, while Home owns only presentation/navigation wiring.

## Tests

- projection selects only active Tasks due on the local current day;
- latest canonical FollowUp history wins over a stale legacy date;
- UTC/offset timestamps are normalized before local-day comparison;
- source Tasks are not reordered/mutated;
- real Drawer Today flow shows today Tasks and hides tomorrow/completed Tasks;
- Today empty state is covered;
- real Drawer About flow opens Flutter `AboutDialog`.

## Guardrails

- no second Task/event projection storage system
- no new router
- Today reuses the existing canonical Home task list
- About uses the existing Flutter about surface
- no Joplin/TimeJot application source is copied

Rebuilt on main `11bff1081311eadff4b0d9333c3aae45245026b0`. Require exact-head Parallel Wave, Full Build with release/debug APK, Android Device Smoke, and post-merge validation.
