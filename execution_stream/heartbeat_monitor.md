# Heartbeat Monitor

Purpose: detect inactive execution components.

Monitored components:

- Orchestrator
- Workers
- Test Pipeline
- Recovery Agent

Rules:

ACTIVE:
component sends regular execution events.

STALE:
no event received within threshold.

RECOVERY:
trigger recovery workflow and record event.

All heartbeat changes must be recorded in Execution Stream history.
