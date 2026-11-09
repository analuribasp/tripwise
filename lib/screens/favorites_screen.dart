import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/destino_repository.dart';
import '../data/session.dart';
import '../models/destination.dart';
import '../models/trip_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/tw_widgets.dart';

/// Lista os destinos que o usuário favoritou (READ da tabela favoritos).
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Destination>> _favoritos;

  @override
  void initState() {
    super.initState();
    _recarregar();
  }

  void _recarregar() {
    final id = Session.usuarioId;
    _favoritos = id == null
        ? Future.value(const [])
        : DestinoRepository.listarFavoritos(id);
  }

  Future<void> _abrir(Destination d) async {
    final id = Session.usuarioId;
    final busca = id == null ? null : await DestinoRepository.ultimaBusca(id);
    final match =
        DestinoRepository.avaliar(d, busca ?? TripPreferences.initial());
    if (!mounted) return;
    await Navigator.of(context)
        .pushNamed(AppRoutes.destination, arguments: match);
    if (mounted) setState(_recarregar);
  }

  Future<void> _remover(Destination d) async {
    final id = Session.usuarioId;
    if (id == null) return;
    await DestinoRepository.alternarFavorito(id, d.id);
    if (!mounted) return;
    mostrarAviso(context, '${d.name} saiu dos favoritos.');
    setState(_recarregar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _favoritos,
          builder: (context, snap) {
            final favoritos = snap.data ?? const <Destination>[];
            final pronto = snap.connectionState == ConnectionState.done;
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              children: [
                Row(
                  children: [
                    TwBackButton(onPressed: () => Navigator.of(context).pop()),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('FAVORITOS', style: AppText.display(34)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Eyebrow(pronto
                    ? '${favoritos.length} ${favoritos.length == 1 ? 'destino salvo' : 'destinos salvos'}'
                    : 'Carregando…'),
                const SizedBox(height: 16),
                if (pronto && favoritos.isEmpty)
                  EmptyState(
                    icon: Icons.favorite_border_rounded,
                    titulo: 'Nenhum favorito ainda',
                    texto:
                        'Abra um destino do Travel Match e toque no coração para guardar aqui.',
                    acao: 'Fazer meu match',
                    onAcao: () => AppRoutes.goToTab(context, 1),
                  ),
                for (final d in favoritos) ...[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _abrir(d),
                    child: TwCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.name.toUpperCase(),
                                    style: AppText.display(26)),
                                const SizedBox(height: 2),
                                Text(
                                  '${d.state} · ${d.categorias.join(', ')}',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 2),
                                Text(d.travelInfo,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          TwIconButton(
                            icon: Icons.favorite_rounded,
                            tooltip: 'Remover dos favoritos',
                            foreground: AppColors.coralEscuro,
                            onPressed: () => _remover(d),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
