import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/session.dart';
import '../data/usuario_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Abertura do app: logo por 2 segundos e segue para a tela inicial.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  /// Se houver sessão salva (SharedPreferences) e o usuário existir no
  /// banco, vai direto para a Home; senão, para a tela inicial.
  Future<void> _iniciar() async {
    final espera = Future.delayed(const Duration(seconds: 2));
    var destino = AppRoutes.welcome;
    try {
      final id = await Session.carregar();
      if (id != null && await UsuarioRepository.buscarPorId(id) != null) {
        destino = AppRoutes.home;
      } else if (id != null) {
        await Session.sair();
      }
    } catch (e) {
      debugPrint('Falha ao carregar sessão: $e');
    }
    await espera;
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(destino);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.turquesa,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', width: 240),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppColors.coral,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text('PREPARANDO SUA VIAGEM…',
                style: AppText.eyebrow(color: AppColors.azulMarinho)),
          ],
        ),
      ),
    );
  }
}
