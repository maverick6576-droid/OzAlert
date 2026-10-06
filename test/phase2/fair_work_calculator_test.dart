import 'package:flutter_test/flutter_test.dart';
import 'package:ozvisa_alert/core/services/fair_work_service.dart';

void main() {
  group('FairWorkService Tests', () {
    test('Official 2026 minimum wage and casual loading calculations', () {
      expect(FairWorkService.nationalMinimumWageHourly, 26.44);
      expect(FairWorkService.minimumCasualHourlyRate, closeTo(33.05, 0.01));
    });

    test('Weekday casual shift calculation', () {
      final pay = FairWorkService.calculateShiftPay(
        hours: 10,
        isCasual: true,
        dayType: 'weekday',
      );

      expect(pay['effectiveHourlyRate'], closeTo(33.05, 0.01));
      expect(pay['grossPay'], closeTo(330.50, 0.1));
      expect(pay['superannuationPay'], closeTo(330.50 * 0.12, 0.1));
    });

    test('Sunday casual penalty rate calculation (175%)', () {
      final pay = FairWorkService.calculateShiftPay(
        hours: 8,
        isCasual: true,
        dayType: 'sunday',
      );

      const expectedRate = 26.44 * 1.75;
      expect(pay['effectiveHourlyRate'], closeTo(expectedRate, 0.01));
      expect(pay['grossPay'], closeTo(expectedRate * 8, 0.1));
    });

    test('Audit payslip detects underpayment', () {
      // Trabajó 10 horas casual pero solo le pagaron $200 (en vez de $330.50)
      final audit = FairWorkService.auditPayslip(
        hoursWorked: 10,
        grossPaid: 200.0,
        isCasual: true,
      );

      expect(audit['isUnderpaid'], isTrue);
      expect(audit['differenceAud'], closeTo(130.50, 0.1));
    });

    test('Audit payslip approves legal payment', () {
      // Trabajó 10 horas casual y le pagaron $350.0 (por encima del mínimo de $330.50)
      final audit = FairWorkService.auditPayslip(
        hoursWorked: 10,
        grossPaid: 350.0,
        isCasual: true,
      );

      expect(audit['isUnderpaid'], isFalse);
    });
  });
}
