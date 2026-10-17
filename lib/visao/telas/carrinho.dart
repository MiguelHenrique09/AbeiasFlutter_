import 'package:flutter/material.dart';
import 'package:trailer_dm/visao/util/layout.dart';
import 'package:trailer_dm/visao/telas/login.dart';
import 'package:trailer_dm/modelo/ItensCarrinho.dart';
import 'package:trailer_dm/controle/ApiPedidos.dart';
import 'package:trailer_dm/controle/LocalStorageService.dart';
import 'package:trailer_dm/controle/AutorizacaoController.dart';

class Carrinho extends StatefulWidget {
  const Carrinho({super.key});

  @override
  State<Carrinho> createState() => _CarrinhoState();
}

class _CarrinhoState extends State<Carrinho> {
  final LocalStorageService _storage = LocalStorageService();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();
  List<ItensCarrinho> itens = [];
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _carregarDados() async {
    final itensSalvos = await _storage.carregarCarrinho();
    final endereco = await _storage.carregarEnderecoEntrega();

    if (!mounted) return;

    setState(() {
      // descarta itens antigos que não têm id de produto da API
      itens = itensSalvos.where((i) => i.idProduto != 0).toList();
      if (endereco != null) _enderecoController.text = endereco;
    });
  }

  Future<void> _alterarQuantidade(int index, int delta) async {
    setState(() {
      itens[index].quantidade += delta;
      if (itens[index].quantidade <= 0) itens.removeAt(index);
    });
    await _storage.salvarCarrinho(itens);
  }

  Future<void> _removerItem(int index) async {
    setState(() {
      itens.removeAt(index);
    });
    await _storage.salvarCarrinho(itens);
  }

  void _irParaLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  Future<void> _finalizarPedido() async {
    if (itens.isEmpty || _enviando) return;
    _enviando = true;

    try {
      final auth = await _storage.carregarAutorizacao();
      if (auth == null)
        throw ApiErro('Faça login para finalizar o pedido.', 401);

      await ApiPedido.criarPedido(
        auth.tokenAutorizacao,
        _enderecoController.text.trim(),
        _observacaoController.text.trim(),
        itens
            .map<Map<String, dynamic>>(
              (i) => {'idProduto': i.idProduto, 'quantidade': i.quantidade},
            )
            .toList(),
      );

      await _storage.limparCarrinho();
      _observacaoController.clear();

      if (!mounted) return;
      setState(() {
        itens = [];
      });
      _mensagem("Pedido enviado com sucesso!");
    } on ApiErro catch (e) {
      if (!mounted) return;
      if (e.status == 401) {
        await AutorizacaoController.desgravaAutorizacao();
        if (!mounted) return;
        _mensagem(e.mensagem);
        _irParaLogin();
      } else {
        _mensagem(e.mensagem);
      }
    } catch (_) {
      if (mounted) _mensagem("Não foi possível conectar ao servidor");
    } finally {
      _enviando = false;
    }
  }

  void abrirDialogPedido() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Finalizar Pedido"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Informe o endereço de entrega:"),
              const SizedBox(height: 10),
              TextField(
                controller: _enderecoController,
                decoration: const InputDecoration(
                  hintText: "Rua, número, bairro...",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final logado =
                    await AutorizacaoController.verificaAutorizacaoOffline();

                if (!context.mounted) return;

                Navigator.pop(context); // fecha o dialog

                if (!logado) {
                  _irParaLogin();
                  return;
                }

                await _storage.salvarEnderecoEntrega(_enderecoController.text);
                await _finalizarPedido();
              },
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Layout(currentIndex: 1, body: _conteudo());
  }

  Widget _conteudo() {
    if (itens.isEmpty) {
      return const Center(child: Text("Seu carrinho está vazio"));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: itens.length,
            itemBuilder: (context, i) {
              var item = itens[i];
              return ListTile(
                title: Text(item.nome),
                subtitle: Text(item.descricao),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removerItem(i),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _alterarQuantidade(i, -1),
                    ),
                    Text(
                      "${item.quantidade}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _alterarQuantidade(i, 1),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: TextField(
            controller: _observacaoController,
            decoration: const InputDecoration(
              hintText: "Observações",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        InkWell(
          onTap: abrirDialogPedido,
          child: Container(
            width: double.infinity,
            color: const Color.fromARGB(255, 230, 154, 14),
            padding: const EdgeInsets.all(15),
            child: const Center(
              child: Text(
                "Finalizar Pedido",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
