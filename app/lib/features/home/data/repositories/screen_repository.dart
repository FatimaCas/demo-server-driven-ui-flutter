import '../../domain/entities/server_screen.dart';
import '../../domain/failures/screen_failure.dart';
import '../../domain/repositories/i_screen_repository.dart';
import '../datasources/screen_data_source.dart';

/// Convierte lo que manda la fuente en [ServerScreen] y traduce sus errores
/// a [ScreenFailure]. Funciona igual con la fuente remota o la local.
class ScreenRepository implements IScreenRepository {
  ScreenRepository(this._source);

  final IScreenDataSource _source;

  @override
  Future<ServerScreen> getScreen(String name) async {
    final Map<String, dynamic> row;
    try {
      row = await _source.fetchScreen(name);
    } on ScreenNotFoundException {
      throw ScreenFailure('La pantalla «$name» no existe en el servidor.');
    } on ScreenSourceException catch (e) {
      throw ScreenFailure('No se pudo cargar la pantalla. ${e.message}');
    } on FormatException {
      throw const ScreenFailure('El servidor mandó un JSON inválido.');
    }

    final layout = row['layout'];
    if (layout is! Map<String, dynamic> || layout['type'] is! String) {
      throw const ScreenFailure(
        'La pantalla no trae un "layout" con "type" de Stac.',
      );
    }

    return ServerScreen(
      name: row['name'] as String? ?? name,
      title: row['title'] as String? ?? '',
      layout: layout,
    );
  }
}
