import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/viagem_repository.dart';
import '../models/trip_preferences.dart';
import '../models/viagem.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/tw_widgets.dart';
import 'trip_form_screen.dart';

/// Detalhe de uma viagem com o roteiro. CRUD completo dos itens do roteiro
/// (tabela `roteiro_itens`) e acesso à edição/exclusão da viagem.
class TripDetailScreen extends StatefulWidget {
  final int viagemId;

  const TripDetailScreen({super.key, required this.viagemId});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  Viagem? _viagem;
  List<RoteiroItem> _itens = const [];
  bool _carregando = true;

  static const _cores = [
    AppColors.coral,
    AppColors.amarelo,
    AppColors.turquesa,
    AppColors.verdePetroleo,
    AppColors.azulMarinho,
  ];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  /// READ: viagem (com JOIN no destino) e itens do roteiro.
  Future<void> _carregar() async {
    final v = await ViagemRepository.buscarPorId(widget.viagemId);
    final itens = await ViagemRepository.listarItens(widget.viagemId);
    if (!mounted) return;
    setState(() {
      _viagem = v;
      _itens = itens;
      _carregando = false;
    });
  }

  Future<void> _editarViagem() async {
    final alterou = await Navigator.of(context).pushNamed(AppRoutes.tripForm,
        arguments: TripFormArgs.editar(_viagem!));
    if (alterou == true) _carregar();
  }

  Future<void> _excluirViagem() async {
    final ok = await confirmar(context,
        titulo: 'Excluir viagem?',
        mensagem:
            'A viagem para ${_viagem!.destinoNome} e todo o roteiro serão apagados.');
    if (!ok) return;
    await ViagemRepository.excluir(widget.viagemId);
    if (!mounted) return;
    mostrarAviso(context, 'Viagem excluída.');
    AppRoutes.goToTab(context, 2);
  }

  /// UPDATE: marca/desmarca o item como concluído.
  Future<void> _alternarConcluido(RoteiroItem item) async {
    await ViagemRepository.atualizarItem(RoteiroItem(
      id: item.id,
      viagemId: item.viagemId,
      dia: item.dia,
      titulo: item.titulo,
      descricao: item.descricao,
      concluido: !item.concluido,
    ));
    _carregar();
  }

