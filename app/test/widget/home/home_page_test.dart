import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sdui_store/features/home/domain/entities/server_screen.dart';
import 'package:sdui_store/features/home/domain/failures/screen_failure.dart';
import 'package:sdui_store/features/home/presentation/pages/home_page.dart';
import 'package:sdui_store/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:stac/stac.dart';

import '../../support/fakes.dart';

Future<void> pumpHome(WidgetTester tester, FakeScreenRepository repo) async {
  Get.put(HomeViewModel(repo));
  await tester.pumpWidget(const GetMaterialApp(home: HomePage()));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => Stac.initialize());
  tearDown(Get.reset);

  testWidgets('pinta lo que manda el servidor', (tester) async {
    await pumpHome(
      tester,
      FakeScreenRepository([textScreen('Hola desde el servidor', title: 'Tienda')]),
    );

    expect(find.text('Hola desde el servidor'), findsOneWidget);
    expect(find.text('Tienda'), findsOneWidget);
  });

  testWidgets('al recargar cambia la UI sin recompilar', (tester) async {
    await pumpHome(
      tester,
      FakeScreenRepository([textScreen('Versión 1'), textScreen('Versión 2')]),
    );

    await tester.tap(find.byKey(HomePage.refreshButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('Versión 1'), findsNothing);
    expect(find.text('Versión 2'), findsOneWidget);
  });

  testWidgets('sin pantalla muestra el error y reintentar', (tester) async {
    await pumpHome(
      tester,
      FakeScreenRepository([const ScreenFailure('No hay servidor')]),
    );

    expect(find.byKey(HomePage.errorKey), findsOneWidget);
    expect(find.text('No hay servidor'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  // Cada JSON del servidor (el activo y las variantes de la presentación) se
  // pinta en tamaño teléfono sin widgets de error de Stac ni desbordes.
  final serverJsons = [
    ...Directory('../server/screens').listSync(),
    ...Directory('../server/demo').listSync(),
  ].whereType<File>().where((f) => f.path.endsWith('.json'));

  for (final file in serverJsons) {
    testWidgets('Stac renderiza ${file.uri.pathSegments.last}', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final raw = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final screen = ServerScreen(
        name: raw['name'] as String,
        title: raw['title'] as String,
        layout: raw['layout'] as Map<String, dynamic>,
      );

      await pumpHome(tester, FakeScreenRepository([screen]));

      expect(find.text(screen.title), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == 'StacErrorWidget',
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
