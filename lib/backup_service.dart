import 'dart:convert';
import 'dart:typed_data';

import 'package:saf/saf.dart';

import 'cloud_backup_provider.dart';
import 'services/encrypted_backup_envelope.dart';

typedef BackupLocalWriter = Future<void> Function(
  String directoryUri,
  String fileName,
  String mimeType,
  Uint8List bytes,
);

/// Portable Android backup service based on the Storage Access Framework.
///
/// Backup documents are ordinary JSON files and can be copied to another
/// phone. The filename uses the Persian (Jalali) calendar for easy sorting
/// and identification by the user.
///
/// A cloud provider is optional. Local Android backup remains available when
/// no provider is configured, while configured providers receive the exact
/// same validated backup bytes.
class ArvinBackupService {
  // The fallback Saf instance must be created when no client is injected, so
  // this assignment cannot use an initializing formal without changing the
  // constructor's dependency-injection behavior.
  // ignore: prefer_initializing_formals
  ArvinBackupService({
    Saf? safClient,
    this.cloudProvider,
    ArvinEncryptedBackupEnvelope? encryptedEnvelope,
    BackupLocalWriter? localWriter,
  })  : saf = safClient ?? Saf(),
        encryptedEnvelope =
            encryptedEnvelope ?? ArvinEncryptedBackupEnvelope(),
        _localWriter = localWriter;

  static const int backupFormatVersion = 1;
  static const String backupType = 'arvin_backup';

  final Saf saf;
  final CloudBackupProvider? cloudProvider;
  final ArvinEncryptedBackupEnvelope encryptedEnvelope;
  final BackupLocalWriter? _localWriter;

  Future<String?> chooseDirectory() async {
    final directory = await saf.pickDirectory();
    return directory?.uri;
  }

  /// Produces the single byte stream used by both SAF and cloud backup.
  ///
  /// Plaintext v1 remains the default. Supplying a passphrase explicitly opts
  /// this one backup into the versioned authenticated encryption envelope.
  Future<Uint8List> prepareBackupBytes(
    Map<String, dynamic> payload, {
    String? passphrase,
  }) async {
    final plainBytes = encodeBackupDocument(payload);
    if (passphrase == null) return plainBytes;
    return encryptedEnvelope.encrypt(plainBytes, passphrase: passphrase);
  }

  /// Opens either a legacy/plaintext v1 document or an encrypted envelope,
  /// then sends the resulting plaintext through the existing validator.
  Future<Map<String, dynamic>> decodeBackupBytes(
    Uint8List bytes, {
    String? passphrase,
  }) async {
    final plainBytes = await encryptedEnvelope.decodeForRestore(
      bytes,
      passphrase: passphrase,
    );
    return validateBackupDocument(jsonDecode(utf8.decode(plainBytes)));
  }

  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
    bool uploadToCloud = true,
    String? encryptionPassphrase,
  }) async {
    final bytes = await prepareBackupBytes(
      payload,
      passphrase: encryptionPassphrase,
    );

    final localWriter = _localWriter;
    if (localWriter != null) {
      await localWriter(directoryUri, fileName, 'application/json', bytes);
    } else {
      await saf.writeFileBytes(
        directoryUri,
        fileName,
        'application/json',
        bytes,
      );
    }

    if (uploadToCloud && cloudProvider != null) {
      await cloudProvider!.uploadBackup(fileName: fileName, bytes: bytes);
    }
  }

  Future<Map<String, dynamic>?> readCloudBackup(
    String fileName, {
    String? passphrase,
  }) async {
    final provider = cloudProvider;
    if (provider == null) {
      throw StateError('No cloud backup provider configured');
    }

    final bytes = await provider.downloadBackup(fileName);
    if (bytes == null) return null;
    return decodeBackupBytes(bytes, passphrase: passphrase);
  }

  Future<void> deleteCloudBackup(String fileName) async {
    final provider = cloudProvider;
    if (provider == null) {
      throw StateError('No cloud backup provider configured');
    }
    await provider.deleteBackup(fileName);
  }

  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async {
    final file = await saf.pickFile();
    if (file == null) return null;

    final bytes = await saf.readFileBytes(file.uri);
    return decodeBackupBytes(bytes, passphrase: passphrase);
  }

  static Uint8List encodeBackupDocument(Map<String, dynamic> payload) {
    final rawSettings = payload['settings'];
    if (rawSettings != null && rawSettings is! Map) {
      throw const FormatException('Arvin backup settings are invalid');
    }

    final document = <String, dynamic>{
      'type': backupType,
      'formatVersion': backupFormatVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'tasks': payload['tasks'] ?? const <dynamic>[],
      if (rawSettings is Map)
        'settings': Map<String, dynamic>.from(rawSettings),
    };

    return Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(document)),
    );
  }

  static Map<String, dynamic> validateBackupDocument(Object? decoded) {
    if (decoded is! Map) {
      throw const FormatException('Invalid Arvin backup format');
    }

    final document = Map<String, dynamic>.from(decoded);
    if (document['type'] != backupType) {
      throw const FormatException('This file is not an Arvin backup');
    }
    if (document['formatVersion'] != backupFormatVersion) {
      throw const FormatException('Unsupported Arvin backup version');
    }
    if (document['tasks'] is! List) {
      throw const FormatException('Arvin backup tasks are invalid');
    }

    final rawSettings = document['settings'];
    if (rawSettings != null && rawSettings is! Map) {
      throw const FormatException('Arvin backup settings are invalid');
    }
    if (rawSettings is Map) {
      document['settings'] = Map<String, dynamic>.from(rawSettings);
    }

    return document;
  }

  String createBackupFileName(DateTime dateTime) {
    final jalali = _toJalali(dateTime.year, dateTime.month, dateTime.day);
    final year = jalali.$1.toString().padLeft(4, '0');
    final month = jalali.$2.toString().padLeft(2, '0');
    final day = jalali.$3.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return 'Arvin_Backup_$year-$month-${day}_$hour-$minute.json';
  }

  (int, int, int) _toJalali(int gy, int gm, int gd) {
    const gregorianMonthDays = <int>[
      0,
      31,
      59,
      90,
      120,
      151,
      181,
      212,
      243,
      273,
      304,
      334,
    ];

    var jy = gy > 1600 ? 979 : 0;
    gy -= gy > 1600 ? 1600 : 621;

    final gy2 = gm > 2 ? gy + 1 : gy;
    var days =
        365 * gy +
        ((gy2 + 3) ~/ 4) -
        ((gy2 + 99) ~/ 100) +
        ((gy2 + 399) ~/ 400) -
        80 +
        gd +
        gregorianMonthDays[gm - 1];

    jy += 33 * (days ~/ 12053);
    days %= 12053;
    jy += 4 * (days ~/ 1461);
    days %= 1461;

    if (days > 365) {
      jy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }

    final jm = days < 186 ? 1 + (days ~/ 31) : 7 + ((days - 186) ~/ 30);
    final jd = 1 + (days < 186 ? days % 31 : (days - 186) % 30);
    return (jy, jm, jd);
  }
}
