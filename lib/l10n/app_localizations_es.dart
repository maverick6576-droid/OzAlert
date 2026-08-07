// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get loginTitle => 'OzAlert';

  @override
  String get loginSubtitle => 'El radar definitivo para tu Work & Holiday Visa de Australia.';

  @override
  String get loginError => 'Error al iniciar sesión:';

  @override
  String get loginGoogle => 'Continuar con Google';

  @override
  String get loginApple => 'Continuar con Apple';

  @override
  String get welcomeTitle => 'Las visas de\nAustralia vuelan\nen minutos.';

  @override
  String get welcomeSubtitle => 'Cada año, miles de personas se quedan fuera por no enterarse a tiempo de la apertura de cupos. Nuestro sistema rastrea las fuentes oficiales 24/7 y te avisa al instante para que seas el primero en aplicar.';

  @override
  String get welcomeBullet1 => 'Notificaciones instantáneas reales';

  @override
  String get welcomeBullet2 => 'Gana ventaja sobre otros aplicantes';

  @override
  String get welcomeBullet3 => 'Fuentes oficiales del gobierno (Inmigración)';

  @override
  String get welcomeButton => 'Configurar mi Radar ahora';

  @override
  String get onboardingTitle => 'Personaliza tu Radar';

  @override
  String get onboardingSubtitle => 'Configura tu perfil para recibir notificaciones de las visas que encajen con tu pasaporte.';

  @override
  String get onboardingLanguage => 'Idioma Preferido';

  @override
  String get onboardingPassports => 'Selecciona tus Pasaportes';

  @override
  String get onboardingErrorEmpty => 'Por favor, selecciona al menos un pasaporte';

  @override
  String get onboardingErrorSave => 'Error al guardar:';

  @override
  String get onboardingNext => 'Siguiente paso';

  @override
  String get paywallTitle => 'Enciende el Radar';

  @override
  String get paywallSubtitle => 'Recibe notificaciones inmediatas en cuanto tu visa esté disponible. Suscríbete para acceder.';

  @override
  String paywallSubscribeMonthly(String price) {
    return 'Suscribirse $price / mes';
  }

  @override
  String get paywallSubscribeOnly => 'Suscribirse';

  @override
  String get paywallRestore => 'Restaurar Compras';

  @override
  String get paywallBypass => 'Bypass al Dashboard (Debug)';

  @override
  String get dashboardTitle => 'Radar OzVisa';

  @override
  String get dashboardTestAlert => 'Probar Alerta';

  @override
  String get dashboardSettings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsLanguage => 'Idioma de la aplicación';

  @override
  String get settingsLanguageEnglish => 'Inglés';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get visaStatusOpen => 'ABIERTO';

  @override
  String get visaStatusClosed => 'CERRADO';

  @override
  String get visaStatusPaused => 'PAUSADO';

  @override
  String get visaSourceButton => 'Ver fuente oficial';
}
