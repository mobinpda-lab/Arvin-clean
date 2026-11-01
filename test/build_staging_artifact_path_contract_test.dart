import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Staging verification follows the repository-level Gradle build directory', () async {
    final workflow = await File('.github/workflows/build.yml').readAsString();
    final androidBuild = await File('android/build.gradle.kts').readAsString();

    expect(androidBuild, contains('.dir("../../build")'));
    expect(
      workflow,
      contains('build/app/outputs/apk/staging/app-staging.apk'),
    );
    expect(
      workflow,
      isNot(contains('android/app/build/outputs/apk/staging/app-staging.apk')),
    );
  });
}
