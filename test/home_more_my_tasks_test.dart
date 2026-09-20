import 'package:arvin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home keeps My Tasks out of the visible owner surface',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    expect(find.text('کارهای من'), findsNothing);
    expect(find.byKey(const ValueKey('home-four-main-views')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-time')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-projects')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-categories')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-main-view-labels')), findsOneWidget);
  });

  testWidgets('More keeps My Tasks as a secondary entry point',
      (tester) async {
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-menu')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-more-my-tasks')), findsOneWidget);
    expect(find.text('کارهای من'), findsOneWidget);
  });
}
