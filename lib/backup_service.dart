import 'dart:convert';
import 'dart:typed_data';

import 'package:saf/saf.dart';

/// Portable Android backup service based on the Storage Access Framework.
///
/// Backup documents are ordinary JSON files and can be copied to another
/// phone. The filename uses the Persian (Jalali) calendar for easy sorting
/// and identification by the user.
class ArvinBackupService {
  ArvinBackupService({Saf? safClient}) : saf = safClient ?? Saf();

  static const int backupFormatVersion = 1;
  static const String backupType = 'arvin_backup';

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
    final document = <String, dynamic>{
      'type': backupType,
      'formatVersion': backupFormatVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'tasks': payload['tasks'] ?? const <dynamic>[],
    };

    final bytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(document)),
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

    return document;
  }

  String createBackupFileName(DateTime dateTime) {
    final jalali = _toJalali(dateTime.year, dateTime.month, dateTime.day);
    final year = jalali.$1.toString().padLeft(4, '0');
    final month = jalali.$2.toString().padLeft(2, '0');
    final day = jalali.$3.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return 'Arvin_Backup_$year-$month-$day-$hour-$minute.json';
  }

  /// Converts a Gregorian date to the Jalali/Persian calendar.
  (int, int, int) _toJalali(int gy, int gm, int gd) {
    final gregorianDay = _daysFromGregorianEpoch(gy, gm, gd);
    var jy = 1 + ((gregorianDay - _jalaliEpochDay) ~/ 12053) * 33;
    var remaining = (gregorianDay - _jalaliEpochDay) % 12053;
    if (remaining < 0) {
      jy -= 33;
      remaining += 12053;
    }

    jy += (remaining ~/ 1461) * 4;
    remaining %= 1461;

    if (remaining > 365) {
      jy += (remaining - 1) ~/ 365;
      remaining = (remaining - 1) % 365;
    }

    final jd = remaining + 1;
    final jm = jd <= 186 ? ((jd - 1) ~/ 31) + 1 : ((jd - 187) ~/ 30) + 7;
    final day = jd <= 186 ? ((jd - 1) % 31) + 1 : ((jd - 187) % 30) + 1;
    return (jy, jm, day);
  }

  int _daysFromGregorianEpoch(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        ((153 * m + 2) ~/ 5) +
        365 * y +
        (y ~/ 4) -
        (y ~/ 100) +
        (y ~/ 400) -
        32045;
  }

  // Julian day number for 1 Farvardin 1 (Jalali).
  static const int _jalaliEpochDay = 1948320;
}
