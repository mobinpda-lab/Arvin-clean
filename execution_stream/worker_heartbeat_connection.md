# Worker Heartbeat Connection

Purpose: Connect Arvin Workers with heartbeat monitoring.

Heartbeat events:
- worker_registered
- worker_started
- worker_progress
- worker_completed
- worker_timeout
- worker_failed

Flow:
Worker -> Heartbeat Monitor -> Runtime Event Store -> Recovery Tracking

Rule:
Missing heartbeat triggers detection, not automatic failure without validation.
