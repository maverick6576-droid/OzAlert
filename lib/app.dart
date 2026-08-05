import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/main_navigation_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/providers/auth_provider.dart';

class OzVisaAlertApp extends ConsumerWidget {
  const OzVisaAlertApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'OzVisa Alert (3 Pantallas)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme, // Forzar light theme para todo
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español como idioma primario
        Locale('en', 'US'),
      ],
      home: authState.when(
        data: (user) {
          if (user != null) {
            // Usuario logueado, va al Dashboard Principal
            return const MainNavigationScreen();
          } else {
            // Usuario no logueado, va a la Pantalla de Login
            return const LoginScreen();
          }
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, _) => Scaffold(
          body: Center(
            child: Text('Error de autenticación: $error'),
          ),
        ),
      ),
    );
  }
}
