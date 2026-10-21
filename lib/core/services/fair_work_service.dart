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

  String getLocalizedName(String? lang) {
    switch (lang?.toLowerCase()) {
      case 'en':
        switch (id) {
          case 'horticulture_lvl1':
            return '🌾 Horticulture Level 1 (First 3 months)';
          case 'horticulture_lvl2':
            return '🍇 Horticulture Level 2 (>3 cumulative months)';
          case 'wine_grade1':
            return '🍷 Wine Industry / Vintage Grade 1';
          case 'pastoral_lvl1':
            return '🐄 Pastoral & Livestock Stations Level 1';
          case 'hospitality':
            return '☕ Hospitality, Cafes & Restaurants';
          case 'retail_clerks':
            return '🛍️ General Retail & Clerical';
          case 'construction_traffic':
            return '🚧 Civil Construction & Traffic Control';
          default:
            return name;
        }
      case 'fr':
        switch (id) {
          case 'horticulture_lvl1':
            return '🌾 Horticulture Niveau 1 (Premiers 3 mois)';
          case 'horticulture_lvl2':
            return '🍇 Horticulture Niveau 2 (>3 mois cumulés)';
          case 'wine_grade1':
            return '🍷 Industrie Vinicole / Vendanges Grade 1';
          case 'pastoral_lvl1':
            return '🐄 Élevage & Stations Pastorales Niveau 1';
          case 'hospitality':
            return '☕ Hôtellerie, Cafés & Restaurants';
          case 'retail_clerks':
            return '🛍️ Commerce de Détail & Bureaux';
          case 'construction_traffic':
            return '🚧 Génie Civil & Contrôle de Circulation';
          default:
            return name;
        }
      case 'it':
        switch (id) {
          case 'horticulture_lvl1':
            return '🌾 Orticoltura Livello 1 (Primi 3 mesi)';
          case 'horticulture_lvl2':
            return '🍇 Orticoltura Livello 2 (>3 mesi accumulati)';
          case 'wine_grade1':
            return '🍷 Industria del Vino / Vendemmia Grado 1';
          case 'pastoral_lvl1':
            return '🐄 Allevamento & Stazioni Pastorali Livello 1';
          case 'hospitality':
            return '☕ Ristorazione, Caffè & Ristoranti';
          case 'retail_clerks':
            return '🛍️ Vendita al Dettaglio & Uffici';
          case 'construction_traffic':
            return '🚧 Ingegneria Civile & Controllo Traffico';
          default:
            return name;
        }
      case 'zh':
        switch (id) {
          case 'horticulture_lvl1':
            return '🌾 园艺1级（前3个月）';
          case 'horticulture_lvl2':
            return '🍇 园艺2级（累计超过3个月）';
          case 'wine_grade1':
            return '🍷 葡萄酒产业 / 采收1级';
          case 'pastoral_lvl1':
            return '🐄 牧业与畜牧工作站1级';
          case 'hospitality':
            return '☕ 餐饮、咖啡馆与餐厅';
          case 'retail_clerks':
            return '🛍️ 零售商业与办公文员';
          case 'construction_traffic':
            return '🚧 土木工程与交通管制';
          default:
            return name;
        }
      case 'es':
      default:
        return name;
    }
  }

  String getLocalizedNote(String? lang) {
    switch (lang?.toLowerCase()) {
      case 'en':
        switch (id) {
          case 'horticulture_lvl1':
            return 'Mandatory minimum floor of \$32.18/h even on piecework. Target rate: \$37.01/h.';
          case 'horticulture_lvl2':
            return 'Mandatory after 90 cumulative days in agriculture (even across different farms).';
          case 'wine_grade1':
            return 'On piece rates, per-kilo pricing must yield at least +20% (\$38.69/h).';
          case 'pastoral_lvl1':
            return 'Strict legal caps on food and accommodation deductions on remote stations.';
          case 'hospitality':
            return 'Automatic exemption from the 6-month employer limit nationwide.';
          case 'retail_clerks':
            return 'Mandatory penalty loading for evenings, Saturdays (150%) and Sundays (175%).';
          case 'construction_traffic':
            return 'Requires White Card / Traffic Controller Ticket. Night shifts up to \$55-\$70/h.';
          default:
            return specialRuleNote;
        }
      case 'fr':
        switch (id) {
          case 'horticulture_lvl1':
            return 'Plancher légal obligatoire de 32,18 \$AUD/h même au rendement. Taux cible : 37,01 \$AUD/h.';
          case 'horticulture_lvl2':
            return 'Obligatoire après 90 jours cumulés dans l’agriculture (même sur plusieurs fermes).';
          case 'wine_grade1':
            return 'Au rendement, le prix au kilo doit rapporter au moins +20% (38,69 \$AUD/h).';
          case 'pastoral_lvl1':
            return 'Plafonds légaux stricts sur les déductions pour repas et hébergement en station isolée.';
          case 'hospitality':
            return 'Exemption automatique de la limite de 6 mois par employeur dans toute l’Australie.';
          case 'retail_clerks':
            return 'Majorations obligatoires pour soirées, samedis (150%) et dimanches (175%).';
          case 'construction_traffic':
            return 'Nécessite White Card / Ticket de Contrôleur. Nuits jusqu’à 55–70 \$AUD/h.';
          default:
            return specialRuleNote;
        }
      case 'it':
        switch (id) {
          case 'horticulture_lvl1':
            return 'Minimo legale obbligatorio di 32,18 \$AUD/h anche a cottimo. Tariffa target: 37,01 \$AUD/h.';
          case 'horticulture_lvl2':
            return 'Obbligatorio dopo 90 giorni accumulati in agricoltura (anche in diverse fattorie).';
          case 'wine_grade1':
            return 'A cottimo, il prezzo al chilo deve consentire di guadagnare almeno il +20% (38,69 \$AUD/h).';
          case 'pastoral_lvl1':
            return 'Limiti legali rigorosi sulle detrazioni per vitto e alloggio nelle stazioni remote.';
          case 'hospitality':
            return 'Esenzione automatica dal limite di 6 mesi per datore di lavoro in tutta l’Australia.';
          case 'retail_clerks':
            return 'Maggiorazione obbligatoria per turni serali, sabati (150%) e domeniche (175%).';
          case 'construction_traffic':
            return 'Richiede White Card / Patentino Controllo Traffico. Notti fino a 55–70 \$AUD/h.';
          default:
            return specialRuleNote;
        }
      case 'zh':
        switch (id) {
          case 'horticulture_lvl1':
            return '计件工作法定最低保底薪资为 \$32.18/小时。目标费率：\$37.01/小时。';
          case 'horticulture_lvl2':
            return '在农业领域累计工作满90天后必须执行（即使在不同农场）。';
          case 'wine_grade1':
            return '计件工作每公斤单价必须保证至少高出20%（\$38.69/小时）。';
          case 'pastoral_lvl1':
            return '偏远牧场对餐费和住宿扣款有严格的法定上限。';
          case 'hospitality':
            return '全澳范围内自动豁免为同一雇主工作不超过6个月的限制。';
          case 'retail_clerks':
            return '晚班、周六（150%）及周日（175%）必须支付法定加班补贴。';
          case 'construction_traffic':
            return '需要持有白卡（White Card）或交通管制资格证。夜班费率高达 \$55–\$70/小时。';
          default:
            return specialRuleNote;
        }
      case 'es':
      default:
        return specialRuleNote;
    }
  }
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

  static String getLocalizedTaxWarning(String issueType, double taxRatePercent, String? lang) {
    final rateStr = taxRatePercent.toStringAsFixed(1);
    switch (lang?.toLowerCase()) {
      case 'en':
        switch (issueType) {
          case 'missing_tfn_45':
            return '⚠️ Excessive withholding ($rateStr%): Missing TFN penalty rate (45%-47%).';
          case 'unregistered_employer_30':
            return '⚠️ 30% withholding: Employer is not registered with ATO as a WHM employer.';
          case 'under_withheld':
            return '⚠️ Withholding is below the legal 15% WHM rate.';
          default:
            return '';
        }
      case 'fr':
        switch (issueType) {
          case 'missing_tfn_45':
            return '⚠️ Retenue excessive ($rateStr%) : Pénalité absence de TFN (45%-47%).';
          case 'unregistered_employer_30':
            return '⚠️ Retenue à 30% : Employeur non enregistré auprès de l\'ATO.';
          case 'under_withheld':
            return '⚠️ Retenue inférieure aux 15% légaux WHM.';
          default:
            return '';
        }
      case 'it':
        switch (issueType) {
          case 'missing_tfn_45':
            return '⚠️ Trattenuta eccessiva ($rateStr%): Penalità TFN mancante (45%-47%).';
          case 'unregistered_employer_30':
            return '⚠️ Trattenuta al 30%: Datore di lavoro non registrato all\'ATO.';
          case 'under_withheld':
            return '⚠️ Trattenuta inferiore al 15% legale per WHM.';
          default:
            return '';
        }
      case 'zh':
        switch (issueType) {
          case 'missing_tfn_45':
            return '⚠️ 税款代扣过高 ($rateStr%)：未提供 TFN 税号导致的惩罚性税率 (45%-47%)。';
          case 'unregistered_employer_30':
            return '⚠️ 代扣30%税率：雇主未在 ATO 注册为合法打工度假雇主。';
          case 'under_withheld':
            return '⚠️ 税款代扣低于 WHM 法定15%税率。';
          default:
            return '';
        }
      case 'es':
      default:
        switch (issueType) {
          case 'missing_tfn_45':
            return '⚠️ Retención excesiva ($rateStr%): Falta de TFN (45%-47%).';
          case 'unregistered_employer_30':
            return '⚠️ Retención del 30%: Empleador no registrado en ATO.';
          case 'under_withheld':
            return '⚠️ Retención inferior al 15% legal de WHM.';
          default:
            return '';
        }
    }
  }
}
