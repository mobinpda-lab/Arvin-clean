import 'package:flutter/services.dart';

class AppFontOption {
  const AppFontOption({
    required this.id,
    required this.label,
    required this.family,
    this.regularAsset,
    this.boldAsset,
  });

  final String id;
  final String label;
  final String family;
  final String? regularAsset;
  final String? boldAsset;

  bool get isBundledDefault => regularAsset == null;
}

abstract final class AppFontCatalog {
  static const String defaultId = 'vazirmatn';

  static const List<AppFontOption> options = <AppFontOption>[
    AppFontOption(id: defaultId, label: 'وزیرمتن', family: 'Vazirmatn'),
    AppFontOption(
      id: 'sahel',
      label: 'ساحل',
      family: 'SelectableSahel',
      regularAsset: 'assets/fonts/selectable/sahel-regular.ttf',
      boldAsset: 'assets/fonts/selectable/sahel-bold.ttf',
    ),
    AppFontOption(
      id: 'parastoo',
      label: 'پرستو',
      family: 'SelectableParastoo',
      regularAsset: 'assets/fonts/selectable/parastoo-regular.ttf',
      boldAsset: 'assets/fonts/selectable/parastoo-bold.ttf',
    ),
    AppFontOption(
      id: 'samim',
      label: 'صمیم',
      family: 'SelectableSamim',
      regularAsset: 'assets/fonts/selectable/samim-regular.ttf',
      boldAsset: 'assets/fonts/selectable/samim-bold.ttf',
    ),
    AppFontOption(
      id: 'tanha',
      label: 'تنها',
      family: 'SelectableTanha',
      regularAsset: 'assets/fonts/selectable/tanha-regular.ttf',
    ),
    AppFontOption(
      id: 'gandom',
      label: 'گندم',
      family: 'SelectableGandom',
      regularAsset: 'assets/fonts/selectable/gandom-regular.ttf',
    ),
    AppFontOption(
      id: 'shabnam',
      label: 'شبنم',
      family: 'SelectableShabnam',
      regularAsset: 'assets/fonts/selectable/shabnam-regular.ttf',
      boldAsset: 'assets/fonts/selectable/shabnam-bold.ttf',
    ),
    AppFontOption(
      id: 'nahid',
      label: 'ناهید',
      family: 'SelectableNahid',
      regularAsset: 'assets/fonts/selectable/nahid-regular.ttf',
    ),
    AppFontOption(
      id: 'vazir_code',
      label: 'وزیر کد',
      family: 'SelectableVazirCode',
      regularAsset: 'assets/fonts/selectable/vazir_code-regular.ttf',
    ),
  ];

  static final Set<String> _loadedIds = <String>{defaultId};
  static bool _loadAttempted = false;

  static Iterable<AppFontOption> get availableOptions =>
      options.where((option) => _loadedIds.contains(option.id));

  static bool isAvailable(String id) => _loadedIds.contains(id);

  static AppFontOption byId(String id) => options.firstWhere(
        (option) => option.id == id,
        orElse: () => options.first,
      );

  static Future<void> loadSelectableFonts() async {
    if (_loadAttempted) return;
    _loadAttempted = true;

    for (final option in options.where((item) => !item.isBundledDefault)) {
      final loader = FontLoader(option.family);
      try {
        loader.addFont(rootBundle.load(option.regularAsset!));
        final boldAsset = option.boldAsset;
        if (boldAsset != null) {
          loader.addFont(rootBundle.load(boldAsset));
        }
        await loader.load();
        _loadedIds.add(option.id);
      } catch (_) {
        // Keep the app usable with Vazirmatn if an optional font asset cannot load.
      }
    }
  }
}
