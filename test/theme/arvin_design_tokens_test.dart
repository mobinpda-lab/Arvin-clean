import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/theme/arvin_design_tokens.dart';

void main() {
  test('shared component dimensions respect the minimum touch target', () {
    expect(ArvinTouchTargets.minimum, 48);
    expect(ArvinButtonTokens.height, greaterThanOrEqualTo(ArvinTouchTargets.minimum));
    expect(ArvinButtonTokens.minimumWidth, greaterThanOrEqualTo(ArvinTouchTargets.minimum));
    expect(ArvinInputTokens.minimumHeight, greaterThanOrEqualTo(ArvinTouchTargets.minimum));
    expect(ArvinNavigationTokens.height, greaterThanOrEqualTo(ArvinTouchTargets.minimum));
  });

  test('component tokens resolve to the shared radius scale', () {
    expect(ArvinButtonTokens.radius, ArvinRadii.control);
    expect(ArvinInputTokens.radius, ArvinRadii.control);
    expect(ArvinCardTokens.radius, ArvinRadii.card);
    expect(ArvinDialogTokens.radius, ArvinRadii.dialog);
    expect(ArvinNavigationTokens.radius, ArvinRadii.navigation);
  });

  test('motion tokens provide fast standard and reduced-motion options', () {
    expect(ArvinMotion.fast.inMilliseconds, lessThan(ArvinMotion.standard.inMilliseconds));
    expect(ArvinMotion.standard.inMilliseconds, lessThan(ArvinMotion.slow.inMilliseconds));
    expect(ArvinMotion.reduced, Duration.zero);
    expect(ArvinMotion.standardCurve, Curves.easeOutCubic);
  });
}
