import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/destino_repository.dart';
import '../data/session.dart';
import '../models/destination.dart';
import '../models/trip_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/tw_widgets.dart';
import 'trip_form_screen.dart';

/// Detalhe do destino com motivos do match e estimativa de gastos.
class DestinationDetailScreen extends StatefulWidget {
  final MatchResult match;

  const DestinationDetailScreen({super.key, required this.match});

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  bool _salvo = false;

  @override
  void initState() {
    super.initState();
    final id = Session.usuarioId;
    if (id != null) {
      // READ: o destino já está nos favoritos?
      DestinoRepository.isFavorito(id, widget.match.destino.id).then((fav) {
        if (mounted) setState(() => _salvo = fav);
      });
    }
  }

  /// CREATE/DELETE na tabela `favoritos`.
  Future<void> _alternarFavorito() async {
    final id = Session.usuarioId;
    if (id == null) return;
    final fav =
        await DestinoRepository.alternarFavorito(id, widget.match.destino.id);
    if (!mounted) return;
    setState(() => _salvo = fav);
    mostrarAviso(context,
        fav ? 'Destino salvo nos favoritos.' : 'Removido dos favoritos.');
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    final d = m.destino;
    final total = m.custo;
    final orcamento = m.orcamento;
    final uso = (total / orcamento).clamp(0.0, 1.0);
    final sobra = orcamento - total;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 220 + MediaQuery.paddingOf(context).top,
            child: Stack(
              children: [
                const Positioned.fill(
                    child: CustomPaint(painter: _BeachPainter())),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TwBackButton(background: AppColors.offWhite),
                        TwIconButton(
                          icon: _salvo
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          tooltip: _salvo ? 'Remover dos salvos' : 'Salvar destino',
                          background: AppColors.offWhite,
                          foreground: AppColors.coralEscuro,
                          onPressed: _alternarFavorito,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Eyebrow('${_estado(d.state)} · Brasil'),
                          const SizedBox(height: 2),
                          Text(d.name.toUpperCase(), style: AppText.display(46)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.azulMarinho,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text('${m.percent}%',
                              style: AppText.display(28,
                                  color: AppColors.amarelo)),
                          Text('MATCH',
                              style: AppText.mono(10,
                                  color: AppColors.offWhite)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Por que combina com você', style: AppText.label),
                const SizedBox(height: 8),
                for (final r in m.motivos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_rounded,
                            color: AppColors.verdePetroleo, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(r,
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF33495C))),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                TwCard(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text('ESTIMATIVA DE GASTOS',
                                style: AppText.display(24)),
                          ),
                          Text('${m.dias} dias · ${m.pessoas} ${m.pessoas == 1 ? 'pessoa' : 'pessoas'}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      for (final c in d.costs)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  c.unidade == 'noite'
                                      ? '${c.label} (${m.dias > 1 ? m.dias - 1 : 1} noites)'
                                      : c.label,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary)),
                              Text(formatBRL(c.totalPara(dias: m.dias, pessoas: m.pessoas)),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      const DashedDivider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(formatBRL(total),
                              style: AppText.display(28,
                                  color: AppColors.coralEscuro)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: uso,
                          minHeight: 10,
                          backgroundColor: AppColors.trilha,
                          color: sobra >= 0
                              ? AppColors.verdePetroleo
                              : AppColors.coralEscuro,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        sobra >= 0
                            ? '${(total / orcamento * 100).round()}% do seu orçamento · sobra ${formatBRL(sobra)}'
                            : 'Passa ${formatBRL(-sobra)} do seu orçamento',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Planejar esta viagem',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.tripForm,
                      arguments: TripFormArgs.nova(m)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _estado(String uf) => switch (uf) {
        'BA' => 'Bahia',
        'RJ' => 'Rio de Janeiro',
        'SP' => 'São Paulo',
        'MG' => 'Minas Gerais',
        _ => uf,
      };
}

/// Ilustração simples de praia (sol, morros, mar e coqueiro).
class _BeachPainter extends CustomPainter {
  const _BeachPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.turquesa);
    canvas.drawCircle(
        Offset(w * 0.69, h * 0.44), 46, Paint()..color = AppColors.amarelo);

    final morros = Path()
      ..moveTo(0, h * 0.68)
      ..lineTo(w * 0.23, h * 0.42)
      ..lineTo(w * 0.38, h * 0.6)
      ..lineTo(w * 0.55, h * 0.38)
      ..lineTo(w * 0.77, h * 0.65)
      ..lineTo(w, h * 0.5)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(morros, Paint()..color = AppColors.verdePetroleo);

    Path onda(double y, double amp) => Path()
      ..moveTo(0, y)
      ..cubicTo(w * 0.18, y - amp, w * 0.33, y + amp, w * 0.51, y)
      ..cubicTo(w * 0.69, y - amp, w * 0.85, y - amp / 2, w, y)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(onda(h * 0.77, 20),
        Paint()..color = AppColors.azulMarinho.withValues(alpha: 0.9));
    canvas.drawPath(onda(h * 0.87, 16), Paint()..color = AppColors.offWhite);

    final tronco = Paint()
      ..color = AppColors.azulMarinho
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final topo = Offset(w * 0.19, h * 0.47);
    canvas.drawPath(
        Path()
          ..moveTo(w * 0.15, h * 0.78)
          ..quadraticBezierTo(w * 0.16, h * 0.6, topo.dx, topo.dy),
        tronco);
    for (final folha in [
      Offset(topo.dx - 32, topo.dy + 12),
      Offset(topo.dx + 30, topo.dy - 2),
      Offset(topo.dx - 22, topo.dy - 18),
      Offset(topo.dx + 8, topo.dy - 26),
    ]) {
      canvas.drawPath(
          Path()
            ..moveTo(topo.dx, topo.dy)
            ..quadraticBezierTo((topo.dx + folha.dx) / 2,
                (topo.dy + folha.dy) / 2 - 10, folha.dx, folha.dy),
          tronco);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
