import 'package:flutter/material.dart';

/// Shared compact RTL-safe wrapping layout for Arvin's canonical task selectors.
/// Uses vertical wrapping and never introduces horizontal scrolling.
class ArvinTaskSelectorWrap extends StatelessWidget {
  const ArvinTaskSelectorWrap({
    super.key,
    required this.children,
    this.spacing = 6,
    this.runSpacing = 6,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) => Wrap(
        textDirection: TextDirection.rtl,
        alignment: WrapAlignment.start,
        spacing: spacing,
        runSpacing: runSpacing,
        children: children,
      );
}
