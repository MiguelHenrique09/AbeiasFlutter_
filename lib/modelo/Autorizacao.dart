class Autorizacao {
  final String email;
  final String senha;
  final String tokenAutorizacao;

  Autorizacao({
    required this.email,
    required this.senha,
    required this.tokenAutorizacao,
  });

  Map<String, dynamic> toMap() => {
    'email': email,
    'senha': senha,
    'tokenAutorizacao': tokenAutorizacao,
  };

  factory Autorizacao.fromMap(Map<String, dynamic> map) => Autorizacao(
    email: map['email'] ?? '',
    senha: map['senha'] ?? '',
    tokenAutorizacao: map['tokenAutorizacao'] ?? '',
  );
}
