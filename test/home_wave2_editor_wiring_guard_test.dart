import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Home add/edit stay wired to the canonical Wave 2 coordinator', () {
    final source = File('lib/main.dart').readAsStringSync();

    expect(
      source,
      contains("import 'services/wave2_product_fast_track.dart';"),
    );
    expect(
      RegExp(r'wave2ProductFastTrack\.prepareEditor\(')
          .allMatches(source)
          .length,
      2,
    );
    expect(
      RegExp(r'wave2ProductFastTrack\.persistProjectSelection\(')
          .allMatches(source)
          .length,
      2,
    );
    expect(source, contains('projects: editorContext.projects'));
    expect(
      source,
      contains('knownCategories: editorContext.knownCategories'),
    );
    expect(source, contains('onProjectChanged: (value) => selectedProjectId = value'));
    expect(
      source,
      isNot(contains('builder: (_) => const ArvinTaskEditorDialog(),')),
    );
  });
}
