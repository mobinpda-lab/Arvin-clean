# PDF / Print implementation — 2026-08-26

Gate F Vertical Slice.

## Implemented

- One read-only `TaskReportProjection` is the shared source for PDF and Print.
- Single Task export is available from each report row.
- Multi-select export is available through report selection.
- All non-trashed Tasks can be exported together.
- `TaskReportPdfRenderer` produces A4 RTL PDF.
- Persian text uses Noto Naskh Arabic regular/bold through the Printing font provider.
- `PdfPreview` consumes the same renderer bytes for preview/share/printing; no second print template exists.
- Report UI is reachable from the existing Home → Calendar → Next Action path.

## Validation

- Projection tests cover all/selected/single data scopes and Persian payload preservation.
- Renderer test produces real `%PDF` bytes with injected offline test fonts.
- Widget test covers single/all/selected UI scope without invoking platform printing.
- Exact-head Fast Lane + Ready full APK Build remain required before merge.

## Dependency compatibility

This repository supports Dart >=3.3. `printing 5.14.3` supports Dart 3.3; the newer 5.15.0 requires Dart 3.12, so this slice intentionally pins the compatible release line. `pdf 3.12.0` remains compatible with the project SDK range.

## Current integration baseline

- Rebased/reconstructed on `main` `93e56d3cc6cd124f0aa6e7023091b63048ab08ea` after Gate H / PR #199 merged.
- The branch now includes the dedicated Release regression surface from Gate H.
- Previous exact-head CI on the pre-#199 base is historical only; a fresh synchronize/full Build on the new head is required before merge.

Refs #195 #5 #153 #199.
