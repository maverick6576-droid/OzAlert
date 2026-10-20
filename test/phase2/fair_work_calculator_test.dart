import 'package:flutter_test/flutter_test.dart';
import 'package:ozvisa_alert/core/services/fair_work_service.dart';

void main() {
  group('FairWorkService Tests', () {
    test('Official 2026 minimum wage and casual loading calculations', () {
      expect(FairWorkService.nationalMinimumWageHourly, 26.44);
      expect(FairWorkService.minimumCasualHourlyRate, closeTo(33.05, 0.01));
    });

    test('Modern Awards catalog and Horticulture Level 1 vs Level 2 bump', () {
      expect(FairWorkService.officialAwards.length, 7);

      final hortLvl1 = FairWorkService.getAwardById('horticulture_lvl1');
      expect(hortLvl1.code, 'MA000028');
      expect(hortLvl1.casualHourlyRate, 32.18);
      expect(hortLvl1.pieceworkTargetHourlyRate, closeTo(32.18 * 1.15, 0.01)); // +15% target

      final hortLvl2 = FairWorkService.getAwardById('horticulture_lvl2');
      expect(hortLvl2.casualHourlyRate, 33.05); // Subida obligatoria tras 90 días

      final wine = FairWorkService.getAwardById('wine_grade1');
      expect(wine.code, 'MA000090');
      expect(wine.pieceworkTargetHourlyRate, closeTo(32.24 * 1.20, 0.01)); // +20% target
    });

    test('Weekday casual shift calculation with specific award', () {
      final pay = FairWorkService.calculateShiftPay(
        hours: 10,
        isCasual: true,
        dayType: 'weekday',
        awardId: 'construction_traffic',
      );

      // En construcción / tráfico el casual es $38.12/h
      expect(pay['effectiveHourlyRate'], closeTo(38.12, 0.01));
      expect(pay['grossPay'], closeTo(381.20, 0.1));
      expect(pay['superannuationPay'], closeTo(381.20 * 0.12, 0.1));
    });

    test('Tax withholding auditor detects 15%, 30%, 45% and under-withholding', () {
      // 1. Correcto 15% WHM
      final audit15 = FairWorkService.auditTaxWithholding(grossPaid: 1000, taxWithheld: 150);
      expect(audit15['issueType'], 'correct_15');

      // 2. Empleador no registrado cobrando 30% flat (abuso de no-residente ordinario)
      final audit30 = FairWorkService.auditTaxWithholding(grossPaid: 1000, taxWithheld: 300);
      expect(audit30['issueType'], 'unregistered_employer_30');

      // 3. Falta de TFN cobrando 45% / 47%
      final audit45 = FairWorkService.auditTaxWithholding(grossPaid: 1000, taxWithheld: 450);
      expect(audit45['issueType'], 'missing_tfn_45');

      // 4. Retención inferior al 15% (advertencia de susto fiscal al hacer el Tax Return)
      final auditLow = FairWorkService.auditTaxWithholding(grossPaid: 1000, taxWithheld: 50);
      expect(auditLow['issueType'], 'under_withheld');
    });

    test('Payday Super deadline calculation (7 business days)', () {
      final payday = DateTime(2026, 8, 3); // Lunes
      final superResult = FairWorkService.calculatePaydaySuper(
        grossPaid: 1000,
        paymentDate: payday,
      );

      expect(superResult['statutorySuperAud'], 120.0); // 12%
      expect(superResult['businessDaysAllowed'], 7);
      final deadline = superResult['paymentDeadline'] as DateTime;
      // 7 días hábiles desde un lunes saltando el fin de semana = Miércoles 12 de Agosto
      expect(deadline.day, 12);
      expect(deadline.month, 8);
    });

    test('Audit payslip detects underpayment', () {
      final audit = FairWorkService.auditPayslip(
        hoursWorked: 10,
        grossPaid: 200.0,
        isCasual: true,
      );

      expect(audit['isUnderpaid'], isTrue);
      expect(audit['differenceAud'], closeTo(130.50, 0.1));
    });

    test('Audit payslip approves legal payment', () {
      final audit = FairWorkService.auditPayslip(
        hoursWorked: 10,
        grossPaid: 350.0,
        isCasual: true,
      );

      expect(audit['isUnderpaid'], isFalse);
    });
  });
}
