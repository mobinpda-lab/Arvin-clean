# Backup restore safety — 2026-08-31

## Current-main finding

Arvin already has Backup UI, encryption, progress feedback, portable files, and a canonical backup manager. The remaining destructive UX gap was narrower: after a file was selected and parsed, the page replaced local Tasks immediately without a final user confirmation.

## Bounded fix

- keep the existing Backup/Restore architecture and callbacks;
- show a non-dismissible confirmation dialog only after a backup file is successfully read;
- display the number of Tasks that will replace local data;
- Cancel performs zero local mutation;
- Restore proceeds through the existing `replaceTasks` callback only after explicit confirmation;
- invalid/encrypted-file failure behavior remains unchanged;
- add widget coverage for cancel/no-mutation and confirm/replace-once behavior.

## Follow-up audit, not part of this slice

The UI currently reads the backup document through the existing raw manager read path. A separate current-main audit should decide whether Settings/Projects restoration must be surfaced through the canonical candidate path without broadening this RC safety fix.
