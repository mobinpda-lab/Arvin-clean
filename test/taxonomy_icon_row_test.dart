import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/widgets/taxonomy_icon_row.dart';

void main() {
  testWidgets('taxonomy icon row keeps project category and tags adjacent', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TaxonomyIconRow(
            project: 'تجهیز اتاق',
            category: 'اتاق آبدارخانه',
            tags: <String>['دهنوی', 'مهم'],
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('taxonomy-icon-row')), findsOneWidget);
    expect(find.byKey(const ValueKey('taxonomy-icon-row-project')), findsOneWidget);
    expect(find.byKey(const ValueKey('taxonomy-icon-row-category')), findsOneWidget);
    expect(find.byKey(const ValueKey('taxonomy-icon-row-tag-دهنوی')), findsOneWidget);
    expect(find.byKey(const ValueKey('taxonomy-icon-row-tag-مهم')), findsOneWidget);
  });

  testWidgets('taxonomy icon row does not create empty taxonomy chips', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TaxonomyIconRow(),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('taxonomy-icon-row')), findsNothing);
  });
}
