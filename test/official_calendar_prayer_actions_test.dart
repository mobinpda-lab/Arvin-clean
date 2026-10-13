import 'package:arvin/calendar_official_reminders.dart';
import 'package:arvin/official_calendar_page.dart';
import 'package:arvin/services/prayer_completion_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _PrayerSource implements OfficialCalendarReminderSource {
  const _PrayerSource();

  @override
  Future<List<OfficialCalendarReminder>> load({required int year}) async => [
        OfficialCalendarReminder(
          id: 'prayer-test-2026-09-15-fajr',
          kind: OfficialReminderKind.prayerTime,
          title: 'نماز صبح',
          date: DateTime(2026, 9, 15, 5, 10),
        ),
      ];
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('prayer actions persist and refresh without task actions',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: OfficialCalendarPage(
          service: const OfficialCalendarReminderService([_PrayerSource()]),
          years: const [2026],
          initialSelectedDay: DateTime(2026, 9, 15),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final prayerCard = find.byKey(
      const ValueKey('reminder-card-prayer-test-2026-09-15-fajr'),
    );
    await tester.ensureVisible(prayerCard);
    // Keep the long-press gesture comfortably beyond the recognizer timeout;
    // this action menu must not depend on a borderline gesture duration.
    final gesture = await tester.startGesture(tester.getCenter(prayerCard));
    await tester.pump(const Duration(milliseconds: 900));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('ادا شد'), findsOneWidget);
    expect(find.text('قضا شد'), findsOneWidget);
    expect(find.text('تعویق'), findsNothing);
    expect(find.text('ویرایش'), findsNothing);
    expect(find.text('تبدیل به کار'), findsNothing);

    await tester.tap(find.text('ادا شد').last);
    await tester.pumpAndSettle();
    expect(find.text('ادا شد'), findsWidgets);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PrayerCompletionStore.key), contains('completed'));

    await tester.tap(find.text('قضا شد').last);
    await tester.pumpAndSettle();
    expect(prefs.getString(PrayerCompletionStore.key), contains('notCompleted'));
  });
}
