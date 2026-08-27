import 'package:arvin/services/interactive_guide_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('interactive guide is visible until it is marked seen', () async {
    final service = InteractiveGuideService();

    expect(await service.shouldShow(), isTrue);

    await service.markSeen();
    expect(await service.shouldShow(), isFalse);

    await service.reset();
    expect(await service.shouldShow(), isTrue);
  });
}
