import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';

void main() {
  testWidgets('Home Bismillah is the only Home phrase using the approved Naskh serif style', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final phrase = find.byKey(const ValueKey('home-bismillah'));
    expect(phrase, findsOneWidget);
    expect(
      tester.widget<Text>(phrase).style?.fontFamily,
      'serif',
    );
  });
}
