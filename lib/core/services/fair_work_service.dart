class FairWorkService {
  // Tarifas oficiales Fair Work 2026
  static const double nationalMinimumWageHourly = 26.44;
  static const double casualLoadingRate = 0.25; // 25%
  static const double superannuationRate = 0.12; // 12.0% (Julio 2025/2026)

  /// Salario mínimo legal para trabajadores Casual (Base + 25%)
  static double get minimumCasualHourlyRate {
    return nationalMinimumWageHourly * (1.0 + casualLoadingRate); // $33.05
  }

  /// Calcula el salario esperado por jornada y desglose
  static Map<String, double> calculateShiftPay({
    required double hours,
    required bool isCasual,
    required String dayType, // 'weekday', 'saturday', 'sunday', 'public_holiday'
    double? customBaseRate,
  }) {
    final base = customBaseRate ?? nationalMinimumWageHourly;
    double hourlyMultiplier = 1.0;

    switch (dayType) {
      case 'saturday':
        hourlyMultiplier = isCasual ? 1.50 : 1.25;
        break;
      case 'sunday':
        hourlyMultiplier = isCasual ? 1.75 : 1.50;
        break;
      case 'public_holiday':
        hourlyMultiplier = isCasual ? 2.50 : 2.25;
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
  }) {
    final minRate = isCasual ? minimumCasualHourlyRate : nationalMinimumWageHourly;
    final legalMinGross = hoursWorked * minRate;
    final difference = grossPaid - legalMinGross;
    final isUnderpaid = difference < -0.01;

    return {
      'isUnderpaid': isUnderpaid,
      'differenceAud': difference.abs(),
      'legalMinGross': legalMinGross,
      'actualHourlyRate': hoursWorked > 0 ? (grossPaid / hoursWorked) : 0.0,
      'legalMinRate': minRate,
    };
  }
}
