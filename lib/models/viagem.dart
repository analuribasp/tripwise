/// Status possíveis de uma viagem (CHECK da tabela `viagens`).
const statusViagem = ['Planejada', 'Confirmada', 'Concluída'];

/// Viagem salva pelo usuário (tabela `viagens` + dados do destino via JOIN).
class Viagem {
  final int? id;
  final int usuarioId;
  final int destinoId;
  final String destinoNome;
  final String destinoUf;
  final DateTime dataIda;
  final DateTime dataVolta;
  final int pessoas;
  final double orcamento;
  final double custoEstimado;
  final int matchPercent;
  final String status;
  final String observacoes;

  const Viagem({
    this.id,
    required this.usuarioId,
    required this.destinoId,
    this.destinoNome = '',
    this.destinoUf = '',
    required this.dataIda,
    required this.dataVolta,
    required this.pessoas,
    required this.orcamento,
    required this.custoEstimado,
    required this.matchPercent,
    this.status = 'Planejada',
    this.observacoes = '',
  });

  int get dias => dataVolta.difference(dataIda).inDays + 1;

  factory Viagem.fromMap(Map<String, Object?> m) => Viagem(
        id: m['id'] as int,
        usuarioId: m['usuario_id'] as int,
        destinoId: m['destino_id'] as int,
        destinoNome: (m['destino_nome'] as String?) ?? '',
        destinoUf: (m['destino_uf'] as String?) ?? '',
        dataIda: DateTime.parse(m['data_ida'] as String),
        dataVolta: DateTime.parse(m['data_volta'] as String),
        pessoas: m['pessoas'] as int,
        orcamento: (m['orcamento'] as num).toDouble(),
        custoEstimado: (m['custo_estimado'] as num).toDouble(),
        matchPercent: m['match_percent'] as int,
        status: m['status'] as String,
        observacoes: (m['observacoes'] as String?) ?? '',
      );

  /// Colunas gravadas na tabela `viagens`.
  Map<String, Object?> toMap() => {
        'usuario_id': usuarioId,
        'destino_id': destinoId,
        'data_ida': dataIso(dataIda),
        'data_volta': dataIso(dataVolta),
        'pessoas': pessoas,
        'orcamento': orcamento,
        'custo_estimado': custoEstimado,
        'match_percent': matchPercent,
        'status': status,
        'observacoes': observacoes,
      };

  Viagem copyWith({
    DateTime? dataIda,
    DateTime? dataVolta,
    int? pessoas,
    double? orcamento,
    double? custoEstimado,
    String? status,
    String? observacoes,
  }) =>
      Viagem(
        id: id,
        usuarioId: usuarioId,
        destinoId: destinoId,
        destinoNome: destinoNome,
        destinoUf: destinoUf,
        dataIda: dataIda ?? this.dataIda,
        dataVolta: dataVolta ?? this.dataVolta,
        pessoas: pessoas ?? this.pessoas,
        orcamento: orcamento ?? this.orcamento,
        custoEstimado: custoEstimado ?? this.custoEstimado,
        matchPercent: matchPercent,
        status: status ?? this.status,
        observacoes: observacoes ?? this.observacoes,
      );
}

/// Item do roteiro de uma viagem (tabela `roteiro_itens`).
class RoteiroItem {
  final int? id;
  final int viagemId;
  final int dia;
  final String titulo;
  final String descricao;
  final bool concluido;

  const RoteiroItem({
    this.id,
    required this.viagemId,
    required this.dia,
    required this.titulo,
    this.descricao = '',
    this.concluido = false,
  });

  factory RoteiroItem.fromMap(Map<String, Object?> m) => RoteiroItem(
        id: m['id'] as int,
        viagemId: m['viagem_id'] as int,
        dia: m['dia'] as int,
        titulo: m['titulo'] as String,
        descricao: (m['descricao'] as String?) ?? '',
        concluido: (m['concluido'] as int) == 1,
      );

  Map<String, Object?> toMap() => {
        'viagem_id': viagemId,
        'dia': dia,
        'titulo': titulo,
        'descricao': descricao,
        'concluido': concluido ? 1 : 0,
      };
}

/// Data no formato do banco: AAAA-MM-DD.
String dataIso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_doisDigitos(d.month)}-${_doisDigitos(d.day)}';

/// Data no formato brasileiro: DD/MM/AAAA.
String dataBr(DateTime d) => '${_doisDigitos(d.day)}/${_doisDigitos(d.month)}/${d.year}';

/// Data curta: "12 nov".
String dataCurta(DateTime d) {
  const meses = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];
  return '${d.day} ${meses[d.month - 1]}';
}

String _doisDigitos(int n) => n.toString().padLeft(2, '0');
