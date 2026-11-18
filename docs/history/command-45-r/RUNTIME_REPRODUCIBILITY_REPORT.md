# Runtime Reproducibility Report — COMMAND 45-R

Status: NOT REPRODUCIBLE / NOT ACCEPTED.

## Completed evidence

Run 44287318505 on SHA 2c07983f262f1114f5e158d1a2d0b3d2253949d8 failed at test compilation because the snapshot test used an invalid Map.data access.

Run 44287623079 on SHA 3532cc1c1c1d204697f33ceb5fd856162ea6d35c used the corrected Map conversion. Both v19 and v20 lanes resolved dependencies, preserved the lockfile, verified the same fixture SHA, and then terminated with SIGBUS during the physical SQLite smoke test.

These are distinct workflow SHAs, not two successful runs on one identical SHA. The available GitHub action interface in this execution supports reading runs, jobs, logs and artifacts, and retrying failed jobs; it does not expose workflow_dispatch or a full rerun-all operation. Therefore the required two independent full executions on the exact same SHA were not established.

## Comparability

- Flutter version in completed runs: 3.47.0 — same.
- Dart version: 3.13.0 — same.
- Lockfile SHA-256: 146c122f71109fae332a2dcfcffc63f8b48e51eebcd183758b0808443f4bcabc — same.
- Fixture SHA-256: 68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0 — same.
- Snapshot content: unavailable because the SQLite test aborted before generation.
- Time and runner metadata normalization: not applicable until snapshots exist.

## Artifacts

Run 44287318505:
- v20 artifact ID 14420635129
- v19 artifact ID 14419009490

Run 44287623079:
- v20 artifact ID 14420406514
- v19 artifact ID 14419238255

The artifacts are real GitHub Actions uploads, but they contain diagnostic logs and runtime evidence, not successful database snapshots.

## Final disposition

No content-equivalence claim can be made. Reproducibility acceptance requires a stable NativeDatabase smoke test, a complete snapshot, and two successful independent executions on the same SHA. Migration v19/v20, schema changes, Main changes, merge, release and deployment remain prohibited.
