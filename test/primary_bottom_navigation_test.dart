import 'dart:io';

import 'package:arvin/widgets/arvin_primary_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('primary navigation exposes the five canonical destinations',
      (tester) async {
    ArvinPrimaryDestination? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: ArvinPrimaryNavigation(
            selected: ArvinPrimaryDestination.home,
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    expect(find.text('خانه'), findsOneWidget);
    expect(find.text('تقویم'), findsOneWidget);
    expect(find.text('دفترچه'), findsOneWidget);
    expect(find.text('اقدام بعدی'), findsOneWidget);
    expect(find.text('بیشتر'), findsOneWidget);

    await tester.tap(find.text('تقویم'));
    await tester.pump();

    expect(selected, ArvinPrimaryDestination.calendar);
  });

  test('Home keeps primary navigation except during multi-select actions', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(source, contains("import 'widgets/arvin_primary_navigation.dart';"));
    expect(source, contains('selected: ArvinPrimaryDestination.home'));
    expect(source, contains('onSelected: _onPrimaryDestinationSelected'));
    expect(source, contains('ArvinPrimaryPageShell('));
    expect(source, contains('_primaryNotebookShell'));
    expect(source, contains('_primaryNextActionShell'));
    expect(source, contains('FilledButton.icon('));
    expect(source, contains('FilledButton.tonalIcon('));
  });
}
