import 'app_fonts.dart';

class ArvinFontOption {
  final String id, nameFa, description, category, fontFamily;
  final bool isAvailableLocally;
  const ArvinFontOption({
    required this.id,
    required this.nameFa,
    required this.description,
    required this.category,
    required this.fontFamily,
    this.isAvailableLocally = false,
  });

  String? get effectiveFontFamily =>
      id == 'system' ? null : (isAvailableLocally ? fontFamily : null);
}

const List<ArvinFontOption> kAvailableArvinFonts = <ArvinFontOption>[
  ArvinFontOption(
    id: 'vazirmatn',
    nameFa: 'وزیرمتن',
    description: 'فونت اصلی و پیش‌فرض آروین؛ فایل‌های آن همراه برنامه بسته‌بندی می‌شوند',
    category: 'عمومی',
    fontFamily: AppFonts.vazirmatnFamily,
    isAvailableLocally: true,
  ),
  ArvinFontOption(id: 'estedad', nameFa: 'استعداد', description: 'مناسب رابط کاربری و تیترهای مدرن', category: 'عمومی', fontFamily: 'Estedad'),
  ArvinFontOption(id: 'sahel', nameFa: 'ساحل', description: 'مناسب مطالعه و متن طولانی', category: 'مطالعه', fontFamily: 'Sahel'),
  ArvinFontOption(id: 'shabnam', nameFa: 'شبنم', description: 'مناسب متن و مطالعه روزانه', category: 'مطالعه', fontFamily: 'Shabnam'),
  ArvinFontOption(id: 'samim', nameFa: 'صمیم', description: 'متن ساده و روان', category: 'مطالعه', fontFamily: 'Samim'),
  ArvinFontOption(id: 'tanha', nameFa: 'تنها', description: 'فونت عمومی و سبک', category: 'عمومی', fontFamily: 'Tanha'),
  ArvinFontOption(id: 'gandom', nameFa: 'گندم', description: 'مناسب متن‌های خواندنی', category: 'مطالعه', fontFamily: 'Gandom'),
  ArvinFontOption(id: 'parastoo', nameFa: 'پرستو', description: 'مناسب متن ادبی و تیتر', category: 'تیتر', fontFamily: 'Parastoo'),
  ArvinFontOption(id: 'mikhak', nameFa: 'میخک', description: 'سبک مدرن و متمایز', category: 'تیتر', fontFamily: 'Mikhak'),
  ArvinFontOption(id: 'lalezar', nameFa: 'لاله‌زار', description: 'مناسب تیتر و گرافیک', category: 'تیتر', fontFamily: 'Lalezar'),
  ArvinFontOption(id: 'vazir-code', nameFa: 'وزیر کد', description: 'فونت مونو برای کد و متن فنی', category: 'برنامه‌نویسی', fontFamily: 'Vazir Code'),
  ArvinFontOption(id: 'system', nameFa: 'فونت دستگاه', description: 'فونت پیش‌فرض سیستم؛ بدون نیاز به فایل اضافی', category: 'عمومی', fontFamily: 'system', isAvailableLocally: true),
];

ArvinFontOption arvinFontById(String? id) {
  for (final option in kAvailableArvinFonts) {
    if (option.id == id || option.fontFamily == id) return option;
  }
  return kAvailableArvinFonts.first;
}
