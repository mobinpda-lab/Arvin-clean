# V19 Execution Runner Report

**Workflow:** `.github/workflows/command-48-r-v19-compatibility.yml`  
**Authoritative run:** `44308608481`  
**Job:** `134816565546`  
**Workflow SHA:** `16e009fe1014e83d2014493ff86fcd7ef44d158e`  
**Run result:** SUCCESS  
**Artifact:** `14429935379` — `command-48-r-v7-to-v19-44308608481`  
**Artifact ZIP SHA-256:** `09e2bd12e09955e4ea69ad3c2c02193dd5a534912fe4ed4942c7ae83df8b2af9`

## Runner sequence

1. Checked out exact approved source ref `310c0e20e3447c488c1e1c102c38bea5040708ca`.
2. Asserted installer blob `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`.
3. Installed Flutter 3.47.0 / Dart 3.13.0.
4. Resolved historical dependencies with `--enforce-lockfile`; no lockfile diff.
5. Extracted fixture source from `f211326e7615f1c907494232dd3aec8d4732c83c`.
6. Verified extracted and working-copy pre-run SHA-256 as `68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0`.
7. Opened the working copy read-only with the v7 inspector and saved the pre-migration snapshot.
8. Closed it, reopened the same working copy and invoked the original `G1DriftSchema.install`.
9. Saved the post-migration snapshot and verified schema version, IDs, core fields, retained source rows, canonical relations, reminders, recurrence, unknown values, integrity and FK status.
10. Uploaded the complete evidence artifact (90-day retention).

## Snapshot hashes

- Pre-migration JSON: `26a5d1d819b93c3c2095ed7b042771a9a6c2064520ada11f2e834935d7460479`
- Post-migration JSON: `cc1ca0a6d19893c1ebaca15c59de1b631a8e32e25dfe3777785e002ccc9dde33`
- Source fixture SHA-256: `68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0`
- Working-copy post-migration SHA-256: `f99c71201e9a8f7c6d36711f05d84fddb6eadc9e6308fcbd7894e39fa7a4c9bf`

The initial run `44308068805` was an execution probe. The authoritative corrected run `44308608481` adds explicit assertions for pre/post user_version, core Task fields, retained source rows, canonical relation parity and unknown payload fields.

## What was not run

No retry, controlled interruption, backup restoration, v20 migration, release or deployment was performed.
