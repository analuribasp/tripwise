import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/session.dart';
import '../data/usuario_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/tw_widgets.dart';

/// Perfil do usuário: READ, UPDATE (nome, cidade, estilos) e DELETE da conta.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _cidade = TextEditingController();
  String _email = '';
  List<String> _catalogo = const [];
  final Set<String> _estilos = {};
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _nome.dispose();
    _cidade.dispose();
    super.dispose();
  }

  /// READ: dados do usuário e catálogo de estilos.
  Future<void> _carregar() async {
    final id = Session.usuarioId;
    if (id == null) return;
    final u = await UsuarioRepository.buscarPorId(id);
    final catalogo = await UsuarioRepository.listarEstilos();
    if (!mounted || u == null) return;
    setState(() {
      _nome.text = u.nome;
      _cidade.text = u.cidadeOrigem;
      _email = u.email;
      _catalogo = catalogo;
      _estilos
        ..clear()
        ..addAll(u.estilos);
      _carregando = false;
    });
  }

  /// UPDATE na tabela `usuarios` e em `usuario_estilos`.
  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    await UsuarioRepository.atualizar(
      Session.usuarioId!,
      nome: _nome.text,
      cidadeOrigem: _cidade.text,
      estilos: [for (final e in _catalogo) if (_estilos.contains(e)) e],
    );
    if (!mounted) return;
    setState(() => _salvando = false);
    mostrarAviso(context, 'Perfil atualizado.');
  }

  /// Abre o diálogo de troca de senha.
  Future<void> _alterarSenha() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const _AlterarSenhaDialog(),
    );
    if (ok == true && mounted) mostrarAviso(context, 'Senha alterada.');
  }

  Future<void> _sair() async {
    await Session.sair();
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
  }

  /// DELETE: apaga a conta e, em cascata, viagens, roteiros e favoritos.
  Future<void> _excluirConta() async {
    final ok = await confirmar(
      context,
      titulo: 'Excluir conta?',
      mensagem:
          'Sua conta, suas viagens e seus roteiros serão apagados deste aparelho. Essa ação não pode ser desfeita.',
      acao: 'Excluir conta',
    );
    if (!ok) return;
    await UsuarioRepository.excluir(Session.usuarioId!);
    await Session.sair();
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  children: [
                    Row(
                      children: [
                        const TwBackButton(),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Text('MEU PERFIL',
                                style: AppText.display(34))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(_email,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.verdePetroleo)),
                    const SizedBox(height: 16),
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
                      label: 'Cidade de origem',
                      hint: 'Ex.: Belo Horizonte',
                      controller: _cidade,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),
                    const Text('Seus estilos de viajante',
                        style: AppText.label),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final e in _catalogo)
                          SelectPill(
                            label: e,
                            selected: _estilos.contains(e),
                            selectedColor: AppColors.verdePetroleo,
                            onTap: () => setState(() => _estilos.contains(e)
                                ? _estilos.remove(e)
                                : _estilos.add(e)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: _salvando ? 'Salvando…' : 'Salvar alterações',
                      onPressed: _salvando ? null : _salvar,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _alterarSenha,
                      icon: const Icon(Icons.lock_outline_rounded),
                      label: const Text('Alterar senha'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.azulMarinho,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppColors.bordaInput),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _sair,
                      icon: const Icon(Icons.logout),
                      label: const Text('Sair da conta'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.azulMarinho,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppColors.bordaInput),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _excluirConta,
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: const Text('Excluir minha conta'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.coralEscuro),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}


/// Diálogo de troca de senha: confere a senha atual e grava a nova.
class _AlterarSenhaDialog extends StatefulWidget {
  const _AlterarSenhaDialog();

  @override
  State<_AlterarSenhaDialog> createState() => _AlterarSenhaDialogState();
}

class _AlterarSenhaDialogState extends State<_AlterarSenhaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _atual = TextEditingController();
  final _nova = TextEditingController();
  final _confirmar = TextEditingController();
  String? _erro;
  bool _salvando = false;

  @override
  void dispose() {
    for (final c in [_atual, _nova, _confirmar]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await UsuarioRepository.alterarSenha(
        Session.usuarioId!,
        senhaAtual: _atual.text,
        novaSenha: _nova.text,
      );
      if (mounted) Navigator.pop(context, true);
    } on UsuarioException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _salvando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.offWhite,
      title: const Text('Alterar senha'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LabeledField(
                label: 'Senha atual',
                hint: '••••••••',
                controller: _atual,
                obscure: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe a senha atual' : null,
              ),
              const SizedBox(height: 10),
              LabeledField(
                label: 'Nova senha',
                hint: '••••••••',
                controller: _nova,
                obscure: true,
                validator: (v) =>
                    (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 10),
              LabeledField(
                label: 'Confirmar nova senha',
                hint: '••••••••',
                controller: _confirmar,
                obscure: true,
                textInputAction: TextInputAction.done,
                validator: (v) => v != _nova.text ? 'Senhas diferentes' : null,
              ),
              if (_erro != null) ...[
                const SizedBox(height: 10),
                Text(
                  _erro!,
                  style: const TextStyle(
                    color: AppColors.coralEscuro,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          style: FilledButton.styleFrom(backgroundColor: AppColors.azulMarinho),
          child: Text(_salvando ? 'Salvando…' : 'Alterar senha'),
        ),
      ],
    );
  }
}
