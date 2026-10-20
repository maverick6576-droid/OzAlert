/// Modelo para Convenios Colectivos Australianos (Modern Awards 2026)
class ModernAward {
  final String id;
  final String name;
  final String code;
  final double baseHourlyRate;
  final double casualHourlyRate;
  final double pieceworkTargetPercentage; // Ej: 0.15 para +15%
  final String specialRuleNote;

  const ModernAward({
    required this.id,
    required this.name,
    required this.code,
    required this.baseHourlyRate,
    required this.casualHourlyRate,
    this.pieceworkTargetPercentage = 0.15,
    required this.specialRuleNote,
  });

  /// Tarifa horaria objetivo mínima que debe permitir ganar el trabajo a destajo (Piece Rate)
  double get pieceworkTargetHourlyRate =>
      casualHourlyRate * (1.0 + pieceworkTargetPercentage);
}

class FairWorkService {
  // Tarifas Oficiales Fair Work vigentes desde el 1 de Julio de 2026
  static const double nationalMinimumWageHourly = 26.44;
  static const double casualLoadingRate = 0.25; // 25%
  static const double superannuationRate = 0.12; // 12.0% (Payday Super)

  /// Catálogo de Convenios Colectivos Modern Awards 2026 para WHM
  static const List<ModernAward> officialAwards = [
    ModernAward(
      id: 'horticulture_lvl1',
      name: '🌾 Horticultura Nivel 1 (Primeros 3 meses)',
      code: 'MA000028',
      baseHourlyRate: 25.74,
      casualHourlyRate: 32.18,
      pieceworkTargetPercentage: 0.15,
      specialRuleNote:
          'Suelo mínimo obligatorio de \$32.18/h incluso a destajo. Tarifa objetivo: \$37.01/h.',
    ),
    ModernAward(
      id: 'horticulture_lvl2',
      name: '🍇 Horticultura Nivel 2 (>3 meses acumulados)',
      code: 'MA000028',
      baseHourlyRate: 26.44,
      casualHourlyRate: 33.05,
      pieceworkTargetPercentage: 0.15,
      specialRuleNote:
          'Obligatorio tras 90 días acumulados en agricultura (incluso en distintas granjas).',
    ),
    ModernAward(
      id: 'wine_grade1',
      name: '🍷 Industria del Vino / Vendimia Grado 1',
      code: 'MA000090',
      baseHourlyRate: 25.79,
      casualHourlyRate: 32.24,
      pieceworkTargetPercentage: 0.20,
      specialRuleNote:
          'En destajo el precio por kilo debe permitir ganar al menos un +20% (\$38.69/h).',
    ),
    ModernAward(
      id: 'pastoral_lvl1',
      name: '🐄 Ganadería y Estaciones Rurales (Pastoral)',
      code: 'MA000035',
      baseHourlyRate: 25.74,
      casualHourlyRate: 32.18,
      specialRuleNote:
          'Límites estrictos a deducciones por comida y cama en estaciones remotas.',
    ),
    ModernAward(
      id: 'hospitality',
      name: '☕ Hostelería, Cafés y Restaurantes',
      code: 'MA000009',
      baseHourlyRate: 26.44,
      casualHourlyRate: 33.05,
      specialRuleNote:
          'Exención automática del límite de 6 meses por empleador en toda Australia.',
    ),
    ModernAward(
      id: 'retail_clerks',
      name: '🛍️ Comercio Minorista y Oficinas (Retail)',
      code: 'MA000004',
      baseHourlyRate: 27.81,
      casualHourlyRate: 34.76,
      specialRuleNote:
          'Recargo obligatorio para tardes, sábados (150%) y domingos (175%).',
    ),
    ModernAward(
      id: 'construction_traffic',
      name: '🚧 Obras Civiles y Control de Tráfico',
      code: 'MA000020',
      baseHourlyRate: 30.50,
      casualHourlyRate: 38.12,
      specialRuleNote:
          'Requiere White Card / Traffic Controller Ticket. Turnos nocturnos hasta \$55-\$70/h.',
    ),
  ];

  static ModernAward getAwardById(String id) {
    return officialAwards.firstWhere(
      (a) => a.id == id,
      orElse: () => officialAwards.first,
    );
  }

  /// Salario mínimo legal para trabajadores Casual (Base + 25%)
  static double get minimumCasualHourlyRate {
    return nationalMinimumWageHourly * (1.0 + casualLoadingRate); // $33.05
  }

  /// Calcula el salario esperado por jornada y desglose
  static Map<String, double> calculateShiftPay({
    required double hours,
    required bool isCasual,
    required String dayType, // 'weekday', 'saturday', 'sunday', 'public_holiday', 'evening'
    String? awardId,
    double? customBaseRate,
  }) {
    final award = awardId != null ? getAwardById(awardId) : null;
    final base = customBaseRate ?? (award?.baseHourlyRate ?? nationalMinimumWageHourly);
    double hourlyMultiplier = 1.0;

    switch (dayType) {
      case 'evening':
        hourlyMultiplier = isCasual ? 1.40 : 1.15;
        break;
      case 'saturday':
        hourlyMultiplier = isCasual ? 1.50 : 1.25;
        break;
      case 'sunday':
        hourlyMultiplier = isCasual ? 1.75 : 1.50;
        break;
      case 'public_holiday':
        hourlyMultiplier = isCasual ? 2.25 : 2.00;
        break;
      case 'weekday':
      default:
        hourlyMultiplier = isCasual ? (1.0 + casualLoadingRate) : 1.0;
        break;
    }

    final effectiveHourlyRate = base * hourlyMultiplier;
    final grossPay = effectiveHourlyRate * hours;
    final superannuationPay = grossPay * superannuationRate;

    return {
      'effectiveHourlyRate': effectiveHourlyRate,
      'grossPay': grossPay,
      'superannuationPay': superannuationPay,
      'totalWithSuper': grossPay + superannuationPay,
    };
  }

