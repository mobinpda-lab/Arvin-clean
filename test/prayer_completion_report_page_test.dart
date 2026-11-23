import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arvin/prayer_completion_report_page.dart';
import 'package:arvin/services/prayer_completion_projection.dart';
import 'package:arvin/services/prayer_completion_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets('report shows today counts and missed prayer list', (tester) async {
    const store = PrayerCompletionStore();
    await store.setStatus(day: DateTime(2026, 9, 15), prayerId: 'prayer-tehran-2026-09-15-fajr', status: PrayerCompletionStatus.completed, updatedAt: DateTime(2026, 9, 15, 8));
    await store.setStatus(day: DateTime(2026, 9, 15), prayerId: 'prayer-tehran-2026-09-15-dhuhr', status: PrayerCompletionStatus.notCompleted, updatedAt: DateTime(2026, 9, 15, 13));
    await tester.pumpWidget(MaterialApp(home: PrayerCompletionReportPage(store: store, now: DateTime(2026, 9, 15, 14))));
    await tester.pumpAndSettle();
    expect(find.text('گزارش نماز'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('prayer-report-completed')), matching: find.text('۱')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('prayer-report-missed')), matching: find.text('۱')), findsOneWidget);
    expect(find.text('اذان ظهر'), findsOneWidget);
    expect(find.text('قضا شد'), findsWidgets);
  });

  testWidgets('range scope exposes Persian date controls', (tester) async {
    await tester.pumpWidget(MaterialApp(home: PrayerCompletionReportPage(now: DateTime(2026, 9, 15))));
    await tester.pumpAndSettle();
    await tester.tap(find.text('بازه'));
    await tester.pump();
    expect(find.byKey(const ValueKey('prayer-report-range-start')), findsOneWidget);
    expect(find.byKey(const ValueKey('prayer-report-range-end')), findsOneWidget);
  });
}
