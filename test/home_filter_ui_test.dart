import 'package:arvin/arvin_colors.dart';
import 'package:arvin/home/home_filter_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home filter opens as an Arvin bottom sheet', (tester) async {
    late BuildContext buttonContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              buttonContext = context;
              return FilledButton(
                key: const ValueKey('open-home-filter'),
                onPressed: () => HomeFilterSheet.show<void>(
                  buttonContext,
                  title: 'انتخاب زمان',
                  accent: ArvinColors.time,
                  child: const Center(child: Text('گزینه‌های زمان')),
                ),
                child: const Text('فیلتر زمان'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('open-home-filter')));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('انتخاب زمان'), findsOneWidget);
    expect(find.text('گزینه‌های زمان'), findsOneWidget);
    expect(find.byTooltip('بستن'), findsOneWidget);

    await tester.tap(find.byTooltip('بستن'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(find.text('انتخاب زمان'), findsNothing);
  });
}
