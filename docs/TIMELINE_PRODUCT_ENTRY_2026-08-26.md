# Timeline product entry — 2026-08-26

## Scope
This slice completes the missing real product entry for the merged `TaskTimelinePage` without rewriting Home or creating another navigation foundation.

## What changed
- Reuses the existing `CanonicalCalendarLauncher`, which Home already opens from its drawer and which already receives canonical `List<Task>`.
- Adds a visible `خط زمانی` action to that existing Home-accessible path.
- With one Task, Timeline opens directly.
- With multiple Tasks, the user explicitly selects the Task before opening its Timeline.
- With no Tasks, the UI reports an explicit empty/unavailable message.

## Why this path
The large transitional Home file does not need another navigation/state rewrite. The existing canonical calendar boundary already owns the canonical Task list and is reachable from Home, so this is a smaller, lower-conflict product integration.

## Validation
Widget tests cover:
- Timeline action visibility;
- direct single-Task Timeline opening;
- multi-Task selection before Timeline opening;
- empty Task-list feedback;
- canonical FollowUp note/result rendering through the already-tested Timeline page.

## Architecture guard
- Reuses `TaskTimelinePage`, `TaskTimelineService`, canonical `Task + FollowUps[]`, and existing Home→Calendar launcher.
- No new Router/AppShell/model/repository/storage/history source.
- No Task/FollowUp mutation.

## Score boundary
After exact-head CI/APK, merge, and successful post-merge main Build, Timeline can be considered for Stage 70 because a real user-facing entry is wired to the canonical path. Higher stages still require final roadmap DoD/handoff/global UI requirements.
