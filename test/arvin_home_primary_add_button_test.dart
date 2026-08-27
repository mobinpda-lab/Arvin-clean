import 'package:arvin/widgets/arvin_home_primary_add_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home primary add action is compact circular indigo plus',
      (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
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
    expect(fab.backgroundColor, ArvinHomePrimaryAddButton.brandColor);
    expect(fab.foregroundColor, Colors.white);

    await tester.tap(find.byKey(const ValueKey('home-primary-add')));
    expect(pressed, isTrue);
  });
}
