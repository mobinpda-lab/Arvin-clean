import 'dart:convert';

import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_page.dart';
import 'package:arvin/backup_service.dart';
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RuntimeBackupService extends ArvinBackupService {
  Map<String, dynamic>? document;
  int writes = 0;

  @override
  String createBackupFileName(DateTime dateTime) => 'runtime-backup.json';

  @override
  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
    bool uploadToCloud = true,
    String? encryptionPassphrase,
  }) async {
    writes += 1;
    document = Map<String, dynamic>.from(payload);
  }

  @override
  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async =>
      document;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('canonical SQL migration and backup/restore runtime smoke',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ArvinBackupManager.directoryKey: 'content://arvin-runtime-smoke',
      TaskStore.key: jsonEncode(<Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'legacy-runtime',
          'title': 'کار مهاجرتی',
          'description': 'داده قدیمی',
          'tags': <String>['مهم'],
          'category': 'فروش',
          'followUps': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'fu-runtime',
              'dateTime': '2026-09-20T10:00:00.000Z',
              'note': 'پیگیری قدیمی',
              'completed': true,
            },
          ],
        },
      ]),
    });

    final store = TaskStore();
    final migrated = await store.load();
    expect(migrated.single.id, 'legacy-runtime');
    expect(migrated.single.followUps.single.id, 'fu-runtime');

    final service = _RuntimeBackupService();
    final manager = ArvinBackupManager(service: service);

    await tester.pumpWidget(
      MaterialApp(
        home: BackupPage(
          manager: manager,
          loadTasks: () async =>
              (await store.load()).map((task) => task.toJson()).toList(),
          replaceTasks: (rawTasks) async {
            await store.save(
              rawTasks.map((raw) => Task.fromJson(raw)).toList(growable: false),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('create_backup_button')));
    await tester.pumpAndSettle();
    expect(service.writes, 1);
    expect(service.document?['tasks'], isNotEmpty);

    service.document = <String, dynamic>{
      'type': ArvinBackupService.backupType,
      'formatVersion': ArvinBackupService.backupFormatVersion,
      'tasks': <Map<String, dynamic>>[
        Task(
          id: 'legacy-runtime',
          title: 'بازیابی‌شده',
          followUps: [
            FollowUp(
              id: 'fu-runtime',
              dateTime: DateTime(2026, 9, 20, 10),
              note: 'پیگیری بازیابی',
              completed: true,
            ),
          ],
        ).toJson(),
      ],
    };

    await tester.tap(find.byKey(const Key('restore_plain_backup_button')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('تأیید بازیابی'), findsOneWidget);

    await tester.tap(find.byKey(const Key('restore_confirm_apply')));
    await tester.pump(const Duration(seconds: 1));

    final restored = await store.load();
    expect(restored.single.id, 'legacy-runtime');
    expect(restored.single.title, 'بازیابی‌شده');
    expect(restored.single.followUps.single.id, 'fu-runtime');
    expect(restored.single.followUps.single.note, 'پیگیری بازیابی');

    await store.save(const <Task>[]);
  });
}
