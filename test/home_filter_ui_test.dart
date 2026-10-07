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
  testWidgets('Home filter cards keep four Persian labels readable on a narrow phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  HomeFilterCard(
                    dimension: HomeFilterDimension.time,
                    title: 'زمان',
                    value: 'همه',
                    accent: ArvinColors.time,
                    soft: ArvinColors.timeSoft,
                    icon: Icons.schedule_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  HomeFilterCard(
                    dimension: HomeFilterDimension.project,
                    title: 'پروژه',
                    value: 'همه',
                    accent: ArvinColors.project,
                    soft: ArvinColors.projectSoft,
                    icon: Icons.folder_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  HomeFilterCard(
                    dimension: HomeFilterDimension.category,
                    title: 'دسته',
                    value: 'همه',
                    accent: ArvinColors.category,
                    soft: ArvinColors.categorySoft,
                    icon: Icons.layers_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  HomeFilterCard(
                    dimension: HomeFilterDimension.tags,
                    title: 'برچسب‌ها',
                    value: 'همه',
                    accent: ArvinColors.tag,
                    soft: ArvinColors.tagSoft,
                    icon: Icons.sell_rounded,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('زمان'), findsOneWidget);
    expect(find.text('پروژه'), findsOneWidget);
    expect(find.text('دسته'), findsOneWidget);
    expect(find.text('برچسب‌ها'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-time')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-project')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-category')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-filter-card-tags')), findsOneWidget);
  });

}
