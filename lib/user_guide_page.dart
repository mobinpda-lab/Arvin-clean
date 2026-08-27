import 'package:flutter/material.dart';

class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  static const _sections = <_GuideSection>[
    _GuideSection(
      icon: Icons.add_circle_outline,
      title: 'ساخت کار جدید',
      summary:
          'یک عنوان بنویسید، در صورت نیاز توضیح، برچسب و تاریخ پیگیری اضافه کنید و ذخیره را بزنید.',
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
      summary:
          'برای زمانی که عجله دارید و فقط می‌خواهید یک کار یا فکر را سریع ثبت کنید.',
      steps: <String>[
        'بالای صفحه روی علامت صاعقه بزنید.',
        'متن کار را وارد کنید.',
        'ثبت را انجام دهید؛ بعداً می‌توانید جزئیات آن را ویرایش کنید.',
      ],
    ),
    _GuideSection(
      icon: Icons.check_circle_outline,
      title: 'انجام‌شده و عقب‌افتاده',
      summary:
          'دایره کنار کار برای انجام‌شده کردن است؛ کارِ تاریخ‌گذشته و انجام‌نشده با هشدار مشخص می‌شود.',
      steps: <String>[
        'وقتی کار تمام شد، روی دایره کنار آن بزنید.',
        'اگر تاریخ پیگیری گذشته باشد و کار هنوز انجام نشده باشد، آروین آن را عقب‌افتاده نشان می‌دهد.',
      ],
    ),
    _GuideSection(
      icon: Icons.search,
      title: 'جست‌وجو و امروز',
      summary:
          'با جست‌وجو کارهای قدیمی را پیدا کنید و از «امروز» کارهای مربوط به روز جاری را ببینید.',
      steps: <String>[
        'برای پیدا کردن کار، بخشی از عنوان، توضیح یا برچسب را در جست‌وجو بنویسید.',
        'از منوی برنامه «امروز» را انتخاب کنید تا کارهای مربوط به امروز نمایش داده شوند.',
      ],
    ),
    _GuideSection(
      icon: Icons.calendar_month_outlined,
      title: 'تقویم و پیگیری‌ها',
      summary:
          'پیگیری‌ها را روی تقویم ببینید و از همان بخش به دفترچه، اقدام بعدی و خط زمانی دسترسی داشته باشید.',
      steps: <String>[
        'از منوی برنامه وارد «تقویم» شوید.',
        'روزهای دارای پیگیری را بررسی کنید.',
        'در صورت نیاز از دکمه‌های «دفترچه»، «اقدام بعدی» یا «خط زمانی» استفاده کنید.',
      ],
    ),
    _GuideSection(
      icon: Icons.archive_outlined,
      title: 'بایگانی و سطل زباله',
      summary:
          'کارهای قدیمی را بایگانی کنید؛ حذف معمولی ابتدا کار را به سطل زباله می‌فرستد.',
      steps: <String>[
        'برای نگهداری یک کار خارج از فهرست فعال، آن را بایگانی کنید.',
        'کار حذف‌شده را از سطل زباله می‌توانید به فعال برگردانید.',
        '«حذف برای همیشه» قابل بازگشت نیست و آروین قبل از آن تأیید می‌گیرد.',
      ],
    ),
    _GuideSection(
      icon: Icons.backup_outlined,
      title: 'پشتیبان‌گیری و بازیابی',
      summary:
          'قبل از تعویض یا ریست گوشی، از اطلاعات آروین نسخه پشتیبان بگیرید.',
      steps: <String>[
        'ابتدا پوشه پشتیبان را انتخاب کنید.',
        'گزینه «ایجاد Backup» را بزنید.',
        'برای برگرداندن اطلاعات، «Restore از فایل» را انتخاب کنید و پیام تأیید را با دقت بخوانید.',
      ],
    ),
    _GuideSection(
      icon: Icons.settings_outlined,
      title: 'تنظیمات',
      summary:
          'ظاهر روشن، تیره یا مطابق سیستم و همچنین نمایش تاریخ فارسی را از تنظیمات انتخاب کنید.',
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
            const SizedBox(height: 20),
            _sectionTitle(context, 'راهنمای تصویری صفحه اصلی'),
            const SizedBox(height: 8),
            const _HomeVisualGuide(),
            const SizedBox(height: 20),
            _sectionTitle(context, 'کار با یک کارت کار'),
            const SizedBox(height: 8),
            const _TaskVisualGuide(),
            const SizedBox(height: 20),
            _sectionTitle(context, 'مسیر پشتیبان‌گیری'),
            const SizedBox(height: 8),
            const _BackupVisualGuide(),
            const SizedBox(height: 20),
            _sectionTitle(context, 'شروع سریع در ۳۰ ثانیه'),
            const SizedBox(height: 8),
            const _QuickStartCard(),
            const SizedBox(height: 20),
            _sectionTitle(context, 'آموزش بخش‌به‌بخش'),
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

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
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
                Icon(
                  Icons.menu_book_outlined,
                  color: colors.onPrimaryContainer,
                ),
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

class _HomeVisualGuide extends StatelessWidget {
  const _HomeVisualGuide();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'این تصویر ساده‌شده، همان بخش‌های مهم صفحه اصلی را نشان می‌دهد. شماره‌ها را با توضیح پایین تصویر تطبیق دهید.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(22),
                color: colors.surfaceContainerLowest,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      color: colors.surfaceContainerHigh,
                      child: Row(
                        children: [
                          const _NumberBadge(number: 1),
                          const SizedBox(width: 4),
                          const Icon(Icons.menu, size: 20),
                          const Spacer(),
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'بسم الله الرحمن الرحیم',
                                style: TextStyle(fontSize: 8),
                              ),
                              Text(
                                'مدیریت کارها وپیگیری آروین',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const _NumberBadge(number: 2),
                          const SizedBox(width: 2),
                          const Icon(Icons.bolt_outlined, size: 18),
                          const SizedBox(width: 6),
                          const Icon(Icons.backup_outlined, size: 18),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
                      child: Row(
                        children: [
                          const _NumberBadge(number: 3),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 38,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colors.outlineVariant,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.search, size: 17),
                                  SizedBox(width: 6),
                                  Text(
                                    'جست‌وجو',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          const _NumberBadge(number: 4),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: const [
                                _MiniChip(text: 'فعال', selected: true),
                                _MiniChip(text: 'بایگانی'),
                                _MiniChip(text: 'سطل زباله'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          const _NumberBadge(number: 5),
                          const SizedBox(width: 8),
                          const Expanded(child: _MiniStat(text: 'کل', value: '12')),
                          const Expanded(child: _MiniStat(text: 'فعال', value: '5')),
                          const Expanded(
                            child: _MiniStat(text: 'انجام‌شده', value: '6'),
                          ),
                          const Expanded(
                            child: _MiniStat(text: 'عقب‌افتاده', value: '1'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _NumberBadge(number: 6),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: colors.surfaceContainer,
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.radio_button_unchecked, size: 19),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'تماس با مشتری',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          'پیگیری: ۱۴۰۵/۰۶/۰۵',
                                          style: TextStyle(fontSize: 9),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const _NumberBadge(number: 7),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 17),
                                SizedBox(width: 4),
                                Text(
                                  'کار جدید',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard_double_arrow_down_rounded),
                SizedBox(width: 6),
                Text('توضیح شماره‌ها'),
              ],
            ),
            const SizedBox(height: 8),
            const _VisualLegend(
              number: 1,
              title: 'منوی اصلی',
              text: 'امروز، تقویم، بایگانی، سطل زباله و تنظیمات از اینجا باز می‌شوند.',
            ),
            const _VisualLegend(
              number: 2,
              title: 'ثبت سریع و پشتیبان',
              text: 'صاعقه برای ثبت سریع است و آیکون پشتیبان برای Backup/Restore.',
            ),
            const _VisualLegend(
              number: 3,
              title: 'جست‌وجو',
              text: 'عنوان، توضیح، برچسب و اطلاعات پیگیری را پیدا می‌کند.',
            ),
            const _VisualLegend(
              number: 4,
              title: 'فیلترها',
              text: 'بین کارهای فعال، بایگانی و سطل زباله جابه‌جا شوید.',
            ),
            const _VisualLegend(
              number: 5,
              title: 'خلاصه وضعیت',
              text: 'تعداد کل، فعال، انجام‌شده و عقب‌افتاده را یک‌جا ببینید.',
            ),
            const _VisualLegend(
              number: 6,
              title: 'کارت کار',
              text: 'روی کارت بزنید تا ویرایش شود؛ دایره کنار آن وضعیت انجام را تغییر می‌دهد.',
            ),
            const _VisualLegend(
              number: 7,
              title: 'کار جدید',
              text: 'برای ساخت یک کار کامل با عنوان، توضیح، برچسب و تاریخ پیگیری.',
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskVisualGuide extends StatelessWidget {
  const _TaskVisualGuide();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: colors.surfaceContainer,
              ),
              child: const Row(
                children: [
                  _NumberBadge(number: 1),
                  SizedBox(width: 6),
                  Icon(Icons.radio_button_unchecked),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ارسال پیش‌فاکتور',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 4),
                        Text('پیگیری: فردا', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
                  _NumberBadge(number: 2),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(
                  child: _ActionHint(
                    icon: Icons.touch_app_outlined,
                    title: 'یک لمس',
                    text: 'باز کردن و ویرایش کار',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _ActionHint(
                    icon: Icons.touch_app,
                    title: 'نگه داشتن',
                    text: 'انتخاب چند کار با هم',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(
                  child: _ActionHint(
                    icon: Icons.check_circle_outline,
                    title: 'دایره کنار کار',
                    text: 'انجام‌شده / انجام‌نشده',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _ActionHint(
                    icon: Icons.swipe_left_outlined,
                    title: 'کشیدن کارت',
                    text: 'فرستادن به سطل زباله',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupVisualGuide extends StatelessWidget {
  const _BackupVisualGuide();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(
                  child: _BackupStep(
                    number: 1,
                    icon: Icons.folder_outlined,
                    text: 'انتخاب پوشه',
                  ),
                ),
                Icon(Icons.arrow_back_rounded),
                Expanded(
                  child: _BackupStep(
                    number: 2,
                    icon: Icons.backup_outlined,
                    text: 'ایجاد Backup',
                  ),
                ),
                Icon(Icons.arrow_back_rounded),
                Expanded(
                  child: _BackupStep(
                    number: 3,
                    icon: Icons.check_circle_outline,
                    text: 'نگهداری فایل',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'برای بازیابی، مسیر برعکس نیست؛ کافی است «Restore از فایل» را بزنید، فایل را انتخاب کنید و پیام تأیید را بخوانید. آروین قبل از جایگزینی اطلاعات، از داده فعلی یک پشتیبان اضطراری می‌سازد.',
              style: Theme.of(context).textTheme.bodyMedium,
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
        subtitle: Text(
          section.summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
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
                Text(
                  'سه نکته مهم',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
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

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primary,
      ),
      child: Text(
        '$number',
        style: TextStyle(
          color: colors.onPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.text, this.selected = false});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: selected ? colors.secondaryContainer : colors.surfaceContainer,
      ),
      child: Text(text, style: const TextStyle(fontSize: 9)),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.text, required this.value});

  final String text;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          Text(text, style: const TextStyle(fontSize: 7)),
        ],
      ),
    );
  }
}

class _VisualLegend extends StatelessWidget {
  const _VisualLegend({
    required this.number,
    required this.title,
    required this.text,
  });

  final int number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NumberBadge(number: number),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionHint extends StatelessWidget {
  const _ActionHint({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 3),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _BackupStep extends StatelessWidget {
  const _BackupStep({
    required this.number,
    required this.icon,
    required this.text,
  });

  final int number;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NumberBadge(number: number),
        const SizedBox(height: 5),
        Icon(icon),
        const SizedBox(height: 4),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
        ),
      ],
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
