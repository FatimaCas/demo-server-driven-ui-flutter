/// Fuente de pantallas. Habla en **mapas crudos** (lo que manda el servidor),
/// no en entidades: así el repositorio se prueba con una fuente falsa.
///
/// Formato esperado:
/// ```json
/// { "name": "home", "title": "SDUI Store", "layout": { "type": "column", ... } }
/// ```
abstract interface class IScreenDataSource {
  Future<Map<String, dynamic>> fetchScreen(String name);
}

/// La fuente no encontró la pantalla pedida.
class ScreenNotFoundException implements Exception {
  const ScreenNotFoundException(this.name);
  final String name;
}

/// La fuente no pudo responder (red, servidor caído, código inesperado).
class ScreenSourceException implements Exception {
  const ScreenSourceException(this.message);
  final String message;
}
