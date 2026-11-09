import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tripwise/main.dart';

void main() {
  testWidgets('fluxo: splash → início → cadastro', (tester) async {
    SharedPreferences.setMockInitialValues({});

    // Tela de celular (390x844) em vez do padrão 800x600 do teste.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const TripWiseApp());
    expect(find.text('PREPARANDO SUA VIAGEM…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Começar agora'), findsOneWidget);

    // A fonte de teste é mais larga que a real, então rola até o botão.
    await tester.ensureVisible(find.text('Começar agora'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Começar agora'));
    await tester.pumpAndSettle();
    expect(find.text('CRIE SUA CONTA'), findsOneWidget);
  });
}
