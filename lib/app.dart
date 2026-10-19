import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/main_navigation_screen.dart';
import 'presentation/navigation/phase2_navigation_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/onboarding/welcome_screen.dart';
import 'presentation/screens/onboarding/referral_source_screen.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/paywall_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/locale_provider.dart';
import 'package:ozvisa_alert/l10n/app_localizations.dart';

class OzVisaAlertApp extends ConsumerStatefulWidget {
  const OzVisaAlertApp({super.key});

  @override
  ConsumerState<OzVisaAlertApp> createState() => _OzVisaAlertAppState();
}

class _OzVisaAlertAppState extends ConsumerState<OzVisaAlertApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Al volver a la app, verificar si el usuario se ha suscrito o ha dejado de pagar para sincronizar el canal FCM
      ref.read(paywallProvider.notifier).checkSubscriptionStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final userProfileState = ref.watch(userProfileProvider);
    ref.watch(paywallProvider);

    return MaterialApp(
      title: 'OzVisa Alert (3 Pantallas)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme, // Forzar light theme para todo
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: ref.watch(localeProvider),
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // Si el usuario forzó un idioma, lo usamos (ya está en 'locale')
        // Si no, comprobamos si el dispositivo está en la lista soportada
        for (var locale in supportedLocales) {
          if (deviceLocale != null && locale.languageCode == deviceLocale.languageCode) {
            return deviceLocale;
          }
        }
        // Fallback a inglés por defecto según requisitos
        return const Locale('en');
      },
      home: authState.when(
        data: (user) {
          if (user == null) {
            // Usuario no logueado, va a la Pantalla de Login
            return const LoginScreen();
          }

          // Si el usuario está logueado, comprobamos si tiene perfil
          return userProfileState.when(
            skipLoadingOnRefresh: true,
            data: (profile) {
              if (profile == null || !profile.onboardingCompleted) {
                // No tiene perfil o no completó el onboarding -> Welcome Intro
                return const WelcomeScreen();
              } else if (profile.referralSource == null) {
                // Completó onboarding pero no ha dicho de dónde viene -> Referral Screen
                return ReferralSourceScreen(onCompleted: () {});
              } else if (profile.currentPhase == 2) {
                // FASE 2: Experiencia dedicada en Australia (Llegada, Empleo, Guías y 88 Días)
                return const Phase2NavigationScreen();
              } else {
                // FASE 1 GRATUITA: Acceso completo al Radar, Equipo y Bitácora (Notificación de apertura bloqueada para PRO)
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
