import 'package:flutter/material.dart';
import 'package:trailer_dm/visao/util/layout.dart';
import 'package:trailer_dm/controle/ApiPedidos.dart';
import 'package:trailer_dm/controle/LocalStorageService.dart';
import 'package:trailer_dm/controle/AutorizacaoController.dart';

class Pedidos extends StatefulWidget {
  const Pedidos({super.key});

  @override
  State<Pedidos> createState() => _PedidosState();
}

class _PedidosState extends State<Pedidos> {
  final LocalStorageService _storage = LocalStorageService();
  List<dynamic> _pedidos = [];
  String _statusSelecionado = 'Todos';

  bool _carregando = true;
  bool _naoLogado = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  Future<void> _carregarPedidos() async {
    final auth = await _storage.carregarAutorizacao();

    if (!mounted) return;

    if (auth == null) {
      setState(() {
        _naoLogado = true;
        _carregando = false;
      });
      return;
    }

    try {
      final lista = await ApiPedido.pedidos(auth.tokenAutorizacao);
      if (!mounted) return;
      setState(() {
        _pedidos = lista;
        _erro = null;
        _naoLogado = false;
        _carregando = false;
      });
    } on ApiErro catch (e) {
      if (e.status == 401) {
        await AutorizacaoController.desgravaAutorizacao();
        if (!mounted) return;
        setState(() {
          _naoLogado = true;
          _carregando = false;
        });
      } else {
        _tratarErro(e.mensagem);
      }
    } catch (_) {
      _tratarErro("Não foi possível conectar ao servidor");
    }
  }

  void _tratarErro(String mensagem) {
    if (!mounted) return;
    if (_pedidos.isEmpty) {
      setState(() {
        _erro = mensagem;
        _carregando = false;
      });
    } else {
      setState(() => _carregando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem)));
    }
  }

  String _resumo(Map pedido) {
    final produtos = pedido["produtos"] as List;
    return produtos
        .map((p) => "${p["nome_produto"]} (${p["pivot"]["quantidade"]})")
        .join(", ");
  }

  String _data(Map pedido) {
    final d = DateTime.tryParse('${pedido["data_hora_pedido"]}')?.toLocal();
    if (d == null) return '';
    String dois(int n) => n.toString().padLeft(2, '0');
    return "${dois(d.day)}/${dois(d.month)}/${d.year} ${dois(d.hour)}:${dois(d.minute)}";
  }

  String _endereco(Map pedido) {
    final e = pedido["endereco"];
    return e == null ? '' : '$e';
  }

  void _mostrarFiltros() {
    const opcoes = ['Todos', 'Confirmando', 'Preparando', 'Pronto'];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final opcao in opcoes)
                ListTile(
                  title: Text(opcao),
                  trailing: _statusSelecionado == opcao
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    setState(() => _statusSelecionado = opcao);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Layout(currentIndex: 2, body: _conteudo());
  }

  Widget _conteudo() {
    if (_naoLogado) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Faça login",
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Você precisa estar logado para visualizar seus pedidos.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_erro!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _erro = null;
                    _carregando = true;
                  });
                  _carregarPedidos();
                },
                child: const Text("Tentar de novo"),
              ),
            ],
          ),
        ),
      );
    }

    final pedidos = _pedidos
        .where(
          (p) =>
              _statusSelecionado == 'Todos' ||
              p["statusPedido"] == _statusSelecionado,
        )
        .toList();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.orange,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _statusSelecionado == 'Todos'
                    ? "Pedidos"
                    : "Pedidos: $_statusSelecionado",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: _mostrarFiltros,
                child: const Icon(
                  Icons.format_list_bulleted,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _carregarPedidos,
            child: pedidos.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Text(
                          _pedidos.isEmpty
                              ? "Você ainda não possui pedidos."
                              : "Nenhum pedido com esse status.",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: pedidos.length,
                    itemBuilder: (context, i) {
                      final pedido = pedidos[i];
                      final double total = double.parse(
                        '${pedido["valor_total"]}',
                      );
                      final String data = _data(pedido);
                      final String endereco = _endereco(pedido);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: ListTile(
                          title: Text("Pedido ${pedido["idPedido"]}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data.isNotEmpty) Text("Data: $data"),
                              Text("Status: ${pedido["statusPedido"]}"),
                              Text("Itens: ${_resumo(pedido)}"),
                              if (endereco.isNotEmpty)
                                Text("Endereço: $endereco"),
                            ],
                          ),
                          trailing: Text(
                            "R\$ ${total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
