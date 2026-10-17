import 'dart:io';

import 'package:arvin/services/task_report_pdf_renderer.dart';
import 'package:arvin/services/task_report_projection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('canonical report typography assets are bundled and loadable', () async {
    const assets = <String>[
      'assets/fonts/vazirmatn-ui-fd/fonts/ttf/Vazirmatn-UI-FD-Regular.ttf',
      'assets/fonts/vazirmatn-ui-fd/fonts/ttf/Vazirmatn-UI-FD-Medium.ttf',
      'assets/fonts/vazirmatn-ui-fd/fonts/ttf/Vazirmatn-UI-FD-SemiBold.ttf',
      'assets/fonts/vazirmatn-ui-fd/fonts/ttf/Vazirmatn-UI-FD-Bold.ttf',
    ];

    for (final asset in assets) {
      final bytes = await rootBundle.load(asset);
      expect(bytes.lengthInBytes, greaterThan(100000), reason: asset);
    }
  });

  test('default PDF renderer builds Persian report with canonical fonts', () async {
    final report = TaskReport(
      title: 'گزارش آروین',
      generatedAt: DateTime(2026, 8, 29, 11, 30),
      entries: const [
        TaskReportEntry(
          id: 'task-1',
          title: 'پیگیری قرارداد',
          description: 'نمونه متن فارسی برای کنترل تایپوگرافی گزارش',
          tags: ['گزارش'],
          checklist: [],
          followUps: [],
          completed: false,
        ),
      ],
    );

    final bytes = await TaskReportPdfRenderer().build(report);

    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    final pdfObjects = String.fromCharCodes(bytes);
    expect(pdfObjects, contains('/FontFile2'));
    expect(pdfObjects, contains('Vazirmatn'));

    final outputPath = Platform.environment['ARVIN_REPORT_PDF_OUTPUT'];
    if (outputPath != null && outputPath.isNotEmpty) {
      final output = File(outputPath);
      await output.parent.create(recursive: true);
      await output.writeAsBytes(bytes, flush: true);
    }
  });
}
