import 'package:sqlite3/sqlite3.dart';

/// Un producto de la tabla `products`.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
    this.oldPrice,
  });

  final int id;
  final String name;
  final int price;
  final int? oldPrice;

  /// Nombre de un ícono de Material (el mismo que entiende Stac).
  final String icon;
}

/// Base de datos de la tienda: productos y un par de banderas.
///
/// Es la fuente de verdad. El servidor la consulta en cada petición y arma
/// el JSON de Stac con lo que encuentra: cambiar una fila cambia la app.
class StoreDb {
  StoreDb._(this._db);

  /// Abre (o crea) la base en [path]. `:memory:` sirve para pruebas.
  factory StoreDb.open(String path) {
    final store = StoreDb._(sqlite3.open(path));
    store._createSchema();
    return store;
  }

  final Database _db;

  void _createSchema() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        old_price INTEGER,
        icon TEXT NOT NULL,
        featured INTEGER NOT NULL DEFAULT 1
      );
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');

    final empty = _db.select('SELECT COUNT(*) AS n FROM products').first['n'] == 0;
    if (empty) {
      _db.execute('''
        INSERT INTO products (name, price, old_price, icon) VALUES
          ('Audífonos BT',      200900, 299900, 'headphones'),
          ('Silla ergonómica',  520000, 780000, 'chair'),
          ('Balón profesional',  99900, 149900, 'sports_soccer'),
          ('Reloj inteligente', 349900, 499900, 'watch');
        INSERT OR IGNORE INTO settings (key, value) VALUES ('black_friday', '0');
      ''');
    }
  }

  /// Productos destacados, en el orden de la tabla.
  List<Product> featuredProducts() {
    return [
      for (final row in _db.select(
        'SELECT id, name, price, old_price, icon FROM products '
        'WHERE featured = 1 ORDER BY id',
      ))
        Product(
          id: row['id'] as int,
          name: row['name'] as String,
          price: row['price'] as int,
          oldPrice: row['old_price'] as int?,
          icon: row['icon'] as String,
        ),
    ];
  }

  bool get blackFriday => _setting('black_friday') == '1';
  set blackFriday(bool value) => _db.execute(
        'INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)',
        ['black_friday', value ? '1' : '0'],
      );

  String? _setting(String key) {
    final rows = _db.select('SELECT value FROM settings WHERE key = ?', [key]);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  void close() => _db.close();
}
