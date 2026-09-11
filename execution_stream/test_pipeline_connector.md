# Test Pipeline Connector

## Purpose
Connect Arvin validation and testing stages to Execution Stream.

## Events

- test_started
- test_progress
- test_passed
- test_failed
- validation_completed

## Flow

Test Runner
↓
Execution Event Bus
↓
Execution Storage
↓
Dashboard

## Rule
Testing reports status only. It does not modify business logic.
