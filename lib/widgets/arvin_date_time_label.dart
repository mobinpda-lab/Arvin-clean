import 'package:flutter/material.dart';

/// Renders Persian date and time together without accidental line wrapping.
///
/// A single row is preferred when the measured text fits at the current
/// accessibility text scale. On genuinely narrow constraints, the component
/// switches deliberately to a two-line layout rather than shrinking text or
/// clipping the time.
class ArvinDateTimeLabel extends StatelessWidget {
  const ArvinDateTimeLabel({
    super.key,
    required this.date,
    required this.time,
    this.timePrefix = '',
    this.style,
    this.spacing = 6,
  });

  final String date;
  final String time;
  final String timePrefix;
  final TextStyle? style;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final direction = Directionality.of(context);
        final scaler = MediaQuery.textScalerOf(context);
        final datePainter = TextPainter(
          text: TextSpan(text: date, style: style),
          textDirection: direction,
          textScaler: scaler,
          maxLines: 1,
        )..layout();
        final timeText = '$timePrefix$time';
        final timePainter = TextPainter(
          text: TextSpan(text: timeText, style: style),
          textDirection: direction,
          textScaler: scaler,
          maxLines: 1,
        )..layout();
        final requiredWidth = datePainter.width + spacing + timePainter.width;
        final fitsOneLine =
            !constraints.hasBoundedWidth || requiredWidth <= constraints.maxWidth;

        final dateWidget = Text(
          date,
          style: style,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        );
        final timeWidget = Text(
          timeText,
          style: style,
          maxLines: 1,
          softWrap: false,
        );

        if (fitsOneLine) {
          return Row(
            textDirection: direction,
            children: [
              Flexible(child: dateWidget),
              SizedBox(width: spacing),
              timeWidget,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            dateWidget,
            const SizedBox(height: 2),
            timeWidget,
          ],
        );
      },
    );
  }
}
