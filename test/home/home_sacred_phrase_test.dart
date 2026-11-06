import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
import 'package:arvin/calendar_page.dart';
import 'package:arvin/theme/app_fonts.dart';

void main() {
  testWidgets('Home and Calendar sacred phrases render path SVGs with single accessible labels', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const ArvinApp());
    await tester.pump();

    final homePhrase = find.byKey(const ValueKey('home-bismillah'));
    expect(homePhrase, findsOneWidget);
    expect(tester.widget<Semantics>(homePhrase).properties.label,
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
    expect(find.byKey(const ValueKey('home-bismillah-svg')), findsOneWidget);
    final homeSvg = tester.widget<SvgPicture>(
      find.byKey(const ValueKey('home-bismillah-svg')),
    );
    expect(homeSvg.width, 210);
    expect(homeSvg.excludeFromSemantics, isTrue);
    expect(find.text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'), findsNothing);

    final tafweezAsset = File('assets/images/branding/tafweez.svg').readAsStringSync();
    expect(tafweezAsset, contains('<title>وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ</title>'));

    await tester.pumpWidget(MaterialApp(
      home: CalendarPage(
        reminders: const [],
        initialSelectedDay: DateTime(2026, 11, 5),
      ),
    ));
    await tester.pump();

    final calendarPhrase = find.byKey(const ValueKey('calendar-sacred-header'));
    expect(calendarPhrase, findsOneWidget);
    expect(tester.widget<Semantics>(calendarPhrase).properties.label,
        'وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ');
    expect(find.byKey(const ValueKey('calendar-sacred-header-svg')), findsOneWidget);
    final calendarSvg = tester.widget<SvgPicture>(
      find.byKey(const ValueKey('calendar-sacred-header-svg')),
    );
    expect(calendarSvg.width, 240);
    expect(calendarSvg.excludeFromSemantics, isTrue);
    expect(find.text('وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ'), findsNothing);

    expect(AppFonts.familyForText('متن عادی رابط کاربری'), AppFonts.vazirmatnFamily);
    expect(AppFonts.familyForText('آروین'), AppFonts.vazirmatnFamily);
    expect(tester.takeException(), isNull);
  });
}
