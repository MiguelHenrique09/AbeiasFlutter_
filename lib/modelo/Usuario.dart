class Usuario {
  final String usuario;
  final String senha;
  String nome;
  String email;
  String telefone;

  Usuario({
    required this.usuario,
    required this.senha,
    required this.nome,
    required this.email,
    required this.telefone,
  });

  Map<String, dynamic> toMap() => {
    'usuario': usuario,
    'senha': senha,
    'nome': nome,
    'email': email,
    'telefone': telefone,
  };

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
    usuario: map['usuario'] ?? '',
    senha: map['senha'] ?? '',
    nome: map['nome'] ?? '',
    email: map['email'] ?? '',
    telefone: map['telefone'] ?? '',
  );
}
