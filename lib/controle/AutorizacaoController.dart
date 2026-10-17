import 'package:trailer_dm/modelo/Autorizacao.dart';
import 'package:trailer_dm/modelo/Usuario.dart';
import 'package:trailer_dm/controle/ApiLogin.dart';
import 'package:trailer_dm/controle/LocalStorageService.dart';

class AutorizacaoController {
  static final LocalStorageService _storage = LocalStorageService();

  // Login pela API do Laravel. Lança ApiErro se der errado.
  static Future<bool> verificaAutorizacaoOnline(Autorizacao auth) async {
    final dados = await ApiLogin.login(auth.email, auth.senha);
    final user = dados['user'];

    await _storage.salvarAutorizacao(
      Autorizacao(
        email: user['email'] ?? auth.email,
        senha: '',
        tokenAutorizacao: dados['token'],
      ),
    );

    await _storage.salvarUsuarioLogado(
      Usuario(
        usuario: user['email'] ?? auth.email,
        senha: '',
        nome: user['nome'] ?? '',
        email: user['email'] ?? auth.email,
        telefone: '',
      ),
    );

    return true;
  }

  // Cadastro ainda é local (será trocado pela API no próximo passo)
  static Future<bool> cadastrarUsuario(Usuario usuario) async {
    final existe = await _storage.usuarioExiste(usuario.email);
    if (existe) return false;
    await _storage.cadastrarUsuario(usuario);
    return true;
  }

  static Future<void> desgravaAutorizacao() async {
    final auth = await _storage.carregarAutorizacao();
    if (auth != null) {
      await ApiLogin.logout(auth.tokenAutorizacao);
    }
    await _storage.desgravarAutorizacao();
  }

  static Future<bool> verificaAutorizacaoOffline() async {
    return await _storage.verificaLogado();
  }
}
