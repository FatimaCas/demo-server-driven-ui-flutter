import 'package:get/get.dart';

import '../../domain/entities/server_screen.dart';
import '../../domain/failures/screen_failure.dart';
import '../../domain/repositories/i_screen_repository.dart';

/// Estado del home: cargando, la pantalla del servidor o un error.
class HomeViewModel extends GetxController {
  HomeViewModel(this._repository);

  static const screenName = 'home';

  final IScreenRepository _repository;

  final screen = Rxn<ServerScreen>();
  final error = RxnString();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// Carga (o recarga, con pull-to-refresh) la pantalla desde el repositorio.
  /// Si falla y ya había una pantalla, se conserva la anterior.
  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      screen.value = await _repository.getScreen(screenName);
    } on ScreenFailure catch (f) {
      error.value = f.message;
    } finally {
      isLoading.value = false;
    }
  }
}
