import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:tripwise/data/database_helper.dart';
import 'package:tripwise/data/destino_repository.dart';
import 'package:tripwise/data/usuario_repository.dart';
import 'package:tripwise/data/viagem_repository.dart';
import 'package:tripwise/models/trip_preferences.dart';
import 'package:tripwise/models/viagem.dart';

/// Testes do CRUD em um banco SQLite em memória.
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseHelper.fechar();
    DatabaseHelper.caminhoPersonalizado = inMemoryDatabasePath;
  });

  test('banco criado com destinos, custos e estilos', () async {
    final destinos = await DestinoRepository.listar();
    expect(destinos, hasLength(8));
    expect(destinos.first.costs, hasLength(4));
    expect(destinos.first.itinerary, hasLength(5));
    expect(await UsuarioRepository.listarEstilos(), hasLength(6));
  });

  test('usuário: create, read, update e delete', () async {
    final id = await UsuarioRepository.cadastrar(
      nome: 'Marina Costa',
      email: 'Marina@Email.com',
      senha: '123456',
      cidadeOrigem: 'Belo Horizonte',
      estilos: ['Relax', 'Econômico'],
    );

    // E-mail único.
    expect(
      () => UsuarioRepository.cadastrar(
          nome: 'Outra', email: 'marina@email.com', senha: 'x'),
      throwsA(isA<UsuarioException>()),
    );

    // Login (senha guardada como hash).
    final u = await UsuarioRepository.autenticar('marina@email.com', '123456');
    expect(u.id, id);
    expect(u.estilos, ['Relax', 'Econômico']);
    expect(
      () => UsuarioRepository.autenticar('marina@email.com', 'errada'),
      throwsA(isA<UsuarioException>()),
    );

    await UsuarioRepository.atualizar(id,
        nome: 'Marina C.', cidadeOrigem: 'Contagem', estilos: ['Cultural']);
    final atualizado = await UsuarioRepository.buscarPorId(id);
    expect(atualizado!.nome, 'Marina C.');
    expect(atualizado.estilos, ['Cultural']);

    await UsuarioRepository.excluir(id);
    expect(await UsuarioRepository.buscarPorId(id), isNull);
  });

  test('travel match ordena destinos de praia dentro do orçamento', () async {
    final top = await DestinoRepository.calcularMatch(TripPreferences.initial());
    expect(top.map((m) => m.destino.name),
        ['Porto Seguro', "Arraial d'Ajuda", 'Salvador']);
    expect(top.first.percent, 94);
    expect(top.first.custo, 2450);
  });

  test('viagem e roteiro: CRUD completo e exclusão em cascata', () async {
    final usuario = await UsuarioRepository.cadastrar(
        nome: 'Marina Costa', email: 'm@x.com', senha: '123456');
    final match =
        (await DestinoRepository.calcularMatch(TripPreferences.initial())).first;

    final id = await ViagemRepository.criar(
      Viagem(
        usuarioId: usuario,
        destinoId: match.destino.id,
        dataIda: DateTime(2026, 11, 12),
        dataVolta: DateTime(2026, 11, 16),
        pessoas: 2,
        orcamento: 2500,
        custoEstimado: match.custo,
        matchPercent: match.percent,
      ),
      match.destino,
    );

    // CREATE copiou os 5 dias do roteiro sugerido.
    var itens = await ViagemRepository.listarItens(id);
    expect(itens, hasLength(5));

    // READ com JOIN no destino.
    final lista = await ViagemRepository.listar(usuario);
    expect(lista.single.destinoNome, 'Porto Seguro');

    // UPDATE da viagem.
    await ViagemRepository.atualizar(
        lista.single.copyWith(status: 'Confirmada', pessoas: 3));
    final v = await ViagemRepository.buscarPorId(id);
    expect(v!.status, 'Confirmada');
    expect(v.pessoas, 3);

    // CRUD de itens do roteiro.
    final novo = await ViagemRepository.criarItem(
        RoteiroItem(viagemId: id, dia: 2, titulo: 'Mergulho'));
    await ViagemRepository.atualizarItem(RoteiroItem(
        id: novo, viagemId: id, dia: 2, titulo: 'Mergulho', concluido: true));
    itens = await ViagemRepository.listarItens(id);
    expect(itens.firstWhere((i) => i.id == novo).concluido, isTrue);
    await ViagemRepository.excluirItem(itens.first.id!);
    expect(await ViagemRepository.listarItens(id), hasLength(5));

    // DELETE da viagem apaga os itens em cascata.
    await ViagemRepository.excluir(id);
    expect(await ViagemRepository.listar(usuario), isEmpty);
    expect(await ViagemRepository.listarItens(id), isEmpty);
  });
}
