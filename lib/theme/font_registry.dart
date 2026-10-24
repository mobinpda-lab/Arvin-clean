import 'app_fonts.dart';

/// The product font is fixed by the owner-approved contract. This small registry
/// remains for compatibility with callers while no alternate UI family is exposed.
class ArvinFontOption {
  final String id, nameFa, description, category, fontFamily;
  final bool isAvailableLocally;

  const ArvinFontOption({
    required this.id,
    required this.nameFa,
    required this.description,
    required this.category,
    required this.fontFamily,
    this.isAvailableLocally = true,
  });

  String? get effectiveFontFamily => fontFamily;
}

const ArvinFontOption kCanonicalArvinFont = ArvinFontOption(
  id: 'vazirmatn',
  nameFa: 'وزیرمتن',
  description: 'فونت ثابت رابط کاربری آروین با پنج وزن مصوب',
  category: 'عمومی',
  fontFamily: AppFonts.vazirmatnFamily,
);

const List<ArvinFontOption> kAvailableArvinFonts = <ArvinFontOption>[
  kCanonicalArvinFont,
];

ArvinFontOption arvinFontById(String? id) => kCanonicalArvinFont;
