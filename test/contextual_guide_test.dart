import 'dart:io';

import 'package:arvin/widgets/contextual_help.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('contextual help stays hidden until the user asks for it',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ContextualHelpOverlay(
          title: 'راهنمای نمونه',
          buttonKey: ValueKey('sample-context-help'),
          steps: <ContextualHelpStep>[
            ContextualHelpStep(
              icon: Icons.touch_app_outlined,
              title: 'مرحله اول',
              body: 'توضیح مرحله اول',
            ),
            ContextualHelpStep(
              icon: Icons.done_outline,
              title: 'مرحله دوم',
              body: 'توضیح مرحله دوم',
            ),
          ],
          child: Scaffold(body: Center(child: Text('صفحه اصلی نمونه'))),
        ),
      ),
    );

    expect(find.text('راهنمای نمونه'), findsNothing);
    expect(find.text('صفحه اصلی نمونه'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('sample-context-help')));
    await tester.pumpAndSettle();

    expect(find.text('راهنمای نمونه'), findsOneWidget);
    expect(find.text('مرحله اول'), findsOneWidget);
    expect(find.text('مرحله دوم'), findsOneWidget);
    expect(find.byKey(const ValueKey('contextual-help-step-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('contextual-help-step-1')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('contextual-help-close')));
    await tester.pumpAndSettle();

    expect(find.text('راهنمای نمونه'), findsNothing);
  });

  test('calendar notebook and backup are wired to contextual help', () {
    final launcher =
        File('lib/widgets/canonical_calendar_launcher.dart').readAsStringSync();
    final settings = File('lib/settings_page.dart').readAsStringSync();

    expect(launcher, contains("ValueKey('calendar-context-help')"));
    expect(launcher, contains("title: 'راهنمای تقویم'"));
    expect(launcher, contains("ValueKey('notebook-context-help')"));
    expect(launcher, contains("title: 'راهنمای دفترچه'"));
    expect(settings, contains("ValueKey('backup-context-help')"));
    expect(settings, contains("title: 'راهنمای پشتیبان‌گیری'"));
  });

  test('parallel wave has an independent guide surface', () {
    final workflow =
        File('.github/workflows/parallel-wave.yml').readAsStringSync();

    expect(workflow, contains('typography, guide, release'));
    expect(workflow, contains('guide)'));
    expect(workflow, contains("-iname '*guide*test.dart'"));
    expect(workflow, contains("-iname '*help*test.dart'"));
  });
}
