import 'dart:convert';

import 'package:arvin/automatic_follow_up_scheduler_adapter.dart';
import 'package:arvin/follow_up_office_page.dart';
import 'package:arvin/follow_up_repository.dart';
import 'package:arvin/services/follow_up_write_coordinator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingScheduler implements AutomaticFollowUpSchedulerAdapter {
  int rescheduleCalls = 0;

  @override
  Future<void> reschedule() async {
    rescheduleCalls += 1;
  }

  @override
  Future<void> cancel() async {}
}

void main() {
  testWidgets('real FollowUp office add write requests alarm rescheduling',
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
    final scheduler = _RecordingScheduler();
    final repository = const FollowUpRepository();
    final coordinator = FollowUpWriteCoordinator(
      repository: repository,
      scheduler: scheduler,
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
    await tester.enterText(find.byType(TextField).first, 'تماس فردا');
    final save = find.text('ذخیره پیگیری');
    await tester.ensureVisible(save);
    await tester.pump();
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(scheduler.rescheduleCalls, 1);
    expect(find.text('تماس فردا'), findsOneWidget);
  });
}
