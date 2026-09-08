import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/home/home_visual_integration.dart';

void main() {
  testWidgets('renders canonical Home identity, search and add action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeVisualIntegration(
          body: SizedBox.shrink(),
          onAdd: null,
          onMenu: null,
          onNotifications: null,
        ),
      ),
    );

    expect(find.text('بسم الله الرحمن الرحیم'), findsOneWidget);
    expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-search')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-notifications')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-add')), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}

// Focused regression coverage for the canonical Home presentation shell.
