import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('due follow-up notification exposes the two direct background actions', () {
    final source =
        File('lib/automatic_follow_up_notification_service.dart').readAsStringSync();

    expect(source, contains("@pragma('vm:entry-point')"));
    expect(source, contains('notificationTapBackground'));
    expect(source, contains("arvinActionDone = 'arvin_action_done'"));
    expect(source, contains("arvinActionSnooze15 = 'arvin_action_snooze_15'"));
    expect(source, contains("'تأیید / انجام شد'"));
    expect(source, contains("'تعویق ۱۵ دقیقه'"));
    expect(source, contains('showsUserInterface: false'));
    expect(source, contains('onDidReceiveBackgroundNotificationResponse: notificationTapBackground'));
  });

  test('background actions mutate canonical TaskStore and re-arm the automatic planner', () {
    final source =
        File('lib/automatic_follow_up_notification_service.dart').readAsStringSync();

    expect(source, contains('final store = TaskStore()'));
    expect(source, contains('task.completed = true'));
    expect(source, contains('DateTime.now().add(const Duration(minutes: 15))'));
    expect(source, contains('await store.save(tasks)'));
    expect(source, contains('AndroidAutomaticFollowUpScheduler().reschedule()'));
    expect(source, contains('await notifications.cancel(id: details.id!)'));
  });

  test('keep-screen-on is persisted, portable, and defaults off', () {
    final settings =
        File('lib/services/app_settings_service.dart').readAsStringSync();
    final page = File('lib/settings_page.dart').readAsStringSync();
    final main = File('lib/main.dart').readAsStringSync();

    expect(settings, contains("_keepScreenOnKey = 'arvin.settings.keepScreenOn'"));
    expect(settings, contains('this.keepScreenOn = false'));
    expect(settings, contains("'keepScreenOn': settings.keepScreenOn"));
    expect(settings, contains('rawKeepScreenOn'));
    expect(page, contains('روشن ماندن صفحه هنگام استفاده از برنامه'));
    expect(page, contains('WakelockPlus.toggle(enable: value)'));
    expect(main, contains('didChangeAppLifecycleState'));
  });

  test('notification implementation does not request full-screen intent', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, isNot(contains('USE_FULL_SCREEN_INTENT')));
  });
}
