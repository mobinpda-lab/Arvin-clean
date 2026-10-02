import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/widgets/arvin_radio_box.dart';

void main() {
  testWidgets('semantic radio box keeps its family color before selection', (tester) async {
    const key = ValueKey('colorful-radio');
    const accent = Color(0xFF3568D4);
    const soft = Color(0xFFE8F0FF);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArvinRadioBox(
            key: key,
            label: 'پروژه‌ها',
            icon: Icons.folder_rounded,
            accent: accent,
            softAccent: soft,
            selected: false,
            onTap: () {},
          ),
        ),
      ),
    );

    final material = tester.widget<Material>(
      find.descendant(
        of: find.byKey(key),
        matching: find.byType(Material),
      ),
    );
    expect(material.color?.a, closeTo(0.62, 0.01));

    final icon = tester.widget<Icon>(find.byIcon(Icons.folder_rounded));
    expect(icon.color, accent);
  });

  testWidgets('selection strengthens the same semantic color family', (tester) async {
    const key = ValueKey('selected-colorful-radio');
    const accent = Color(0xFF7650C8);
    const soft = Color(0xFFF0EAFF);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArvinRadioBox(
            key: key,
            label: 'دسته‌ها',
            icon: Icons.grid_view_rounded,
            accent: accent,
            softAccent: soft,
            selected: true,
            onTap: () {},
          ),
        ),
      ),
    );

    final material = tester.widget<Material>(
      find.descendant(
        of: find.byKey(key),
        matching: find.byType(Material),
      ),
    );
    expect(material.color?.a, closeTo(0.95, 0.01));
  });
}
