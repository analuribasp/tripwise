/// Custo de referência de um destino (tabela `custos_destino`).
class CostItem {
  final String label;
  final double valor;

  /// `pessoa`, `noite` ou `pessoa_dia`.
  final String unidade;

  const CostItem(this.label, this.valor, this.unidade);

  factory CostItem.fromMap(Map<String, Object?> m) => CostItem(
        m['item'] as String,
        (m['valor'] as num).toDouble(),
        m['unidade'] as String,
      );

  /// Valor total para uma viagem de [dias] dias com [pessoas] pessoas.
  double totalPara({required int dias, required int pessoas}) {
    final noites = dias > 1 ? dias - 1 : 1;
    final quartos = (pessoas / 2).ceil();
    return switch (unidade) {
      'noite' => valor * noites * quartos,
      'pessoa_dia' => valor * pessoas * dias,
      _ => valor * pessoas,
    };
  }
}

/// Um dia do roteiro sugerido (tabela `roteiro_modelo`).
class DayPlan {
  final int dia;
  final String titulo;
  final String descricao;

  const DayPlan(this.dia, this.titulo, this.descricao);

  factory DayPlan.fromMap(Map<String, Object?> m) => DayPlan(
        m['dia'] as int,
        m['titulo'] as String,
        (m['descricao'] as String?) ?? '',
      );
}

/// Destino recomendável pelo Travel Match (tabela `destinos`).
class Destination {
  final int id;
  final String name;
  final String state;
  final List<String> categorias;
  final String travelInfo;
  final String description;
  final String highlight;
  final int matchBase;
  final List<CostItem> costs;
  final List<DayPlan> itinerary;

  const Destination({
    required this.id,
    required this.name,
    required this.state,
    required this.categorias,
    required this.travelInfo,
    required this.description,
    required this.highlight,
    required this.matchBase,
    this.costs = const [],
    this.itinerary = const [],
  });

  factory Destination.fromMap(
    Map<String, Object?> m, {
    List<CostItem> costs = const [],
    List<DayPlan> itinerary = const [],
  }) =>
      Destination(
        id: m['id'] as int,
        name: m['nome'] as String,
        state: m['uf'] as String,
        categorias: (m['categorias'] as String).split(','),
        travelInfo: (m['info_transporte'] as String?) ?? '',
        description: (m['descricao'] as String?) ?? '',
        highlight: (m['destaque'] as String?) ?? '',
        matchBase: m['match_base'] as int,
        costs: costs,
        itinerary: itinerary,
      );

  String get category => categorias.join(' + ').toLowerCase();

  double custoPara({required int dias, required int pessoas}) => costs.fold(
      0, (soma, c) => soma + c.totalPara(dias: dias, pessoas: pessoas));
}

/// Resultado do Travel Match para um destino.
class MatchResult {
  final Destination destino;
  final int percent;
  final double custo;
  final int orcamento;
  final int dias;
  final int pessoas;
  final List<String> motivos;

  const MatchResult({
    required this.destino,
    required this.percent,
    required this.custo,
    required this.orcamento,
    required this.dias,
    required this.pessoas,
    required this.motivos,
  });

  double get folga => orcamento - custo;
}
