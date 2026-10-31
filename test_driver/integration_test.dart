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
      try {
        final outputDirectory = Directory('artifacts/device-smoke');
        // Screenshot bytes are delivered to the host-side integration
        // driver, so create the artifact directory on the runner (not inside
        // the Android app sandbox) before writing the exact workflow path.
        await outputDirectory.create(recursive: true);
        if (screenshotBytes.isEmpty) {
          // ignore: avoid_print
          print('WARNING: screenshot capture returned empty bytes for $screenshotName; continuing without artifact.');
          return false;
        }
        final file = File('${outputDirectory.path}/$screenshotName.png');
        await file.writeAsBytes(screenshotBytes, flush: true);
        if (!await file.exists() || await file.length() == 0) {
          // ignore: avoid_print
          print('WARNING: screenshot artifact was not written or is empty: ${file.path}; continuing without artifact.');
          return false;
        }
        // Keep the upload contract visible in the driver log for auditability.
        // For the calendar scenario this resolves to:
        // artifacts/device-smoke/calendar-card-independent-reminder-edit.png
        // ignore: avoid_print
        print('SCREENSHOT_ARTIFACT_WRITTEN=${file.path}');
        return true;
      } catch (error, stackTrace) {
        // A screenshot is evidence, not a reason to crash the integration
        // driver after the test itself has completed. The workflow upload
        // step emits its own missing-file warning; acceptance still requires
        // the exact artifact to exist.
        // ignore: avoid_print
        print('WARNING: screenshot artifact capture/write failed for $screenshotName: $error');
        // ignore: avoid_print
        print(stackTrace);
        return false;
      }
    },
  );
}
