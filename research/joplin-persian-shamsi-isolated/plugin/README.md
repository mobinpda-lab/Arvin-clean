# Joplin Persian Shamsi — isolated plugin

This is a standalone Joplin plugin project.

## Current milestone: 0.1.0 scaffold

The current build is intentionally minimal. It only proves the plugin registration/build path. Persian font, RTL rendering, and Jalali conversion are separate implementation steps.

## Hard isolation rule

This project must never become part of Arvin runtime.

- No import from Arvin Dart/Flutter code.
- No Arvin database, models, services, settings, or runtime.
- No Joplin dependency added to Arvin.
- No changes to Arvin's `lib/`, `pubspec.yaml`, database, or application startup for this plugin.
- The plugin is built with Node/TypeScript and Joplin's plugin toolchain only.
- The only shared location is this repository. The software projects remain independent.

## Build

Use the current Joplin generator/toolchain (currently generator-joplin 3.7.2) and run:

```
npm install
npm run dist
```

The expected installable archive is written under `publish/`.

## First acceptance gate

PASS only when:

1. `npm install` succeeds.
2. `npm run dist` succeeds.
3. A `.jpl` archive is produced.
4. The manifest declares desktop + mobile support.
5. The plugin can be loaded in Joplin Development Mode.
6. No Arvin product file outside this isolated directory is required.

No claim is made here that Android rendering or Jalali date replacement works yet.

## Next implementation

After the scaffold build passes:

1. Add a Markdown-It renderer/content script for Persian RTL + VazirHarf.
2. Add a self-contained Gregorian → Jalali formatter.
3. Test visible date surfaces without modifying stored timestamps.
4. Test Android installation and sync/data integrity.
