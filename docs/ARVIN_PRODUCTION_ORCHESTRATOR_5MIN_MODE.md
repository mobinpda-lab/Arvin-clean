# Arvin Production Orchestrator - 5 Minute Mode

## Goal
Enable continuous GitHub production flow with minimum manual intervention.

## Execution Cycle

```
Every 5 minutes
    ↓
Check eligible PRs
    ↓
Validate CI status
    ↓
Validate Build and Device gates
    ↓
Allow controlled merge
    ↓
Record evidence
```

## Rules

- Only approved automation PRs enter the flow.
- Main branch protection remains active.
- Only one merge operation runs at a time.
- Failed gates stop promotion.
- Evidence is tied to exact commit SHA.

## Continuous Development

```
Issue
 ↓
Planner
 ↓
Task Queue
 ↓
Worker
 ↓
PR
 ↓
CI
 ↓
Merge
 ↓
Release
```

## Post-RC Queue

Future parallel streams:

- Smart FollowUp Engine
- Multi Device Sync
- Project Tracking
- Automation improvements

This document defines the operating direction for autonomous production workflows.
