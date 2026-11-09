/// Respostas do usuário no questionário do Travel Match.
class TripPreferences {
  final String origem;
  final int orcamento;
  final int dias;
  final int pessoas;
  final String tipo;
  final String prioridade;

  const TripPreferences({
    required this.origem,
    required this.orcamento,
    required this.dias,
    required this.pessoas,
    required this.tipo,
    required this.prioridade,
  });

  factory TripPreferences.initial() => const TripPreferences(
        origem: 'Belo Horizonte',
        orcamento: 2500,
        dias: 5,
        pessoas: 2,
        tipo: 'Praia',
        prioridade: 'Economia',
      );

  TripPreferences copyWith({
    String? origem,
    int? orcamento,
    int? dias,
    int? pessoas,
    String? tipo,
    String? prioridade,
  }) =>
      TripPreferences(
        origem: origem ?? this.origem,
        orcamento: orcamento ?? this.orcamento,
        dias: dias ?? this.dias,
        pessoas: pessoas ?? this.pessoas,
        tipo: tipo ?? this.tipo,
        prioridade: prioridade ?? this.prioridade,
      );

  List<String> get resumo => [
        origem,
        formatBRL(orcamento),
        '$dias dias',
        pessoas == 1 ? '1 pessoa' : '$pessoas pessoas',
        tipo,
        prioridade,
      ];
}

/// Formata um valor em reais sem casas decimais: 2500 → "R$ 2.500".
String formatBRL(num valor) {
  final inteiro = valor.round().abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < inteiro.length; i++) {
    if (i > 0 && (inteiro.length - i) % 3 == 0) buffer.write('.');
    buffer.write(inteiro[i]);
  }
  return '${valor < 0 ? '-' : ''}R\$ $buffer';
}
