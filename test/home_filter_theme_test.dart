import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/arvin_colors.dart';
import 'package:arvin/home/home_filter_ui.dart';

void main() {
  testWidgets('active Home filter pill uses the global turquoise selection token', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeFilterPill(
            label: 'زمان',
            icon: Icons.schedule,
            accent: Colors.deepPurple,
            soft: Colors.deepPurple.shade50,
            active: true,
            onPressed: () {},
          ),
        ),
      ),
    );

    final chip = tester.widget<ActionChip>(find.byType(ActionChip));
    expect(chip.backgroundColor, ArvinColors.primarySoft);
    expect(chip.side?.color, ArvinColors.primary.withAlpha(90));
    expect(tester.widget<Text>(find.text('زمان')).style?.color, ArvinColors.primary);
  });

  testWidgets('active Home filter cards and removable filter chips use turquoise', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Row(
                children: [
                  HomeFilterCard(
                    dimension: HomeFilterDimension.center,
                    title: 'مرکز',
                    value: 'مدرسه',
                    accent: Colors.deepPurple,
                    soft: Colors.deepPurple.shade50,
                    icon: Icons.business,
                    active: true,
                    onTap: () {},
                  ),
                ],
              ),
              HomeFilterChip(
                label: 'مدرسه',
                accent: Colors.deepPurple,
                soft: Colors.deepPurple.shade50,
                onRemove: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final selectedCard = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byKey(const ValueKey('home-filter-card-center')),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final cardDecoration = selectedCard.decoration! as BoxDecoration;
    expect(cardDecoration.border!.top.color, ArvinColors.primary.withAlpha(150));

    final chipContainer = tester.widget<Container>(
      find.ancestor(of: find.text('مدرسه'), matching: find.byType(Container)).first,
    );
    final chipDecoration = chipContainer.decoration! as BoxDecoration;
    expect(chipDecoration.color, ArvinColors.primarySoft);
    expect(chipDecoration.border!.top.color, ArvinColors.primary.withAlpha(65));
    expect(tester.widget<Text>(find.text('مدرسه')).style?.color, ArvinColors.primary);
  });
}
