import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

/// Entrega `screens/<name>.json` en `GET /screens/<name>`.
///
/// El archivo se lee en cada petición: edítalo, recarga la app y el cambio
/// aparece sin reiniciar el servidor.
Future<void> main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final screensDir = Directory.fromUri(Platform.script.resolve('../screens/'));

  final router = Router()
    ..get('/health', (Request _) => Response.ok('ok'))
    ..get('/screens/<name>', (Request _, String name) async {
      // Solo nombres simples: nada de "../" para salir de la carpeta.
      if (!RegExp(r'^[a-z0-9_-]+$').hasMatch(name)) {
        return Response.badRequest(body: 'Nombre inválido');
      }
      final file = File('${screensDir.path}$name.json');
      if (!await file.exists()) {
        return Response.notFound('No existe la pantalla "$name"');
      }
      return Response.ok(
        await file.readAsString(),
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_cors())
      .addHandler(router.call);

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  print('Servidor SDUI en http://localhost:${server.port}');
  print('Pantallas en ${screensDir.path}');
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
