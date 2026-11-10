import 'package:arvin/widgets/arvin_home_primary_add_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home primary add action follows the active theme', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3A86EF))),
        home: Scaffold(
          floatingActionButton: ArvinHomePrimaryAddButton(
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('home-primary-add')), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('کار جدید'), findsNothing);

    final fab = tester.widget<FloatingActionButton>(
      find.byKey(const ValueKey('home-primary-add')),
    );
    expect(fab.backgroundColor, Theme.of(tester.element(find.byKey(const ValueKey('home-primary-add')))).colorScheme.primary);
    expect(fab.foregroundColor, Colors.white);

    await tester.tap(find.byKey(const ValueKey('home-primary-add')));
    expect(pressed, isTrue);
  });
}