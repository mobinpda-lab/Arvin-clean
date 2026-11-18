import 'dart:typed_data';

/// Storage abstraction for cloud backup providers.
///
/// The backup format and local Storage Access Framework implementation stay
/// independent from the provider. Concrete integrations (for example,
/// Dropbox) implement this contract without changing the backup format.
abstract interface class CloudBackupProvider {
  Future<void> uploadBackup({
    required String fileName,
    required Uint8List bytes,
  });

  Future<Uint8List?> downloadBackup(String fileName);

  Future<void> deleteBackup(String fileName);

  Future<bool> exists(String fileName);
}
