import 'dart:convert';
import 'package:http/http.dart' as http;

// Erro da API: mensagem para o usuário + status HTTP (ex.: 401)
class ApiErro implements Exception {
  final String mensagem;
  final int? status;
  ApiErro(this.mensagem, [this.status]);

  @override
  String toString() => mensagem;
}

class ApiPedido {
  static const String base = 'https://abeias.wasmer.app/api';

  static Map<String, String> _headers([String? token]) => {
    'Accept': 'application/json', // faz o Laravel responder em JSON
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static void _checar401(http.Response r) {
    if (r.statusCode == 401) {
      throw ApiErro('Sessão expirada. Faça login novamente.', 401);
    }
  }

  static Future<List<dynamic>> produtos() async {
    final r = await http.get(Uri.parse('$base/produtos'), headers: _headers());
    if (r.statusCode != 200) {
      throw ApiErro('Erro ao carregar produtos (${r.statusCode})');
    }
    return jsonDecode(r.body);
  }

  static Future<List<dynamic>> pedidos(String token) async {
    final r = await http.get(
      Uri.parse('$base/pedidos'),
      headers: _headers(token),
    );

    _checar401(r);
    if (r.statusCode != 200) {
      throw ApiErro('Erro ao carregar pedidos (${r.statusCode})', r.statusCode);
    }
    return jsonDecode(r.body);
  }

  static Future<void> criarPedido(
    String token,
    String endereco,
    String observacoes,
    List<Map<String, dynamic>> itens,
  ) async {
    final r = await http.post(
      Uri.parse('$base/pedidos'),
      headers: _headers(token),
      body: jsonEncode({
        'endereco': endereco,
        'observacoes': observacoes,
        'itens': itens,
      }),
    );

    if (r.statusCode == 201) return;

    String mensagem = 'Erro ao enviar pedido (${r.statusCode})';
    try {
      final dados = jsonDecode(r.body);
      final erros = dados['errors'];
      if (erros is Map && erros.isNotEmpty) {
        mensagem = '${erros.values.first[0]}';
      } else if (dados['message'] != null) {
        mensagem = '${dados['message']}';
      }
    } catch (_) {}

    throw ApiErro(mensagem, r.statusCode);
  }

  static Future<void> logout(String token) async {
    try {
      await http.post(Uri.parse('$base/logout'), headers: _headers(token));
    } catch (_) {}
  }
}
