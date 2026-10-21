import 'package:flutter_test/flutter_test.dart';
import 'package:ozvisa_alert/core/services/community_telemetry_service.dart';

void main() {
  group('CommunityTelemetryService Tests', () {
    test('singleton instance returns identical instance', () {
      final s1 = CommunityTelemetryService();
      final s2 = CommunityTelemetryService();
      expect(identical(s1, s2), isTrue);
    });

    test('logFarmShift handles offline/uninitialized state without throwing', () async {
      final telemetry = CommunityTelemetryService();
      await expectLater(
        telemetry.logFarmShift(
          abn: '51 824 753 556',
          postcode: '4870',
          industry: 'horticulture',
          hourlyRateAud: 32.50,
          hoursWorked: 38.0,
          grossPayAud: 1235.0,
          isFairWorkCompliant: true,
          hasPiecework: false,
          form1263Signed: true,
          targetVisaYear: 2,
        ),
        completes,
      );
    });

    test('logFarmShift discards empty postcode and abn gracefully', () async {
      final telemetry = CommunityTelemetryService();
      await expectLater(
        telemetry.logFarmShift(
          abn: null,
          postcode: '',
          industry: 'agriculture',
          hourlyRateAud: 0.0,
          hoursWorked: 0.0,
          grossPayAud: 0.0,
          isFairWorkCompliant: true,
        ),
        completes,
      );
    });

    test('logVisaProcessing handles offline/uninitialized state without throwing', () async {
      final telemetry = CommunityTelemetryService();
      await expectLater(
        telemetry.logVisaProcessing(
          countryCode: 'ES',
          subclass: '462',
          visaYear: 2,
          processingDays: 8,
          hadS56: false,
        ),
        completes,
      );
    });

    test('logRentalBond extracts state correctly and completes safely', () async {
      final telemetry = CommunityTelemetryService();
      await expectLater(
        telemetry.logRentalBond(
          stateAuthority: 'NSW Fair Trading (RBO)',
          weeklyRentAud: 350.0,
          bondAmountAud: 1400.0,
          propertyAddress: '12 Bondi Road, Bondi NSW 2026',
        ),
        completes,
      );
    });

    test('logVehicleTransaction handles vehicle sales safely', () async {
      final telemetry = CommunityTelemetryService();
      await expectLater(
        telemetry.logVehicleTransaction(
          makeModel: 'Toyota HiAce',
          year: '2008',
          regoState: 'WA',
          salePriceAud: 8500.0,
          odometerKm: '260,000 km',
        ),
        completes,
      );
    });

    test('logTaxSaving records benchmark without throwing', () async {
      final telemetry = CommunityTelemetryService();
      await expectLater(
        telemetry.logTaxSaving(
          annualIncomeAud: 45000.0,
          mesSavingAud: 900.0,
          accumulatedSuperAud: 5400.0,
          netDaspRefundAud: 1890.0,
          isWhv: true,
        ),
        completes,
      );
    });
  });
}
