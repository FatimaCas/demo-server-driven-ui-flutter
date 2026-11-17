import 'dart:convert';

import 'package:flutter/services.dart';

import 'screen_data_source.dart';

/// Lee las pantallas de `assets/screens/<name>.json`. Sirve para correr la
/// app sin servidor (`--dart-define=DATA_SOURCE=local`).
class ScreenLocalDataSource implements IScreenDataSource {
  ScreenLocalDataSource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  @override
  Future<Map<String, dynamic>> fetchScreen(String name) async {
    final String raw;
    try {
      raw = await _bundle.loadString('assets/screens/$name.json', cache: false);
    } catch (_) {
      throw ScreenNotFoundException(name);
    }
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
