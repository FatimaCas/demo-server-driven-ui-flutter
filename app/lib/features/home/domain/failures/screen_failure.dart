/// Lo único que la presentación ve cuando cargar una pantalla falla.
class ScreenFailure implements Exception {
  const ScreenFailure(this.message);

  final String message;

  @override
  String toString() => 'ScreenFailure: $message';
}
