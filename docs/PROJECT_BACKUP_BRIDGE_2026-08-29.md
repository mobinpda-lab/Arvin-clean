# Project Backup Bridge — 2026-08-29

This slice wires canonical Projects into the existing Arvin backup document without introducing a second backup format or Project persistence path.

- ProjectStore remains the only local Project persistence owner.
- ArvinBackupManager remains the only portable backup document owner.
- ProjectBackupBridge loads Projects before backup and restores candidate Projects through ProjectStore.
- Task payloads remain canonical Task JSON; no `projectId` is added to Task.
- Home/main.dart wiring remains a later current-main integration slice.
