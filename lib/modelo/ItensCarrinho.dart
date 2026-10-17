class ItensCarrinho {
  final int idProduto;
  final String nome;
  final String descricao;
  final double preco;
  int quantidade;

  ItensCarrinho({
    this.idProduto = 0,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.quantidade,
  });

  Map<String, dynamic> toJson() => {
    'idProduto': idProduto,
    'nome': nome,
    'descricao': descricao,
    'preco': preco,
    'quantidade': quantidade,
  };

  factory ItensCarrinho.fromJson(Map<String, dynamic> json) => ItensCarrinho(
    idProduto: json['idProduto'] ?? 0,
    nome: json['nome'],
    descricao: json['descricao'],
    preco: (json['preco'] as num).toDouble(),
    quantidade: json['quantidade'],
  );
}
