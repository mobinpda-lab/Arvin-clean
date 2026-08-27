import 'package:flutter/material.dart';

class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  static const _sections = <_GuideSection>[
    _GuideSection(
      icon: Icons.add_circle_outline,
      title: 'ساخت کار جدید',
      summary: 'یک عنوان بنویسید، در صورت نیاز توضیح، برچسب و تاریخ پیگیری اضافه کنید و ذخیره را بزنید.',
      steps: <String>[
        'در صفحه اصلی روی «کار جدید» بزنید.',
        'عنوان کار را بنویسید؛ توضیحات و برچسب اختیاری هستند.',
        'اگر لازم است دوباره سراغ کار بروید، تاریخ پیگیری تعیین کنید.',
        'روی «ذخیره» بزنید.',
      ],
    ),
    _GuideSection(
      icon: Icons.bolt_outlined,
      title: 'ثبت سریع',
      summary: 'برای زمانی که عجله دارید و فقط می‌خواهید یک کار یا فکر را سریع ثبت کنید.',
      steps: <String>[
        'بالای صفحه روی علامت صاعقه بزنید.',
        'متن کار را وارد کنید.',
        'ثبت را انجام دهید؛ بعداً می‌توانید جزئیات آن را ویرایش کنید.',
      ],
    ),
    _GuideSection(
      icon: Icons.check_circle_outline,
      title: 'انجام‌شده و عقب‌افتاده',
      summary: 'دایره کنار کار برای انجام‌شده کردن است؛ کارِ تاریخ‌گذشته و انجام‌نشده با هشدار مشخص می‌شود.',
      steps: <String>[
        'وقتی کار تمام شد، روی دایره کنار آن بزنید.',
        'اگر تاریخ پیگیری گذشته باشد و کار هنوز انجام نشده باشد، آروین آن را عقب‌افتاده نشان می‌دهد.',
      ],
    ),
    _GuideSection(
      icon: Icons.search,
      title: 'جست‌وجو و امروز',
      summary: 'با جست‌وجو کارهای قدیمی را پیدا کنید و از «امروز» کارهای مربوط به روز جاری را ببینید.',
      steps: <String>[
        'برای پیدا کردن کار، بخشی از عنوان، توضیح یا برچسب را در جست‌وجو بنویسید.',
        'از منوی برنامه «امروز» را انتخاب کنید تا کارهای مربوط به امروز نمایش داده شوند.',
      ],
    ),
    _GuideSection(
      icon: Icons.calendar_month_outlined,
      title: 'تقویم و پیگیری‌ها',
      summary: 'پیگیری‌ها را روی تقویم ببینید و از همان بخش به دفترچه، اقدام بعدی و خط زمانی دسترسی داشته باشید.',
      steps: <String>[
        'از منوی برنامه وارد «تقویم» شوید.',
        'روزهای دارای پیگیری را بررسی کنید.',
        'در صورت نیاز از دکمه‌های «دفترچه»، «اقدام بعدی» یا «خط زمانی» استفاده کنید.',
      ],
    ),
    _GuideSection(
      icon: Icons.archive_outlined,
      title: 'بایگانی و سطل زباله',
      summary: 'کارهای قدیمی را بایگانی کنید؛ حذف معمولی ابتدا کار را به سطل زباله می‌فرستد.',
      steps: <String>[
        'برای نگهداری یک کار خارج از فهرست فعال، آن را بایگانی کنید.',
        'کار حذف‌شده را از سطل زباله می‌توانید به فعال برگردانید.',
        '«حذف برای همیشه» قابل بازگشت نیست و آروین قبل از آن تأیید می‌گیرد.',
      ],
    ),
    _GuideSection(
      icon: Icons.backup_outlined,
      title: 'پشتیبان‌گیری و بازیابی',
      summary: 'قبل از تعویض یا ریست گوشی، از اطلاعات آروین نسخه پشتیبان بگیرید.',
      steps: <String>[
        'ابتدا پوشه پشتیبان را انتخاب کنید.',
        'گزینه «ایجاد Backup» را بزنید.',
        'برای برگرداندن اطلاعات، «Restore از فایل» را انتخاب کنید و پیام تأیید را با دقت بخوانید.',
      ],
    ),
    _GuideSection(
      icon: Icons.settings_outlined,
      title: 'تنظیمات',
      summary: 'ظاهر روشن، تیره یا مطابق سیستم و همچنین نمایش تاریخ فارسی را از تنظیمات انتخاب کنید.',
      steps: <String>[
        'از منو وارد «تنظیمات» شوید.',
        'حالت نمایش دلخواه را انتخاب کنید.',
        'در صورت تمایل «نمایش تاریخ فارسی» را فعال کنید.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('راهنمای استفاده از آروین')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _welcomeCard(context),
            const SizedBox(height: 16),
            Text(
              'شروع سریع در ۳۰ ثانیه',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const _QuickStartCard(),
            const SizedBox(height: 20),
            Text(
              'آموزش بخش‌به‌بخش',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            for (final section in _sections) ...[
              _GuideSectionCard(section: section),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 12),
            const _SafetyCard(),
          ],
        ),
      ),
    );
  }

  Widget _welcomeCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book_outlined, color: colors.onPrimaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'آروین خیلی ساده است',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onPrimaryContainer,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'هر چیزی را که نباید فراموش کنید ثبت کنید، برایش زمان پیگیری بگذارید و بعد از انجام، علامت انجام‌شده را بزنید. این راهنما بدون اینترنت در خود برنامه در دسترس است.',
              style: TextStyle(color: colors.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  const _QuickStartCard();

  @override
  Widget build(BuildContext context) {
    const items = <(IconData, String)>[
      (Icons.add, '«کار جدید» را بزنید'),
      (Icons.edit_outlined, 'عنوان کار را بنویسید'),
      (Icons.event_outlined, 'اگر لازم است تاریخ پیگیری بگذارید'),
      (Icons.save_outlined, 'ذخیره کنید'),
      (Icons.today_outlined, 'هر روز بخش «امروز» را ببینید'),
      (Icons.check_circle_outline, 'بعد از انجام، کار را تیک بزنید'),
      (Icons.backup_outlined, 'هر چند وقت یک‌بار پشتیبان بگیرید'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (var index = 0; index < items.length; index++)
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: CircleAvatar(
                  radius: 16,
                  child: Text('${index + 1}'),
                ),
                title: Text(items[index].$2),
                trailing: Icon(items[index].$1),
              ),
          ],
        ),
      ),
    );
  }
}

class _GuideSectionCard extends StatelessWidget {
  const _GuideSectionCard({required this.section});

  final _GuideSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(child: Icon(section.icon, size: 20)),
        title: Text(
          section.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(section.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(),
          for (var index = 0; index < section.steps.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(section.steps[index])),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.secondaryContainer,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates_outlined),
                SizedBox(width: 8),
                Text('سه نکته مهم', style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
            SizedBox(height: 10),
            Text('• کاری را که شاید دوباره لازم شود، به‌جای حذف دائمی بایگانی کنید.'),
            SizedBox(height: 6),
            Text('• برای کارهای مهم تاریخ پیگیری بگذارید.'),
            SizedBox(height: 6),
            Text('• قبل از تعویض یا ریست گوشی یک پشتیبان تازه بسازید.'),
          ],
        ),
      ),
    );
  }
}

class _GuideSection {
  const _GuideSection({
    required this.icon,
    required this.title,
    required this.summary,
    required this.steps,
  });

  final IconData icon;
  final String title;
  final String summary;
  final List<String> steps;
}
