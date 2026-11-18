import 'dart:convert';
import 'dart:io';

import 'package:sdui_server/home_screen.dart';
import 'package:sdui_server/store_db.dart';

/// Escribe en `demo/` las pantallas que el servidor entrega con los datos
/// de siempre. Sirven de muestra y las usan las pruebas de la app.
///
/// ```bash
/// dart run bin/export_demo.dart
/// ```
void main() {
  final dir = Directory.fromUri(Platform.script.resolve('../demo/'))
    ..createSync(recursive: true);
  final db = StoreDb.open(':memory:');
  const encoder = JsonEncoder.withIndent('  ');

  void write(String file, {required bool blackFriday, required int version}) {
    db.blackFriday = blackFriday;
    File('${dir.path}$file').writeAsStringSync(
      '${encoder.convert(buildHome(db, clientVersion: version))}\n',
    );
  }

  write('home_normal.json', blackFriday: false, version: 2);
  write('home_black_friday.json', blackFriday: true, version: 2);
  write('home_app_v1.json', blackFriday: false, version: 1);
  db.close();
}
