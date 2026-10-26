import 'package:trailer_dm/modelo/Autorizacao.dart';
import 'package:trailer_dm/modelo/Usuario.dart';
import 'package:trailer_dm/controle/ApiPedidos.dart';
import 'package:trailer_dm/controle/LocalStorageService.dart';

class AutorizacaoController {
  static final LocalStorageService _storage = LocalStorageService();

  static Future<void> salvarSessaoWeb({
    required String token,
    required String nome,
    required String email,
  }) async {
    await _storage.salvarAutorizacao(
      Autorizacao(email: email, senha: '', tokenAutorizacao: token),
    );
    await _storage.salvarUsuarioLogado(
      Usuario(usuario: email, senha: '', nome: nome, email: email),
    );
  }

  static Future<void> desgravaAutorizacao() async {
    final auth = await _storage.carregarAutorizacao();
    if (auth != null) {
      await ApiPedido.logout(auth.tokenAutorizacao);
    }
    await _storage.desgravarAutorizacao();
  }

  static Future<bool> verificaAutorizacaoOffline() async {
    return await _storage.verificaLogado();
  }
}
