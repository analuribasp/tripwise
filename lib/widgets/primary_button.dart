import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botão principal (coral com "sombra sólida"), usado nas ações de cada tela.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool iconLeading;
  final Color background;
  final Color foreground;
  final Color shadow;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconLeading = false,
    this.background = AppColors.coral,
    this.foreground = AppColors.branco,
    this.shadow = AppColors.coralEscuro,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = icon == null ? null : Icon(icon, size: 22);
    return Semantics(
      button: true,
      label: label,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: shadow, offset: const Offset(0, 6))],
        ),
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: IconTheme(
                data: IconThemeData(color: foreground),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (iconWidget != null && iconLeading) ...[
                      iconWidget,
                      const SizedBox(width: 10),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (iconWidget != null && !iconLeading) ...[
                      const SizedBox(width: 10),
                      iconWidget,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
