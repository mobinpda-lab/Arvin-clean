import 'package:flutter/material.dart';

/// Presentation-only canonical Home shell. Existing Task/FollowUp data paths
/// remain owned by the real Home route; this widget adds no persistence.
class HomeVisualIntegration extends StatelessWidget {
  const HomeVisualIntegration({super.key, required this.body, this.onAdd});

  final Widget body;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Center(
                child: Text(
                  'آروین',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('home-canonical-add'),
        onPressed: onAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}
