# Quick Capture UI PR gate — 2026-08-26

Delivery stays Draft until exact-head `Arvin Build` and `Arvin Parallel Wave` pass. Early Draft CI is intentional: it validates the independent dialog/test/documentation slice before Home wiring, so product work can continue in parallel without waiting for the scorecard lane.

Required before merge:
1. Home entry point wired.
2. Canonical persistence through existing `TaskMigrationWriter` / `arvin.tasks` only.
3. Focused Home regression tests.
4. Exact-head APK validation.
5. Post-merge main Build.
