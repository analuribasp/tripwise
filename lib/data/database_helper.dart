import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sql;

import 'db_factory_stub.dart'
    if (dart.library.js_interop) 'db_factory_web.dart';
import 'schema.dart';

/// Abre o banco SQLite do app, cria as tabelas e insere os dados iniciais.
///
/// Segue o padrão do `SQLHelper` visto em aula: um único ponto de acesso
/// ao banco, usado pelos repositórios de cada tabela.
class DatabaseHelper {
  DatabaseHelper._();

  static const nomeArquivo = 'tripwise.db';
  static const versao = 1;

  /// Permite usar outro caminho (ex.: banco em memória nos testes).
  static String? caminhoPersonalizado;

  static sql.Database? _db;

  static Future<sql.Database> db() async {
    if (_db != null) return _db!;
    configurarFabricaBanco();
    final caminho = caminhoPersonalizado ??
        (kIsWeb
            ? nomeArquivo
            : p.join(await sql.getDatabasesPath(), nomeArquivo));
    _db = await sql.openDatabase(
      caminho,
      version: versao,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _criar,
    );
    return _db!;
  }

  static Future<void> _criar(sql.Database db, int version) async {
    final batch = db.batch();
    for (final comando in schemaV1) {
      batch.execute(comando);
    }
    for (final estilo in estilosSeed) {
      batch.insert('estilos', {'nome': estilo});
    }
    await batch.commit(noResult: true);
    await _inserirDestinos(db);
    debugPrint('Banco $nomeArquivo criado (versão $version).');
  }

  static Future<void> _inserirDestinos(sql.Database db) async {
    for (final d in destinosSeed) {
      final id = await db.insert('destinos', {
        'nome': d.nome,
        'uf': d.uf,
        'categorias': d.categorias,
        'info_transporte': d.transporte,
        'descricao': d.descricao,
        'destaque': d.destaque,
        'match_base': d.matchBase,
      });
      final batch = db.batch();
      for (var i = 0; i < custosItens.length; i++) {
        batch.insert('custos_destino', {
          'destino_id': id,
          'item': custosItens[i].$1,
          'valor': d.custos[i],
          'unidade': custosItens[i].$2,
        });
      }
      for (var dia = 0; dia < d.roteiro.length; dia++) {
        batch.insert('roteiro_modelo', {
          'destino_id': id,
          'dia': dia + 1,
          'titulo': d.roteiro[dia].$1,
          'descricao': d.roteiro[dia].$2,
        });
      }
      await batch.commit(noResult: true);
    }
  }

  /// Fecha a conexão (usado nos testes).
  static Future<void> fechar() async {
    await _db?.close();
    _db = null;
  }
}
