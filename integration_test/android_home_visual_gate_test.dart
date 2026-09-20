import 'package:arvin/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android Home visual gate - four grouping modes', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final skipGuide = find.text('رد کردن');
    if (skipGuide.evaluate().isNotEmpty) {
      await tester.tap(skipGuide);
      await tester.pumpAndSettle();
    }

    expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);
    expect(find.text('بسم الله الرحمن الرحیم'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-time')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-projects')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-categories')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-labels')), findsOneWidget);
    expect(find.text('کل'), findsNothing);
    expect(find.text('فعال'), findsNothing);
    expect(find.text('انجام‌شده'), findsNothing);
    expect(find.text('عقب‌افتاده'), findsNothing);
    expect(find.text('کارهای من'), findsNothing);
    expect(find.byKey(const ValueKey('home-group-mode-selector')), findsNothing);

    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();

    Future<void> capture(String mode) async {
      await binding.takeScreenshot('arvin-home-$mode');
    }

    await capture('time');

    for (final mode in <String>['projects', 'categories', 'labels']) {
      await tester.tap(find.byKey(ValueKey('home-main-view-$mode')));
      await tester.pumpAndSettle();
      await capture(mode);
    }
  });
}
