import 'dart:convert';
import 'dart:typed_data';

import 'package:saf/saf.dart';

/// Portable Android backup service based on the Storage Access Framework.
///
/// The selected folder is granted by Android and can be used again after
/// application restarts. Backup files are ordinary JSON documents, so they
/// can be copied to another phone and restored there.
class ArvinBackupService {
  ArvinBackupService({Saf? safClient}) : saf = safClient ?? Saf();

  final Saf saf;

  Future<String?> chooseDirectory() async {
    final directory = await saf.pickDirectory();
    return directory?.uri;
  }

  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
  }) async {
    final bytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(payload)),
    );
    await saf.writeFileBytes(directoryUri, fileName, 'application/json', bytes);
  }

  Future<Map<String, dynamic>?> readBackup() async {
    final file = await saf.pickFile();
    if (file == null) return null;
    final bytes = await saf.readFileBytes(file.uri);
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map) {
      throw const FormatException('Invalid Arvin backup format');
    }
    return Map<String, dynamic>.from(decoded);
  }
}
