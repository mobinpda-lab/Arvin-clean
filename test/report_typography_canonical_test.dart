import 'package:arvin/services/task_report_pdf_renderer.dart';
import 'package:arvin/services/task_report_projection.dart';
import 'package:arvin/theme/font_registry.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Vazirmatn five-weight fonts and OFL license are bundled',
      () async {
    const light = 'assets/fonts/ui/vazirmatn/Vazirmatn-Light.ttf';
    const regular = 'assets/fonts/ui/vazirmatn/Vazirmatn-Regular.ttf';
    const medium = 'assets/fonts/ui/vazirmatn/Vazirmatn-Medium.ttf';
    const semiBold = 'assets/fonts/ui/vazirmatn/Vazirmatn-SemiBold.ttf';
    const bold = 'assets/fonts/ui/vazirmatn/Vazirmatn-Bold.ttf';

    final lightBytes = await rootBundle.load(light);
    final regularBytes = await rootBundle.load(regular);
    final mediumBytes = await rootBundle.load(medium);
    final semiBoldBytes = await rootBundle.load(semiBold);
    final boldBytes = await rootBundle.load(bold);
    final license = await rootBundle.loadString('assets/fonts/ui/vazirmatn/LICENSE.txt');

    expect(lightBytes.lengthInBytes, greaterThan(1000));
    expect(regularBytes.lengthInBytes, greaterThan(1000));
    expect(mediumBytes.lengthInBytes, greaterThan(1000));
    expect(semiBoldBytes.lengthInBytes, greaterThan(1000));
    expect(boldBytes.lengthInBytes, greaterThan(1000));
    expect(license, contains('SIL OPEN FONT LICENSE Version 1.1'));
    expect(arvinFontById('vazirmatn').fontFamily, 'Vazirmatn');
    expect(
      kAvailableArvinFonts.map((font) => font.id).toList(),
      ['vazirmatn', 'system-default'],
    );
  });

  test('default PDF renderer embeds canonical Persian Vazirmatn fonts', () async {
    final report = TaskReport(
      title: 'گزارش آروین',
      generatedAt: DateTime(2026, 8, 29, 11, 30),
      entries: const [
        TaskReportEntry(
          id: 'task-1',
          title: 'پیگیری قرارداد ۱۲۳، ۴۵۶؟',
          description: 'نمونه متن فارسی و اعداد فارسی برای کنترل تایپوگرافی گزارش',
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
