import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/widgets/startup_crash_screen.dart';

void main() {
  testWidgets('shows the complete error and stack in a scrollable screen', (tester) async {
    const error = 'Startup database initialization failed';
    const stack = 'Database.open (database.dart:42)\nmain (main.dart:18)';

    await tester.pumpWidget(
      const MaterialApp(
        home: StartupCrashScreen(errorText: error, stackTrace: stack),
      ),
    );

    expect(find.text('گزارش خطای آروین'), findsOneWidget);
    expect(find.text(error), findsOneWidget);
    expect(find.text(stack), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(SelectionArea), findsOneWidget);
  });
}
