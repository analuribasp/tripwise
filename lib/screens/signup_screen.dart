import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/session.dart';
import '../data/usuario_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/tw_widgets.dart';

/// Cadastro do usuário, incluindo o perfil de viajante.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static const _perfis = [
    'Aventureiro',
    'Relax',
    'Cultural',
    'Gastronômico',
    'Econômico',
    'Natureza',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _cidade = TextEditingController();
  final _senha = TextEditingController();
  final _confirmar = TextEditingController();
  final Set<String> _selecionados = {'Relax', 'Econômico'};
  bool _aceitouTermos = true;
  bool _salvando = false;

  @override
  void dispose() {
    for (final c in [_nome, _email, _cidade, _senha, _confirmar]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _criarConta() async {
    final valido = _formKey.currentState!.validate();
    if (!valido) return;
    if (_selecionados.isEmpty) {
      _aviso('Escolha pelo menos um estilo de viajante.');
      return;
    }
    if (!_aceitouTermos) {
      _aviso('Aceite os termos de uso para continuar.');
      return;
    }
    setState(() => _salvando = true);
    try {
      // CREATE: grava o usuário e os estilos no SQLite.
      final id = await UsuarioRepository.cadastrar(
        nome: _nome.text,
        email: _email.text,
        senha: _senha.text,
        cidadeOrigem: _cidade.text,
        estilos: [
          for (final p in _perfis)
            if (_selecionados.contains(p)) p
        ],
      );
      await Session.entrar(id);
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } on UsuarioException catch (e) {
      _aviso(e.mensagem);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _aviso(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            children: [
              const Row(
                children: [
                  TwBackButton(),
                  SizedBox(width: 14),
                  Expanded(child: Eyebrow('Cartão de embarque · novo viajante')),
                ],
              ),
              const SizedBox(height: 14),
              Text('CRIE SUA CONTA', style: AppText.display(42)),
              const SizedBox(height: 14),
              LabeledField(
                label: 'Nome completo',
                hint: 'Seu nome',
                controller: _nome,
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Informe seu nome'
                    : null,
              ),
              const SizedBox(height: 10),
              LabeledField(
                label: 'E-mail',
                hint: 'voce@email.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null ||
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v))
                    ? 'E-mail inválido'
                    : null,
              ),
              const SizedBox(height: 10),
              LabeledField(
                label: 'Cidade de origem',
                hint: 'Ex.: Belo Horizonte',
                controller: _cidade,
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LabeledField(
                      label: 'Senha',
                      hint: '••••••••',
                      controller: _senha,
                      obscure: true,
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Mínimo 6 caracteres'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LabeledField(
                      label: 'Confirmar',
                      hint: '••••••••',
                      controller: _confirmar,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      validator: (v) =>
                          v != _senha.text ? 'Senhas diferentes' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Quem é você como viajante?', style: AppText.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in _perfis)
                    SelectPill(
                      label: p,
                      selected: _selecionados.contains(p),
                      selectedColor: AppColors.verdePetroleo,
                      onTap: () => setState(() {
                        _selecionados.contains(p)
                            ? _selecionados.remove(p)
                            : _selecionados.add(p);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                value: _aceitouTermos,
                onChanged: (v) => setState(() => _aceitouTermos = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                title: const Text(
                  'Aceito os termos de uso e a política de privacidade',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: _salvando ? 'Salvando…' : 'Criar conta',
                onPressed: _salvando ? null : _criarConta,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                child: const Text.rich(
                  TextSpan(
                    text: 'Já tem conta? ',
                    style:
                        TextStyle(color: AppColors.azulMarinho, fontSize: 15),
                    children: [
                      TextSpan(
                        text: 'Entrar',
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
    );
  }
}
