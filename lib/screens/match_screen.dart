import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/destino_repository.dart';
import '../models/destination.dart';
import '../models/trip_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/tw_widgets.dart';

/// Funcionalidade principal: ranking de destinos por compatibilidade.
class MatchScreen extends StatefulWidget {
  final TripPreferences preferences;

  const MatchScreen({super.key, required this.preferences});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  static const _medalhas = [AppColors.amarelo, AppColors.prata, AppColors.bronze];

  /// READ: destinos do SQLite, avaliados com as preferências.
  late final Future<List<MatchResult>> _resultados =
      DestinoRepository.calcularMatch(widget.preferences);

  TripPreferences get preferences => widget.preferences;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _resultados,
      builder: (context, snap) => _build(context, snap.data),
    );
  }

  Widget _build(BuildContext context, List<MatchResult>? resultados) {
    final destinos = resultados ?? const <MatchResult>[];

    return Scaffold(
      backgroundColor: AppColors.turquesa,
      bottomNavigationBar: const TwBottomNav(currentIndex: 1),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TwBackButton(background: AppColors.offWhite),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Ajustar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.offWhite,
                    foregroundColor: AppColors.azulMarinho,
                    minimumSize: const Size(0, 40),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFonts.body),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Eyebrow(
                resultados == null
                    ? 'Calculando seu match…'
                    : '${destinos.length} destinos mais compatíveis',
                color: AppColors.verdeEscuro),
            const SizedBox(height: 2),
            Text('SEU TRAVEL MATCH', style: AppText.display(44)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final item in preferences.resumo)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(item,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < destinos.length; i++) ...[
              _MatchTicket(
                rank: i + 1,
                medalColor: _medalhas[i % _medalhas.length],
                match: destinos[i],
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatchTicket extends StatelessWidget {
  final int rank;
  final Color medalColor;
  final MatchResult match;

  const _MatchTicket({
    required this.rank,
    required this.medalColor,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    final destino = match.destino;
    final folga = match.folga;
    final dentro = folga >= 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.azulMarinho.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context)
              .pushNamed(AppRoutes.destination, arguments: match),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: medalColor,
                      child: Text('$rank', style: AppText.display(24)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(destino.name.toUpperCase(),
                              style: AppText.display(28)),
                          const SizedBox(height: 2),
                          Text(
                            '${destino.state} · ${destino.category} · ${destino.travelInfo}',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${match.percent}%',
                            style: AppText.display(34,
                                color: AppColors.verdePetroleo)),
                        Text('MATCH', style: AppText.mono(11)),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: DashedDivider(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'Estimativa total ',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                          children: [
                            TextSpan(
                              text: formatBRL(match.custo),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.azulMarinho),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: dentro ? AppColors.menta : AppColors.rosa,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        dentro
                            ? '${formatBRL(folga)} abaixo'
                            : '${formatBRL(-folga)} acima',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: dentro
                              ? AppColors.verdeEscuro
                              : AppColors.coralEscuro,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
