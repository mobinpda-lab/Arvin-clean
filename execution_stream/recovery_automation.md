# Arvin Recovery Automation

## Purpose
Automatic recovery tracking for failed factory tasks.

## Flow
Worker Failure
-> Error Event
-> Recovery Decision
-> Retry / Escalation
-> Recovery Event
-> Continue Pipeline

## Recovery States

FAILED
RECOVERING
RETRYING
RECOVERED
ESCALATED

## Rules
- Preserve execution history
- Never hide failures
- Record retry attempts
- Send final state to Execution Stream
