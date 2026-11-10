import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/widgets/today_focus_toggle_button.dart';

void main() {
  for (final width in [360.0, 390.0, 412.0]) {
    testWidgets('today focus action keeps 48dp target at ${width.toInt()}dp width', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 720));
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: TodayFocusToggleButton(
              key: const ValueKey('focus-toggle'),
              selected: false,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      ));

      final button = find.byKey(const ValueKey('focus-toggle'));
      final size = tester.getSize(button);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(find.byTooltip('افزودن به برگزیده‌های امروز'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(button);
      expect(tapped, isTrue);
      await tester.binding.setSurfaceSize(null);
    });
  }
}
