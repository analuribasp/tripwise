import 'package:flutter/material.dart';

import 'models/destination.dart';
import 'models/trip_preferences.dart';
import 'screens/about_screen.dart';
import 'screens/destination_detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/match_screen.dart';
import 'screens/my_trips_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'screens/trip_form_screen.dart';
import 'screens/welcome_screen.dart';

/// Rotas nomeadas do app e a navegação entre as telas.
///
/// Fluxo principal:
/// splash → início → cadastro/login → home → preferências → match
/// → destino → planejar viagem → minhas viagens → detalhe/roteiro.
/// A barra inferior leva a home, match, viagens e sobre.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const welcome = '/inicio';
  static const login = '/login';
  static const signup = '/cadastro';
  static const home = '/home';
  static const preferences = '/preferencias';
  static const match = '/match';
  static const destination = '/destino';
  static const tripForm = '/viagem/formulario';
  static const myTrips = '/viagens';
  static const tripDetail = '/viagem';
  static const profile = '/perfil';
  static const about = '/sobre';

  /// Rotas acessíveis pela barra de navegação inferior, na ordem das abas.
  static const tabs = [home, preferences, myTrips, about];

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final Widget page = switch (settings.name) {
      splash => const SplashScreen(),
      welcome => const WelcomeScreen(),
      login => const LoginScreen(),
      signup => const SignupScreen(),
      home => const HomeScreen(),
      preferences => const PreferencesScreen(),
      match => MatchScreen(
          preferences:
              args is TripPreferences ? args : TripPreferences.initial(),
        ),
      destination when args is MatchResult =>
        DestinationDetailScreen(match: args),
      tripForm when args is TripFormArgs => TripFormScreen(args: args),
      myTrips => const MyTripsScreen(),
      tripDetail when args is int => TripDetailScreen(viagemId: args),
      profile => const ProfileScreen(),
      about => AboutScreen(showNav: args != false),
      _ => const HomeScreen(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  /// Troca de aba sem empilhar telas repetidas.
  static void goToTab(BuildContext context, int index) {
    final target = tabs[index];
    if (ModalRoute.of(context)?.settings.name == target) return;
    final nav = Navigator.of(context);
    if (target == home) {
      nav.pushNamedAndRemoveUntil(home, (route) => false);
    } else {
      nav.pushNamedAndRemoveUntil(
          target, (route) => route.settings.name == home);
    }
  }
}
