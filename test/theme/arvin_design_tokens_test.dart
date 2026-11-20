import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/theme/arvin_design_tokens.dart';
import 'package:arvin/widgets/arvin_primary_navigation.dart';

void main() {
  test('shared spacing, radius, motion and touch tokens are valid', () {
    expect(ArvinSpacing.x1, 4);
    expect(ArvinSpacing.x2, 8);
    expect(ArvinSpacing.x3, 12);
    expect(ArvinRadii.navigation, 18);
    expect(ArvinMotion.standard, const Duration(milliseconds: 220));
    expect(ArvinTouchTargets.minimum, 48);
    expect(ArvinTypography.caption, 10.5);
  });

  testWidgets('primary navigation consumes the shared visual tokens', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: ArvinPrimaryNavigation(
            selected: ArvinPrimaryDestination.home,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    final item = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    expect(item.duration, ArvinMotion.standard);
    final decoration = item.decoration! as BoxDecoration;
    expect(
      decoration.borderRadius,
      BorderRadius.circular(ArvinRadii.navigation),
    );

    final caption = tester.widget<Text>(
      find.text('خانه'),
    );
    expect(caption.style?.fontSize, ArvinTypography.caption);

    expect(
      find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 60,
      ),
      findsOneWidget,
    );
    expect(ArvinTouchTargets.minimum, lessThanOrEqualTo(60));
  });
}
