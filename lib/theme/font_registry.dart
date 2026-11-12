class ArvinFontOption {
  final String id;
  final String nameFa;
  final String description;
  final String category;
  final String fontFamily;

  const ArvinFontOption({
    required this.id,
    required this.nameFa,
    required this.description,
    required this.category,
    required this.fontFamily,
  });

  String get effectiveFontFamily => fontFamily;
}

const ArvinFontOption _vazirHarf = ArvinFontOption(
  id: 'vazirharf',
  nameFa: 'وزیرحرف',
  description: 'فونت رسمی فارسی رابط کاربری آروین، نسخه ۳۴٫۰۰۳',
  category: 'عمومی',
  fontFamily: 'VazirHarf',
);

const List<ArvinFontOption> kAvailableArvinFonts = <ArvinFontOption>[
  _vazirHarf,
];

ArvinFontOption arvinFontById(String? id) => _vazirHarf;
