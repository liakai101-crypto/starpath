import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:starpath/main.dart';

Future<void> _setViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1280, 2400));
}

void main() {
  String zh(List<int> codes) => String.fromCharCodes(codes);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('StarPath opens the Orbit cabin', (WidgetTester tester) async {
    await _setViewport(tester);
    await tester.pumpWidget(const StarPathApp());
    await tester.pump();

    expect(find.text('Command'), findsOneWidget);
    expect(find.byKey(const ValueKey('ship-EX-002')), findsWidgets);
    expect(find.text('Orbit'), findsOneWidget);
  });

  testWidgets('EX-002 unlocks after a pulse', (WidgetTester tester) async {
    await _setViewport(tester);
    await tester.pumpWidget(const StarPathApp());
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('launch-pulse-button')));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const ValueKey('ship-Navigator Emma')), findsWidgets);
  });

  testWidgets('Base shows signal records and an AI suggestion', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    await tester.pumpWidget(const StarPathApp());
    await tester.pump();

    await tester.tap(find.text('Base'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Icebreaker Signal'), findsOneWidget);
    expect(find.text('Late-night orbit ping'), findsOneWidget);
  });

  testWidgets('Capsule unlocks Emma memory after orbit pulse', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    await tester.pumpWidget(const StarPathApp());
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('launch-pulse-button')));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('Capsule'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('First Coordinate'), findsWidgets);
    expect(
      find.text('The first shared trace appears after Emma is unlocked.'),
      findsWidgets,
    );
  });

  testWidgets('language toggle switches Orbit labels to Traditional Chinese', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    await tester.pumpWidget(const StarPathApp());
    await tester.pump();

    await tester.tap(find.text(zh([0x7e41, 0x4e2d])));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text(zh([0x661f, 0x57df])), findsOneWidget);
    expect(find.text(zh([0x6307, 0x63ee, 0x8266])), findsOneWidget);
    expect(find.text(zh([0x767c, 0x5c04, 0x8108, 0x885d])), findsOneWidget);
  });

  testWidgets('Hubble decrypts an encrypted ship signal', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    await tester.pumpWidget(const StarPathApp());
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('ship-EX-002')));
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.byKey(const ValueKey('hubble-copilot')).hitTestable());
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const ValueKey('ship-EX-002')), findsOneWidget);
    expect(find.byKey(const ValueKey('hubble-copilot')), findsOneWidget);
  });

  testWidgets('pulse overheats after three launches', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    await tester.pumpWidget(const StarPathApp());
    await tester.pump();

    for (int i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const ValueKey('launch-pulse-button')));
      await tester.pump(const Duration(milliseconds: 350));
    }

    expect(find.text('Cooling'), findsOneWidget);
  });

  testWidgets('wormhole opens to a selected friend ship', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    await tester.pumpWidget(const StarPathApp());
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('action-quantum')));
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.byKey(const ValueKey('wormhole-target-EX-002')));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const ValueKey('ship-Unknown QT-009')), findsWidgets);
  });

  testWidgets('hibernation toggles into wake mode', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    await tester.pumpWidget(const StarPathApp());
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('action-hibernate')));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Wake'), findsOneWidget);
  });

  testWidgets('singularity event lights capsule badge', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    await tester.pumpWidget(const StarPathApp());
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('action-singularity')));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('Engage'));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.tap(find.text('Capsule'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Singularity Core'), findsOneWidget);
    expect(find.text('Badge Wall'), findsOneWidget);
  });
}
