import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';

void main() {
  testWidgets('Home filters combine OR within each dimension and AND across dimensions', (tester) async {
    final today = DateTime(2026, 11, 5, 10);
    final due = today.toIso8601String();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'arvin.tasks': '''
[
  {"id":"personal-home","title":"شخصی خانه","dueDate":"$due","category":"شخصی","tags":["خانه"]},
  {"id":"work-home","title":"کاری خانه","dueDate":"$due","category":"کاری","tags":["خانه"]},
  {"id":"personal-office","title":"شخصی اداری","dueDate":"$due","category":"شخصی","tags":["اداری"]},
  {"id":"work-office","title":"کاری اداری","dueDate":"$due","category":"کاری","tags":["اداری"]},
  {"id":"other-home","title":"سایر خانه","dueDate":"$due","category":"سایر","tags":["خانه"]},
  {"id":"personal-other","title":"شخصی متفرقه","dueDate":"$due","category":"شخصی","tags":["متفرقه"]}
]
''',
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    final categoryFilter = find.byKey(const ValueKey('home-filter-card-category'));
    await tester.ensureVisible(categoryFilter);
    await tester.tap(categoryFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'شخصی'));
    await tester.tap(find.widgetWithText(CheckboxListTile, 'کاری'));
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();

    final tagFilter = find.byKey(const ValueKey('home-filter-card-tags'));
    await tester.ensureVisible(tagFilter);
    await tester.tap(tagFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'خانه'));
    await tester.tap(find.widgetWithText(CheckboxListTile, 'اداری'));
    await tester.tap(find.text('تأیید / اعمال فیلتر'));
    await tester.pumpAndSettle();

    expect(find.text('شخصی خانه'), findsOneWidget);
    expect(find.text('کاری خانه'), findsOneWidget);
    expect(find.text('شخصی اداری'), findsOneWidget);
    expect(find.text('کاری اداری'), findsOneWidget);
    expect(find.text('سایر خانه'), findsNothing);
    expect(find.text('شخصی متفرقه'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
