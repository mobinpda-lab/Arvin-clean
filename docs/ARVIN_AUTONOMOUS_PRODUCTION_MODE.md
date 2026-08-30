# ARVIN-CLEAN — Autonomous Production Mode

## Purpose

Enable continuous production flow until Release Candidate readiness.

## Active Principles

- GitHub Driven Development
- Maximum Parallel Execution
- Production Orchestrator
- CI Auto Recovery
- Auto PR Flow
- Auto Documentation

## Execution Cycle

Issue
↓
Branch
↓
Code
↓
Test
↓
CI
↓
PR
↓
Merge
↓
Documentation
↓
Next Task

## Release Candidate Rule

Until Release Candidate is ready:

- Work continues after each successful block.
- Only real blockers are reported.
- Reports remain short and non-technical.
- Avoid unnecessary feature expansion.

## Priority Order

1. Release Blockers
2. Core Stability
3. Data Integrity
4. CI Recovery
5. Build Stability
6. Remaining Features

## Parallel Development Rules

- Parallel lanes must not modify conflicting shared areas simultaneously.
- Tests are required before merge.
- Documentation is updated with implementation.
- Core completion has priority over scattered features.

## Finish Mode

Detect → Fix → Test → Merge → Document → Continue

Status: Active
