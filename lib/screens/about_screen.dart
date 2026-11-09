import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/tw_widgets.dart';

/// Tela "Sobre o App": proposta, funcionamento e equipe.
class AboutScreen extends StatelessWidget {
  /// Falso quando o "Sobre" é aberto antes do login (tela inicial).
  final bool showNav;

  const AboutScreen({super.key, this.showNav = true});

  static const _passos = [
    ('01', 'Perfil e preferências', AppColors.turquesa),
    ('02', 'Orçamento e período', AppColors.creme),
    ('03', 'Travel Match com % de compatibilidade', AppColors.rosa),
    ('04', 'Custos estimados e roteiro pronto', AppColors.salvia),
  ];

  static const _equipe = [
    'Ana Luiza Ribas',
    'Ana Paula Lopes',
    'Débora Lino',
    'Thiago Bahia',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar:
          showNav ? const TwBottomNav(currentIndex: 3) : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          children: [
            Row(
              children: [
                TwBackButton(
                  onPressed: () => Navigator.of(context).canPop()
                      ? Navigator.of(context).pop()
                      : AppRoutes.goToTab(context, 0),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Text('SOBRE O TRIPWISE',
                        style: AppText.display(34))),
              ],
            ),
            const SizedBox(height: 16),
            TwCard(
              radius: 22,
              child: Row(
                children: [
                  Image.asset('assets/images/logo_mark.png', width: 64),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'O TripWise recomenda viagens a partir de ',
                        children: [
                          TextSpan(
                            text: 'quem você é como viajante',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.azulMarinho),
                          ),
                          TextSpan(
                              text:
                                  ', não do destino. Você diz como quer viajar e o app encontra o que mais combina.'),
                        ],
                      ),
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: Color(0xFF33495C)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('COMO FUNCIONA', style: AppText.display(26)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.7,
              children: [
                for (final p in _passos)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: p.$3,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.$1, style: AppText.display(26)),
                        const SizedBox(height: 4),
                        Text(p.$2,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text('EQUIPE', style: AppText.display(26)),
            const SizedBox(height: 10),
            TwCard(
              radius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  for (var i = 0; i < _equipe.length; i++) ...[
                    SizedBox(
                      height: 38,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_equipe[i],
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          Text('SEAT 01${String.fromCharCode(65 + i)}',
                              style: AppText.mono(12,
                                  color: AppColors.textSecondary,
                                  weight: FontWeight.w400)),
                        ],
                      ),
                    ),
                    if (i < _equipe.length - 1)
                      const DashedDivider(thickness: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Projeto Integrado · Desenvolvimento Móvel · PUC Minas · 2026/2\nVersão 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, height: 1.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

}
