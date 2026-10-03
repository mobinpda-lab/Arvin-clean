# Recovery System Connector

## Purpose
Track self-healing and recovery actions.

## Events

- error_detected
- recovery_started
- recovery_attempted
- recovery_completed
- recovery_failed

## Flow

Failure Detection
↓
Recovery Agent
↓
Execution Event Bus
↓
Execution History

## Rule
Recovery actions must be visible and auditable.
