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
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsDeleteAccountConfirmTitle => '¿Estás seguro?';

  @override
  String get settingsDeleteAccountConfirmMessage => 'Esta acción es irreversible y eliminará todos tus datos. ¿Quieres continuar?';

  @override
  String get settingsDeleteAccountConfirmButton => 'Eliminar';

  @override
  String get settingsDeleteAccountCancelButton => 'Cancelar';

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
  String get paywallActivateMonthly => 'Continuar con Plan Mensual';

  @override
  String get paywallDisclaimer => 'El pago se cargará a tu cuenta de Apple o Google al confirmar la compra. La suscripción se renueva automáticamente a menos que se cancele al menos 24 horas antes del final del período actual. Puedes gestionar o cancelar tu suscripción en los ajustes de tu cuenta después de la compra.';

  @override
  String get paywallTermsOfUse => 'Términos de Uso';

  @override
  String get paywallPrivacyPolicy => 'Política de Privacidad';

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

  @override
  String get navRadar => 'Radar';

  @override
  String get navEquipment => 'Equipo';

  @override
  String get navNews => 'Bitácora';

  @override
  String get checklistIdentityDocumentsTitle => 'Documentos de identidad';

  @override
  String get checklistIdentityDocumentsDesc => 'Páginas de tu pasaporte (foto, datos, fechas). Certificado de nacimiento con nombres de padres. Prueba de cambio de nombre (si aplica).';

  @override
  String get checklistEducationTitle => 'Educación';

  @override
  String get checklistEducationDesc => 'Evidencia de tus calificaciones educativas (título universitario, años cursados o equivalente, dependiendo de las exigencias para tu país).';

  @override
  String get checklistEnglishLanguageTitle => 'Nivel de inglés';

  @override
  String get checklistEnglishLanguageDesc => 'Evidencia de estudios en inglés, o examen aprobado en los últimos 12 meses (IELTS 4.5, PTE 30, Cambridge C1 147, o TOEFL iBT 32).';

  @override
  String get checklistGovernmentSupportTitle => 'Apoyo del Gobierno';

  @override
  String get checklistGovernmentSupportDesc => 'Carta de apoyo de tu gobierno (solo para ciertos países como Perú, Ecuador, etc. No requerida para España, Argentina, Chile, etc.).';

  @override
  String get checklistEnoughMoneyTitle => 'Fondos suficientes para tu estancia y salida';

  @override
  String get checklistEnoughMoneyDesc => 'Evidencia de dinero para tu estancia (normalmente \$5.000 AUD) y dinero para un billete de salida de Australia (o el billete ya comprado).';

  @override
  String get checklistCharacterDocumentsTitle => 'Documentos de carácter (Antecedentes)';

  @override
  String get checklistCharacterDocumentsDesc => 'Certificados de policía de cada país donde hayas pasado 12+ meses en los últimos 10 años (desde los 16 años), y registro militar si aplica.';

  @override
  String get checklistGettingHelpTitle => 'Notificar si recibes ayuda (Agentes)';

  @override
  String get checklistGettingHelpDesc => 'Formulario 956A o 956 si usas un agente migratorio o autorizas a alguien para recibir tus documentos.';

  @override
  String get checklistPrepareDocumentsTitle => 'Preparar tus documentos';

  @override
  String get checklistPrepareDocumentsDesc => 'Traducir al inglés todos los documentos por un traductor cualificado y escanear/fotografiar todos los originales y traducciones a color.';

  @override
  String radarLastChecked(String seconds) {
    return 'Última comprobación: hace $seconds segundos (Frecuencia: cada 60 seg)';
  }

  @override
  String get newsExplore => 'Explorar';

  @override
  String get newsUpdated => 'ACTUALIZADO';

  @override
  String get countryAR => 'Argentina';

  @override
  String get countryAT => 'Austria';

  @override
  String get countryBR => 'Brasil';

  @override
  String get countryCL => 'Chile';

  @override
  String get countryCN => 'China';

  @override
  String get countryCZ => 'República Checa';

  @override
  String get countryEC => 'Ecuador';

  @override
  String get countryGR => 'Grecia';

  @override
  String get countryHU => 'Hungría';

  @override
  String get countryIN => 'India';

  @override
  String get countryID => 'Indonesia';

  @override
  String get countryIL => 'Israel';

  @override
  String get countryLU => 'Luxemburgo';

  @override
  String get countryMY => 'Malasia';

  @override
  String get countryMN => 'Mongolia';

  @override
  String get countryPG => 'Papúa Nueva Guinea';

  @override
  String get countryPE => 'Perú';

  @override
  String get countryPL => 'Polonia';

  @override
  String get countryPT => 'Portugal';

  @override
  String get countrySM => 'San Marino';

  @override
  String get countrySG => 'Singapur';

  @override
  String get countrySK => 'Eslovaquia';

  @override
  String get countrySI => 'Eslovenia';

  @override
  String get countryES => 'España';

  @override
  String get countryCH => 'Suiza';

  @override
  String get countryTH => 'Tailandia';

  @override
  String get countryTR => 'Turquía';

  @override
  String get countryUY => 'Uruguay';

  @override
  String get countryVN => 'Vietnam';

  @override
  String notificationTestTitle(String countryName) {
    return '🔔 TEST ALERTA: OzVisa Radar Activo ($countryName)';
  }

  @override
  String get notificationTestBody => '✅ Conexión verificada: Servidores monitoreando visas 24/7 en tiempo real.';

  @override
  String notificationTestLongBody(String countryName) {
    return '¡El sistema de rastreo de los servidores de OzVisa Alert está operativo para $countryName! Te notificaremos al segundo en que el Departamento de Home Affairs abra plazas.';
  }

  @override
  String get notificationChannelName => 'OzVisa Alertas de Apertura';

  @override
  String get notificationChannelDesc => 'Notificaciones inmediatas de apertura de plazas de visa Work & Holiday';

  @override
  String get notificationTestTicker => 'OzVisa Alerta Test';
}
