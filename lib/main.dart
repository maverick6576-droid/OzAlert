import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'data/repositories/paywall_repository_impl.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final sharedPrefs = await SharedPreferences.getInstance();

  // 1. Inicialización de Firebase con credenciales reales configuradas para Android e iOS
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase inicializado correctamente para el proyecto ozvisa-alert-prod.');
  } catch (e) {
    debugPrint(
      'ℹ️ Aviso al inicializar Firebase: $e. La app ejecutará de forma tolerante a fallos.',
    );
  }

  // 2. Inicialización del servicio de notificaciones para el botón "Probar Alerta"
  try {
    await NotificationService().init();
    debugPrint('✅ Servicio de notificaciones locales inicializado.');
  } catch (e) {
    debugPrint('⚠️ Error al inicializar notificaciones: $e');
  }

  // 3. Inicialización de RevenueCat SDK
  try {
    final paywallRepo = PaywallRepositoryImpl();
    final apiKey = Platform.isIOS 
        ? 'appl_mWMOfbVYrPnaAwAqyAfvZWipwZD'
        : 'goog_AuxdpuYZxTRkEFUaxmhQqVwOeid';
    await paywallRepo.initRevenueCat(apiKey);
    debugPrint('✅ RevenueCat inicializado para ${Platform.isIOS ? 'iOS' : 'Android'}.');
  } catch (e) {
    debugPrint('⚠️ Error en RevenueCat: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const OzVisaAlertApp(),
    ),
  );
}
