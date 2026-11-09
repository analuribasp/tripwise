import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/session.dart';
import '../data/usuario_repository.dart';
import '../data/viagem_repository.dart';
import '../models/usuario.dart';
import '../models/viagem.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/tw_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<(Usuario?, Viagem?)> _dados;

  @override
  void initState() {
    super.initState();
    _dados = _carregar();
  }

  /// READ: usuário logado e próxima viagem, direto do SQLite.
  Future<(Usuario?, Viagem?)> _carregar() async {
    final id = Session.usuarioId;
    if (id == null) return (null, null);
    return (
      await UsuarioRepository.buscarPorId(id),
      await ViagemRepository.proxima(id),
    );
  }

  Future<void> _abrir(String rota, {Object? args}) async {
    await Navigator.of(context).pushNamed(rota, arguments: args);
    if (!mounted) return;
    setState(() {
      _dados = _carregar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const TwBottomNav(currentIndex: 0),
      body: SafeArea(
        child: FutureBuilder(
          future: _dados,
          builder: (context, snap) {
            final usuario = snap.data?.$1;
            final proxima = snap.data?.$2;
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logo_mark.png', width: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Olá, viajante',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary)),
                          Text(usuario?.primeiroNome ?? '',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    TwIconButton(
                      icon: Icons.person_outline_rounded,
                      tooltip: 'Meu perfil',
                      onPressed: () => _abrir(AppRoutes.profile),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const _MatchHero(),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PRÓXIMA VIAGEM', style: AppText.display(26)),
                    TextButton(
                      onPressed: () => AppRoutes.goToTab(context, 2),
                      child: const Text('Minhas viagens',
                          style: TextStyle(
                              color: AppColors.verdePetroleo,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (snap.connectionState != ConnectionState.done)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (proxima == null)
                  EmptyState(
                    icon: Icons.luggage_outlined,
                    titulo: 'Nenhuma viagem ainda',
                    texto:
                        'Faça seu Travel Match e salve a viagem que mais combinar com você.',
                    acao: 'Fazer meu match',
                    onAcao: () => AppRoutes.goToTab(context, 1),
                  )
                else
                  TripTicketCard(
                    viagem: proxima,
                    onTap: () =>
                        _abrir(AppRoutes.tripDetail, args: proxima.id),
                  ),
                const SizedBox(height: 22),
                Text('INSPIRE-SE POR ESTILO', style: AppText.display(26)),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(
                        child: _StyleTile(
                            label: 'Praia',
                            icon: Icons.beach_access_outlined,
                            color: AppColors.turquesa)),
                    SizedBox(width: 10),
                    Expanded(
                        child: _StyleTile(
                            label: 'Montanha',
                            icon: Icons.landscape_outlined,
                            color: AppColors.creme)),
                    SizedBox(width: 10),
                    Expanded(
                        child: _StyleTile(
                            label: 'Cidade',
                            icon: Icons.location_city_outlined,
                            color: AppColors.rosa)),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MatchHero extends StatelessWidget {
  const _MatchHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.azulMarinho,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.turquesa, width: 2),
              ),
              alignment: Alignment.center,
              child: const CircleAvatar(
                  radius: 34, backgroundColor: AppColors.amarelo),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Travel Match', color: AppColors.turquesa),
                const SizedBox(height: 10),
                SizedBox(
                  width: 250,
                  child: Text('NÃO SABE PRA ONDE IR? MELHOR AINDA.',
                      style: AppText.display(38, color: AppColors.offWhite)
                          .copyWith(height: 0.95)),
                ),
                const SizedBox(height: 10),
                const SizedBox(
                  width: 260,
                  child: Text(
                    'Responda poucas perguntas e receba os destinos que mais combinam com você.',
                    style: TextStyle(
                        fontSize: 14, height: 1.4, color: Color(0xFFD5E6EE)),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () =>
                      AppRoutes.goToTab(context, 1),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  iconAlignment: IconAlignment.end,
                  label: const Text('Fazer meu match'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.amarelo,
                    foregroundColor: AppColors.azulMarinho,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFonts.body),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StyleTile(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => AppRoutes.goToTab(context, 1),
        child: SizedBox(
          height: 92,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: AppColors.azulMarinho),
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
