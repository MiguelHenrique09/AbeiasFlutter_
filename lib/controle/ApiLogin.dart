import 'dart:convert';
import 'package:http/http.dart' as http;

// Exceção própria da API: guarda uma mensagem pronta para mostrar ao usuário
class ApiErro implements Exception {
  final String mensagem;
  ApiErro(this.mensagem);

  @override
  String toString() => mensagem;
}

class ApiLogin {
  static const String base = 'https://abeias.wasmer.app/api';

  static Map<String, String> _headers([String? token]) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static Future<List<dynamic>> produtos() async {
    final r = await http.get(Uri.parse('$base/produtos'), headers: _headers());
    if (r.statusCode != 200) {
      throw ApiErro('Erro ao carregar produtos (${r.statusCode})');
    }
    return jsonDecode(r.body);
  }

  static Future<void> logout(String token) async {
    try {
      await http.post(Uri.parse('$base/logout'), headers: _headers(token));
    } catch (_) {}
  }
}
