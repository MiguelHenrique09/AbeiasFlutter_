import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiProduto {
  static const String base = 'https://abeias.wasmer.app/api';

  static Future<List<dynamic>> produtos() async {
    final r = await http.get(
      Uri.parse('$base/produtos'),
      headers: {'Accept': 'application/json'},
    );
    if (r.statusCode != 200) {
      throw Exception('Erro ao carregar produtos (${r.statusCode})');
    }
    return jsonDecode(r.body);
  }
}
