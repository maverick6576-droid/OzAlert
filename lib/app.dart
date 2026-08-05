import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/main_navigation_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/onboarding/welcome_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/paywall/paywall_screen.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/user_provider.dart';

class OzVisaAlertApp extends ConsumerWidget {
  const OzVisaAlertApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userProfileState = ref.watch(userProfileProvider);

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
          if (user == null) {
            // Usuario no logueado, va a la Pantalla de Login
            return const LoginScreen();
          }

          // Si el usuario está logueado, comprobamos si tiene perfil
          return userProfileState.when(
            data: (profile) {
              if (profile == null || !profile.onboardingCompleted) {
                // No tiene perfil o no completó el onboarding -> Welcome Intro
                return const WelcomeScreen();
              } else if (!profile.isPremium) {
                // Perfil completo, pero NO ha pagado -> Paywall
                return const PaywallScreen();
              } else {
                // Perfil completo y PAGADO -> Dashboard Principal
                return const MainNavigationScreen();
              }
            },
            loading: () => const _LoadingScreen(),
            error: (err, _) => _ErrorScreen(err.toString()),
          );
        },
        loading: () => const _LoadingScreen(),
        error: (error, _) => _ErrorScreen(error.toString()),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String error;
  const _ErrorScreen(this.error);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Error: $error')),
    );
  }
}
