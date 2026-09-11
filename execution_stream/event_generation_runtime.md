# Event Generation Runtime

Purpose: Activate automatic execution events.

Event sources:
- Orchestrator
- Worker
- Test Pipeline
- Recovery System

Required events:
- task_started
- worker_started
- worker_progress
- test_started
- test_completed
- recovery_started
- release_ready

All events flow through Runtime Event Store.
