import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:sdui_server/home_screen.dart';
import 'package:sdui_server/store_db.dart';

/// Entrega las pantallas en `GET /screens/<name>`.
///
/// Los productos salen de SQLite (`data/store.db`) en cada petición: cambia
/// una fila, recarga la app y la pantalla cambia sin reiniciar el servidor.
/// El header `x-client-version` dice qué widgets propios conoce la app.
Future<void> main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final dbFile = File.fromUri(Platform.script.resolve('../data/store.db'));
  await dbFile.parent.create(recursive: true);
  final db = StoreDb.open(dbFile.path);

  final router = Router()
    ..get('/health', (Request _) => Response.ok('ok'))
    ..get('/screens/<name>', (Request request, String name) {
      if (name != 'home') {
        return Response.notFound('No existe la pantalla "$name"');
      }
      final version = int.tryParse(request.headers['x-client-version'] ?? '');
      final screen = buildHome(db, clientVersion: version ?? 1);
      return Response.ok(
        jsonEncode(screen),
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors())
      .addHandler(router.call);

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Servidor SDUI en http://localhost:${server.port}');
  print('Base de datos en ${dbFile.path}');
}

/// Permite que la app corriendo en Chrome (`flutter run -d chrome`) haga fetch.
Middleware _cors() {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': '*',
  };
  return (inner) => (request) async {
        if (request.method == 'OPTIONS') return Response.ok('', headers: headers);
        final response = await inner(request);
        return response.change(headers: headers);
      };
}
