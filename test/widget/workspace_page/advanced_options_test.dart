import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paintroid/core/localization/app_localizations.dart';
import 'package:paintroid/ui/pages/workspace_page/workspace_page.dart';
import 'package:paintroid/ui/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Widget sut;

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    final lightTheme = LightPaintroidThemeData();
    final darkTheme = DarkPaintroidThemeData();

    sut = ProviderScope(
      child: PaintroidTheme(
        lightTheme: lightTheme,
        darkTheme: darkTheme,
        child: MaterialApp(
          theme: lightTheme.materialThemeData,
          darkTheme: darkTheme.materialThemeData,
          home: const WorkspacePage(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
        ),
      ),
    );
  });

  testWidgets('[ADVANCED_OPTIONS]: opens dialog, defaults off, toggles and confirms',
      (WidgetTester tester) async {
    await tester.pumpWidget(sut);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Advanced Options'));
    await tester.pumpAndSettle();

    expect(find.text('Advanced Options'), findsAtLeastNWidgets(1));
    expect(find.text('Antialiasing'), findsOneWidget);
    expect(find.text('Smoothing'), findsOneWidget);

    final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches.length, 2);
    expect(switches[0].value, isFalse);
    expect(switches[1].value, isFalse);

    await tester.tap(find.text('Antialiasing'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Advanced Options'));
    await tester.pumpAndSettle();

    final switchesAfterReopen =
        tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switchesAfterReopen.length, 2);
    expect(switchesAfterReopen[0].value, isTrue);
    expect(switchesAfterReopen[1].value, isFalse);
  });
}