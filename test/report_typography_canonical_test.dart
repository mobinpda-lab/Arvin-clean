import 'package:arvin/services/task_report_pdf_renderer.dart';
import 'package:arvin/services/task_report_projection.dart';
import 'package:arvin/theme/font_registry.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('canonical Vazirmatn report typography assets are bundled and loadable',
      () async {
    const regular = 'assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf';
    const medium = 'assets/fonts/ui/vazirmatn/Vazirmatn-Medium.ttf';
    const bold = 'assets/fonts/ui/vazirmatn/Vazirmatn-Bold.ttf';

    final regularBytes = await rootBundle.load(regular);
    final mediumBytes = await rootBundle.load(medium);
    final boldBytes = await rootBundle.load(bold);

    expect(regularBytes.lengthInBytes, greaterThan(1000));
    expect(mediumBytes.lengthInBytes, greaterThan(1000));
    expect(boldBytes.lengthInBytes, greaterThan(1000));
    expect(arvinFontById('vazirmatn').fontFamily, 'Vazirmatn');
    expect(
      kAvailableArvinFonts.map((font) => font.id).toList(),
      ['vazirmatn'],
    );
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
  });
}
