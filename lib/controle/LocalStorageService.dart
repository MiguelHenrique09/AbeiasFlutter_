import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trailer_dm/modelo/ItensCarrinho.dart';
import 'package:trailer_dm/modelo/Autorizacao.dart';
import 'package:trailer_dm/modelo/Usuario.dart';

class LocalStorageService {
  static const _chaveCarrinho = 'carrinho';
  static const _chaveEndereco = 'endereco_entrega';
  static const _chavePedidos = 'pedidos_cache';
  static const _chavePedidosCliente = 'pedidos_cliente';
  static const _chaveProximoId = 'proximo_id_pedido';
  static const _chaveAutorizacao = 'autorizacao';
  static const _chaveUsuarios = 'usuarios_cadastrados';
  static const _chaveUsuarioLogado = 'usuario_logado';

  // Carrinho
  Future<void> salvarCarrinho(List<ItensCarrinho> itens) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = itens.map((item) => item.toJson()).toList();
    await prefs.setString(_chaveCarrinho, jsonEncode(lista));
  }

  Future<List<ItensCarrinho>> carregarCarrinho() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chaveCarrinho);
    if (dados == null) return [];
    final lista = jsonDecode(dados) as List;
    return lista.map((json) => ItensCarrinho.fromJson(json)).toList();
  }

  Future<void> limparCarrinho() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveCarrinho);
  }

  // Chamado no long-press do Cardápio (Principal)
  Future<void> adicionarAoCarrinho(Map produto) async {
    final itens = await carregarCarrinho();
    final index = itens.indexWhere((i) => i.nome == produto["nome"]);

    if (index != -1) {
      itens[index].quantidade += 1;
    } else {
      itens.add(
        ItensCarrinho(
          nome: produto["nome"],
          descricao: produto["descricao"],
          preco: (produto["preco"] as num).toDouble(),
          quantidade: 1,
        ),
      );
    }
    await salvarCarrinho(itens);
  }

  // Endereço de entrega (salvo só ao finalizar o pedido, pois pode mudar)
  Future<void> salvarEnderecoEntrega(String endereco) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveEndereco, endereco);
  }

  Future<String?> carregarEnderecoEntrega() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveEndereco);
  }

  // Pedidos vindos da "API" simulada
  // Future<void> salvarPedidosCache(List<Map<String, dynamic>> pedidos) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(_chavePedidos, jsonEncode(pedidos));
  // }

  Future<List<Map<String, dynamic>>> carregarPedidosCache() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chavePedidos);
    if (dados == null) return [];
    final lista = jsonDecode(dados) as List;
    return lista.cast<Map<String, dynamic>>();
  }

  // Gera um ID sequencial (1, 2, 3...) pros pedidos do cliente
  Future<int> proximoIdPedido() async {
    final prefs = await SharedPreferences.getInstance();
    final atual = prefs.getInt(_chaveProximoId) ?? 1;
    await prefs.setInt(_chaveProximoId, atual + 1);
    return atual;
  }

  // Pedidos feitos pelo cliente (finalizados no Carrinho)
  Future<void> salvarPedidoCliente(Map<String, dynamic> pedido) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await carregarPedidosCliente();
    lista.add(pedido);
    await prefs.setString(_chavePedidosCliente, jsonEncode(lista));
  }

  Future<List<Map<String, dynamic>>> carregarPedidosCliente() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chavePedidosCliente);
    if (dados == null) return [];
    final lista = jsonDecode(dados) as List;
    return lista.cast<Map<String, dynamic>>();
  }

  // Autorização (sessão logada — guarda só qual usuário está logado)
  Future<void> salvarAutorizacao(Autorizacao auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveAutorizacao, jsonEncode(auth.toMap()));
  }

  Future<void> desgravarAutorizacao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveAutorizacao);
    await prefs.remove(_chaveUsuarioLogado);
  }

  // Dados do usuário logado (vindos da API no login)
  Future<void> salvarUsuarioLogado(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveUsuarioLogado, jsonEncode(usuario.toMap()));
  }

  Future<Autorizacao?> carregarAutorizacao() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chaveAutorizacao);
    if (dados == null) return null;
    return Autorizacao.fromMap(jsonDecode(dados));
  }

  Future<bool> verificaLogado() async {
    final auth = await carregarAutorizacao();
    return auth != null;
  }

  // Usuários cadastrados (nome, email, telefone, usuario, senha)
  Future<void> cadastrarUsuario(Usuario usuario) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await carregarUsuarios();
    lista.add(usuario);
    await prefs.setString(
      _chaveUsuarios,
      jsonEncode(lista.map((u) => u.toMap()).toList()),
    );
  }

  Future<List<Usuario>> carregarUsuarios() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chaveUsuarios);
    if (dados == null) return [];
    final lista = jsonDecode(dados) as List;
    return lista.map((json) => Usuario.fromMap(json)).toList();
  }

  Future<bool> usuarioExiste(String usuario) async {
    final lista = await carregarUsuarios();
    return lista.any((u) => u.usuario == usuario);
  }

  // Atualiza nome/email/telefone do usuário (usado ao salvar o Perfil)
  Future<void> atualizarUsuario(Usuario usuarioAtualizado) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await carregarUsuarios();
    final index = lista.indexWhere(
      (u) => u.usuario == usuarioAtualizado.usuario,
    );
    if (index != -1) {
      lista[index] = usuarioAtualizado;
      await prefs.setString(
        _chaveUsuarios,
        jsonEncode(lista.map((u) => u.toMap()).toList()),
      );
    }
  }

  // Retorna o Usuario de quem está logado no momento (salvo no login pela API)
  Future<Usuario?> usuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString(_chaveUsuarioLogado);
    if (dados == null) return null;
    return Usuario.fromMap(jsonDecode(dados));
  }
}
