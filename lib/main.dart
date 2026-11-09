import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_routes.dart';
import 'theme/app_theme.dart';
import 'widgets/tw_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TripWiseApp());
}

class TripWiseApp extends StatelessWidget {
  const TripWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      builder: (context, child) => PhoneFrame(child: child!),
    );
  }
}
