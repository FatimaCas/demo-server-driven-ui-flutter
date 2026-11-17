import 'package:get/get.dart';

import '../../features/home/data/datasources/screen_data_source.dart';
import '../../features/home/data/datasources/screen_local_data_source.dart';
import '../../features/home/data/datasources/screen_remote_data_source.dart';
import '../../features/home/data/repositories/screen_repository.dart';
import '../../features/home/domain/repositories/i_screen_repository.dart';
import '../../features/home/presentation/viewmodels/home_view_model.dart';
import '../config/app_config.dart';

/// Raíz de composición: el único lugar que elige implementaciones.
/// Cambiar de servidor a assets locales es cambiar una línea aquí.
class AppBindings extends Bindings {
  AppBindings(this.config);

  final AppConfig config;

  @override
  void dependencies() {
    Get.put<IScreenDataSource>(switch (config.dataSource) {
      DataSourceMode.remote => ScreenRemoteDataSource(baseUrl: config.serverUrl),
      DataSourceMode.local => ScreenLocalDataSource(),
    });
    Get.put<IScreenRepository>(ScreenRepository(Get.find()));
    Get.put(HomeViewModel(Get.find()));
  }
}
