import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/session.dart';
import '../data/viagem_repository.dart';
import '../models/viagem.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/tw_widgets.dart';
import 'trip_form_screen.dart';

/// Aba "Viagens": lista (READ), edição (UPDATE) e exclusão (DELETE)
/// das viagens salvas no SQLite.
class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  late Future<List<Viagem>> _viagens;

  @override
  void initState() {
    super.initState();
    _recarregar();
  }

  void _recarregar() {
    final id = Session.usuarioId;
    _viagens = id == null
        ? Future.value(const [])
        : ViagemRepository.listar(id);
  }

  Future<void> _abrir(Viagem v) async {
    await Navigator.of(context).pushNamed(AppRoutes.tripDetail, arguments: v.id);
    if (mounted) setState(_recarregar);
  }

  Future<void> _editar(Viagem v) async {
    await Navigator.of(context)
        .pushNamed(AppRoutes.tripForm, arguments: TripFormArgs.editar(v));
    if (mounted) setState(_recarregar);
  }

  Future<void> _excluir(Viagem v) async {
    final ok = await confirmar(
      context,
      titulo: 'Excluir viagem?',
      mensagem:
          'A viagem para ${v.destinoNome} e todo o roteiro dela serão apagados.',
    );
    if (!ok) return;
    await ViagemRepository.excluir(v.id!);
    if (!mounted) return;
    mostrarAviso(context, 'Viagem excluída.');
    setState(_recarregar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const TwBottomNav(currentIndex: 2),
      body: SafeArea(
        child: FutureBuilder(
          future: _viagens,
          builder: (context, snap) {
            final viagens = snap.data ?? const <Viagem>[];
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              children: [
                Row(
                  children: [
                    TwBackButton(onPressed: () => AppRoutes.goToTab(context, 0)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('MINHAS VIAGENS',
                          style: AppText.display(34)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Eyebrow(snap.connectionState == ConnectionState.done
                    ? '${viagens.length} ${viagens.length == 1 ? 'viagem salva' : 'viagens salvas'}'
                    : 'Carregando…'),
                const SizedBox(height: 16),
                if (snap.connectionState == ConnectionState.done &&
                    viagens.isEmpty)
                  EmptyState(
                    icon: Icons.luggage_outlined,
                    titulo: 'Nenhuma viagem salva',
                    texto:
                        'Faça o Travel Match, escolha um destino e toque em “Planejar esta viagem”.',
                    acao: 'Fazer meu match',
                    onAcao: () => AppRoutes.goToTab(context, 1),
                  ),
                for (final v in viagens) ...[
                  Dismissible(
                    key: ValueKey(v.id),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      await _excluir(v);
                      return false;
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: AppColors.coralEscuro,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: AppColors.branco),
                    ),
                    child: TripTicketCard(
                      viagem: v,
                      onTap: () => _abrir(v),
                      trailing: PopupMenuButton<String>(
                        tooltip: 'Opções',
                        icon: const Icon(Icons.more_vert,
                            color: AppColors.textSecondary),
                        onSelected: (op) =>
                            op == 'editar' ? _editar(v) : _excluir(v),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'editar',
                              child: ListTile(
                                  leading: Icon(Icons.edit_outlined),
                                  title: Text('Editar'))),
                          PopupMenuItem(
                              value: 'excluir',
                              child: ListTile(
                                  leading: Icon(Icons.delete_outline),
                                  title: Text('Excluir'))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (viagens.isNotEmpty)
                  const Text(
                    'Dica: arraste uma viagem para a esquerda para excluir.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
