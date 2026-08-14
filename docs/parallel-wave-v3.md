# Parallel Wave v3 — 2026-08-14

## Purpose

Keep independent Arvin commits and waves running concurrently while preventing one surface from masking failures in another.

## CI changes

- Android CI generates the Android platform when the checked-out branch does not contain a MainActivity, then performs the V2 embedding audit.
- Surface matrix uses area-specific test files instead of running the entire test suite for every matrix entry.
- Missing dedicated tests are reported as non-blocking rather than causing a false failure.
- `fail-fast: false` remains enabled so independent matrix entries continue after a failure.

## Verification commit

- CI commit: `1202a295b58bddb15ef6931e42d48721078e8fc4`
- Branch: `ci/parallel-wave-v3`

## Execution rule

Independent commits and independent waves should be started concurrently. Only real code dependencies should impose ordering. A red workflow should block only the dependent path, not unrelated work.
