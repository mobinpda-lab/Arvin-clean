import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_page.dart';
import 'package:arvin/backup_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeBackupService extends ArvinBackupService {
  int writeCount = 0;
  int readCount = 0;
  String? lastEncryptionPassphrase;
  String? lastReadPassphrase;
  Map<String, dynamic>? readResult;
  Object? readError;

  @override
  String createBackupFileName(DateTime dateTime) => 'backup.json';

  @override
  Future<void> writeBackup({
    required String directoryUri,
    required Map<String, dynamic> payload,
    required String fileName,
    bool uploadToCloud = true,
    String? encryptionPassphrase,
  }) async {
    writeCount += 1;
    lastEncryptionPassphrase = encryptionPassphrase;
  }

  @override
  Future<Map<String, dynamic>?> readBackup({String? passphrase}) async {
    readCount += 1;
    lastReadPassphrase = passphrase;
    final error = readError;
    if (error != null) throw error;
    return readResult;
  }
}

Widget _app({
  required _FakeBackupService service,
  Future<List<Map<String, dynamic>>> Function()? loadTasks,
  Future<void> Function(List<Map<String, dynamic>> tasks)? replaceTasks,
}) {
  return MaterialApp(
    home: BackupPage(
      manager: ArvinBackupManager(service: service),
      loadTasks: loadTasks ??
          () async => <Map<String, dynamic>>[
                <String, dynamic>{'id': 'task-1', 'title': 'کار نمونه'},
              ],
      replaceTasks: replaceTasks ?? (_) async {},
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ArvinBackupManager.directoryKey: 'content://arvin-backups',
    });
  });

  testWidgets('plaintext backup remains default and does not prompt',
      (tester) async {
    final service = _FakeBackupService();
    await tester.pumpWidget(_app(service: service));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('backup_passphrase_field')), findsNothing);
    expect(
      tester.widget<SwitchListTile>(
        find.byKey(const Key('backup_encryption_toggle')),
      ).value,
      isFalse,
    );

    await tester.tap(find.byKey(const Key('create_backup_button')));
    await tester.pumpAndSettle();

    expect(service.writeCount, 1);
    expect(service.lastEncryptionPassphrase, isNull);
    expect(find.textContaining('پشتیبان ساخته شد'), findsOneWidget);
  });

  testWidgets('encrypted backup requires matching non-empty confirmation',
      (tester) async {
    final service = _FakeBackupService();
    await tester.pumpWidget(_app(service: service));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('backup_encryption_toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('create_backup_button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('backup_passphrase_field')),
      'secret-123',
    );
    await tester.enterText(
      find.byKey(const Key('backup_passphrase_confirm_field')),
      'different',
    );
    await tester.tap(find.byKey(const Key('backup_passphrase_confirm')));
    await tester.pump();

    expect(find.text('دو رمز یکسان نیستند'), findsOneWidget);
    expect(service.writeCount, 0);

    await tester.enterText(
      find.byKey(const Key('backup_passphrase_confirm_field')),
      'secret-123',
    );
    await tester.tap(find.byKey(const Key('backup_passphrase_confirm')));
    await tester.pumpAndSettle();

    expect(service.writeCount, 1);
    expect(service.lastEncryptionPassphrase, 'secret-123');
    expect(find.textContaining('پشتیبان رمزگذاری‌شده ساخته شد'), findsOneWidget);
  });

  testWidgets('cancelling encrypted backup performs no write', (tester) async {
    final service = _FakeBackupService();
    var loadCount = 0;
    await tester.pumpWidget(
      _app(
        service: service,
        loadTasks: () async {
          loadCount += 1;
          return <Map<String, dynamic>>[];
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('backup_encryption_toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('create_backup_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('backup_passphrase_cancel')));
    await tester.pumpAndSettle();

    expect(loadCount, 0);
    expect(service.writeCount, 0);
  });

  testWidgets('encrypted restore forwards passphrase and replaces tasks once',
      (tester) async {
    final service = _FakeBackupService()
      ..readResult = <String, dynamic>{
        'type': ArvinBackupService.backupType,
        'formatVersion': ArvinBackupService.backupFormatVersion,
        'tasks': <Map<String, dynamic>>[
          <String, dynamic>{'id': 'restored-1', 'title': 'بازیابی‌شده'},
        ],
      };
    var replaceCount = 0;
    List<Map<String, dynamic>>? replaced;

    await tester.pumpWidget(
      _app(
        service: service,
        replaceTasks: (tasks) async {
          replaceCount += 1;
          replaced = tasks;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('restore_encrypted_backup_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('restore_passphrase_field')),
      'restore-secret',
    );
    await tester.tap(find.byKey(const Key('restore_passphrase_confirm')));
    await tester.pumpAndSettle();

    expect(service.readCount, 1);
    expect(service.lastReadPassphrase, 'restore-secret');
    expect(replaceCount, 1);
    expect(replaced?.single['id'], 'restored-1');
    expect(find.text('اطلاعات با موفقیت بازیابی شد'), findsOneWidget);
  });

  testWidgets('wrong encrypted restore passphrase never mutates local tasks',
      (tester) async {
    final service = _FakeBackupService()
      ..readError = const FormatException('authentication failed');
    var replaceCount = 0;

    await tester.pumpWidget(
      _app(
        service: service,
        replaceTasks: (_) async => replaceCount += 1,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('restore_encrypted_backup_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('restore_passphrase_field')),
      'wrong-secret',
    );
    await tester.tap(find.byKey(const Key('restore_passphrase_confirm')));
    await tester.pumpAndSettle();

    expect(service.readCount, 1);
    expect(service.lastReadPassphrase, 'wrong-secret');
    expect(replaceCount, 0);
    expect(find.textContaining('رمز نادرست است'), findsOneWidget);
  });

  testWidgets('passphrase is operation scoped and never persisted',
      (tester) async {
    final service = _FakeBackupService();
    await tester.pumpWidget(_app(service: service));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('backup_encryption_toggle')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('create_backup_button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('backup_passphrase_field')),
      'memory-only-secret',
    );
    await tester.enterText(
      find.byKey(const Key('backup_passphrase_confirm_field')),
      'memory-only-secret',
    );
    await tester.tap(find.byKey(const Key('backup_passphrase_confirm')));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), <String>{ArvinBackupManager.directoryKey});
    expect(service.lastEncryptionPassphrase, 'memory-only-secret');
  });
}
