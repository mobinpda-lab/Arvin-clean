# COMMAND 45-R — Runtime Results

Status: BLOCKED — RUNTIME NOT VERIFIED

Repository: mobinpda-lab/Arvin-clean
Canonical branch: recovery-02/main-based-integration
Reference SHA supplied: acc2f46dd070e7ba7e19f7bac1c0749d359414be
Latest branch head at this report: b7cbaba6f07fb2de8e5b3085740498449e78719e
PR #3495: OPEN / DRAFT / UNMERGED
Main: 45e4202b03a434459e4c021a04efa7e8396359db (unchanged)

## Executed runs

- Run 44287318505, event push, SHA 2c07983f262f1114f5e158d1a2d0b3d2253949d8: FAILURE. Both v19 and v20 reached dependency resolution and fixture verification; test compilation failed because the generated smoke test treated a Map as if it had a .data getter.
- Run 44287623079, event push, SHA 3532cc1c1c1d204697f33ceb5fd856162ea6d35c: FAILURE. The compile defect was corrected. Both matrix jobs opened the NativeDatabase connection and completed the first table-list query, then the Dart process terminated with SIGBUS / BUS_ADRERR (exit 134) before a snapshot was produced.
- Run 44287872905, event push, SHA c7885d77b0ab326d59c5e5a4130cb33af66d6b30: diagnostic execution; job logs showed constructor, ensureOpen and first query completion before the native crash in the v19 lane. The run was still in progress when this report was authored.
- Run 44288042082, event push, SHA b7cbaba6f07fb2de8e5b3085740498449e78719e: diagnostic stage markers added; execution was in progress when this report was authored.

## Proven in completed job logs

- Flutter 3.47.0 stable; framework revision 4cf24164269a5ebf0c16a028a00727d0e77bbb05.
- Dart SDK 3.13.0 stable.
- Flutter Doctor ran. Flutter/Chrome checks passed; Android licenses were not accepted and Linux desktop GTK3 development libraries were absent. These warnings do not establish a migration failure.
- Dependency resolution passed with --enforce-lockfile.
- pubspec.lock SHA-256: 146c122f71109fae332a2dcfcffc63f8b48e51eebcd183758b0808443f4bcabc; no lockfile diff.
- Extracted fixture SHA-256 matched: 68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0; size 106,496 bytes.

## Not accepted

- NativeDatabase full read-only inspection and integrity checks: NOT ACCEPTED.
- Snapshot generation: NOT ACHIEVED.
- Two successful independent runs on one identical SHA: NOT ACHIEVED.
- Content snapshot parity: NOT TESTED.
- COMMAND 45-R acceptance: NO-GO.

No v19 or v20 migration was invoked. The workflow uses a temporary extracted copy of the fixture. No Main change, merge, release or deployment was performed.

## Addendum — additional diagnostic run (18 Nov 2026)

Run 44295851388 executed on SHA 80ffa54ae9f2d5b2556eccb6dbfe697b6006fa88 and failed in both matrix lanes. Detailed logs now prove that all 12 expected tables were read, the task IDs and SQLite metadata were queried, `integrity_check` and `foreign_key_check` completed, and the normalized snapshot JSON was encoded (3,886 characters). The process then crashed with SIGBUS during asynchronous `File.writeAsString`, before the write-complete marker and artifact snapshot could be confirmed. This narrows the current failure to the asynchronous snapshot output / Dart runner interaction, not fixture opening or table reads.

A follow-up change switched the snapshot write to synchronous `writeAsStringSync` on SHA 5646cfc06977e3d0b4999874b33aa8c0892c9296. Run 44296037837 was started on that SHA and was still in progress at report refresh. Its outcome is not yet accepted. No snapshot success is claimed until the new logs and uploaded files confirm it.

The two required independent successful runs on the exact same SHA remain outstanding.