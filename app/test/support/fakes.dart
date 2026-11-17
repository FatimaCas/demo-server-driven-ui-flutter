import 'package:sdui_store/features/home/data/datasources/screen_data_source.dart';
import 'package:sdui_store/features/home/domain/entities/server_screen.dart';
import 'package:sdui_store/features/home/domain/failures/screen_failure.dart';
import 'package:sdui_store/features/home/domain/repositories/i_screen_repository.dart';

/// Fuente falsa: devuelve lo que se le dé o lanza lo que se le diga.
class FakeScreenDataSource implements IScreenDataSource {
  Map<String, dynamic>? response;
  Object? error;
  final requested = <String>[];

  @override
  Future<Map<String, dynamic>> fetchScreen(String name) async {
    requested.add(name);
    if (error != null) throw error!;
    return response!;
  }
}

/// Repositorio falso: entrega las pantallas en cola, en orden.
class FakeScreenRepository implements IScreenRepository {
  FakeScreenRepository(this.results);

  /// Cada elemento es un [ServerScreen] o un [ScreenFailure].
  final List<Object> results;
  int calls = 0;

  @override
  Future<ServerScreen> getScreen(String name) async {
    final result = results[calls.clamp(0, results.length - 1)];
    calls++;
    if (result is ScreenFailure) throw result;
    return result as ServerScreen;
  }
}

ServerScreen textScreen(String text, {String title = 'Prueba'}) => ServerScreen(
      name: 'home',
      title: title,
      layout: {'type': 'text', 'data': text},
    );
