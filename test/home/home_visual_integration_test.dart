import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/home/home_visual_integration.dart';
import 'package:arvin/theme/app_fonts.dart';

void main() {
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
    expect(
      tester.widget<Semantics>(sacredPhrase).properties.label,
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    );
    expect(
      find.byWidgetPredicate((widget) => widget is SvgPicture &&
          (widget.bytesLoader as dynamic).assetName == 'assets/images/branding/bismillah.svg'),
      findsOneWidget,
    );
    expect(AppFonts.familyForText('أُفَوِّضُ أَمْرِی إِلَى اللَّهِ'), AppFonts.vazirmatnFamily);
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
