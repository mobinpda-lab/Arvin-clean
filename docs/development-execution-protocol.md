# ARVIN-CLEAN — DEVELOPMENT EXECUTION PROTOCOL

## GAP ↔ ChatGPT ↔ GitHub

## Purpose

This document defines the execution cycle for completing Arvin-clean through evidence-based, controlled development.

## Roles

### GAP

Responsibilities:
- Analyze defects and gaps.
- Provide evidence-based recommendations.
- Provide Patch/Diff suggestions.
- Provide validation commands and expected results.

### ChatGPT

Responsibilities:
- Receive GAP instructions.
- Verify scope before execution.
- Apply only approved changes when GitHub execution is available.
- Collect validation evidence.
- Report real results back to GAP.

### GitHub

GitHub is the source of truth for:
- Code
- Branches
- Commits
- Pull Requests
- CI/CD
- Validation history

## Development Cycle

GAP Analysis

↓

Patch / Command Proposal

↓

Repository Verification

↓

Minimal Change Execution

↓

Test / Analyze / Build

↓

CI Validation

↓

Commit

↓

Pull Request

↓

Review

↓

Report Result

↓

Iteration

## Execution Rules

1. No change without evidence.
2. Every change must record:
   - Base SHA
   - Branch
   - Changed files
   - Diff
   - Test results
   - Build results
   - CI results
3. Changes outside approved scope are forbidden.
4. Completion, green, or merge claims require real evidence.

## GAP Request Format

- Problem
- Evidence
- Root Cause
- Base SHA
- Files To Change
- Files Forbidden
- Patch/Diff
- Commands
- Expected Result
- Risk
- Rollback Plan

## Goal

Repeat the cycle:

Analysis → Minimal Change → Validation → CI → Review → Improvement

until Arvin-clean reaches production readiness.
