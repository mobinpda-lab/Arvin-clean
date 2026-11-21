# LIVE BASELINE REPORT — COMMAND 60-R
**Observed:** 2026-11-19  
**Repository:** mobinpda-lab/Arvin-clean

- Main: `45e4202b03a434459e4c021a04efa7e8396359db`.
- Canonical branch at start: `871abadc158464b6059d88350b1cb6fb48def7df`.
- PR #3495: OPEN / DRAFT / UNMERGED, base main, head branch recovery-02/main-based-integration.
- PR #3384: OPEN / DRAFT / UNMERGED; historical V19 stream.
- PR #3463: OPEN / DRAFT / UNMERGED; historical V20/M2M stream.
- PR #1901: OPEN; historical product regression acceptance source.
- Main remains read-only. Read and write access verified.
- COMMAND 59 commits re-read: `1dc43001e2572933d4cafd602641d46617f179cd` and `871abadc158464b6059d88350b1cb6fb48def7df`.
- Main schema path is V7; canonical branch G1 schema is V9. Historical V19/V20 branches remain separate and are not an accepted sequential upgrade path.
- Existing docs state PR #3495 was the only active path; this newer COMMAND 60-R explicitly authorizes five separate work branches. Five branches were created from baseline SHA without modifying Main.
- Initial CI results are recorded in MASTER_TRACKER. All results are exact-SHA scoped.
