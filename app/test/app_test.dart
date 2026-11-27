import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/app.dart';
import 'package:news_app/state/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(WidgetTester tester, Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  await tester.pumpWidget(ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(sp)],
    child: const NewsApp(),
  ));
}

/// pumpAndSettle never returns while the skeleton/spinner animates, so pump a fixed time.
Future<void> settle(WidgetTester t) async {
  for (var i = 0; i < 30; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('first launch goes splash -> welcome, then feed after Get started', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpApp(tester, {});
    expect(find.text('A clearer view of India.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1300));
    await settle(tester);
    expect(find.text('Get started'), findsOneWidget);

    await tester.ensureVisible(find.text('Get started'));
    await settle(tester);
    await tester.tap(find.text('Get started'));
    await settle(tester);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('returning user lands on feed and can switch tabs', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpApp(tester, {'onboarded': true});
    await tester.pump(const Duration(milliseconds: 1300));
    await settle(tester);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Discover').last);
    await settle(tester);
    expect(find.text('Follow what matters to you.'), findsOneWidget);
  });

  testWidgets('Marathi renders with Devanagari copy and a Marathi category', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pumpApp(tester, {'onboarded': true, 'language': 'mr'});
    await tester.pump(const Duration(milliseconds: 1300));
    await settle(tester);
    expect(find.text('मुख्य बातम्या'), findsWidgets);
    await tester.tap(find.text('शोधा').last);
    await settle(tester);
    expect(find.text('तुमच्यासाठी महत्त्वाचे ते जाणून घ्या.'), findsOneWidget);
  });
}
