# Arvin Cloud Backup Track

## Current status

- Local backup/restore: complete and covered by CI.
- Cloud provider contract: implemented.
- Cloud provider wiring through `ArvinBackupManager`: implemented.
- Cloud backup settings abstraction: implemented on PR #3.
- Dropbox transport: not implemented yet.
- Credential persistence: intentionally deferred to secure platform storage.

## Next milestones

1. Integrate the validated cloud settings and manager wiring changes.
2. Implement Dropbox transport behind `CloudBackupProvider`.
3. Add authentication/configuration UI without persisting tokens in SharedPreferences.
4. Add cloud upload/download/delete integration tests.
5. Run analyze, test, and release APK CI before closing the cloud phase.
