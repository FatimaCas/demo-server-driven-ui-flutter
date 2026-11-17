import '../entities/server_screen.dart';

abstract interface class IScreenRepository {
  /// Trae la pantalla [name]. Lanza `ScreenFailure` si no se puede.
  Future<ServerScreen> getScreen(String name);
}
