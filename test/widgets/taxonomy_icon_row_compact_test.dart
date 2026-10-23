import 'package:arvin/widgets/taxonomy_icon_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('taxonomy chips fit a 320 logical-pixel viewport without overflow',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: TaxonomyIconRow(
                project: 'پروژه طولانی برای بررسی سرریز',
                category: 'دسته‌بندی بسیار طولانی',
                tags: <String>[
                  'برچسب طولانی اول',
                  'برچسب طولانی دوم',
                  'برچسب طولانی سوم',
                ],
                maxTags: 3,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('taxonomy-icon-row')), findsOneWidget);
    expect(find.byKey(const ValueKey('taxonomy-icon-row-project')), findsOneWidget);
    expect(find.byKey(const ValueKey('taxonomy-icon-row-category')), findsOneWidget);
  });
}
