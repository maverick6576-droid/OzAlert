/// Servicio para Asesoramiento Fiscal, Exención de Medicare (MES), Rego de Vehículos y Licencias de Alto Retorno
class HighRoiTicket {
  final String id;
  final String title;
  final String code;
  final double estimatedCostAud;
  final double averageHourlyWageAud;
  final double payoffHours;
  final String description;
  final String descriptionEn;
  final List<String> industries;

  const HighRoiTicket({
    required this.id,
    required this.title,
    required this.code,
    required this.estimatedCostAud,
    required this.averageHourlyWageAud,
    required this.payoffHours,
    required this.description,
    required this.descriptionEn,
    required this.industries,
  });
}

class TaxAndRegoService {
  // ===========================================================================
  // 1. EXENCIÓN DE MEDICARE LEVY (MES) 2.0%
  // ===========================================================================

  /// Países con Acuerdo de Sanidad Recíproca (RHCA) con Australia
  /// Los ciudadanos de estos países SÍ tienen acceso a Medicare, por lo que NO suelen
  /// calificar para la exención del 2% si se inscriben en Medicare.
  static const List<String> rhcaCountries = [
    'United Kingdom',
    'Italy',
    'New Zealand',
    'Netherlands',
    'Sweden',
    'Finland',
    'Norway',
    'Malta',
    'Belgium',
    'Slovenia',
    'Republic of Ireland',
  ];

  /// Países WHM sin acceso a Medicare general (Elegibles al 100% para la exención del 2% MES)
  /// Incluye España (donde solo hay coberturas muy limitadas no aplicables a WHM en general),
  /// Chile, Argentina, Uruguay, Colombia, Perú, Ecuador, México, Francia, Alemania, Canadá, Japón, Corea, etc.
  static bool isEligibleForMedicareLevyExemption(String countryName) {
    final clean = countryName.trim().toLowerCase();
    for (final rhca in rhcaCountries) {
      if (clean.contains(rhca.toLowerCase())) {
        return false;
      }
    }
    return true;
  }

  /// Calcula el ahorro directo en el Tax Return por la exención del 2.0% de Medicare
  static double calculateMedicareLevySaving(double annualTaxableIncome) {
    if (annualTaxableIncome <= 0) return 0.0;
    // La tasa de Medicare Levy en Australia es del 2.0% sobre la base imponible
    return annualTaxableIncome * 0.02;
  }

  // ===========================================================================
  // 2. DOCTRINA ADDY (TRATADOS DE NO DISCRIMINACIÓN TRIBUTARIA)
  // ===========================================================================

  /// Países protegidos por cláusulas de no discriminación fiscal (Sentencia HCA Addy v Commissioner)
  /// Si demuestran ser residentes fiscales australianos por permanencia en un mismo lugar,
  /// pueden acceder al tramo exento de \$18,200 AUD en lugar del 15% desde el dólar 1.
  static const List<String> addyEligibleCountries = [
    'Chile',
    'Germany',
    'Israel',
    'Japan',
    'Norway',
    'Finland',
    'Turkey',
    'United Kingdom',
  ];

  static bool isAddyProtectedCountry(String countryName) {
    final clean = countryName.trim().toLowerCase();
    for (final c in addyEligibleCountries) {
      if (clean.contains(c.toLowerCase())) return true;
    }
    return false;
  }

  /// Calcula la diferencia de impuesto entre el régimen WHM (15% plano hasta \$45,000)
  /// y el régimen de residente fiscal con tramo exento de \$18,200 (Addy)
  static Map<String, double> calculateAddyTaxComparison(double annualIncome) {
    if (annualIncome <= 0) {
      return {'whmTax': 0.0, 'residentTax': 0.0, 'potentialSaving': 0.0};
    }

    // 1. Régimen Estándar WHM (15% hasta $45,000, 30% hasta $135,000)
    double whmTax = 0.0;
    if (annualIncome <= 45000) {
      whmTax = annualIncome * 0.15;
    } else if (annualIncome <= 135000) {
      whmTax = (45000 * 0.15) + ((annualIncome - 45000) * 0.30);
    } else {
      whmTax = (45000 * 0.15) + (90000 * 0.30) + ((annualIncome - 135000) * 0.37);
    }

    // 2. Régimen Residente Ordinario (Tramo exento de $18,200 bajo Stage 3 Tax Cuts 2026)
    // 0 - $18,200: 0%
    // $18,201 - $45,000: 16%
    // $45,001 - $135,000: 30%
    double residentTax = 0.0;
    if (annualIncome <= 18200) {
      residentTax = 0.0;
    } else if (annualIncome <= 45000) {
      residentTax = (annualIncome - 18200) * 0.16;
    } else if (annualIncome <= 135000) {
      residentTax = ((45000 - 18200) * 0.16) + ((annualIncome - 45000) * 0.30);
    } else {
      residentTax = ((45000 - 18200) * 0.16) + (90000 * 0.30) + ((annualIncome - 135000) * 0.37);
    }

    final saving = (whmTax - residentTax) > 0 ? (whmTax - residentTax) : 0.0;

    return {
      'whmTax': whmTax,
      'residentTax': residentTax,
      'potentialSaving': saving,
    };
  }

  // ===========================================================================
  // 3. CÁLCULO DASP (DEVOLUCIÓN DE SUPERANNUATION AL SALIR DEL PAÍS)
  // ===========================================================================

