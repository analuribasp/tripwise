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
