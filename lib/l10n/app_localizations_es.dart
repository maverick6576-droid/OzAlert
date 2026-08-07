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

  @override
  String get settingsLegal => 'Legal';

  @override
  String get settingsPrivacyPolicy => 'Política de Privacidad';

  @override
  String get settingsTerms => 'Términos y Condiciones';

  @override
  String get checklistTitle => 'Kit de Expedición';

  @override
  String get checklistProgress => 'Progreso del Equipo';

  @override
  String get checklistDescription => 'Prepara tu mochila (certificados y ahorros) con antelación para no quedarte atrás cuando empiece la aventura.';

  @override
  String get checklistKeyDocs => 'Documentos Clave:';

  @override
  String get checklistInstructions => 'Asegura cada ítem en tu inventario conforme lo consigas:';

  @override
  String get checklistTip => 'Consejo Explorador: Los cupos suelen desaparecer como espejismos en el desierto. Tener tus PDFs organizados es vital para sobrevivir al proceso.';

  @override
  String get dashboardSafeExpedition => 'Expedición Segura';

  @override
  String get dashboardSafeExpeditionDesc => 'El horizonte está despejado. Te avisaremos con un destello de bengala (notificación) en cuanto el Departamento habilite plazas para tus pasaportes.';

  @override
  String get newsTitle => 'Radar de Noticias';

  @override
  String get newsTabOfficial => 'Fuentes Oficiales';

  @override
  String get newsTabAlerts => 'Google Alerts';

  @override
  String get newsEmptyState => 'Radar oficial en silencio. No hay noticias.';

  @override
  String get newsGlobalAlerts => 'Alertas globales monitorizadas.';

  @override
  String newsError(String errorText) {
    return 'Interferencia en el Radar.\nNo se pudieron cargar las noticias.\n$errorText';
  }

  @override
  String get radarScanning => 'Servidores rastreando la web oficial de Inmigración de Australia';

  @override
  String get passportSelectorTitle => 'Selecciona tu Pasaporte (WHV 417 & 462)';

  @override
  String passportSubclass(String subclass) {
    return 'Subclase $subclass • Australia WHV';
  }

  @override
  String get paywallModalTitle => 'Desbloquea el Radar 24/7 de Visas Australia';

  @override
  String get paywallModalDesc => 'Recibe una Alerta Push y un Email inmediato en el segundo exacto en que el Departamento de Home Affairs abra plazas para tu país.';

  @override
  String get paywallPlanAnnualTitle => 'Pase de Temporada (Anual)';

  @override
  String get paywallPlanAnnualDesc => 'Mejor valor • Ahorras 37%';

  @override
  String get paywallPlanMonthlyTitle => 'Plan Mensual Flex';

  @override
  String get paywallPlanMonthlyDesc => 'Cancela en cualquier momento con 1 clic';

  @override
  String get paywallActivateAnnual => 'Activar Pase de Temporada (\$14.99)';

  @override
  String get paywallActivateMonthly => 'Activar Plan Mensual (\$1.99)';

  @override
  String get paywallDisclaimer => 'Sin periodo de prueba para garantizar servidores dedicados sin saturación. Pago procesado de forma segura a través de RevenueCat / App Store / Google Play. Puedes cancelar tu suscripción en cualquier momento desde los ajustes de tu cuenta.';

  @override
  String get visaStatusOpenDesc => 'Visas disponibles. ¡Inicia la expedición!';

  @override
  String get visaStatusPausedDesc => 'A la espera. Procesamiento temporalmente detenido.';

  @override
  String get visaStatusClosedDesc => 'Campamento cerrado. 0 plazas actualmente.';

  @override
  String get errorOpeningLink => 'No se pudo abrir el enlace.';

  @override
  String get tooltipScanRadar => 'Escanear radar en vivo';

  @override
  String get newsSourceOfficial => 'FUENTE OFICIAL';

  @override
  String get newsSourceMarket => 'MERCADO / DIVISAS';

  @override
  String get partnerAffiliate => 'SOCIO AFILIADO • 15% DTO';

  @override
  String get partnerDescription => 'Imprescindible para activar tu visa al pasar aduana en Sídney o Melbourne. Cobertura completa COVID, deportes y trabajo.';

  @override
  String get partnerActivate => 'Activar Promoción de Seguro (15% Dto)';

  @override
  String testAlertSending(String countryNames) {
    return '⚡ Enviando alerta de prueba para $countryNames... Llegará en 2 segundos.';
  }

  @override
  String get checklistCompletedDescription => '¡Todo listo! Mochila preparada al 100%.';

  @override
  String get partnerTitle => '¿Necesitas seguro médico para Australia? Obtén 15% de descuento con Chapka / IATI Seguros';

  @override
  String get paywallSuccessMessage => '✅ ¡Acceso VIP Activado! Alertas inmediatas 24/7 habilitadas o compras restauradas exitosamente.';
}
