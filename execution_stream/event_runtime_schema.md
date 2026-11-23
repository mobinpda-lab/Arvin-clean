# Execution Stream Runtime Event Schema

## Purpose
Define the runtime event format used by Arvin components.

## Event Flow

Component -> Event Bus -> Stream Storage -> Live View

## Required Fields

```json
{
  "event_id": "unique-id",
  "timestamp": "ISO-8601",
  "component": "orchestrator|worker|tester|recovery",
  "event_type": "started|progress|success|failed",
  "status": "running|completed|error",
  "message": "description",
  "metadata": {}
}
```

## Rules

- Every important execution step creates an event.
- Events are append-only.
- Business logic must remain independent.
- Failures must create recovery events.
