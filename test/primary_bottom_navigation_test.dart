import 'dart:io';

import 'package:arvin/widgets/arvin_primary_navigation.dart';
import 'package:arvin/arvin_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('primary navigation exposes exactly five canonical destinations',
      (tester) async {
    var selected = ArvinPrimaryDestination.home;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            bottomNavigationBar: ArvinPrimaryNavigation(
              selected: selected,
              onSelected: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );

    expect(find.text('خانه'), findsOneWidget);
    expect(find.text('تقویم'), findsOneWidget);
    expect(find.text('دفترچه'), findsOneWidget);
    expect(find.text('گزارش‌ها'), findsOneWidget);
    expect(find.text('اقدام بعدی'), findsNothing);
    expect(find.byType(Expanded), findsNWidgets(5));
    expect(find.text('بیشتر'), findsOneWidget);
    final iconColors = tester.widgetList<Icon>(find.byType(Icon)).take(5).map((icon) => icon.color).toSet();
    expect(iconColors, hasLength(5));
    expect(iconColors, containsAll(const [Color(0xFF0F766E), Color(0xFF2A9D8F), Color(0xFFC76B16), Color(0xFF8E6CCF), Color(0xFF219EBC)]));


    await tester.tap(find.text('تقویم'));
    await tester.pump();

    expect(selected, ArvinPrimaryDestination.calendar);

    await tester.tap(find.text('دفترچه'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(selected, ArvinPrimaryDestination.notebook);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.note_alt_rounded)).color,
      const Color(0xFFC76B16),
    );
  });

  test('Home keeps primary navigation except during multi-select actions', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains("import 'widgets/arvin_primary_navigation.dart';"));
    expect(source, contains('selected: ArvinPrimaryDestination.home'));
    expect(source, contains('onSelected: _onPrimaryDestinationSelected'));
    expect(source, contains('ArvinPrimaryPageShell('));
    expect(source, contains('_primaryNotebookShell'));
    expect(source, isNot(contains('_primaryNextActionShell')));
    expect(source, isNot(contains('home-more-next-action')));
    expect(source, isNot(contains('ArvinPrimaryDestination.nextAction')));
    expect(source, contains('FilledButton.icon('));
    expect(source, contains('TaskBulkSelectionBar('));
  });
  test('Notebook orange icon maintains at least 3:1 contrast on light navigation surfaces', () {
    const notebookOrange = Color(0xFFC76B16);
    const lightSurfaces = [
      ArvinColors.surface,
      ArvinColors.background,
      ArvinColors.primarySoft,
      Color(0xFFF0F5FC),
    ];

    for (final surface in lightSurfaces) {
      final foregroundLuminance = notebookOrange.computeLuminance();
      final backgroundLuminance = surface.computeLuminance();
      final lighter = foregroundLuminance > backgroundLuminance
          ? foregroundLuminance
          : backgroundLuminance;
      final darker = foregroundLuminance > backgroundLuminance
          ? backgroundLuminance
          : foregroundLuminance;
      final ratio = (lighter + 0.05) / (darker + 0.05);
      expect(ratio, greaterThanOrEqualTo(3.0));
    }
  });

}
