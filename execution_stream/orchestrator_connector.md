# Arvin Execution Stream Orchestrator Connector

## Purpose
Define how the Arvin Orchestrator publishes runtime events into Execution Stream.

## Required Events

- orchestrator_started
- task_received
- task_planned
- worker_assigned
- task_completed
- task_failed

## Event Flow

Orchestrator

↓

Execution Event Bus

↓

Event Storage

↓

Dashboard / Reports

## Integration Rule

The Orchestrator must report execution state without changing business logic.

Execution Stream observes the system; it does not control the product workflow.

## Example

```json
{
 "event":"task_received",
 "component":"orchestrator",
 "status":"running",
 "task_id":"example"
}
```
