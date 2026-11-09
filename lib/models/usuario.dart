/// Usuário cadastrado (tabela `usuarios` + estilos de `usuario_estilos`).
class Usuario {
  final int id;
  final String nome;
  final String email;
  final String cidadeOrigem;
  final List<String> estilos;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.cidadeOrigem = '',
    this.estilos = const [],
  });

  factory Usuario.fromMap(Map<String, Object?> m,
          {List<String> estilos = const []}) =>
      Usuario(
        id: m['id'] as int,
        nome: m['nome'] as String,
        email: m['email'] as String,
        cidadeOrigem: (m['cidade_origem'] as String?) ?? '',
        estilos: estilos,
      );

  String get primeiroNome => nome.trim().split(RegExp(r'\s+')).first;
}
