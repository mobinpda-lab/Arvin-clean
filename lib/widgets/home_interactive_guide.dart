import 'package:flutter/material.dart';

class HomeGuideTarget {
  const HomeGuideTarget({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final GlobalKey key;
  final String title;
  final String description;
  final IconData icon;
}

Future<bool> showHomeInteractiveGuide({
  required BuildContext context,
  required List<HomeGuideTarget> targets,
}) async {
  final resolved = <_ResolvedGuideTarget>[];
  for (final target in targets) {
    final targetContext = target.key.currentContext;
    final renderObject = targetContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) continue;
    final topLeft = renderObject.localToGlobal(Offset.zero);
    resolved.add(
      _ResolvedGuideTarget(
        rect: topLeft & renderObject.size,
        title: target.title,
        description: target.description,
        icon: target.icon,
      ),
    );
  }

  if (resolved.isEmpty || !context.mounted) return false;

  return await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, __, ___) => _HomeInteractiveGuideOverlay(
          targets: resolved,
        ),
        transitionBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ) ??
      false;
}

class _HomeInteractiveGuideOverlay extends StatefulWidget {
  const _HomeInteractiveGuideOverlay({required this.targets});

  final List<_ResolvedGuideTarget> targets;

  @override
  State<_HomeInteractiveGuideOverlay> createState() =>
      _HomeInteractiveGuideOverlayState();
}

class _HomeInteractiveGuideOverlayState
    extends State<_HomeInteractiveGuideOverlay> {
  int index = 0;

  void _next() {
    if (index >= widget.targets.length - 1) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => index += 1);
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.targets[index];
    final media = MediaQuery.of(context);
    final safeTop = media.padding.top + 16;
    final safeBottom = media.size.height - media.padding.bottom - 16;
    const cardEstimate = 220.0;

    var cardTop = target.rect.bottom + 18;
    if (cardTop + cardEstimate > safeBottom) {
      cardTop = target.rect.top - cardEstimate - 18;
    }
    if (cardTop < safeTop) cardTop = safeTop;

    return Material(
      type: MaterialType.transparency,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SpotlightPainter(
                  targetRect: target.rect.inflate(8),
                  overlayColor: Colors.black.withValues(alpha: 0.68),
                  borderColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Positioned(
              top: cardTop,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Card(
                  elevation: 12,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(child: Icon(target.icon, size: 20)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                target.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            Text('${index + 1}/${widget.targets.length}'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(target.description),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('رد کردن'),
                            ),
                            const Spacer(),
                            FilledButton.icon(
                              onPressed: _next,
                              icon: Icon(
                                index == widget.targets.length - 1
                                    ? Icons.check
                                    : Icons.arrow_back,
                              ),
                              label: Text(
                                index == widget.targets.length - 1
                                    ? 'تمام'
                                    : 'بعدی',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.targetRect,
    required this.overlayColor,
    required this.borderColor,
  });

  final Rect targetRect;
  final Color overlayColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final spotlightRRect = RRect.fromRectAndRadius(
      targetRect,
      const Radius.circular(14),
    );
    final hole = Path()..addRRect(spotlightRRect);
    final shade = Path.combine(PathOperation.difference, full, hole);

    canvas.drawPath(shade, Paint()..color = overlayColor);
    canvas.drawRRect(
      spotlightRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = borderColor,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.borderColor != borderColor;
  }
}

class _ResolvedGuideTarget {
  const _ResolvedGuideTarget({
    required this.rect,
    required this.title,
    required this.description,
    required this.icon,
  });

  final Rect rect;
  final String title;
  final String description;
  final IconData icon;
}
