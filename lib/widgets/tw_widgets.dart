import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models/trip_preferences.dart';
import '../models/viagem.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Botão quadrado de voltar (44×44) usado no topo das telas.
class TwBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color background;

  const TwBackButton({
    super.key,
    this.onPressed,
    this.background = AppColors.branco,
  });

  @override
  Widget build(BuildContext context) {
    return TwIconButton(
      icon: Icons.arrow_back_rounded,
      tooltip: 'Voltar',
      background: background,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
    );
  }
}

class TwIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;

  const TwIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.background = AppColors.branco,
    this.foreground = AppColors.azulMarinho,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: background == AppColors.branco
              ? const BorderSide(color: AppColors.borda)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 22, color: foreground),
          ),
        ),
      ),
    );
  }
}

/// Texto pequeno em caixa alta e fonte "cartão de embarque".
class Eyebrow extends StatelessWidget {
  final String text;
  final Color color;

  const Eyebrow(this.text, {super.key, this.color = AppColors.verdePetroleo});

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: AppText.eyebrow(color: color));
}

/// Campo de formulário com rótulo acima.
class LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;

  const LabeledField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          textInputAction: textInputAction,
          style: const TextStyle(fontSize: 16, color: AppColors.azulMarinho),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

/// Chip selecionável em formato de pílula.
class SelectPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  const SelectPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor = AppColors.azulMarinho,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? selectedColor : AppColors.branco,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? selectedColor : AppColors.bordaInput,
            width: 1.5,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                    color: selected ? AppColors.branco : AppColors.azulMarinho,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão branco com borda suave.
class TwCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;

  const TwCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.branco,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.borda),
      ),
      child: child,
    );
  }
}

/// Linha tracejada horizontal (picote de cartão de embarque).
class DashedDivider extends StatelessWidget {
  final Color color;
  final double thickness;

  const DashedDivider({
    super.key,
    this.color = AppColors.tracejado,
    this.thickness = 2,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dash = 6.0;
        const gap = 5.0;
        final count = (constraints.maxWidth / (dash + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => SizedBox(
              width: dash,
              height: thickness,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            ),
          ),
        );
      },
    );
  }
}

/// Barra de navegação inferior (Início, Match, Viagens, Sobre).
class TwBottomNav extends StatelessWidget {
  final int currentIndex;

  const TwBottomNav({super.key, required this.currentIndex});

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Início'),
    (Icons.explore_outlined, Icons.explore, 'Match'),
    (Icons.luggage_outlined, Icons.luggage, 'Viagens'),
    (Icons.info_outline_rounded, Icons.info_rounded, 'Sobre'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.branco,
        border: Border(top: BorderSide(color: AppColors.borda)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: i == currentIndex ? _items[i].$2 : _items[i].$1,
                    label: _items[i].$3,
                    selected: i == currentIndex,
                    onTap: () => AppRoutes.goToTab(context, i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.coralEscuro : AppColors.textMuted;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Moldura de largura máxima: no navegador o app fica centralizado
/// com proporção de celular; no celular ocupa a tela toda.
class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.azulMarinho,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: child,
        ),
      ),
    );
  }
}

/// Cartão de embarque de uma viagem salva (Home e Minhas Viagens).
class TripTicketCard extends StatelessWidget {
  final Viagem viagem;
  final VoidCallback? onTap;
  final Widget? trailing;

  const TripTicketCard(
      {super.key, required this.viagem, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final v = viagem;
    return Material(
      color: AppColors.branco,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borda),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(dataCurta(v.dataIda).toUpperCase(),
                              style: AppText.mono(12,
                                  color: AppColors.textSecondary)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.flight_takeoff_rounded,
                                size: 16, color: AppColors.coral),
                          ),
                          Text(dataCurta(v.dataVolta).toUpperCase(),
                              style: AppText.mono(12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('${v.destinoNome.toUpperCase()} · ${v.destinoUf}',
                          style: AppText.display(26)),
                      const SizedBox(height: 2),
                      Text(
                        '${v.dias} dias · ${v.pessoas} ${v.pessoas == 1 ? 'pessoa' : 'pessoas'} · ${formatBRL(v.custoEstimado)}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      StatusChip(status: v.status),
                    ],
                  ),
                ),
              ),
              if (trailing != null) trailing!,
              Container(
                width: 78,
                color: AppColors.creme,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${v.matchPercent}%',
                        style: AppText.display(28,
                            color: AppColors.verdePetroleo)),
                    Text('MATCH', style: AppText.mono(10)),
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

/// Etiqueta colorida com o status da viagem.
class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'Confirmada' => (AppColors.menta, AppColors.verdeEscuro),
      'Concluída' => (AppColors.prata, AppColors.azulMarinho),
      _ => (AppColors.creme, const Color(0xFF7A5B00)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(status,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

/// Estado vazio com ícone, texto e ação.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String texto;
  final String? acao;
  final VoidCallback? onAcao;

  const EmptyState({
    super.key,
    required this.icon,
    required this.titulo,
    required this.texto,
    this.acao,
    this.onAcao,
  });

  @override
  Widget build(BuildContext context) {
    return TwCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.coral),
          const SizedBox(height: 8),
          Text(titulo.toUpperCase(),
              textAlign: TextAlign.center, style: AppText.display(24)),
          const SizedBox(height: 4),
          Text(texto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
          if (acao != null) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onAcao,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.azulMarinho,
                minimumSize: const Size(0, 44),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontFamily: AppFonts.body),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(acao!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Pergunta de confirmação para ações destrutivas (DELETE).
Future<bool> confirmar(BuildContext context,
    {required String titulo,
    required String mensagem,
    String acao = 'Excluir'}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.offWhite,
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar')),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.coralEscuro),
          child: Text(acao),
        ),
      ],
    ),
  );
  return ok ?? false;
}

void mostrarAviso(BuildContext context, String mensagem) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(mensagem)));
}
