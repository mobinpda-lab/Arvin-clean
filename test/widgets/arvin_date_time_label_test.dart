import 'package:arvin/widgets/arvin_date_time_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({required double width, double textScale = 1}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 700),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SizedBox(
              width: width,
              child: const ArvinDateTimeLabel(
                date: 'سه‌شنبه ۲۱ مهر ۱۴۰۵',
                time: '۰۹:۳۰',
                timePrefix: 'ساعت ',
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('keeps date and time in one row when the measured text fits',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 800));
    await tester.pumpWidget(host(width: 560));

    expect(find.byType(ArvinDateTimeLabel), findsOneWidget);
    expect(find.descendant(
      of: find.byType(ArvinDateTimeLabel),
      matching: find.byType(Row),
    ), findsOneWidget);
    expect(find.text('سه‌شنبه ۲۱ مهر ۱۴۰۵'), findsOneWidget);
    expect(find.text('ساعت ۰۹:۳۰'), findsOneWidget);
  });

  testWidgets('uses an explicit stacked fallback when width or accessibility scale prevents fit',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(190, 800));
    await tester.pumpWidget(host(width: 160, textScale: 1.8));

    expect(find.descendant(
      of: find.byType(ArvinDateTimeLabel),
      matching: find.byType(Column),
    ), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
