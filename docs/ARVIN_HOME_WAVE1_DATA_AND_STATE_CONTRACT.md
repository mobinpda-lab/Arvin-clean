# Arvin Home Wave 1 — Data and State Contract

## Purpose
Define the runtime rules for the Home implementation before code changes.

## Source of truth
- Existing Task data model remains authoritative.
- UI grouping must consume real stored data.
- No duplicate storage layer may be introduced.

## Home states

### Loading
- Show a lightweight loading state.
- Do not create fake task statistics.

### Empty
- Explain how to create the first task.
- Keep navigation available.

### Error
- Preserve user data.
- Provide recovery action.

## Grouping rules

### Time
- Use due date, not reminder or follow-up date.
- Separate overdue, today and future.

### Projects
- Group by actual project relation.
- Unassigned tasks remain accessible.

### Categories
- Independent from projects.
- Category selection must not modify task ownership.

### Labels
- A task can appear in multiple label groups.
- Counting must remain unique.

## Acceptance
A Home implementation is accepted only after:
- real data connection
- state handling
- interaction validation
- Android verification
