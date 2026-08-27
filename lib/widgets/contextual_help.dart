import 'package:flutter/material.dart';

class ContextualHelpStep {
  const ContextualHelpStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

Future<void> showContextualHelp(
  BuildContext context, {
  required String title,
  required List<ContextualHelpStep> steps,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.78,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              Row(
                children: [
                  const Icon(Icons.help_outline),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(sheetContext)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (var index = 0; index < steps.length; index++) ...[
                Card(
                  key: ValueKey('contextual-help-step-$index'),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          child: Text('${index + 1}'),
                        ),
                        const SizedBox(width: 10),
                        Icon(steps[index].icon),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                steps[index].title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(steps[index].body),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (index != steps.length - 1) const SizedBox(height: 6),
              ],
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const ValueKey('contextual-help-close'),
                onPressed: () => Navigator.of(sheetContext).pop(),
                icon: const Icon(Icons.done),
                label: const Text('متوجه شدم'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ContextualHelpOverlay extends StatelessWidget {
  const ContextualHelpOverlay({
    super.key,
    required this.child,
    required this.title,
    required this.steps,
    this.buttonKey,
  });

  final Widget child;
  final String title;
  final List<ContextualHelpStep> steps;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        PositionedDirectional(
          end: 12,
          top: 72,
          child: SafeArea(
            child: Material(
              elevation: 2,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: IconButton(
                key: buttonKey,
                tooltip: 'راهنمای این صفحه',
                onPressed: () => showContextualHelp(
                  context,
                  title: title,
                  steps: steps,
                ),
                icon: const Icon(Icons.help_outline),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
