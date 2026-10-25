import 'app_fonts.dart';

class ArvinFontOption {
  final String id, nameFa, description, category, fontFamily;
  const ArvinFontOption({
    required this.id,
    required this.nameFa,
    required this.description,
    required this.category,
    required this.fontFamily,
    this.isAvailableLocally = true,
  });

  final bool isAvailableLocally;
  String? get effectiveFontFamily => fontFamily;
}

const List<ArvinFontOption> kAvailableArvinFonts = <ArvinFontOption>[
  ArvinFontOption(
    id: 'vazirmatn',
    nameFa: 'وزیرمتن',
    description: 'فونت رسمی و بسته‌بندی‌شده آروین',
    category: 'عمومی',
    fontFamily: AppFonts.vazirmatnFamily,
  ),
];

ArvinFontOption arvinFontById(String? id) => kAvailableArvinFonts.single;
