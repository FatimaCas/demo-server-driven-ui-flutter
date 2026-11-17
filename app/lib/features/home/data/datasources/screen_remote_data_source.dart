import 'dart:convert';

import 'package:http/http.dart' as http;

import 'screen_data_source.dart';

/// Pide las pantallas al servidor shelf: `GET <baseUrl>/screens/<name>`.
class ScreenRemoteDataSource implements IScreenDataSource {
  ScreenRemoteDataSource({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Future<Map<String, dynamic>> fetchScreen(String name) async {
    final http.Response response;
    try {
      response = await _client
          .get(Uri.parse('$baseUrl/screens/$name'))
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      throw ScreenSourceException('No se pudo contactar a $baseUrl ($e)');
    }

    if (response.statusCode == 404) throw ScreenNotFoundException(name);
    if (response.statusCode != 200) {
      throw ScreenSourceException('El servidor respondió ${response.statusCode}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }
}
