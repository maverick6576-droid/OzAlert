import '../../domain/models/checklist_item.dart';
import '../../domain/models/news_item.dart';

class MockData {
  // Lista inicial de verificación de requisitos Work and Holiday (Subclase 417 y 462)
  static const List<ChecklistItem> initialChecklist = [
    ChecklistItem(
      id: 'immiaccount_setup',
      title: 'Crear y verificar cuenta ImmiAccount',
      description:
          'Registrarse en el portal oficial del Department of Home Affairs (online.immi.gov.au) y configurar la verificación en 2 pasos (2FA).',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'identity_documents',
      title: 'Documentos de identidad y Pasaporte',
      description:
          'Páginas de tu pasaporte a color (mín. 12 meses de validez recomendada), certificado de nacimiento con nombres de ambos padres y foto tamaño pasaporte.',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'government_support',
      title: 'Apoyo del Gobierno (Solo ciertos países)',
      description:
          'Carta de apoyo gubernamental únicamente si tu país lo exige (ej. Perú, Ecuador). NO requerida para España, Argentina, Chile, Uruguay, etc.',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'english_language',
      title: 'Certificado oficial de Nivel de Inglés',
      description:
          'Examen aprobado en los últimos 12 meses (PTE Academic ≥ 30, IELTS ≥ 4.5, Cambridge C1 CAE ≥ 147, o TOEFL iBT ≥ 32) o evidencia de estudios en inglés.',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'education',
      title: 'Título o Expediente de Educación Superior',
      description:
          'Evidencia de tus calificaciones educativas para Subclase 462 (título universitario, grado superior o 2 años universitarios aprobados según tu país).',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'enough_money',
      title: 'Fondos suficientes (\$5.000 AUD + Vuelo)',
      description:
          'Extracto bancario oficial reciente a tu nombre con al menos \$5.000 AUD (~3.100 €) más fondos para un billete de salida de Australia.',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'character_documents',
      title: 'Certificado de Antecedentes Penales',
      description:
          'Certificado policial de cada país donde hayas residido 12+ meses en los últimos 10 años (desde los 16 años) y registro militar si aplica.',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'health_exams',
      title: 'Exámenes médicos y radiografía (Si aplica)',
      description:
          'Comprobar si tu país de residencia o profesión (sanidad/educación) requiere revisión médica con médico autorizado (Panel Physician y HAP ID).',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'prepare_documents',
      title: 'Traducciones oficiales y escaneo a color',
      description:
          'Traducir al inglés todo documento no redactado en inglés (Traductor Jurado / NAATI) y escanear originales y traducciones a color en PDF (<5 MB).',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'getting_help',
      title: 'Formulario 956 / 956A (Solo si usas Agente)',
      description:
          'Incluir únicamente si contratas un agente migratorio registrado (MARA) o autorizas a un tercero a recibir correspondencia en tu nombre.',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'immiaccount_draft',
      title: 'Dejar borrador de solicitud listo en ImmiAccount',
      description:
          'Rellenar y guardar las páginas del formulario Work & Holiday (462 / 417) con antelación para adjuntar documentos y enviar en minutos al abrir cupos.',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'visa_payment_submit',
      title: 'Tarjeta preparada para tasa (\$650 AUD) y Envío',
      description:
          'Asegurar límite de pago online internacional (Wise, Revolut o banco) para abonar los \$650 AUD de tasa oficial en ImmiAccount.',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'switch_to_phase2',
      title: 'Pasar a la Fase 2 de la app (¡Visado Concedido!)',
      description:
          'Cuando recibas tu Visa Grant Notification, activa la Fase 2 de OzAlert para desbloquear el Checklist de Aterrizaje, Guías en Australia, 88 Días, Sueldo y CV.',
      isChecked: false,
    ),
  ];

  // Noticias oficiales, Guías y Alertas de la Comunidad precargadas
  static const List<NewsItem> defaultNews = [
    // Avisos Oficiales
    NewsItem(
      title:
          'Actualización del Department of Home Affairs: Tiempos de procesamiento de visas Subclase 462',
      link:
          'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-processing-times',
      pubDate: '04 AGO 2026',
      description:
          'Inmigración de Australia reporta que el 90% de las visas Work & Holiday solicitadas con documentación biométrica completa se procesan en menos de 14 días laborables.',
      category: 'oficial',
    ),
    NewsItem(
      title:
          'Nuevos requisitos de verificación de fondos bancarios para solicitantes hispanohablantes',
      link:
          'https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/first-visa',
      pubDate: '01 AGO 2026',
      description:
          'Se recuerda que los extractos bancarios adjuntados en ImmiAccount deben incluir el nombre completo del titular e IBAN visible en formato PDF oficial del banco.',
      category: 'oficial',
    ),

    // Guías y Artículos de Interés
    NewsItem(
      title:
          'Guía paso a paso: Cómo abrir tu cuenta bancaria australiana (Commonwealth Bank o NAB) desde tu país',
      link:
          'https://www.commbank.com.au/moving-to-australia/working-holiday.html',
      pubDate: '28 JUL 2026',
      description:
          'Puedes solicitar la apertura de tu cuenta corriente australiana hasta 14 días antes de volar y recoger tu tarjeta de débito al aterrizar en Sídney o Melbourne.',
      category: 'guia',
    ),
    NewsItem(
      title:
          'Cómo solicitar tu TFN (Tax File Number) gratis en los primeros 7 días tras llegar a Australia',
      link: 'https://www.ato.gov.au/individuals-and-families/tax-file-number',
      pubDate: '24 JUL 2026',
      description:
          'El Tax File Number es indispensable para trabajar legalmente en hostelería, construcción o granjas sin sufrir retenciones fiscales máximas.',
      category: 'guia',
    ),
    NewsItem(
      title:
          'Top 5 ciudades y zonas regionales para encontrar trabajo rápidamente en temporada alta',
      link: 'https://www.australia.com/es-cl/work-and-study.html',
      pubDate: '20 JUL 2026',
      description:
          'Queensland y el Norte de Australia ofrecen gran demanda en turismo y hostelería con salarios por encima de \$30 AUD/hora.',
      category: 'guia',
    ),

    // Alertas de la Comunidad / Mercado
    NewsItem(
      title:
          'Alerta de Divisas: El dólar australiano (\$AUD) muestra paridad estable frente al euro en 0,61 €',
      link: 'https://www.rba.gov.au/statistics/frequency/exchange-rates.html',
      pubDate: 'HOY - 11:30',
      description:
          'Buen momento para transferir tus primeros ahorros iniciales mediante Wise o Revolut antes de tu viaje.',
      category: 'comunidad',
    ),
    NewsItem(
      title:
          'Vuelos España/Argentina a Sídney: Aerolíneas con promociones de equipaje extra para estudiantes y WHV',
      link: 'https://www.qantas.com',
      pubDate: 'AYER',
      description:
          'Qantas y Emirates permiten solicitar la tarifa joven con 40 kg de equipaje facturado presentando el grant letter de tu visa 417 o 462.',
      category: 'comunidad',
    ),
  ];
}