  /// CREATE ou UPDATE de um item pelo diálogo.
  Future<void> _abrirDialogoItem([RoteiroItem? item]) async {
    final resultado = await showModalBottomSheet<RoteiroItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.offWhite,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _ItemSheet(
        viagemId: widget.viagemId,
        maxDia: _viagem?.dias ?? 30,
        item: item,
      ),
    );
    if (resultado == null) return;
    if (item == null) {
      await ViagemRepository.criarItem(resultado);
      if (mounted) mostrarAviso(context, 'Atividade adicionada.');
    } else {
      await ViagemRepository.atualizarItem(resultado);
      if (mounted) mostrarAviso(context, 'Atividade atualizada.');
    }
    _carregar();
  }

  /// DELETE de um item do roteiro.
  Future<void> _excluirItem(RoteiroItem item) async {
    final ok = await confirmar(context,
        titulo: 'Excluir atividade?', mensagem: '“${item.titulo}” será removida.');
    if (!ok) return;
    await ViagemRepository.excluirItem(item.id!);
    if (mounted) mostrarAviso(context, 'Atividade excluída.');
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final v = _viagem;
    final feitos = _itens.where((i) => i.concluido).length;

    return Scaffold(
      bottomNavigationBar: const TwBottomNav(currentIndex: 2),
      floatingActionButton: v == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _abrirDialogoItem(),
              backgroundColor: AppColors.coral,
              foregroundColor: AppColors.branco,
              icon: const Icon(Icons.add),
              label: const Text('Atividade',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
      body: SafeArea(
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : v == null
                ? const Center(child: Text('Viagem não encontrada.'))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 96),
                    children: [
                      Row(
                        children: [
                          TwBackButton(
                            onPressed: () => Navigator.of(context).canPop()
                                ? Navigator.of(context).pop()
                                : AppRoutes.goToTab(context, 2),
                          ),
                          const Spacer(),
                          TwIconButton(
                            icon: Icons.edit_outlined,
                            tooltip: 'Editar viagem',
                            onPressed: _editarViagem,
                          ),
                          const SizedBox(width: 8),
                          TwIconButton(
                            icon: Icons.delete_outline,
                            tooltip: 'Excluir viagem',
                            foreground: AppColors.coralEscuro,
                            onPressed: _excluirViagem,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Eyebrow('${dataCurta(v.dataIda)} – ${dataCurta(v.dataVolta)} · ${v.dias} dias'),
                          const Spacer(),
                          StatusChip(status: v.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${v.destinoNome.toUpperCase()} · ${v.destinoUf}',
                          style: AppText.display(40)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _Info(
                              icon: Icons.group_outlined,
                              texto:
                                  '${v.pessoas} ${v.pessoas == 1 ? 'pessoa' : 'pessoas'}'),
                          _Info(
                              icon: Icons.payments_outlined,
                              texto: formatBRL(v.custoEstimado)),
                          _Info(
                              icon: Icons.favorite_border,
                              texto: '${v.matchPercent}% match'),
                        ],
                      ),
                      if (v.observacoes.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        TwCard(
                          color: AppColors.creme,
                          padding: const EdgeInsets.all(12),
                          child: Text(v.observacoes,
                              style: const TextStyle(fontSize: 14)),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Text('ROTEIRO', style: AppText.display(26)),
                          const Spacer(),
                          Text('$feitos de ${_itens.length} feitos',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_itens.isEmpty)
                        const EmptyState(
                          icon: Icons.map_outlined,
                          titulo: 'Roteiro vazio',
                          texto: 'Toque em “+ Atividade” para montar o seu.',
                        ),
                      for (var i = 0; i < _itens.length; i++)
                        _ItemTile(
                          item: _itens[i],
                          cor: _cores[(_itens[i].dia - 1) % _cores.length],
                          mostrarDia: i == 0 || _itens[i - 1].dia != _itens[i].dia,
                          onToggle: () => _alternarConcluido(_itens[i]),
                          onEditar: () => _abrirDialogoItem(_itens[i]),
                          onExcluir: () => _excluirItem(_itens[i]),
                        ),
                    ],
                  ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _Info({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.coral),
          const SizedBox(width: 6),
          Flexible(
            child: Text(texto,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final RoteiroItem item;
  final Color cor;
  final bool mostrarDia;
  final VoidCallback onToggle;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _ItemTile({
    required this.item,
    required this.cor,
    required this.mostrarDia,
    required this.onToggle,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final claro = cor == AppColors.coral ||
        cor == AppColors.verdePetroleo ||
        cor == AppColors.azulMarinho;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: mostrarDia
                ? CircleAvatar(
                    radius: 18,
                    backgroundColor: cor,
                    child: Text('${item.dia}',
                        style: AppText.display(20,
                            color: claro
                                ? AppColors.branco
                                : AppColors.azulMarinho)),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Material(
              color: item.concluido ? AppColors.salvia : AppColors.branco,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.borda),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onEditar,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                  child: Row(
                    children: [
                      Checkbox(
                        value: item.concluido,
                        onChanged: (_) => onToggle(),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DIA ${item.dia}',
                                style: AppText.mono(11,
                                    color: AppColors.textSecondary)),
                            Text(
                              item.titulo,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                decoration: item.concluido
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (item.descricao.isNotEmpty)
                              Text(item.descricao,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Excluir atividade',
                        onPressed: onExcluir,
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Formulário em bottom sheet para criar/editar uma atividade.
class _ItemSheet extends StatefulWidget {
  final int viagemId;
  final int maxDia;
  final RoteiroItem? item;

  const _ItemSheet({required this.viagemId, required this.maxDia, this.item});

  @override
  State<_ItemSheet> createState() => _ItemSheetState();
}

class _ItemSheetState extends State<_ItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _titulo = TextEditingController(text: widget.item?.titulo);
  late final _descricao = TextEditingController(text: widget.item?.descricao);
  late int _dia = widget.item?.dia ?? 1;

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.item == null ? 'NOVA ATIVIDADE' : 'EDITAR ATIVIDADE',
                style: AppText.display(28)),
            const SizedBox(height: 14),
            LabeledField(
              label: 'Título',
              hint: 'Ex.: Passeio de barco',
              controller: _titulo,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe um título' : null,
            ),
            const SizedBox(height: 10),
            LabeledField(
              label: 'Descrição (opcional)',
              hint: 'Ex.: saída às 9h do píer',
              controller: _descricao,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Dia', style: AppText.label),
                const Spacer(),
                IconButton(
                  tooltip: 'Dia anterior',
                  onPressed: _dia > 1 ? () => setState(() => _dia--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_dia',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                IconButton(
                  tooltip: 'Próximo dia',
                  onPressed: _dia < widget.maxDia
                      ? () => setState(() => _dia++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                Navigator.of(context).pop(RoteiroItem(
                  id: widget.item?.id,
                  viagemId: widget.viagemId,
                  dia: _dia,
                  titulo: _titulo.text.trim(),
                  descricao: _descricao.text.trim(),
                  concluido: widget.item?.concluido ?? false,
                ));
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.coral,
                minimumSize: const Size.fromHeight(52),
                textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFonts.body),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
