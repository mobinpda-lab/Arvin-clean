import 'dart:convert';

import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('legacy storage upgrades into canonical SQL and survives a fresh store',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      TaskStore.key: jsonEncode(<Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'android-upgrade-task',
          'title': 'داده پیش از ارتقا',
          'description': 'اطلاعات کامل',
          'tags': <String>['مهم', 'فروش'],
          'category': 'فروش',
          'completed': true,
          'archived': false,
          'trashed': false,
          'followUpEnabled': true,
          'followUps': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'android-upgrade-follow-up',
              'dateTime': '2026-09-20T10:00:00.000Z',
              'title': 'تماس پیش از ارتقا',
              'note': 'پیگیری پیش از ارتقا',
              'result': 'منتظر پاسخ',
              'reminderDate': '2026-09-21T09:00:00.000Z',
              'nextFollowUp': '2026-09-22T11:00:00.000Z',
              'completed': true,
              'waitingForResponse': true,
              'personIds': <String>['legacy-person-1', 'legacy-person-2'],
            },
          ],
          'checklist': <String>['مرحله ۱', 'مرحله ۲'],
          'futureField': <String, dynamic>{'keep': 'unknown'},
        },
      ]),
    });

    // This is the first launch after an upgrade: legacy preferences exist,
    // while TaskStore must perform the one-way cutover to canonical SQL.
    final upgradeStore = TaskStore();
    final migrated = await upgradeStore.load();

    expect(migrated, hasLength(1));
    expect(migrated.single.id, 'android-upgrade-task');
    expect(migrated.single.title, 'داده پیش از ارتقا');
    expect(migrated.single.description, 'اطلاعات کامل');
    expect(migrated.single.tags, <String>['مهم', 'فروش']);
    expect(migrated.single.category, 'فروش');
    expect(migrated.single.completed, isTrue);
    final migratedFollowUp = migrated.single.followUps.single;
    expect(migratedFollowUp.id, 'android-upgrade-follow-up');
    expect(migratedFollowUp.title, 'تماس پیش از ارتقا');
    expect(migratedFollowUp.note, 'پیگیری پیش از ارتقا');
    expect(migratedFollowUp.result, 'منتظر پاسخ');
    expect(migratedFollowUp.reminderDate, DateTime.utc(2026, 9, 21, 9));
    expect(migratedFollowUp.nextFollowUp, DateTime.utc(2026, 9, 22, 11));
    expect(migratedFollowUp.waitingForResponse, isTrue);
    expect(migratedFollowUp.personIds, <String>['legacy-person-1', 'legacy-person-2']);
    expect(migratedFollowUp.completed, isTrue);
    expect(migrated.single.checklist, <String>['مرحله ۱', 'مرحله ۲']);

    // Legacy storage is deliberately changed after cutover. A fresh
    // TaskStore instance must still read canonical SQL, proving this is not
    // a same-instance cache test.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      TaskStore.key,
      jsonEncode(<Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'android-upgrade-task',
          'title': 'داده قدیمی تغییرکرده',
          'description': '',
          'tags': <String>[],
        },
      ]),
    );

    final freshStore = TaskStore();
    final afterUpgrade = await freshStore.load();

    expect(afterUpgrade, hasLength(1));
    expect(afterUpgrade.single.id, 'android-upgrade-task');
    expect(afterUpgrade.single.title, 'داده پیش از ارتقا');
    final reloadedFollowUp = afterUpgrade.single.followUps.single;
    expect(reloadedFollowUp.id, 'android-upgrade-follow-up');
    expect(reloadedFollowUp.title, 'تماس پیش از ارتقا');
    expect(reloadedFollowUp.note, 'پیگیری پیش از ارتقا');
    expect(reloadedFollowUp.result, 'منتظر پاسخ');
    expect(reloadedFollowUp.reminderDate, DateTime.utc(2026, 9, 21, 9));
    expect(reloadedFollowUp.nextFollowUp, DateTime.utc(2026, 9, 22, 11));
    expect(reloadedFollowUp.waitingForResponse, isTrue);
    expect(reloadedFollowUp.personIds, <String>['legacy-person-1', 'legacy-person-2']);
    expect(reloadedFollowUp.completed, isTrue);
    expect(afterUpgrade.single.checklist, <String>['مرحله ۱', 'مرحله ۲']);

    await freshStore.save(const <Task>[]);
  });
}
