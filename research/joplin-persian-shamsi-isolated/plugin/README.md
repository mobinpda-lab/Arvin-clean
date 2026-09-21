# Joplin Persian Shamsi — isolated plugin

This is a standalone Joplin plugin project.

## Current milestone: 0.2.0 renderer scaffold

The plugin now contains:

- Joplin MarkdownItPlugin registration for the note renderer.
- RTL Persian presentation wrapper.
- Self-contained Gregorian → Jalali display conversion for explicit YYYY-MM-DD and YYYY/MM/DD text.
- Persian digits for converted dates.
- VazirHarf 34.0.3 as an npm dependency.
- Build configuration that copies the bundled variable TTF from the dependency into the final plugin archive.

The plugin does not modify stored note text, note timestamps, database records, or sync data.

## Hard isolation rule

This project must never become part of Arvin runtime.

- No import from Arvin Dart/Flutter code.
- No Arvin database, models, services, settings, or runtime.
- No Joplin dependency added to Arvin.
- No changes to Arvin's lib/, pubspec.yaml, database, or application startup for this plugin.
- The plugin is built with Node/TypeScript and the Joplin plugin toolchain only.
- The only shared location is this repository. The software projects remain independent.
- If future work appears to require touching Arvin product code, stop and review the architecture before proceeding.

## Build

Use the Joplin plugin toolchain and run:

```text
npm install
npm run dist
```

The expected installable archive is written under publish/.

The build is designed to copy node_modules/vazirharf/fonts/ttf/Vazirharf[wght].ttf to dist/fonts/Vazirharf[wght].ttf and include it in the .jpl archive.

## Verification status

Implemented in source:
- Plugin registration: PASS
- RTL renderer logic: PASS at source level
- Jalali conversion logic: PASS at source level
- Persian digits: PASS at source level
- VazirHarf dependency: PASS
- Font packaging path: PASS at configuration level
- Isolation contract: PASS

Not yet execution-proven:
- npm install in the available execution environment.
- npm run dist.
- Actual .jpl generation.
- Loading the plugin in Joplin Desktop.
- Android installation and rendering.
- Verification that all Joplin UI date surfaces are converted.
- Sync/data-integrity test.

Do not report these items as PASS until an actual run produces evidence.

## Acceptance gate

The first release candidate requires:

1. npm install succeeds.
2. npm run dist succeeds.
3. A .jpl archive is produced.
4. The archive contains the plugin manifest, compiled scripts, CSS, and VazirHarf font.
5. The plugin loads in Joplin Development Mode.
6. Persian text renders RTL with VazirHarf.
7. Explicit Gregorian dates in note content render as Jalali without changing stored note data.
8. Android installation succeeds.
9. Sync remains normal before and after plugin installation.

## Next implementation

The next work item is execution verification, not adding more product features:

1. Run npm install.
2. Run npm run dist.
3. Inspect the generated .jpl contents.
4. Fix any build/package errors.
5. Only after a successful package build, move to Desktop and Android runtime tests.
