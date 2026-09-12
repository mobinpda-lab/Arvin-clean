import 'package:flutter_test/flutter_test.dart';

import 'package:arvin/services/wave2_product_fast_track.dart';

void main() {
  test('Wave 2 coordinator prepares the canonical editor context', () async {
    final coordinator = Wave2ProductFastTrack();
    final context = await coordinator.prepareEditor(tasks: const []);

    expect(context.projects, isEmpty);
    expect(context.knownCategories, isEmpty);
    expect(context.selectedProjectId, isNull);
  });
}
