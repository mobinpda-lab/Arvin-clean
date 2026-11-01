import 'package:arvin/alarm_overlay_page.dart';
import 'package:arvin/main.dart' as app;
import 'package:arvin/models/task.dart';
import 'package:arvin/services/task_store.dart';
import 'package:arvin/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class _NoopAlarmNotifications implements AlarmOverlayNotificationController {
  @override
  Future<void> cancel(int notificationId) async {}
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android renders the dedicated Alarm Overlay with Vazirmatn and Persian Reminder time',
    (tester) async {
      final store = TaskStore();
      await store.save(<Task>[
        Task(
          id: 'device-alarm-smoke-task',
          title: 'آزمون نمایش یادآور روی دستگاه',
          createdAt: DateTime(2026, 11, 1, 8),
          taskReminders: <TaskReminder>[
            TaskReminder(
              id: 'device-alarm-smoke-reminder',
              title: 'یادآور آزمایشی',
              date: DateTime(2026, 11, 1, 9, 54),
              sequence: 1,
            ),
          ],
          nextReminderSequence: 2,
        ),
      ]);

      app.main();
      await _pumpFrames(tester, frames: 15);

      final skipGuide = find.text('رد کردن');
      if (skipGuide.evaluate().isNotEmpty) {
        await tester.tap(skipGuide);
        await _pumpFrames(tester);
      }

      final navigator = app.arvinNavigatorKey.currentState;
      expect(navigator, isNotNull);
      navigator!.push<void>(
        MaterialPageRoute<void>(
          builder: (_) => AlarmOverlayPage(
            taskId: 'device-alarm-smoke-task',
            taskReminderId: 'device-alarm-smoke-reminder',
            notificationId: 7101,
            taskStore: store,
            notificationController: _NoopAlarmNotifications(),
            rescheduleReminders: () async {},
          ),
        ),
      );
      await _pumpFrames(tester);

      expect(find.byKey(const ValueKey('alarm-overlay-stop')), findsOneWidget);
      expect(find.byKey(const ValueKey('alarm-overlay-task-title')), findsOneWidget);
      expect(find.byKey(const ValueKey('alarm-overlay-reminder-time')), findsOneWidget);
      expect(find.textContaining('۰۹:۵۴'), findsOneWidget);
      expect(find.text('تعویق یادآور'), findsOneWidget);
      expect(find.byKey(const ValueKey('alarm-overlay-volume-row')), findsOneWidget);

      final title = tester.widget<Text>(
        find.byKey(const ValueKey('alarm-overlay-task-title')),
      );
      expect(title.style?.fontFamily, AppFonts.vazirmatnFamily);

      await binding.convertFlutterSurfaceToImage();
      await _pumpFrames(tester);
      await binding.takeScreenshot('alarm-overlay-top');

      final followUp = find.byKey(const ValueKey('alarm-overlay-follow-up'));
      await tester.scrollUntilVisible(
        followUp,
        100,
        scrollable: find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Scrollable),
        ),
      );
      await _pumpFrames(tester);
      expect(followUp.hitTestable(), findsOneWidget);
      await binding.takeScreenshot('alarm-overlay-follow-up');
    },
  );
}


Future<void> _pumpFrames(
  WidgetTester tester, {
  int frames = 5,
}) async {
  for (var frame = 0; frame < frames; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
