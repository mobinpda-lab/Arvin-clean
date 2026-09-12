import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arvin/services/wave2_product_fast_track.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Wave 2 coordinator prepares the canonical editor context', () async {
    final coordinator = Wave2ProductFastTrack();
    final context = await coordinator.prepareEditor(tasks: const []);

    expect(context.projects, isEmpty);
    expect(context.knownCategories, isEmpty);
    expect(context.selectedProjectId, isNull);
  });
}
