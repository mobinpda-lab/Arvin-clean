import 'package:flutter/material.dart';

/// Canonical Home primary add action.
///
/// The owner-approved Home reference uses a compact circular indigo `+`, not
/// an extended text FAB. Integration into Home remains a separate small slice
/// so this visual component can validate independently.
class ArvinHomePrimaryAddButton extends StatelessWidget {
  const ArvinHomePrimaryAddButton({
    super.key,
    required this.onPressed,
  });

  static const Color brandColor = Color(0xFF4A4CAB);

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: const ValueKey('home-primary-add'),
      onPressed: onPressed,
      tooltip: 'افزودن کار جدید',
      backgroundColor: brandColor,
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add, size: 30),
    );
  }
}
