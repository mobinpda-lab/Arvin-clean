# Exact-head release gate — 2026-10-01

Issue: #undefined

Target main HEAD:
`90473841c43d53ba1ea14b764eaf555e51438f3d`

## Required evidence
This branch exists only to activate a fresh PR-triggered validation path. No product runtime/storage/model change is intended.

Required exact-head evidence:
- Analyze
- full Test
- Build
- Release/Debug APK
- Device Smoke
- Calendar Provider Acceptance when applicable

Historical runs on earlier SHAs do not satisfy this gate.

## Current observed state
At branch creation, the exact target SHA had no PR-triggered workflow runs returned by the GitHub Actions commit-run query.
