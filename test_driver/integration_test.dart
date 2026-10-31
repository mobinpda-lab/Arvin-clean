import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (
      String screenshotName,
      List<int> screenshotBytes, [
      Map<String, Object?>? args,
    ]) async {
      // Screenshot bytes are delivered to the host-side integration
      // driver, so create the artifact directory on the runner (not inside
      // the Android app sandbox) before writing the exact workflow path.
      final outputDirectory = Directory('artifacts/device-smoke');
      await outputDirectory.create(recursive: true);
      final file = File('${outputDirectory.path}/$screenshotName.png');
      await file.writeAsBytes(screenshotBytes, flush: true);
      if (!await file.exists() || await file.length() == 0) {
        throw FileSystemException('Screenshot artifact was not written', file.path);
      }
      // Keep the upload contract visible in the driver log for auditability.
      // For the calendar scenario this resolves to:
      // artifacts/device-smoke/calendar-card-independent-reminder-edit.png
      // ignore: avoid_print
      print('SCREENSHOT_ARTIFACT_WRITTEN=${file.path}');
      return true;
    },
  );
}
