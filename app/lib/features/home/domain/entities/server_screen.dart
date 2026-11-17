/// Una pantalla descrita por el servidor.
///
/// [layout] es el árbol de widgets en el formato de Stac (`{"type": ...}`).
/// El dominio no sabe nada de Stac: solo guarda el JSON tal cual.
class ServerScreen {
  const ServerScreen({
    required this.name,
    required this.title,
    required this.layout,
  });

  final String name;
  final String title;
  final Map<String, dynamic> layout;
}
