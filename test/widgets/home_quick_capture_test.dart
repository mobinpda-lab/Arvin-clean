import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/main.dart';

void main() {
  testWidgets('Home primary add persists canonical task and preserves history',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'arvin.tasks': jsonEncode([
        {
          'id': 'existing',
          'title': 'کار قبلی',
          'followUps': [
            {
              'id': 'f1',
              'dateTime': '2026-08-25T10:00:00.000',
              'note': 'تاریخچه محفوظ',
              'result': 'موفق',
              'nextFollowUp': null,
            },
          ],
        },
      ]),
    });

    await tester.pumpWidget(const ArvinApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-canonical-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('task-editor-title')),
      'تماس با علی',
    );
    await tester.enterText(
      find.byKey(const ValueKey('task-editor-tag')),
      'مهم',
    );
    await tester.tap(find.byKey(const ValueKey('task-editor-add-tag')));
    await tester.ensureVisible(find.byKey(const ValueKey('task-editor-save')));
    await tester.tap(find.byKey(const ValueKey('task-editor-save')));
    await tester.pumpAndSettle();

    expect(find.text('تماس با علی'), findsOneWidget);
    expect(find.text('مهم'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    final raw = jsonDecode(prefs.getString('arvin.tasks')!) as List<dynamic>;
    expect(raw, hasLength(2));
    final existing = Map<String, dynamic>.from(
      raw.firstWhere((item) => (item as Map)['id'] == 'existing') as Map,
    );
    final captured = Map<String, dynamic>.from(
      raw.firstWhere((item) => (item as Map)['title'] == 'تماس با علی') as Map,
    );

    expect(existing['followUps'], hasLength(1));
    expect(
      Map<String, dynamic>.from((existing['followUps'] as List).single as Map)['note'],
      'تاریخچه محفوظ',
    );
    expect(captured['tags'], ['مهم']);
    expect(DateTime.tryParse(captured['createdAt'] as String? ?? ''), isNotNull);
  });
}
