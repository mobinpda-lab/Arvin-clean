import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/backup_service.dart';

void main() {
  group('ArvinBackupService', () {
    final service = ArvinBackupService();

    test('creates a Persian-date backup filename', () {
      final name = service.createBackupFileName(DateTime(2026, 8, 12, 9, 13));
      expect(name, 'Arvin_Backup_1405-05-21_09-13.json');
    });

    test('creates zero-padded backup time', () {
      final name = service.createBackupFileName(DateTime(2026, 1, 2, 3, 4));
      expect(name, 'Arvin_Backup_1404-10-12_03-04.json');
    });
  });
}
