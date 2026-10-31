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

const ArvinFontOption _vazirmatn = ArvinFontOption(
  id: 'vazirmatn',
  nameFa: 'وزیرمتن',
  description: 'فونت استاندارد و یکپارچه رابط کاربری آروین',
  category: 'عمومی',
  fontFamily: 'Vazirmatn',
);

const List<ArvinFontOption> kAvailableArvinFonts = <ArvinFontOption>[
  _vazirmatn,
];

ArvinFontOption arvinFontById(String? id) => _vazirmatn;
