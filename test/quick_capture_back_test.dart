import 'package:arvin/quick_capture_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Quick Capture Back dismisses keyboard before closing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickCaptureDialog(onCaptured: (_) async {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final input = find.byKey(const ValueKey('quick-capture-input'));
    expect(input, findsOneWidget);

    await tester.showKeyboard(input);
    await tester.pump();

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isTrue,
    );

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.byKey(const ValueKey('quick-capture-dialog')), findsOneWidget);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isFalse,
    );
  });
}
