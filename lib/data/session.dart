import 'package:shared_preferences/shared_preferences.dart';

/// Sessão do usuário logado, guardada com SharedPreferences
/// (dado pequeno e simples, como visto na aula de Persistência parte 1).
class Session {
  Session._();

  static const _chaveUsuario = 'usuario_id';

  static int? _usuarioId;

  /// Id do usuário logado (em memória depois de [carregar]).
  static int? get usuarioId => _usuarioId;

  static Future<int?> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    _usuarioId = prefs.getInt(_chaveUsuario);
    return _usuarioId;
  }

  static Future<void> entrar(int usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveUsuario, usuarioId);
    _usuarioId = usuarioId;
  }

  static Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveUsuario);
    _usuarioId = null;
  }
}
