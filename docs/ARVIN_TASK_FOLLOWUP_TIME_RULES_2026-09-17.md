# ARVIN Task vs FollowUp Time Rules

Date: 2026-09-17

## Core rule

Arvin must distinguish between normal Tasks and Follow Up items.

## Normal Task

- Creating a normal Task must NOT automatically assign today's date.
- Creating a normal Task must NOT automatically assign a time.
- Creating a normal Task must NOT automatically create a Reminder.
- A Task can exist without date and time.
- Missing date/time means the user has not scheduled it yet, not that the Task is invalid.

Later scheduling:

- Date only -> calendar representation must be an All Day event.
- Date + time -> calendar representation must be a timed event.

## Follow Up

Follow Up is different from a normal Task.

Every follow-up action must automatically record:

- Date
- Time
- Timeline history entry

A follow-up record without timestamp is not acceptable.

## Implementation requirement

All Task creation flows (Quick Add and Full Form) must follow these rules.
Calendar mapping must preserve the difference between:

- unscheduled Task
- all-day Task
- timed Task
- timestamped Follow Up
