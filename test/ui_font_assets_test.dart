import 'package:arvin/theme/font_registry.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const assets = <String>[
    'assets/fonts/vazirmatn-ui-fd/fonts/ttf/Vazirmatn-UI-FD-Regular.ttf',
    'assets/fonts/vazirmatn-ui-fd/fonts/ttf/Vazirmatn-UI-FD-Medium.ttf',
    'assets/fonts/vazirmatn-ui-fd/fonts/ttf/Vazirmatn-UI-FD-SemiBold.ttf',
    'assets/fonts/vazirmatn-ui-fd/fonts/ttf/Vazirmatn-UI-FD-Bold.ttf',
    'assets/fonts/ui/estedad/Estedad-Regular.ttf',
    'assets/fonts/ui/estedad/Estedad-Medium.ttf',
    'assets/fonts/ui/estedad/Estedad-SemiBold.ttf',
    'assets/fonts/ui/estedad/Estedad-Bold.ttf',
    'assets/fonts/ui/shabnam/Shabnam-Regular.ttf',
    'assets/fonts/ui/shabnam/Shabnam-Medium.ttf',
    'assets/fonts/ui/shabnam/Shabnam-Bold.ttf',
    'assets/fonts/ui/sahel/Sahel-Regular.ttf',
    'assets/fonts/ui/sahel/Sahel-SemiBold.ttf',
    'assets/fonts/ui/sahel/Sahel-Bold.ttf',
    'assets/fonts/ui/samim/Samim-Regular.ttf',
    'assets/fonts/ui/samim/Samim-Medium.ttf',
    'assets/fonts/ui/samim/Samim-Bold.ttf',
    'assets/fonts/ui/tanha/Tanha-Regular.ttf',
    'assets/fonts/ui/gandom/Gandom-Regular.ttf',
    'assets/fonts/ui/parastoo/Parastoo-Regular.ttf',
    'assets/fonts/ui/parastoo/Parastoo-Bold.ttf',
    'assets/fonts/ui/mikhak/Mikhak-Regular.ttf',
    'assets/fonts/ui/mikhak/Mikhak-Medium.ttf',
    'assets/fonts/ui/mikhak/Mikhak-SemiBold.ttf',
    'assets/fonts/ui/mikhak/Mikhak-Bold.ttf',
    'assets/fonts/ui/lalezar/Lalezar-Regular.ttf',
    'assets/fonts/ui/vazircode/Vazir-Code-Regular.ttf',
  ];

  test('every non-system picker option is locally backed by a registered family', () {
    final unavailable = kAvailableArvinFonts
        .where((option) => option.id != 'system' && !option.isAvailableLocally)
        .map((option) => option.id)
        .toList(growable: false);
    expect(unavailable, isEmpty);
    expect(
      kAvailableArvinFonts
          .where((option) => option.id != 'system')
          .map((option) => option.fontFamily)
          .toSet(),
      containsAll(<String>[
        'Vazirmatn', 'Estedad', 'Sahel', 'Shabnam', 'Samim', 'Tanha',
        'Gandom', 'Parastoo', 'Mikhak', 'Lalezar', 'Vazir Code', 'VazirHarf',
      ]),
    );
  });

  test('all declared UI and report font files load from the app bundle', () async {
    for (final asset in assets) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(10000), reason: asset);
    }
  });
}
