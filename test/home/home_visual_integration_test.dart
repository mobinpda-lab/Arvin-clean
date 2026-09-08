import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/home/home_visual_integration.dart';

void main() {
  testWidgets('renders canonical Home title and circular add action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeVisualIntegration(
          body: const SizedBox.shrink(),
          onAdd: null,
        ),
      ),
    );

    expect(find.text('آروین'), findsOneWidget);
    expect(find.byKey(const Key('home-canonical-add')), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
