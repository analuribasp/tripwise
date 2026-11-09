import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/tw_widgets.dart';

/// Tela inicial: apresenta a proposta do app e leva ao cadastro ou login.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 45,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.turquesa,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: SafeArea(
                bottom: false,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned(
                      top: 24,
                      right: 32,
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.amarelo,
                      ),
                    ),
                    Transform.rotate(
                      angle: -3 * math.pi / 180,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                              color: const Color(0xFFF4B6A8), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.azulMarinho
                                  .withValues(alpha: 0.18),
                              blurRadius: 40,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(22),
                        child: Transform.rotate(
                          angle: 3 * math.pi / 180,
                          child: Image.asset('assets/images/logo.png',
                              semanticLabel: 'Logo TripWise'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 55,
            child: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 52)
                          .clamp(0.0, double.infinity)),
                  child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('em vez de “pra onde eu vou?”'),
                    const SizedBox(height: 12),
                    Text(
                      'DIGA COMO VOCÊ QUER VIAJAR. A GENTE ENCONTRA O DESTINO.',
                      style: AppText.display(40).copyWith(height: 0.95),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Perfil, orçamento e período viram um Travel Match com os destinos que mais combinam com você.',
                      style: AppText.body,
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: 'Começar agora',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.signup),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AppRoutes.login),
                          child: const Text.rich(
                            TextSpan(
                              text: 'Já tenho conta · ',
                              style: TextStyle(
                                  color: AppColors.azulMarinho,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15),
                              children: [
                                TextSpan(
                                  text: 'Entrar',
                                  style: TextStyle(color: AppColors.coralEscuro),
                                ),
                              ],
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context)
                              .pushNamed(AppRoutes.about, arguments: false),
                          child: const Text(
                            'Sobre o app',
                            style: TextStyle(
                                color: AppColors.verdePetroleo,
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                  ),
                ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
