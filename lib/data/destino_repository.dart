import '../models/destination.dart';
import '../models/trip_preferences.dart';
import 'database_helper.dart';

/// Leitura de destinos, cálculo do Travel Match, buscas e favoritos.
class DestinoRepository {
  DestinoRepository._();

  /// READ: todos os destinos, com custos e roteiro modelo.
  static Future<List<Destination>> listar() async {
    final db = await DatabaseHelper.db();
    final destinos = await db.query('destinos', orderBy: 'id');
    final custos = await db.query('custos_destino', orderBy: 'id');
    final roteiro = await db.query('roteiro_modelo', orderBy: 'destino_id, dia');
    return [
      for (final d in destinos)
        Destination.fromMap(
          d,
          costs: custos
              .where((c) => c['destino_id'] == d['id'])
              .map(CostItem.fromMap)
              .toList(),
          itinerary: roteiro
              .where((r) => r['destino_id'] == d['id'])
              .map(DayPlan.fromMap)
              .toList(),
        ),
    ];
  }

  /// READ: um destino pelo id.
  static Future<Destination?> buscarPorId(int id) async {
    final todos = await listar();
    for (final d in todos) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// Calcula a compatibilidade de cada destino com as preferências e
  /// devolve os [limite] melhores, do maior para o menor match.
  static Future<List<MatchResult>> calcularMatch(TripPreferences prefs,
      {int limite = 3}) async {
    final destinos = await listar();
    final resultados = destinos.map((d) => avaliar(d, prefs)).toList()
      ..sort((a, b) => b.percent.compareTo(a.percent));
    return resultados.take(limite).toList();
  }

  /// Regra do match: parte da nota base do destino e ajusta conforme o
  /// tipo de viagem, o orçamento e a prioridade escolhida.
  static MatchResult avaliar(Destination d, TripPreferences prefs) {
    final custo = d.custoPara(dias: prefs.dias, pessoas: prefs.pessoas);
    final orcamento = prefs.orcamento;
    var nota = d.matchBase.toDouble();
    final motivos = <String>[];

    if (d.categorias.contains(prefs.tipo)) {
      motivos.add('Combina com viagem de ${prefs.tipo.toLowerCase()}');
    } else {
      nota -= 30;
    }

    if (custo <= orcamento) {
      motivos.add(
          'Cabe no orçamento para ${prefs.pessoas} ${prefs.pessoas == 1 ? 'pessoa' : 'pessoas'}');
      if (prefs.prioridade == 'Economia' && custo <= orcamento * 0.85) {
        nota += 3;
      }
    } else {
      final excesso = (custo - orcamento) / orcamento * 100;
      nota -= excesso.clamp(5, 30);
      motivos.add('Passa ${formatBRL(custo - orcamento)} do orçamento');
    }

    if (prefs.prioridade == 'Experiência' &&
        d.categorias.any((c) => c == 'Natureza' || c == 'Cultura')) {
      nota += 3;
    }
    if (d.highlight.isNotEmpty) motivos.add(d.highlight);

    return MatchResult(
      destino: d,
      percent: nota.round().clamp(30, 99),
      custo: custo,
      orcamento: orcamento,
      dias: prefs.dias,
      pessoas: prefs.pessoas,
      motivos: motivos,
    );
  }

  // ---------- Buscas (histórico do questionário) ----------

  /// CREATE: grava as respostas do questionário.
  static Future<int> salvarBusca(int usuarioId, TripPreferences p) async {
    final db = await DatabaseHelper.db();
    return db.insert('buscas', {
      'usuario_id': usuarioId,
      'origem': p.origem,
      'orcamento': p.orcamento,
      'dias': p.dias,
      'pessoas': p.pessoas,
      'tipo': p.tipo,
      'prioridade': p.prioridade,
    });
  }

  /// READ: última busca do usuário (para preencher o questionário).
  static Future<TripPreferences?> ultimaBusca(int usuarioId) async {
    final db = await DatabaseHelper.db();
    final linhas = await db.query('buscas',
        where: 'usuario_id = ?',
        whereArgs: [usuarioId],
        orderBy: 'id DESC',
        limit: 1);
    if (linhas.isEmpty) return null;
    final m = linhas.first;
    return TripPreferences(
      origem: m['origem'] as String,
      orcamento: (m['orcamento'] as num).round(),
      dias: m['dias'] as int,
      pessoas: m['pessoas'] as int,
      tipo: m['tipo'] as String,
      prioridade: m['prioridade'] as String,
    );
  }

  // ---------- Favoritos ----------

  /// READ: o destino é favorito do usuário?
  static Future<bool> isFavorito(int usuarioId, int destinoId) async {
    final db = await DatabaseHelper.db();
    final linhas = await db.query('favoritos',
        where: 'usuario_id = ? AND destino_id = ?',
        whereArgs: [usuarioId, destinoId],
        limit: 1);
    return linhas.isNotEmpty;
  }

  /// CREATE/DELETE: marca ou desmarca o favorito. Retorna o novo estado.
  static Future<bool> alternarFavorito(int usuarioId, int destinoId) async {
    final db = await DatabaseHelper.db();
    if (await isFavorito(usuarioId, destinoId)) {
      await db.delete('favoritos',
          where: 'usuario_id = ? AND destino_id = ?',
          whereArgs: [usuarioId, destinoId]);
      return false;
    }
    await db.insert(
        'favoritos', {'usuario_id': usuarioId, 'destino_id': destinoId});
    return true;
  }
}
