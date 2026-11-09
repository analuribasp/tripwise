import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_routes.dart';
import '../data/destino_repository.dart';
import '../data/session.dart';
import '../data/viagem_repository.dart';
import '../models/destination.dart';
import '../models/trip_preferences.dart';
import '../models/viagem.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/tw_widgets.dart';

/// Argumentos do formulário: nova viagem (a partir do match) ou edição.
class TripFormArgs {
  final MatchResult? match;
  final Viagem? viagem;

  const TripFormArgs.nova(MatchResult this.match) : viagem = null;
  const TripFormArgs.editar(Viagem this.viagem) : match = null;

  bool get editando => viagem != null;
}

/// Formulário de viagem: CREATE (nova) e UPDATE (editar).
class TripFormScreen extends StatefulWidget {
  final TripFormArgs args;

  const TripFormScreen({super.key, required this.args});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orcamento = TextEditingController();
  final _obs = TextEditingController();

  Destination? _destino;
  late DateTime _ida;
  late DateTime _volta;
  late int _pessoas;
  String _status = statusViagem.first;
  bool _salvando = false;

  bool get _editando => widget.args.editando;

  @override
  void initState() {
    super.initState();
    final v = widget.args.viagem;
    final m = widget.args.match;
    if (v != null) {
      _ida = v.dataIda;
      _volta = v.dataVolta;
      _pessoas = v.pessoas;
      _status = v.status;
      _orcamento.text = v.orcamento.round().toString();
      _obs.text = v.observacoes;
      DestinoRepository.buscarPorId(v.destinoId).then((d) {
        if (mounted) setState(() => _destino = d);
      });
    } else {
      final hoje = DateTime.now();
      _ida = DateTime(hoje.year, hoje.month, hoje.day)
          .add(const Duration(days: 30));
      _volta = _ida.add(Duration(days: m!.dias - 1));
      _pessoas = m.pessoas;
      _orcamento.text = m.orcamento.toString();
      _destino = m.destino;
    }
  }

  @override
  void dispose() {
    _orcamento.dispose();
    _obs.dispose();
    super.dispose();
  }

  int get _dias => _volta.difference(_ida).inDays + 1;

  double get _custo =>
      _destino?.custoPara(dias: _dias, pessoas: _pessoas) ??
      widget.args.viagem?.custoEstimado ??
      0;

  Future<void> _escolherData({required bool ida}) async {
    final atual = ida ? _ida : _volta;
    final escolhida = await showDatePicker(
      context: context,
      initialDate: atual,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: ida ? 'Data de ida' : 'Data de volta',
    );
    if (escolhida == null) return;
    setState(() {
      if (ida) {
        final duracao = _volta.difference(_ida);
        _ida = escolhida;
        _volta = escolhida.add(duracao);
      } else if (!escolhida.isBefore(_ida)) {
        _volta = escolhida;
      } else {
        mostrarAviso(context, 'A volta não pode ser antes da ida.');
      }
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final usuarioId = Session.usuarioId;
    if (usuarioId == null) return;
    setState(() => _salvando = true);
    final orcamento = double.parse(_orcamento.text);
    try {
      if (_editando) {
        // UPDATE na tabela `viagens`.
        final v = widget.args.viagem!.copyWith(
          dataIda: _ida,
          dataVolta: _volta,
          pessoas: _pessoas,
          orcamento: orcamento,
          custoEstimado: _custo,
          status: _status,
          observacoes: _obs.text.trim(),
        );
        await ViagemRepository.atualizar(v);
        if (!mounted) return;
        mostrarAviso(context, 'Viagem atualizada.');
        Navigator.of(context).pop(true);
      } else {
        // CREATE: grava a viagem e copia o roteiro sugerido.
        final m = widget.args.match!;
        final id = await ViagemRepository.criar(
          Viagem(
            usuarioId: usuarioId,
            destinoId: m.destino.id,
            dataIda: _ida,
            dataVolta: _volta,
            pessoas: _pessoas,
            orcamento: orcamento,
            custoEstimado: _custo,
            matchPercent: m.percent,
            status: _status,
            observacoes: _obs.text.trim(),
          ),
          m.destino,
        );
        if (!mounted) return;
        mostrarAviso(context, 'Viagem para ${m.destino.name} salva!');
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.tripDetail,
          (route) => route.settings.name == AppRoutes.home,
          arguments: id,
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nome = _destino?.name ?? widget.args.viagem?.destinoNome ?? '';
    final orcamento = double.tryParse(_orcamento.text) ?? 0;
    final cabe = _custo <= orcamento;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            children: [
              Row(
                children: [
                  const TwBackButton(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Eyebrow(
                        _editando ? 'Editar viagem' : 'Nova viagem'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(nome.toUpperCase(), style: AppText.display(42)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Ida',
                      data: _ida,
                      onTap: () => _escolherData(ida: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateField(
                      label: 'Volta',
                      data: _volta,
                      onTap: () => _escolherData(ida: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TwCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 60,
                  child: Row(
                    children: [
                      const Icon(Icons.group_outlined,
                          color: AppColors.coral, size: 22),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Viajantes',
                            style: TextStyle(
                                fontSize: 14, color: AppColors.textSecondary)),
                      ),
                      TwIconButton(
                        icon: Icons.remove_rounded,
                        tooltip: 'Menos pessoas',
                        background: AppColors.offWhite,
                        onPressed: _pessoas > 1
                            ? () => setState(() => _pessoas--)
                            : null,
                      ),
                      SizedBox(
                        width: 44,
                        child: Text('$_pessoas',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                      TwIconButton(
                        icon: Icons.add_rounded,
                        tooltip: 'Mais pessoas',
                        background: AppColors.offWhite,
                        onPressed: () => setState(() => _pessoas++),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Orçamento total (R\$)', style: AppText.label),
              const SizedBox(height: 6),
              TextFormField(
                controller: _orcamento,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(hintText: 'Ex.: 2500'),
                onChanged: (_) => setState(() {}),
                validator: (v) => (v == null || (int.tryParse(v) ?? 0) <= 0)
                    ? 'Informe um valor maior que zero'
                    : null,
              ),
              const SizedBox(height: 14),
              const Text('Status', style: AppText.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in statusViagem)
                    SelectPill(
                      label: s,
                      selected: _status == s,
                      selectedColor: AppColors.verdePetroleo,
                      onTap: () => setState(() => _status = s),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Observações', style: AppText.label),
              const SizedBox(height: 6),
              TextFormField(
                controller: _obs,
                maxLines: 3,
                maxLength: 300,
                decoration: const InputDecoration(
                    hintText: 'Ex.: reservar pousada perto da praia'),
              ),
              const SizedBox(height: 6),
              TwCard(
                color: cabe ? AppColors.menta : AppColors.rosa,
                child: Row(
                  children: [
                    Icon(
                        cabe
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_rounded,
                        color: cabe
                            ? AppColors.verdeEscuro
                            : AppColors.coralEscuro),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Custo estimado: ${formatBRL(_custo)} para $_dias dias'
                        '${cabe ? '' : ' · acima do orçamento'}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: _salvando
                    ? 'Salvando…'
                    : (_editando ? 'Salvar alterações' : 'Salvar viagem'),
                icon: Icons.bookmark_add_outlined,
                iconLeading: true,
                onPressed: _salvando ? null : _salvar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime data;
  final VoidCallback onTap;

  const _DateField(
      {required this.label, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 6),
        Material(
          color: AppColors.branco,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.bordaInput, width: 1.5),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.calendar_month_outlined,
                      size: 20, color: AppColors.coral),
                  const SizedBox(width: 8),
                  Text(dataBr(data),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
