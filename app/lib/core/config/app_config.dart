import 'package:flutter/foundation.dart';

/// De dónde salen las pantallas.
enum DataSourceMode { remote, local }

/// Configuración que llega por `--dart-define` al compilar:
///
/// ```bash
/// flutter run                                   # servidor shelf
/// flutter run --dart-define=DATA_SOURCE=local   # JSON de assets/, sin servidor
/// flutter run --dart-define=SERVER_URL=http://192.168.1.20:8080
/// ```
class AppConfig {
  const AppConfig({required this.dataSource, required this.serverUrl});

  factory AppConfig.fromEnvironment() {
    const mode = String.fromEnvironment('DATA_SOURCE', defaultValue: 'remote');
    const url = String.fromEnvironment('SERVER_URL');
    return AppConfig(
      dataSource:
          mode == 'local' ? DataSourceMode.local : DataSourceMode.remote,
      serverUrl: url.isNotEmpty ? url : _defaultServerUrl(),
    );
  }

  final DataSourceMode dataSource;
  final String serverUrl;

  /// En el emulador de Android, `localhost` es el propio emulador:
  /// el PC se alcanza en `10.0.2.2`.
  static String _defaultServerUrl() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }
}
