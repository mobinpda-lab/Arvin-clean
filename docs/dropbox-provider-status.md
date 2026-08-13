# Dropbox Provider

The concrete Dropbox transport is implemented behind `CloudBackupProvider` on `feat/dropbox-cloud-provider`.

It covers upload, download, delete, and metadata existence checks through Dropbox API v2, with an injectable request handler for tests.

No credential is persisted by this provider.
