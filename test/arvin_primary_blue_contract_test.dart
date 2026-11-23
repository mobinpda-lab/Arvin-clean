import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/arvin_colors.dart';

void main() {
  group('REV10 owner-locked Primary Blue', () {
    test('uses the exact canonical name', () {
      expect(ArvinColors.primaryName, 'Primary Blue');
    });

    test('uses the exact owner-approved HEX value', () {
      expect(ArvinColors.primary, const Color(0xFF4169A1));
    });
  });
}
