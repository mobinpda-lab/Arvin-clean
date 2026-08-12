import 'dart:convert';
import 'dart:typed_data';

import 'package:persistent_user_dir_access_android/persistent_user_dir_access_android.dart';

/// Android backup storage using the system directory picker (SAF).
///
/// The selected directory URI can be persisted by the application and reused
/// after restarts. Backup files are ordinary JSON files and can therefore be
/// copied to another phone and restored there.
class ArvinBackupService {
  const ArvinBackupService({this.userDirs = const PersistentUserDirAccessAndroid()});

  final PersistentUserDirAccessAndroid userDirs;

  Future<String> chooseDirectory() => userDirs.requestDirectoryUri();

  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
  }) async {
    final bytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(payload)),
    );
    await userDirs.writeFile(
      directoryUri,
      fileName,
      'application/json',
      bytes,
      true,
    );
  }
}
