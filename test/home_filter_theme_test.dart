import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/home/home_filter_ui.dart';

const _accent = Color(0xFF3A86EF);

ThemeData _theme() => ThemeData(
      colorScheme: const ColorScheme.light(
        primary: _accent,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF232433),
        onSurfaceVariant: Color(0xFF666A80),
        outline: Color(0xFFD9ECEA),
      ),
    );

void main() {
  testWidgets('active Home filter pill follows the live theme accent and keeps a 48dp target',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: _theme(),
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

    final pill = find.byType(HomeFilterPill);
    final material = tester.widget<Material>(
      find.descendant(of: pill, matching: find.byType(Material)).first,
    );
    final scheme = _theme().colorScheme;
    expect(tester.getSize(pill).height, 48);
    expect(material.color, Color.alphaBlend(_accent.withAlpha(18), Colors.white));
    final shape = material.shape! as StadiumBorder;
    expect(shape.side.color, _accent.withAlpha(90));
    expect(
      tester.widget<Text>(find.text('زمان')).style?.color,
      scheme.primary,
    );
  });

  testWidgets('active Home filter cards and removable chips follow live accent',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: _theme(),
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

    final selectedCardContainers = tester
        .widgetList<AnimatedContainer>(
          find.descendant(
            of: find.byKey(const ValueKey('home-filter-card-center')),
            matching: find.byType(AnimatedContainer),
          ),
        )
        .toList(growable: false);
    expect(selectedCardContainers, isNotEmpty);
    final hasBrandBorder = selectedCardContainers.any((container) {
      final decoration = container.decoration;
      return decoration is BoxDecoration &&
          decoration.border?.top.color == _accent.withAlpha(150);
    });
    expect(hasBrandBorder, isTrue);

    final chipWidget = find.byType(HomeFilterChip).first;
    final chipContainer = tester.widget<Container>(
      find.descendant(of: chipWidget, matching: find.byType(Container)).first,
    );
    final chipDecoration = chipContainer.decoration! as BoxDecoration;
    expect(
      chipDecoration.color,
      Color.alphaBlend(_accent.withAlpha(18), Colors.white),
    );
    expect(chipDecoration.border!.top.color, _accent.withAlpha(65));
    expect(
      tester.widget<Text>(
        find.descendant(of: chipWidget, matching: find.text('مدرسه')),
      ).style?.color,
      _accent,
    );
  });
}
