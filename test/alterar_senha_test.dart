import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:tripwise/data/database_helper.dart';
import 'package:tripwise/data/usuario_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseHelper.fechar();
    DatabaseHelper.caminhoPersonalizado = inMemoryDatabasePath;
  });

  test('depois de alterar, só a senha nova entra', () async {
    final id = await UsuarioRepository.cadastrar(
        nome: 'Marina Costa', email: 'marina@x.com', senha: '123456');

    await UsuarioRepository.alterarSenha(id,
        senhaAtual: '123456', novaSenha: 'senhaNova1');

    final usuario =
        await UsuarioRepository.autenticar('marina@x.com', 'senhaNova1');
    expect(usuario.email, 'marina@x.com');
    expect(
      () => UsuarioRepository.autenticar('marina@x.com', '123456'),
      throwsA(isA<UsuarioException>()),
    );
  });

  test('senha atual errada não altera nada', () async {
    final id = await UsuarioRepository.cadastrar(
        nome: 'Marina Costa', email: 'errada@x.com', senha: '123456');

    expect(
      () => UsuarioRepository.alterarSenha(id,
          senhaAtual: 'outra-senha', novaSenha: 'senhaNova1'),
      throwsA(isA<UsuarioException>()
          .having((e) => e.mensagem, 'mensagem', 'Senha atual incorreta.')),
    );

    // a antiga continua valendo
    final usuario =
        await UsuarioRepository.autenticar('errada@x.com', '123456');
    expect(usuario.email, 'errada@x.com');
  });

  test('nova senha curta demais é recusada', () async {
    final id = await UsuarioRepository.cadastrar(
        nome: 'Marina Costa', email: 'curta@x.com', senha: '123456');

    expect(
      () => UsuarioRepository.alterarSenha(id,
          senhaAtual: '123456', novaSenha: '123'),
      throwsA(isA<UsuarioException>()),
    );
    final usuario = await UsuarioRepository.autenticar('curta@x.com', '123456');
    expect(usuario.email, 'curta@x.com');
  });
}