  /// Auditor de nómina: detecta si el pago recibido está por debajo de la ley
  static Map<String, dynamic> auditPayslip({
    required double hoursWorked,
    required double grossPaid,
    required bool isCasual,
    String? awardId,
    bool isPiecework = false,
  }) {
    final award = awardId != null ? getAwardById(awardId) : null;
    final double minRate;

    if (award != null) {
      minRate = isCasual ? award.casualHourlyRate : award.baseHourlyRate;
    } else {
      minRate = isCasual ? minimumCasualHourlyRate : nationalMinimumWageHourly;
    }

    final legalMinGross = hoursWorked * minRate;
    final difference = grossPaid - legalMinGross;
    final isUnderpaid = difference < -0.01;
    final actualHourly = hoursWorked > 0 ? (grossPaid / hoursWorked) : 0.0;

    // Auditoría de Destajo (Piecework)
    final pieceworkTargetRate = award?.pieceworkTargetHourlyRate ?? (minRate * 1.15);
    final meetsPieceworkTarget = actualHourly >= pieceworkTargetRate;

    return {
      'isUnderpaid': isUnderpaid,
      'differenceAud': difference.abs(),
      'underpaidAmount': difference.abs(),
      'legalMinGross': legalMinGross,
      'actualHourlyRate': actualHourly,
      'legalMinRate': minRate,
      'isPiecework': isPiecework,
      'pieceworkTargetRate': pieceworkTargetRate,
      'meetsPieceworkTarget': meetsPieceworkTarget,
    };
  }

  /// Audita la retención de impuestos (PAYG Withholding) para visados 417/462
  /// Tasa legal WHM: 15% sobre los primeros $45,000 AUD
  static Map<String, dynamic> auditTaxWithholding({
    required double grossPaid,
    required double taxWithheld,
  }) {
    if (grossPaid <= 0) {
      return {
        'isIrregular': false,
        'taxRatePercent': 0.0,
        'status': 'OK',
        'issueType': 'correct_15',
        'warning': null,
        'warningMessage': null,
      };
    }

    final taxRatePercent = (taxWithheld / grossPaid) * 100;

    if (taxRatePercent > 40.0) {
      return {
        'isIrregular': true,
        'taxRatePercent': taxRatePercent,
        'status': 'MISSING_TFN',
        'issueType': 'missing_tfn_45',
        'warning': '⚠️ Retención excesiva (${taxRatePercent.toStringAsFixed(1)}%): Falta de TFN (45%-47%).',
        'warningMessage':
            '⚠️ Retención excesiva (${taxRatePercent.toStringAsFixed(1)}%): Tu empleador está aplicando la tasa de penalización del 45% o 47% por falta de Tax File Number (TFN). Entrega tu TFN antes de 28 días.',
      };
    } else if (taxRatePercent > 25.0) {
      return {
        'isIrregular': true,
        'taxRatePercent': taxRatePercent,
        'status': 'UNREGISTERED_EMPLOYER',
        'issueType': 'unregistered_employer_30',
        'warning': '⚠️ Retención del 30%: Empleador no registrado en ATO.',
        'warningMessage':
            '⚠️ Retención irregular (${taxRatePercent.toStringAsFixed(1)}%): Te están reteniendo el 30% como no residente ordinario. Tu empleador debe registrarse en la ATO como empleador WHM para aplicar el 15% legal.',
      };
    } else if (taxRatePercent < 13.0) {
      return {
        'isIrregular': true,
        'taxRatePercent': taxRatePercent,
        'status': 'UNDER_WITHHELD',
        'issueType': 'under_withheld',
        'warning': '⚠️ Retención inferior al 15% legal de WHM.',
        'warningMessage': '⚠️ Retención inferior al 15%: Puede que te toque pagar la diferencia a la ATO.',
      };
    } else {
      return {
        'isIrregular': false,
        'taxRatePercent': taxRatePercent,
        'status': 'OK',
        'issueType': 'correct_15',
        'warning': null,
        'warningMessage': null,
      };
    }
  }

  /// Calcula el pago de Payday Super (12%) y la fecha límite legal de ingreso (7 días hábiles)
  static Map<String, dynamic> calculatePaydaySuper({
    required double grossPaid,
    required DateTime paymentDate,
  }) {
    final superAmount = grossPaid * superannuationRate;

    // Sumar 7 días hábiles (omitiendo sábados y domingos)
    DateTime deadline = paymentDate;
    int businessDaysAdded = 0;
    while (businessDaysAdded < 7) {
      deadline = deadline.add(const Duration(days: 1));
      if (deadline.weekday != DateTime.saturday && deadline.weekday != DateTime.sunday) {
        businessDaysAdded++;
      }
    }

    return {
      'superAmountAud': superAmount,
      'statutorySuperAud': superAmount,
      'businessDaysAllowed': 7,
      'deadlineDate': deadline,
      'paymentDeadline': deadline,
      'daysRemaining': deadline.difference(DateTime.now()).inDays,
    };
  }
}
