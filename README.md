# demo-server-driven-ui-flutter

Demo de **Server-Driven UI** en Flutter con [Stac](https://stac.dev). Es una
tienda cuyo home (banner, categorías y productos destacados) lo describe el
servidor en JSON. Cambias los datos, recargas la app y la pantalla cambia sin
recompilar ni publicar una versión nueva.

```
app/      la app Flutter (GetX + Stac), arquitectura limpia por feature
server/   un servidor shelf en Dart + SQLite que arma las pantallas
```

## Cómo correrlo

**1. El servidor** (puerto 8080):

```bash
cd server
dart pub get
dart run bin/server.dart
```

**2. La app**, en otra terminal:

```bash
cd app
flutter pub get
flutter run
```

| Dónde corre la app | URL del servidor que usa |
|---|---|
| Emulador de Android | `http://10.0.2.2:8080` (el PC visto desde el emulador) |
| Web, escritorio, simulador de iOS | `http://localhost:8080` |
| Teléfono físico | `flutter run --dart-define=SERVER_URL=http://<IP-del-PC>:8080` |

**Sin servidor:** `flutter run --dart-define=DATA_SOURCE=local` lee
`app/assets/screens/home.json`. El título dice «(sin servidor)» para que se note.

## El truco de la demo

Los productos viven en SQLite (`server/data/store.db`, se crea sola la primera
vez). El servidor la consulta en cada petición y arma el JSON de Stac.

```bash
cd server
sqlite3 data/store.db "UPDATE products SET price = 150000 WHERE name = 'Audífonos BT'"
sqlite3 data/store.db "UPDATE settings SET value = '1' WHERE key = 'black_friday'"   # '0' para volver
```

Recarga la app (⟳ o pull-to-refresh) y la pantalla cambia sin recompilar.

### Widget propio: `productCard`

El servidor manda `{"type": "productCard", "name": ..., "price": ...}` y la app lo
dibuja con un parser propio (`app/lib/features/home/presentation/stac/product_card.dart`)
registrado en `Stac.initialize(parsers: [...])`.

### Versionado mínimo

El parser viaja *compilado* en la app: el JSON solo compone con el vocabulario
que la app ya trae. Por eso la app manda el header `x-client-version` y, si es
menor que 2, el servidor entrega la misma tarjeta con widgets básicos de Stac.

```bash
flutter run                              # vocabulario 2: usa productCard
flutter run --dart-define=VOCABULARY=1   # simula la app vieja (sin parser)
```

### Pantallas de muestra

`dart run bin/export_demo.dart` (en `server/`) escribe en `server/demo/` lo que
el servidor entrega con los datos iniciales: `home_normal`, `home_black_friday`
y `home_app_v1`. Las pruebas de la app las pintan.

## Arquitectura

La misma idea que `r_market`: capas por feature, inyección de dependencias,
view models que hablan con la **interfaz** del repositorio y sin casos de uso.

```
app/lib/
  main.dart                 Stac.initialize() + GetMaterialApp
  core/
    config/app_config.dart  DATA_SOURCE y SERVER_URL (--dart-define)
    di/app_bindings.dart    raíz de composición: elige remoto o local
  features/home/
    domain/
      entities/server_screen.dart        nombre, título y el layout (JSON de Stac)
      repositories/i_screen_repository.dart
      failures/screen_failure.dart
    data/
      datasources/screen_data_source.dart          interfaz + excepciones
      datasources/screen_remote_data_source.dart   GET /screens/<name> (http)
      datasources/screen_local_data_source.dart    assets/screens/<name>.json
      repositories/screen_repository.dart          mapa → entidad, errores → Failure
    presentation/
      viewmodels/home_view_model.dart   GetxController: screen, error, isLoading
      pages/home_page.dart              cascarón nativo + Stac.fromJson(layout)
```

**Dónde entra Stac.** El dominio y los datos no saben que existe Stac: para
ellos el layout es un `Map`. Solo `home_page.dart` llama a `Stac.fromJson`. Lo
nativo (AppBar, pull-to-refresh, carga, errores) vive en la app. Lo que va dentro
del scroll lo decide el servidor.

**Si una recarga falla**, el view model conserva la última pantalla buena y
muestra el error encima.

### El formato que entrega el servidor

```json
{
  "name": "home",
  "title": "SDUI Store",
  "layout": { "type": "column", "children": [ ... ] }
}
```

`layout` es JSON de Stac. Ejemplos de widgets en [docs.stac.dev](https://docs.stac.dev/).

## Pruebas

```bash
cd app
flutter test
```

Ninguna habla con el servidor: usan falsos escritos a mano (`test/support/fakes.dart`).

| Archivo | Qué prueba |
|---|---|
| `test/unit/home/screen_repository_test.dart` | convertir la respuesta y traducir errores, con fuente falsa |
| `test/unit/home/home_view_model_test.dart` | carga, error y recarga, con repositorio falso |
| `test/widget/home/home_page_test.dart` | que la página pinta el JSON, recarga y muestra errores; además pinta cada JSON de `server/demo/` en tamaño teléfono y falla si hay un widget de error de Stac o un desborde |
