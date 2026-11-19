import 'package:flutter/foundation.dart';

/// De dónde salen las pantallas.
enum DataSourceMode { remote, local }

/// Configuración que llega por `--dart-define` al compilar:
///
/// ```bash
/// flutter run                                   # servidor shelf
/// flutter run --dart-define=DATA_SOURCE=local   # JSON de assets/, sin servidor
/// flutter run --dart-define=SERVER_URL=http://192.168.1.20:8080
/// flutter run --dart-define=VOCABULARY=1       # simula una app sin `productCard`
/// ```
class AppConfig {
  const AppConfig({
    required this.dataSource,
    required this.serverUrl,
    this.vocabulary = currentVocabulary,
  });

  /// Versión del vocabulario de widgets que trae esta app compilada:
  /// 1 = solo widgets de Stac, 2 = además `productCard`.
  static const currentVocabulary = 2;

  factory AppConfig.fromEnvironment() {
    const mode = String.fromEnvironment('DATA_SOURCE', defaultValue: 'remote');
    const url = String.fromEnvironment('SERVER_URL');
    const vocabulary =
        int.fromEnvironment('VOCABULARY', defaultValue: currentVocabulary);
    return AppConfig(
      vocabulary: vocabulary,
      dataSource:
          mode == 'local' ? DataSourceMode.local : DataSourceMode.remote,
      serverUrl: url.isNotEmpty ? url : _defaultServerUrl(),
    );
  }

  final DataSourceMode dataSource;
  final String serverUrl;
  final int vocabulary;

  /// En el emulador de Android, `localhost` es el propio emulador:
  /// el PC se alcanza en `10.0.2.2`.
  static String _defaultServerUrl() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }
}
