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
              'note': 'پیگیری پیش از ارتقا',
              'completed': true,
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
    expect(migrated.single.followUps.single.id, 'android-upgrade-follow-up');
    expect(migrated.single.followUps.single.note, 'پیگیری پیش از ارتقا');
    expect(migrated.single.followUps.single.completed, isTrue);
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
    expect(afterUpgrade.single.followUps.single.id, 'android-upgrade-follow-up');
    expect(afterUpgrade.single.checklist, <String>['مرحله ۱', 'مرحله ۲']);

    await freshStore.save(const <Task>[]);
  });
}
