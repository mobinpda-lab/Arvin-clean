# Arvin Execution Stream Event Contract

## Purpose
Define standard runtime events for factory execution visibility.

## Events

STARTED
- component
- task_id
- timestamp

RUNNING
- progress
- worker_id

SUCCESS
- result
- artifact

FAILED
- error
- recovery_action

RECOVERED
- retry
- next_action

## Flow

Worker
 -> Event Generator
 -> Execution Stream
 -> Monitoring
 -> Recovery
