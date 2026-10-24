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

  testWidgets('Follow-up office records history without scheduling legacy dates',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {'id': 't1', 'title': 'مشتری', 'followUps': <Object>[]},
      ]),
    });
    final repository = const FollowUpRepository();
    final coordinator = FollowUpWriteCoordinator(repository: repository);

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
    await tester.enterText(find.byKey(const ValueKey('follow-up-entry-note')), 'تماس ثبت‌شده');
    await tester.tap(find.byKey(const ValueKey('follow-up-entry-save')));
    await tester.pumpAndSettle();

    expect(find.text('تماس ثبت‌شده'), findsOneWidget);
    expect(find.text('فقط پیگیری‌های موعدرسیده'), findsNothing);
  });
}
