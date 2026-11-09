import '../models/destination.dart';
import '../models/viagem.dart';
import 'database_helper.dart';

/// CRUD das tabelas `viagens` e `roteiro_itens`.
class ViagemRepository {
  ViagemRepository._();

  static const _selectViagem = '''
    SELECT v.*, d.nome AS destino_nome, d.uf AS destino_uf
    FROM viagens v
    JOIN destinos d ON d.id = v.destino_id''';

  /// CREATE: grava a viagem e copia o roteiro sugerido do destino
  /// (até o número de dias da viagem) para `roteiro_itens`.
  static Future<int> criar(Viagem viagem, Destination destino) async {
    final db = await DatabaseHelper.db();
    return db.transaction((txn) async {
      final id = await txn.insert('viagens', viagem.toMap());
      final dias = viagem.dias;
      for (final dia in destino.itinerary) {
        if (dia.dia > dias) break;
        await txn.insert(
          'roteiro_itens',
          RoteiroItem(
            viagemId: id,
            dia: dia.dia,
            titulo: dia.titulo,
            descricao: dia.descricao,
          ).toMap(),
        );
      }
      return id;
    });
  }

  /// READ: viagens do usuário, da mais próxima para a mais distante.
  static Future<List<Viagem>> listar(int usuarioId) async {
    final db = await DatabaseHelper.db();
    final linhas = await db.rawQuery(
      '$_selectViagem WHERE v.usuario_id = ? ORDER BY v.data_ida, v.id',
      [usuarioId],
    );
    return linhas.map(Viagem.fromMap).toList();
  }

  /// READ: próxima viagem ainda não concluída (para a Home).
  static Future<Viagem?> proxima(int usuarioId) async {
    final db = await DatabaseHelper.db();
    final linhas = await db.rawQuery(
      "$_selectViagem WHERE v.usuario_id = ? AND v.status <> 'Concluída' "
      'ORDER BY v.data_ida LIMIT 1',
      [usuarioId],
    );
    return linhas.isEmpty ? null : Viagem.fromMap(linhas.first);
  }

  /// READ: uma viagem pelo id.
  static Future<Viagem?> buscarPorId(int id) async {
    final db = await DatabaseHelper.db();
    final linhas = await db.rawQuery('$_selectViagem WHERE v.id = ?', [id]);
    return linhas.isEmpty ? null : Viagem.fromMap(linhas.first);
  }

  /// UPDATE: altera datas, pessoas, orçamento, status e observações.
  static Future<int> atualizar(Viagem viagem) async {
    final db = await DatabaseHelper.db();
    return db.update(
      'viagens',
      {...viagem.toMap(), 'atualizado_em': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [viagem.id],
    );
  }

  /// DELETE: apaga a viagem (os itens do roteiro vão junto, em cascata).
  static Future<int> excluir(int id) async {
    final db = await DatabaseHelper.db();
    return db.delete('viagens', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Itens do roteiro ----------

  /// READ: itens do roteiro de uma viagem, por dia.
  static Future<List<RoteiroItem>> listarItens(int viagemId) async {
    final db = await DatabaseHelper.db();
    final linhas = await db.query('roteiro_itens',
        where: 'viagem_id = ?', whereArgs: [viagemId], orderBy: 'dia, id');
    return linhas.map(RoteiroItem.fromMap).toList();
  }

  /// CREATE: novo item no roteiro.
  static Future<int> criarItem(RoteiroItem item) async {
    final db = await DatabaseHelper.db();
    return db.insert('roteiro_itens', item.toMap());
  }

  /// UPDATE: edita um item (título, descrição, dia ou concluído).
  static Future<int> atualizarItem(RoteiroItem item) async {
    final db = await DatabaseHelper.db();
    return db.update('roteiro_itens', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  /// DELETE: remove um item do roteiro.
  static Future<int> excluirItem(int id) async {
    final db = await DatabaseHelper.db();
    return db.delete('roteiro_itens', where: 'id = ?', whereArgs: [id]);
  }
}
