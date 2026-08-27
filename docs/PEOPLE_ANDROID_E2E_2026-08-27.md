# People / Contacts — Android E2E boundary

Date: 2026-08-27
Issue: #336

## Purpose

Close the People / Contacts stage-85 regression/E2E gap by exercising the existing canonical user flow on a real Android emulator.

## Covered flow

1. Launch the real Arvin app.
2. Create a canonical Task from Home.
3. Open Calendar from the Home drawer.
4. Use More → Timeline for the created Task.
5. Open the existing Task-facing People editor.
6. Add one local Arvin-owned Person display name.
7. Verify persistence through the existing TaskStore / `arvin.tasks` path.
8. Cancel removal and verify zero mutation.
9. Confirm removal and verify persistence while unrelated Task fields remain unchanged.

## Guardrails

- No device Contacts permission or import.
- No Android contact-provider identifier.
- No phone/email enrichment.
- No standalone People repository, database, or storage key.
- No cloud/network People sync.
- Existing Home Android smoke remains mandatory.
- Home and People run as independent Ready-only Android emulator jobs so one flow cannot serialize or indefinitely block the other.
- Each device job has a bounded workflow timeout to prevent a stuck emulator from holding the gate forever.

## Promotion rule

People / Contacts may move from stage 70 to stage 85 only after focused regression coverage, exact-head Fast/Build/APK/Device success, merge, and green post-merge main Build/Device validation.
