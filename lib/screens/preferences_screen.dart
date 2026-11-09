import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/destino_repository.dart';
import '../data/session.dart';
import '../data/usuario_repository.dart';
import '../models/trip_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/tw_widgets.dart';

/// Questionário do Travel Match: como o usuário quer viajar.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  static const _tipos = ['Praia', 'Montanha', 'Cidade', 'Natureza', 'Cultura'];
  static const _prioridades = ['Economia', 'Conforto', 'Experiência'];

  TripPreferences _prefs = TripPreferences.initial();

  void _update(TripPreferences p) => setState(() => _prefs = p);

  @override
  void initState() {
    super.initState();
    _carregarUltimaBusca();
  }

  /// READ: preenche o questionário com a última busca salva ou, se não
  /// houver, com a cidade de origem do cadastro.
  Future<void> _carregarUltimaBusca() async {
    final id = Session.usuarioId;
    if (id == null) return;
    final ultima = await DestinoRepository.ultimaBusca(id);
    final usuario = await UsuarioRepository.buscarPorId(id);
    if (!mounted) return;
    setState(() {
      _prefs = ultima ??
          (usuario != null && usuario.cidadeOrigem.isNotEmpty
              ? _prefs.copyWith(origem: usuario.cidadeOrigem)
              : _prefs);
    });
  }

  /// CREATE: grava a busca no histórico e abre o resultado do match.
  Future<void> _buscar() async {
    final id = Session.usuarioId;
    if (id != null) await DestinoRepository.salvarBusca(id, _prefs);
    if (!mounted) return;
    Navigator.of(context).pushNamed(AppRoutes.match, arguments: _prefs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const TwBottomNav(currentIndex: 1),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          children: [
            Row(
              children: [
                TwBackButton(
                    onPressed: () => AppRoutes.goToTab(context, 0)),
                const SizedBox(width: 14),
                Expanded(
                  child: Row(
                    children: [
                      for (var i = 0; i < 4; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: i < 3
                                  ? AppColors.verdePetroleo
                                  : AppColors.bordaInput,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Eyebrow('Travel Match · etapa 3 de 4'),
            const SizedBox(height: 4),
            Text('COMO VOCÊ QUER VIAJAR?', style: AppText.display(40)),
            const SizedBox(height: 16),
            TwCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.place_outlined,
                    label: 'Saindo de',
                    trailing: Text(_prefs.origem,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  const Divider(height: 1, color: AppColors.trilha),
                  _InfoRow(
                    icon: Icons.payments_outlined,
                    label: 'Orçamento',
                    trailing: _Stepper(
                      value: formatBRL(_prefs.orcamento),
                      semantic: 'orçamento',
                      onMinus: () => _update(_prefs.copyWith(
                          orcamento: (_prefs.orcamento - 250).clamp(500, 50000))),
                      onPlus: () => _update(
                          _prefs.copyWith(orcamento: _prefs.orcamento + 250)),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.trilha),
                  _InfoRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'Duração',
                    trailing: _Stepper(
                      value: '${_prefs.dias} dias',
                      semantic: 'dias',
                      onMinus: () => _update(_prefs.copyWith(
                          dias: (_prefs.dias - 1).clamp(1, 60))),
                      onPlus: () =>
                          _update(_prefs.copyWith(dias: _prefs.dias + 1)),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.trilha),
                  _InfoRow(
                    icon: Icons.group_outlined,
                    label: 'Viajantes',
                    trailing: _Stepper(
                      value: _prefs.pessoas == 1
                          ? '1 pessoa'
                          : '${_prefs.pessoas} pessoas',
                      semantic: 'pessoas',
                      onMinus: () => _update(_prefs.copyWith(
                          pessoas: (_prefs.pessoas - 1).clamp(1, 20))),
                      onPlus: () =>
                          _update(_prefs.copyWith(pessoas: _prefs.pessoas + 1)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text('Que tipo de viagem você quer?', style: AppText.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in _tipos)
                  SelectPill(
                    label: t,
                    selected: _prefs.tipo == t,
                    onTap: () => _update(_prefs.copyWith(tipo: t)),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('O que é mais importante pra você?',
                style: AppText.label),
            const SizedBox(height: 8),
            TwCard(
              padding: const EdgeInsets.all(5),
              radius: 16,
              child: Row(
                children: [
                  for (final p in _prioridades)
                    Expanded(
                      child: _Segment(
                        label: p,
                        selected: _prefs.prioridade == p,
                        onTap: () => _update(_prefs.copyWith(prioridade: p)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Encontrar meu match',
              icon: Icons.flight_takeoff_rounded,
              onPressed: _buscar,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _InfoRow(
      {required this.icon, required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.coral, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary)),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String value;
  final String semantic;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _Stepper({
    required this.value,
    required this.semantic,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
            icon: Icons.remove_rounded,
            tooltip: 'Diminuir $semantic',
            onTap: onMinus),
        SizedBox(
          width: 96,
          child: Text(value,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
        _StepButton(
            icon: Icons.add_rounded,
            tooltip: 'Aumentar $semantic',
            onTap: onPlus),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _StepButton(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.offWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.bordaInput, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 18, color: AppColors.azulMarinho),
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Segment(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.amarelo : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 42,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.azulMarinho
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
