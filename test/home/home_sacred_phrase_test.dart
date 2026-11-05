import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
import 'package:arvin/calendar_page.dart';
import 'package:arvin/theme/app_fonts.dart';

void main() {
  testWidgets('Home Bismillah and Calendar text use Vazirmatn only until SVG assets are installed', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const ArvinApp());
    await tester.pump();

    final homePhrase = find.byKey(const ValueKey('home-bismillah'));
    expect(homePhrase, findsOneWidget);
    final homeStyle = tester.widget<Text>(homePhrase).style!;
    expect(homeStyle.fontFamily, AppFonts.vazirmatnFamily);
    expect(homeStyle.fontFamilyFallback, isNull);
    expect(homeStyle.fontWeight, FontWeight.w600);

    await tester.pumpWidget(MaterialApp(
      home: CalendarPage(
        reminders: const [],
        initialSelectedDay: DateTime(2026, 11, 5),
      ),
    ));
    await tester.pump();

    final calendarPhrase = find.byKey(const ValueKey('calendar-sacred-header'));
    expect(calendarPhrase, findsOneWidget);
    final calendarStyle = tester.widget<Text>(calendarPhrase).style!;
    expect(calendarStyle.fontFamily, AppFonts.sacredArabicFamily);
    expect(calendarStyle.fontFamilyFallback, isNull);
    expect(calendarStyle.fontWeight, FontWeight.w600);

    expect(AppFonts.familyForText('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'), AppFonts.sacredArabicFamily);
    expect(AppFonts.familyForText('أُفَوِّضُ أَمْرِی إِلَى اللَّهِ'), AppFonts.sacredArabicFamily);
    expect(AppFonts.familyForText('افوض امری الی الله'), AppFonts.sacredArabicFamily);
    expect(AppFonts.familyForText('متن عادی رابط کاربری'), AppFonts.vazirmatnFamily);
    expect(AppFonts.familyForText('آروین'), AppFonts.vazirmatnFamily);
    expect(tester.takeException(), isNull);
  });
}
