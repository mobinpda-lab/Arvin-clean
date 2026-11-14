import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';
import 'package:arvin/calendar_page.dart';
import 'package:arvin/theme/app_fonts.dart';

void _expectPathOnlySvgAsset(String assetPath) {
  final source = File(assetPath).readAsStringSync();

  // Rendering through SvgPicture below validates that flutter_svg can parse it.
  expect(
    source,
    matches(RegExp(r'^\s*<svg\b[^>]*>[\s\S]*</svg>\s*$')),
    reason: '$assetPath must be a complete SVG document',
  );
  expect(source, contains('xmlns="http://www.w3.org/2000/svg"'));

  final elements = RegExp(r'<\/?([A-Za-z][A-Za-z0-9:_-]*)\b')
      .allMatches(source)
      .map((match) => match.group(1))
      .toSet();
  expect(
    elements,
    equals(<String>{'svg', 'path'}),
    reason: '$assetPath must contain only SVG and vector path elements',
  );

  final paths = RegExp(r'<path\b([^>]*)>').allMatches(source);
  expect(paths, isNotEmpty, reason: '$assetPath must contain vector paths');
  for (final path in paths) {
    expect(
      path.group(1),
      matches(RegExp(r'\bd\s*=\s*"[^"]+"')),
      reason: '$assetPath path elements must have non-empty path data',
    );
  }

  final textContent = source.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  expect(
    textContent,
    isEmpty,
    reason: '$assetPath must not contain text content or metadata text',
  );
}

void main() {
  testWidgets(
    'Home and Calendar sacred phrases render path SVGs with single accessible labels',
    (tester) async {
      final semanticsHandle = tester.ensureSemantics();
      try {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        _expectPathOnlySvgAsset('assets/images/branding/bismillah.svg');
  
        await tester.pumpWidget(const ArvinApp());
        await tester.pump();
  
        const homeLabel = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
        final homePhrase = find.byKey(const ValueKey('home-bismillah'));
        expect(homePhrase, findsOneWidget);
        expect(
          tester.widget<Semantics>(homePhrase).properties.label,
          homeLabel,
        );
        expect(find.bySemanticsLabel(homeLabel), findsOneWidget);
        expect(find.byKey(const ValueKey('home-bismillah-svg')), findsOneWidget);
        final homeSvg = tester.widget<SvgPicture>(
          find.byKey(const ValueKey('home-bismillah-svg')),
        );
        expect(homeSvg.width, 118);
        expect(homeSvg.excludeFromSemantics, isTrue);
        expect(find.text(homeLabel), findsNothing);
        expect(
          find.byWidgetPredicate((widget) =>
              widget is SvgPicture &&
              (widget.bytesLoader as dynamic).assetName ==
                  'assets/images/branding/tafweez.svg'),
          findsNothing,
          reason: 'Calendar tafweez asset must not leak into Home',
        );
  
        _expectPathOnlySvgAsset('assets/images/branding/tafweez.svg');
  
        await tester.pumpWidget(
          MaterialApp(
            home: CalendarPage(
              reminders: const [],
              initialSelectedDay: DateTime(2026, 11, 5),
            ),
          ),
        );
        await tester.pump();
  
        const calendarLabel = 'وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ';
        final calendarPhrase =
            find.byKey(const ValueKey('calendar-sacred-header'));
        expect(calendarPhrase, findsOneWidget);
        expect(
          tester.widget<Semantics>(calendarPhrase).properties.label,
          calendarLabel,
        );
        expect(find.bySemanticsLabel(calendarLabel), findsOneWidget);
        expect(
          find.byKey(const ValueKey('calendar-sacred-header-svg')),
          findsOneWidget,
        );
        final calendarSvg = tester.widget<SvgPicture>(
          find.byKey(const ValueKey('calendar-sacred-header-svg')),
        );
        expect(calendarSvg.width, 180);
        expect(calendarSvg.excludeFromSemantics, isTrue);
        expect(find.text(calendarLabel), findsNothing);
        expect(
          find.byWidgetPredicate((widget) =>
              widget is SvgPicture &&
              (widget.bytesLoader as dynamic).assetName ==
                  'assets/images/branding/bismillah.svg'),
          findsNothing,
          reason: 'Home bismillah asset must not leak into Calendar',
        );
  
        expect(
          'Vazirmatn',
          'Vazirmatn',
        );
        expect('Vazirmatn', AppFonts.vazirmatnFamily);
        expect(tester.takeException(), isNull);
      } finally {
        semanticsHandle.dispose();
      }
    },
  );
}
