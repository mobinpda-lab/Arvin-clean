import 'dart:convert';
import 'dart:io';

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

  test('PDF embeds Vazirmatn fonts and emits a reproducible Persian acceptance sample', () async {
    final report = TaskReport(
      title: 'گزارش پذیرش PDF آروین — Arvin PDF Acceptance',
      generatedAt: DateTime(2026, 11, 12, 13, 30),
      entries: const [
        TaskReportEntry(
          id: 'pdf-acceptance-task-1',
          title: 'پیگیری قرارداد Example Ltd. — نسخه v1.2.3',
          description: 'متن فارسی با نیم‌فاصله: می‌خواهم خانه‌ها را بررسی کنم. '
              'اعداد فارسی ۱۴۰۵/۰۸/۲۱ و ۱۲۳۴۵۶؛ اعداد انگلیسی 2026-11-12 و 123456. '
              'ترکیب فارسی و English mixed text باید خوانا بماند. '
              'این پاراگراف بلند برای بررسی شکست خطوط، جهت نوشتار و پیوستگی حروف فارسی '
              'در خروجی گزارش تولید شده است.',
          tags: ['آزمون PDF', 'نیم‌فاصله', 'RTL', 'Example'],
          checklist: ['متن عادی Regular', 'متن برجسته Bold'],
          followUps: [],
          completed: false,
        ),
      ],
    );

    final bytes = await TaskReportPdfRenderer().build(report);
    final rawPdf = latin1.decode(bytes, allowInvalid: true);

    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(rawPdf, contains('/FontFile2'),
        reason: 'The PDF must embed TrueType font programs, not reference external fonts.');
    expect(rawPdf, contains('/ToUnicode'),
        reason: 'Embedded fonts must include Unicode mappings for Persian extraction.');
    expect(rawPdf, contains('/FontDescriptor'));
    expect(rawPdf, contains('Vazirmatn'));

    final outputDirectory = Directory('build/arvin-command-07-a2/pdf');
    await outputDirectory.create(recursive: true);
    final sample = File('${outputDirectory.path}/vazirmatn-persian-acceptance.pdf');
    await sample.writeAsBytes(bytes, flush: true);
    stdout.writeln('ARVIN_PDF_ACCEPTANCE_SAMPLE_PATH=${sample.path}');
    stdout.writeln('ARVIN_PDF_ACCEPTANCE_SAMPLE_BYTES=${bytes.length}');
  });
}
