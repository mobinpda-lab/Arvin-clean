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
    tester.view.physicalSize = const Size(800, 1800);
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
    await tester.scrollUntilVisible(
      prayerCard,
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    // Use an explicit long press so the gesture recognizer receives the full
    // hold duration on the visible card before the action sheet is asserted.
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

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PrayerCompletionStore.key), contains('completed'));

    // The action sheet closes after a selection. Reopen it before choosing the
    // independent "not completed" state; the card's subtitle is not the
    // authoritative persistence assertion for every all-day presentation.
    final updatedPrayerCard = find.byKey(
      const ValueKey('reminder-card-prayer-test-2026-09-15-fajr'),
    );
    await tester.ensureVisible(updatedPrayerCard);
    final secondGesture = await tester.startGesture(
      tester.getCenter(updatedPrayerCard),
    );
    await tester.pump(const Duration(milliseconds: 900));
    await secondGesture.up();
    await tester.pumpAndSettle();

    await tester.tap(find.text('قضا شد').last);
    await tester.pumpAndSettle();
    expect(prefs.getString(PrayerCompletionStore.key), contains('notCompleted'));
  });
}
