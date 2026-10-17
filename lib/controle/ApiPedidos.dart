import 'dart:convert';
import 'package:http/http.dart' as http;

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

  static Future<void> logout(String token) async {
    try {
      await http.post(Uri.parse('$base/logout'), headers: _headers(token));
    } catch (_) {}
  }

  // Envia o pedido. itens: [{idProduto, quantidade}]. O preço é calculado no servidor.
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

    if (r.statusCode == 401) {
      throw ApiErro('Sessão expirada. Faça login novamente.', 401);
    }

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

  // Pedidos de quem está logado
  static Future<List<dynamic>> pedidos(String token) async {
    final r = await http.get(
      Uri.parse('$base/pedidos'),
      headers: _headers(token),
    );

    if (r.statusCode == 401) {
      throw ApiErro('Sessão expirada. Faça login novamente.', 401);
    }
    if (r.statusCode != 200) {
      throw ApiErro('Erro ao carregar pedidos (${r.statusCode})', r.statusCode);
    }
    return jsonDecode(r.body);
  }
}
