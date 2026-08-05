import '../../domain/models/checklist_item.dart';
import '../../domain/models/news_item.dart';

class MockData {
  // Lista inicial de verificación de requisitos Work and Holiday (Subclase 417 y 462)
  static const List<ChecklistItem> initialChecklist = [
    ChecklistItem(
      id: 'identity_documents',
      title: 'Documentos de identidad',
      description:
          'Páginas de tu pasaporte (foto, datos, fechas). Certificado de nacimiento con nombres de padres. Prueba de cambio de nombre (si aplica).',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'education',
      title: 'Educación',
      description:
          'Evidencia de tus calificaciones educativas (título universitario, años cursados o equivalente, dependiendo de las exigencias para tu país).',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'english_language',
      title: 'Nivel de inglés',
      description:
          'Evidencia de estudios en inglés, o examen aprobado en los últimos 12 meses (IELTS 4.5, PTE 30, Cambridge C1 147, o TOEFL iBT 32).',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'government_support',
      title: 'Apoyo del Gobierno',
      description:
          'Carta de apoyo de tu gobierno (solo para ciertos países como Perú, Ecuador, etc. No requerida para España, Argentina, Chile, etc.).',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'enough_money',
      title: 'Fondos suficientes para tu estancia y salida',
      description:
          'Evidencia de dinero para tu estancia (normalmente \$5.000 AUD) y dinero para un billete de salida de Australia (o el billete ya comprado).',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'character_documents',
      title: 'Documentos de carácter (Antecedentes)',
      description:
          'Certificados de policía de cada país donde hayas pasado 12+ meses en los últimos 10 años (desde los 16 años), y registro militar si aplica.',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'getting_help',
      title: 'Notificar si recibes ayuda (Agentes)',
      description:
          'Formulario 956A o 956 si usas un agente migratorio o autorizas a alguien para recibir tus documentos.',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'prepare_documents',
      title: 'Preparar tus documentos',
      description:
          'Traducir al inglés todos los documentos por un traductor cualificado y escanear/fotografiar todos los originales y traducciones a color.',
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
