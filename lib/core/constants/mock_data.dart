import '../../domain/models/checklist_item.dart';
import '../../domain/models/news_item.dart';

class MockData {
  // Lista inicial de verificación de requisitos Work and Holiday (Subclase 417 y 462)
  static const List<ChecklistItem> initialChecklist = [
    ChecklistItem(
      id: 'passport_validity',
      title: 'Pasaporte con más de 6 meses de validez',
      description:
          'Tu pasaporte biométrico debe tener vigencia superior a 6 meses desde tu fecha prevista de entrada a Australia.',
      isChecked: true,
    ),
    ChecklistItem(
      id: 'english_test',
      title: 'Examen de inglés aprobado (IELTS / PTE)',
      description:
          'Certificado con nota media mínima de 4.5 en IELTS General o 30 en PTE Academic, con máximo 12 meses de antigüedad.',
      isChecked: true,
    ),
    ChecklistItem(
      id: 'proof_of_funds',
      title: 'Fondos bancarios acreditados (\$5.000 AUD)',
      description:
          'Extracto bancario reciente en euros o dólares equivalente a 5.000 AUD más billete de salida (aprox. 3.200€ total).',
      isChecked: false,
    ),
    ChecklistItem(
      id: 'university_degree',
      title: 'Título universitario / Certificado de estudios',
      description:
          'Para Subclase 462: mínimo 2 años completos de estudios universitarios o título superior finalizado.',
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
