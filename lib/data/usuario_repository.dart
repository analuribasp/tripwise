import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart' as sql;

import '../models/usuario.dart';
import 'database_helper.dart';

/// E-mail já cadastrado ou credenciais inválidas.
class UsuarioException implements Exception {
  final String mensagem;
  const UsuarioException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// CRUD da tabela `usuarios` (e dos estilos em `usuario_estilos`).
class UsuarioRepository {
  UsuarioRepository._();

  /// A senha nunca é gravada em texto puro: guardamos o hash SHA-256.
  static String hashSenha(String email, String senha) => sha256
      .convert(utf8.encode('${email.trim().toLowerCase()}:$senha'))
      .toString();

  /// CREATE: cadastra o usuário e seus estilos de viajante.
  static Future<int> cadastrar({
    required String nome,
    required String email,
    required String senha,
    String cidadeOrigem = '',
    List<String> estilos = const [],
  }) async {
    final db = await DatabaseHelper.db();
    final emailNorm = email.trim().toLowerCase();
    try {
      return await db.transaction((txn) async {
        final id = await txn.insert(
          'usuarios',
          {
            'nome': nome.trim(),
            'email': emailNorm,
            'senha_hash': hashSenha(emailNorm, senha),
            'cidade_origem': cidadeOrigem.trim(),
          },
          conflictAlgorithm: sql.ConflictAlgorithm.abort,
        );
        await _gravarEstilos(txn, id, estilos);
        return id;
      });
    } on sql.DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const UsuarioException('Este e-mail já está cadastrado.');
      }
      rethrow;
    }
  }

  /// READ: confere e-mail e senha. Retorna o usuário ou lança exceção.
  static Future<Usuario> autenticar(String email, String senha) async {
    final db = await DatabaseHelper.db();
    final emailNorm = email.trim().toLowerCase();
    final linhas = await db.query(
      'usuarios',
      where: 'email = ? AND senha_hash = ?',
      whereArgs: [emailNorm, hashSenha(emailNorm, senha)],
      limit: 1,
    );
    if (linhas.isEmpty) {
      throw const UsuarioException('E-mail ou senha incorretos.');
    }
    return (await buscarPorId(linhas.first['id'] as int))!;
  }

  /// READ: busca um usuário pelo id, com os estilos (JOIN).
  static Future<Usuario?> buscarPorId(int id) async {
    final db = await DatabaseHelper.db();
    final linhas =
        await db.query('usuarios', where: 'id = ?', whereArgs: [id], limit: 1);
    if (linhas.isEmpty) return null;
    final estilos = await db.rawQuery('''
      SELECT e.nome FROM estilos e
      JOIN usuario_estilos ue ON ue.estilo_id = e.id
      WHERE ue.usuario_id = ?
      ORDER BY e.id''', [id]);
    return Usuario.fromMap(linhas.first,
        estilos: estilos.map((e) => e['nome'] as String).toList());
  }

  /// READ: catálogo de estilos de viajante.
  static Future<List<String>> listarEstilos() async {
    final db = await DatabaseHelper.db();
    final linhas = await db.query('estilos', orderBy: 'id');
    return linhas.map((e) => e['nome'] as String).toList();
  }

  /// UPDATE: altera nome, cidade e estilos do usuário.
  static Future<void> atualizar(
    int id, {
    required String nome,
    required String cidadeOrigem,
    required List<String> estilos,
  }) async {
    final db = await DatabaseHelper.db();
    await db.transaction((txn) async {
      await txn.update(
        'usuarios',
        {'nome': nome.trim(), 'cidade_origem': cidadeOrigem.trim()},
        where: 'id = ?',
        whereArgs: [id],
      );
      await txn
          .delete('usuario_estilos', where: 'usuario_id = ?', whereArgs: [id]);
      await _gravarEstilos(txn, id, estilos);
    });
  }

  /// DELETE: exclui a conta. Viagens, roteiros, buscas e favoritos
  /// são apagados em cascata (ON DELETE CASCADE).
  static Future<void> excluir(int id) async {
    final db = await DatabaseHelper.db();
    await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> _gravarEstilos(
      sql.DatabaseExecutor txn, int usuarioId, List<String> estilos) async {
    for (final nome in estilos) {
      await txn.rawInsert('''
        INSERT OR IGNORE INTO usuario_estilos (usuario_id, estilo_id)
        SELECT ?, id FROM estilos WHERE nome = ?''', [usuarioId, nome]);
    }
  }
}
