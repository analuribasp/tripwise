import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:tripwise/data/database_helper.dart';
import 'package:tripwise/data/destino_repository.dart';
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

  test('lista os favoritos do mais recente para o mais antigo', () async {
    final usuario = await UsuarioRepository.cadastrar(
        nome: 'Marina Costa', email: 'lista@x.com', senha: '123456');
    final destinos = await DestinoRepository.listar();

    expect(await DestinoRepository.listarFavoritos(usuario), isEmpty);

    await DestinoRepository.alternarFavorito(usuario, destinos[0].id);
    await DestinoRepository.alternarFavorito(usuario, destinos[1].id);

    final lista = await DestinoRepository.listarFavoritos(usuario);
    expect(lista.map((d) => d.id), [destinos[1].id, destinos[0].id]);
    // vem com custos e roteiro, pronto para abrir o detalhe
    expect(lista.first.costs, hasLength(4));

    await DestinoRepository.alternarFavorito(usuario, destinos[1].id);
    final depois = await DestinoRepository.listarFavoritos(usuario);
    expect(depois.map((d) => d.id), [destinos[0].id]);
  });

  test('cada usuário vê só os próprios favoritos e a exclusão limpa tudo',
      () async {
    final ana = await UsuarioRepository.cadastrar(
        nome: 'Ana', email: 'ana@x.com', senha: '123456');
    final bia = await UsuarioRepository.cadastrar(
        nome: 'Bia', email: 'bia@x.com', senha: '123456');
    final destino = (await DestinoRepository.listar()).first;

    await DestinoRepository.alternarFavorito(ana, destino.id);

    expect(await DestinoRepository.listarFavoritos(ana), hasLength(1));
    expect(await DestinoRepository.listarFavoritos(bia), isEmpty);

    await UsuarioRepository.excluir(ana);
    expect(await DestinoRepository.listarFavoritos(ana), isEmpty);
  });
}
