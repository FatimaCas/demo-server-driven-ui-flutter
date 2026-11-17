import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sdui_store/features/home/domain/failures/screen_failure.dart';
import 'package:sdui_store/features/home/presentation/viewmodels/home_view_model.dart';

import '../../support/fakes.dart';

void main() {
  tearDown(Get.reset);

  test('carga la pantalla al iniciarse', () async {
    final vm = Get.put(HomeViewModel(FakeScreenRepository([textScreen('Hola')])));
    await Future<void>.delayed(Duration.zero);

    expect(vm.screen.value?.layout['data'], 'Hola');
    expect(vm.error.value, isNull);
    expect(vm.isLoading.value, isFalse);
  });

  test('muestra el error si la primera carga falla', () async {
    final vm = Get.put(HomeViewModel(
      FakeScreenRepository([const ScreenFailure('Servidor caído')]),
    ));
    await Future<void>.delayed(Duration.zero);

    expect(vm.screen.value, isNull);
    expect(vm.error.value, 'Servidor caído');
  });

  test('si una recarga falla, conserva la pantalla anterior', () async {
    final vm = Get.put(HomeViewModel(FakeScreenRepository([
      textScreen('v1'),
      const ScreenFailure('Servidor caído'),
    ])));
    await Future<void>.delayed(Duration.zero);

    await vm.load();

    expect(vm.screen.value?.layout['data'], 'v1');
    expect(vm.error.value, 'Servidor caído');
  });

  test('recargar trae la versión nueva del servidor', () async {
    final vm = Get.put(HomeViewModel(FakeScreenRepository([
      textScreen('v1'),
      textScreen('v2'),
    ])));
    await Future<void>.delayed(Duration.zero);

    await vm.load();

    expect(vm.screen.value?.layout['data'], 'v2');
  });
}
