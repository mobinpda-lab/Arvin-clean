import 'dart:convert';

import 'package:arvin/follow_up_office_page.dart';
import 'package:arvin/follow_up_repository.dart';
import 'package:arvin/services/follow_up_write_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/services/task_store.dart';

void main() {
  setUp(() async {
    await TaskStore.resetTestDatabase();
  });
  testWidgets('real FollowUp office add write requests independent reminder rescheduling',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 't1',
          'title': 'مشتری',
          'followUps': <Object>[],
        },
      ]),
    });
    var reminderRescheduleCalls = 0;
    final repository = const FollowUpRepository();
    final coordinator = FollowUpWriteCoordinator(
      repository: repository,
      reminderReschedule: () async {
        reminderRescheduleCalls++;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: FollowUpOfficePage(
          repository: repository,
          writeCoordinator: coordinator,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('ثبت پیگیری'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('follow-up-entry-note')), 'تماس فردا');

    final save = find.byKey(const ValueKey('follow-up-entry-save'));
    expect(save, findsOneWidget);
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(reminderRescheduleCalls, 1);
    expect(find.text('تماس فردا'), findsOneWidget);
  });
}
