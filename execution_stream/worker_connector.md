# Execution Stream Worker Connector

## Purpose

Connect Arvin workers to the Execution Stream observability layer.

## Worker Events

Workers must emit:

- worker_assigned
- worker_started
- worker_progress
- worker_completed
- worker_failed

## Flow

Worker

↓

Execution Event Bus

↓

Event Storage

↓

Dashboard / Reports

## Rules

- Worker logic must remain independent.
- Execution Stream only observes and records.
- Every execution attempt must have a traceable lifecycle.
