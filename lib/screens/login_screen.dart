import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/session.dart';
import '../data/usuario_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/tw_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  bool _entrando = false;

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _entrando = true);
    try {
      // READ: confere e-mail e hash da senha no SQLite.
      final usuario = await UsuarioRepository.autenticar(_email.text, _senha.text);
      await Session.entrar(usuario.id);
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } on UsuarioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.mensagem)));
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: TwBackButton(),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Image.asset('assets/images/logo.png',
                            width: 200, semanticLabel: 'Logo TripWise'),
                      ),
                      const SizedBox(height: 20),
                      Text('BEM-VINDO DE VOLTA', style: AppText.display(42)),
                      const SizedBox(height: 6),
                      const Text(
                        'Entre para ver seus matches e roteiros salvos.',
                        style: AppText.body,
                      ),
                      const SizedBox(height: 20),
                      LabeledField(
                        label: 'E-mail',
                        hint: 'voce@email.com',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Informe um e-mail válido'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      LabeledField(
                        label: 'Senha',
                        hint: '••••••••',
                        controller: _senha,
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Informe sua senha'
                            : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Recuperação de senha chega na próxima sprint.')),
                          ),
                          child: const Text('Esqueci minha senha',
                              style: TextStyle(
                                  color: AppColors.verdePetroleo,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 16),
                      PrimaryButton(
                          label: _entrando ? 'Entrando…' : 'Entrar',
                          onPressed: _entrando ? null : _entrar),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.signup),
                        child: const Text.rich(
                          TextSpan(
                            text: 'Ainda não tem conta? ',
                            style: TextStyle(
                                color: AppColors.azulMarinho, fontSize: 15),
                            children: [
                              TextSpan(
                                text: 'Criar conta',
                                style: TextStyle(
                                    color: AppColors.coralEscuro,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
