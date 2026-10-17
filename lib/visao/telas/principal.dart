import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trailer_dm/controle/ApiProduto.dart';
import 'package:trailer_dm/modelo/ItensCarrinho.dart';
import 'package:trailer_dm/visao/util/layout.dart';
import 'package:trailer_dm/controle/LocalStorageService.dart';

class Principal extends StatelessWidget {
  const Principal({super.key});

  @override
  Widget build(BuildContext context) {
    return const Layout(currentIndex: 0, body: _Cardapio());
  }
}

class _Cardapio extends StatefulWidget {
  const _Cardapio();

  @override
  State<_Cardapio> createState() => _CardapioState();
}

class _CardapioState extends State<_Cardapio> {
  final LocalStorageService _storage = LocalStorageService();
  late Future<List<dynamic>> _futuroProdutos;
  String _tipoSelecionado = 'Todos';

  @override
  void initState() {
    super.initState();
    _futuroProdutos = ApiProduto.produtos();
  }

  Future<void> _adicionarProduto(BuildContext context, Map produto) async {
    try {
      final int id = produto['idProduto'];
      final itens = await _storage.carregarCarrinho();
      final index = itens.indexWhere((i) => i.idProduto == id);

      if (index != -1) {
        itens[index].quantidade += 1;
      } else {
        itens.add(
          ItensCarrinho(
            idProduto: id,
            nome: produto['nome_produto'],
            descricao: produto['descricao'],
            preco: double.parse('${produto['preco_atual']}'),
            quantidade: 1,
          ),
        );
      }

      await _storage.salvarCarrinho(itens);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Adicionado ao carrinho!")),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _mostrarDetalhes(BuildContext context, Map produto, double preco) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(produto['nome_produto']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(produto['descricao']),
              const SizedBox(height: 12),
              Text(
                "R\$ ${preco.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
              onPressed: () => _adicionarProduto(context, produto),
              child: const Text("Adicionar ao carrinho"),
            ),
          ],
        );
      },
    );
  }

  // texto = o que aparece na barra | valor = o que vem em tipo_produto
  Widget _filtro(String texto, String valor) {
    final bool selecionado = _tipoSelecionado == valor;

    return GestureDetector(
      onTap: () => setState(() => _tipoSelecionado = valor),
      child: Text(
        texto,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selecionado
              ? const Color.fromARGB(255, 4, 0, 36)
              : Colors.white,
          decoration: selecionado ? TextDecoration.underline : null,
          decorationColor: const Color.fromARGB(255, 4, 0, 36),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color.fromARGB(255, 230, 154, 14),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _filtro('Todos', 'Todos'),
              _filtro('Lanches', 'Lanche'),
              _filtro('Porções', 'Porção'),
              _filtro('Bebidas', 'Bebida'),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _futuroProdutos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          snapshot.error.toString().replaceFirst(
                            'Exception: ',
                            '',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _futuroProdutos = ApiProduto.produtos();
                            });
                          },
                          child: const Text("Tentar de novo"),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final todos = snapshot.data!;
              final produtos = todos
                  .where(
                    (p) =>
                        _tipoSelecionado == 'Todos' ||
                        p['tipo_produto'] == _tipoSelecionado,
                  )
                  .toList();

              if (produtos.isEmpty) {
                return const Center(child: Text("Nenhum produto encontrado."));
              }

              return ListView.builder(
                itemCount: produtos.length,
                itemBuilder: (context, i) {
                  final produto = produtos[i];
                  final String? imagem = produto['imagem_url'];
                  final double preco = double.parse(
                    '${produto['preco_atual']}',
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      onTap: () => _mostrarDetalhes(context, produto, preco),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: imagem == null
                              ? const Icon(Icons.fastfood, size: 32)
                              : CachedNetworkImage(
                                  imageUrl: imagem,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.broken_image),
                                ),
                        ),
                      ),
                      title: Text(
                        produto['nome_produto'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        produto['descricao'],
                        style: const TextStyle(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: SizedBox(
                        width: 80,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "R\$ ${preco.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
