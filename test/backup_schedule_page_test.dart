import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/backup_manager.dart';
import 'package:arvin/backup_schedule.dart';
import 'package:arvin/backup_schedule_page.dart';
import 'package:arvin/backup_scheduler_adapter.dart';

class _RecordingScheduler implements BackupSchedulerAdapter {
  BackupSchedule? scheduled;
  bool cancelled = false;

  @override
  Future<void> schedule(BackupSchedule schedule) async {
    scheduled = schedule;
  }

  @override
  Future<void> cancel() async {
    cancelled = true;
  }
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required _RecordingScheduler scheduler,
  bool enabled = true,
  String? directory = 'content://backup-folder',
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(BackupSchedule.enabledKey, enabled);
  if (directory != null) {
    await prefs.setString(ArvinBackupManager.directoryKey, directory);
  }

  await tester.pumpWidget(
    MaterialApp(
      home: BackupSchedulePage(
        scheduler: scheduler,
        loadTasks: () async => <Map<String, dynamic>>[],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('backup schedule page shows Persian controls', (tester) async {
    final scheduler = _RecordingScheduler();
    await _pumpPage(tester, scheduler: scheduler);

    expect(find.text('زمان‌بندی پشتیبان‌گیری'), findsOneWidget);
    expect(find.text('پشتیبان‌گیری خودکار'), findsOneWidget);
    expect(find.text('ذخیره تنظیمات'), findsOneWidget);
  });

  testWidgets('saving an enabled schedule calls the scheduler', (tester) async {
    final scheduler = _RecordingScheduler();
    await _pumpPage(tester, scheduler: scheduler, enabled: true);

    await tester.tap(find.text('ذخیره تنظیمات'));
    await tester.pumpAndSettle();

    expect(scheduler.scheduled, isNotNull);
    expect(scheduler.scheduled!.enabled, isTrue);
    expect(scheduler.cancelled, isFalse);
  });

  testWidgets('enabled schedule without a directory is not scheduled', (tester) async {
    final scheduler = _RecordingScheduler();
    await _pumpPage(tester, scheduler: scheduler, directory: null);

    await tester.tap(find.text('ذخیره تنظیمات'));
    await tester.pumpAndSettle();

    expect(scheduler.scheduled, isNull);
    expect(
      find.text('برای پشتیبان‌گیری خودکار ابتدا پوشه پشتیبان را انتخاب کنید'),
      findsOneWidget,
    );
  });

  testWidgets('saving a disabled schedule cancels the scheduler', (tester) async {
    final scheduler = _RecordingScheduler();
    await _pumpPage(tester, scheduler: scheduler, enabled: false);

    await tester.tap(find.text('ذخیره تنظیمات'));
    await tester.pumpAndSettle();

    expect(scheduler.scheduled, isNull);
    expect(scheduler.cancelled, isTrue);
  });
}
