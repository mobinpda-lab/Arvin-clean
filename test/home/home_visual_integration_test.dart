import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/home/home_visual_integration.dart';
import 'package:arvin/theme/app_fonts.dart';

void main() {
  testWidgets('Home sacred SVG and capsule use Option #8 theme colors in light theme', (tester) async {
    final lightTheme = ThemeData.light().copyWith(
      colorScheme: ThemeData.light().colorScheme.copyWith(
        primary: const Color(0xFF3A86EF),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: const HomeVisualIntegration(body: SizedBox.shrink()),
      ),
    );
    final svg = tester.widget<SvgPicture>(
      find.byKey(const ValueKey('home-bismillah-svg')),
    );
    expect(svg.colorFilter, ColorFilter.mode(lightTheme.colorScheme.onSurface, BlendMode.srcIn));
    final capsule = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('home-bismillah-capsule-surface')),
    );
    expect(
      (capsule.decoration as BoxDecoration).color,
      Color.alphaBlend(lightTheme.colorScheme.primary.withAlpha(10), lightTheme.colorScheme.surface),
    );
  });

  testWidgets('Home sacred SVG and capsule adapt to dark theme contrast', (tester) async {
    final darkTheme = ThemeData.dark();
    await tester.pumpWidget(
      MaterialApp(
        theme: darkTheme,
        home: const HomeVisualIntegration(body: SizedBox.shrink()),
      ),
    );
    final svg = tester.widget<SvgPicture>(
      find.byKey(const ValueKey('home-bismillah-svg')),
    );
    expect(svg.colorFilter, ColorFilter.mode(darkTheme.colorScheme.onSurface, BlendMode.srcIn));
    final capsule = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('home-bismillah-capsule-surface')),
    );
    expect((capsule.decoration as BoxDecoration).color, darkTheme.colorScheme.surfaceContainerLow);
  });

  testWidgets('renders canonical Home identity, search and add action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeVisualIntegration(
          body: SizedBox.shrink(),
          onAdd: null,
          onMenu: null,
          onNotifications: null,
        ),
      ),
    );

    final sacredPhrase = find.byKey(const ValueKey('home-bismillah-capsule'));
    expect(sacredPhrase, findsOneWidget);
    expect(find.byKey(const ValueKey('home-bismillah-svg')), findsOneWidget);
    expect(
      tester.widget<Semantics>(sacredPhrase).properties.label,
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    );
    expect(
      find.byWidgetPredicate((widget) => widget is SvgPicture &&
          (widget.bytesLoader as dynamic).assetName == 'assets/images/branding/bismillah.svg'),
      findsOneWidget,
    );
    expect(AppFonts.familyForText('وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ'), AppFonts.vazirmatnFamily);
    expect(AppFonts.familyForText('افوض امری الی الله'), AppFonts.vazirmatnFamily);
    expect(AppFonts.familyForText('متن فارسی رابط کاربری'), AppFonts.vazirmatnFamily);
    expect(find.text('مدیریت کارها و پیگیری آروین'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-search')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-notifications')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-canonical-add')), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}

// Focused regression coverage for the canonical Home presentation shell.