  /// Calcula el importe neto de devolución de Superannuation (DASP)
  /// - WHM (Subclases 417 y 462): Retención del 65% por ley ATO
  /// - Estudiantes (Subclase 500) y otras temporales: Retención del 35%
  static Map<String, double> calculateDaspRefund({
    required double grossSuperAccumulated,
    required bool isWorkingHolidayVisa,
  }) {
    final taxRate = isWorkingHolidayVisa ? 0.65 : 0.35;
    final taxWithheld = grossSuperAccumulated * taxRate;
    final netRefund = grossSuperAccumulated - taxWithheld;

    return {
      'grossSuper': grossSuperAccumulated,
      'taxRatePercentage': taxRate * 100,
      'taxWithheld': taxWithheld,
      'netRefund': netRefund > 0 ? netRefund : 0.0,
    };
  }

  // ===========================================================================
  // 4. GUÍA DE COMPRAVENTA DE VEHÍCULOS Y REGO DE WESTERN AUSTRALIA (WA)
  // ===========================================================================

  /// Características clave de la matrícula de Western Australia (WA Rego) frente a otros estados
  static const Map<String, dynamic> waRegoGuide = {
    'title': 'Ventajas de Western Australia (WA Rego) para Mochileros',
    'titleEn': 'Why WA Rego is the Backpacker Standard across Australia',
    'benefits': [
      'Sin inspección técnica anual obligatoria (No RWC / No Pink Slip en renovaciones ordinarias).',
      'Renovación 100% online o por correo desde cualquier punto de Australia (DoT WA).',
      'Traspaso de titularidad simple sin necesidad de desplazarse a una oficina de tráfico en WA.',
      'Mayor valor de reventa en el mercado de campers y furgonetas entre viajeros.',
    ],
    'benefitsEn': [
      'No annual mandatory roadworthy inspection (No RWC / Pink Slip for standard renewals).',
      '100% online or mail-in renewals from anywhere in Australia via DoT WA portal.',
      'Straightforward transfer of ownership by mail without visiting a local branch in WA.',
      'Significantly higher resale value among backpackers touring remote areas.',
    ],
    'ppsrUrl': 'https://www.ppsr.gov.au/',
    'ppsrCostAud': 2.0,
    'ppsrWarning':
        'Comprueba SIEMPRE el VIN en la web del gobierno ppsr.gov.au (\$2 AUD). Si el vehículo tiene una deuda financiera pendiente, el banco te lo confiscará legalmente aunque lo hayas pagado.',
    'ppsrWarningEn':
        'ALWAYS run a \$2 AUD VIN check on the official government website ppsr.gov.au. If the previous owner has unpaid loans, the finance company can legally seize the car.',
  };

  // ===========================================================================
  // 5. CATÁLOGO DE CURSOS Y LICENCIAS DE ALTO RETORNO (HIGH-ROI TICKETS)
  // ===========================================================================

  static const List<HighRoiTicket> highRoiTickets = [
    HighRoiTicket(
      id: 'white_card',
      title: 'White Card (Construcción)',
      code: 'CPCCWHS1001',
      estimatedCostAud: 55.0,
      averageHourlyWageAud: 38.0,
      payoffHours: 1.5,
      description:
          'Certificación obligatoria de inducción de seguridad. Te permite acceder a obras, tráfico y labores auxiliares donde el sueldo mínimo ronda los \$35-\$45/h.',
      descriptionEn:
          'Mandatory general construction induction. Unlocks access to commercial sites, traffic control, and civil works at \$35-\$45/hr.',
      industries: ['Construcción', 'Obras Civiles', 'Demolición'],
    ),
    HighRoiTicket(
      id: 'traffic_control',
      title: 'Traffic Controller (Blue/Yellow Card)',
      code: 'RIISS00054 / RIISS00055',
      estimatedCostAud: 320.0,
      averageHourlyWageAud: 44.0,
      payoffHours: 7.3,
      description:
          'Uno de los trabajos más solicitados por WHMs. Turnos de día (\$38-\$44/h) y de noche (\$50-\$65/h con recargos). Se amortiza en 1 jornada de trabajo.',
      descriptionEn:
          'One of the most lucrative WHM roles. Day shifts (\$38-\$44/hr) and night penalty shifts (\$50-\$65/hr). Pays off in a single work day.',
      industries: ['Control de Tráfico', 'Infraestructuras', 'Eventos'],
    ),
    HighRoiTicket(
      id: 'forklift_lf',
      title: 'Forklift Licence (Toro / Carretilla LF)',
      code: 'TLILIC0003 (High Risk Work)',
      estimatedCostAud: 390.0,
      averageHourlyWageAud: 36.5,
      payoffHours: 10.7,
      description:
          'Licencia de alto riesgo (LF). Imprescindible para almacenes logísticos, centros de empaquetado de fruta (packing sheds) y distribución.',
      descriptionEn:
          'High Risk Work Licence (LF). Essential for high-paying logistics warehouses, cold storage, and regional fruit packing sheds.',
      industries: ['Logística', 'Packing Sheds', 'Almacenes'],
    ),
    HighRoiTicket(
      id: 'rsa_course',
      title: 'RSA (Responsible Service of Alcohol)',
      code: 'SITHFAB021',
      estimatedCostAud: 45.0,
      averageHourlyWageAud: 33.05,
      payoffHours: 1.4,
      description:
          'Requisito legal para servir alcohol en bares, restaurantes y eventos en Australia. Te permite cobrar tarifas casual con penalizaciones de hasta \$40-\$50/h fines de semana.',
      descriptionEn:
          'Mandatory accreditation to sell or serve alcohol in hospitality venues. Unlocks weekend casual penalty rates up to \$50/hr.',
      industries: ['Hostelería', 'Bares', 'Eventos'],
    ),
  ];
}
