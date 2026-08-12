import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/backup_schedule_page.dart';

void main() {
  testWidgets('backup schedule page shows Persian controls', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BackupSchedulePage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('زمان‌بندی پشتیبان‌گیری'), findsOneWidget);
    expect(find.text('پشتیبان‌گیری خودکار'), findsOneWidget);
    expect(find.text('ذخیره تنظیمات'), findsOneWidget);
  });
}
