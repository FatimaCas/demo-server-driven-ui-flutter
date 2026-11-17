import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_store/features/home/data/datasources/screen_data_source.dart';
import 'package:sdui_store/features/home/data/repositories/screen_repository.dart';
import 'package:sdui_store/features/home/domain/failures/screen_failure.dart';

import '../../support/fakes.dart';

void main() {
  late FakeScreenDataSource source;
  late ScreenRepository repository;

  setUp(() {
    source = FakeScreenDataSource();
    repository = ScreenRepository(source);
  });

  test('convierte la respuesta en ServerScreen', () async {
    source.response = {
      'name': 'home',
      'title': 'SDUI Store',
      'layout': {'type': 'text', 'data': 'Hola'},
    };

    final screen = await repository.getScreen('home');

    expect(source.requested, ['home']);
    expect(screen.title, 'SDUI Store');
    expect(screen.layout['type'], 'text');
  });

  test('rechaza un layout sin "type"', () async {
    source.response = {'name': 'home', 'layout': {'data': 'Hola'}};

    expect(repository.getScreen('home'), throwsA(isA<ScreenFailure>()));
  });

  test('traduce "no existe" a ScreenFailure', () async {
    source.error = const ScreenNotFoundException('home');

    expect(
      repository.getScreen('home'),
      throwsA(isA<ScreenFailure>().having(
        (f) => f.message,
        'message',
        contains('no existe'),
      )),
    );
  });

  test('traduce un fallo de red a ScreenFailure', () async {
    source.error = const ScreenSourceException('timeout');

    expect(repository.getScreen('home'), throwsA(isA<ScreenFailure>()));
  });
}
