import 'package:flutter_test/flutter_test.dart';
import 'package:ozvisa_alert/core/services/tax_and_rego_service.dart';

void main() {
  group('TaxAndRegoService Tests', () {
    test('Medicare Levy Exemption 2% eligibility and calculations', () {
      // España, Chile, Argentina, Francia son elegibles al 100% (sin RHCA completo)
      expect(TaxAndRegoService.isEligibleForMedicareLevyExemption('Spain'), isTrue);
      expect(TaxAndRegoService.isEligibleForMedicareLevyExemption('Chile'), isTrue);
      expect(TaxAndRegoService.isEligibleForMedicareLevyExemption('Argentina'), isTrue);

      // Reino Unido e Italia tienen RHCA recíproco
      expect(TaxAndRegoService.isEligibleForMedicareLevyExemption('United Kingdom'), isFalse);
      expect(TaxAndRegoService.isEligibleForMedicareLevyExemption('Italy'), isFalse);

      // Ahorro exacto del 2% sobre $45,000 AUD de ingresos = $900 AUD
      final saving = TaxAndRegoService.calculateMedicareLevySaving(45000);
      expect(saving, 900.0);
    });

    test('Addy Doctrine calculation and country detection', () {
      expect(TaxAndRegoService.isAddyProtectedCountry('Chile'), isTrue);
      expect(TaxAndRegoService.isAddyProtectedCountry('Germany'), isTrue);
      expect(TaxAndRegoService.isAddyProtectedCountry('Spain'), isFalse);

      // Con $30,000 AUD de ingresos anuales:
      // WHM standard (15%): $4,500 AUD
      // Residente bajo Addy ($18,200 exentos + 16% del resto): ($30,000 - $18,200) * 0.16 = $1,888 AUD
      // Ahorro potencial: $4,500 - $1,888 = $2,612 AUD
      final comp = TaxAndRegoService.calculateAddyTaxComparison(30000);
      expect(comp['whmTax'], 4500.0);
      expect(comp['residentTax'], closeTo(1888.0, 0.1));
      expect(comp['potentialSaving'], closeTo(2612.0, 0.1));
    });

    test('DASP Superannuation refund calculation', () {
      // Para WHM (417/462), la retención ATO es del 65%
      final whmDasp = TaxAndRegoService.calculateDaspRefund(
        grossSuperAccumulated: 10000,
        isWorkingHolidayVisa: true,
      );
      expect(whmDasp['taxRatePercentage'], 65.0);
      expect(whmDasp['taxWithheld'], 6500.0);
      expect(whmDasp['netRefund'], 3500.0);

      // Para Estudiantes (500), la retención es del 35%
      final studentDasp = TaxAndRegoService.calculateDaspRefund(
        grossSuperAccumulated: 10000,
        isWorkingHolidayVisa: false,
      );
      expect(studentDasp['taxRatePercentage'], 35.0);
      expect(studentDasp['taxWithheld'], 3500.0);
      expect(studentDasp['netRefund'], 6500.0);
    });

    test('High-ROI Tickets catalog validation', () {
      expect(TaxAndRegoService.highRoiTickets.isNotEmpty, isTrue);
      final whiteCard = TaxAndRegoService.highRoiTickets.firstWhere((t) => t.id == 'white_card');
      expect(whiteCard.payoffHours, lessThan(3.0)); // Amortización en menos de 3 horas de trabajo
    });
  });
}
