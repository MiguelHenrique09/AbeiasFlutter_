import 'dart:convert';
import 'package:http/http.dart' as http;

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

  // Devolve {user: {...}, token: "..."}
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    final r = await http.post(
      Uri.parse('$base/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': senha}),
    );

    Map<String, dynamic> dados;
    try {
      dados = jsonDecode(r.body);
    } catch (_) {
      throw ApiErro('Erro ao entrar (${r.statusCode})');
    }

    if (r.statusCode != 200) {
      throw ApiErro(
        dados['errors']?['email']?[0] ?? dados['message'] ?? 'Erro ao entrar',
      );
    }
    return dados;
  }

  // Devolve {user: {...}, token: "..."}
  static Future<Map<String, dynamic>> cadastrar(
    String nome,
    String email,
    String senha,
  ) async {
    final r = await http.post(
      Uri.parse('$base/cadastrar'),
      headers: _headers(),
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'password': senha,
        'password_confirmation': senha,
      }),
    );

    Map<String, dynamic> dados;
    try {
      dados = jsonDecode(r.body);
    } catch (_) {
      throw ApiErro('Erro ao cadastrar (${r.statusCode})');
    }

    if (r.statusCode != 200 && r.statusCode != 201) {
      final erros = dados['errors'] as Map<String, dynamic>?;
      final primeiro = erros?.values.first;
      throw ApiErro(
        (primeiro is List ? primeiro.first : null) ??
            dados['message'] ??
            'Erro ao cadastrar',
      );
    }
    return dados;
  }

  static Future<void> logout(String token) async {
    try {
      await http.post(Uri.parse('$base/logout'), headers: _headers(token));
    } catch (_) {}
  }
}
