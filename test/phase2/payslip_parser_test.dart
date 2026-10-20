import 'package:flutter_test/flutter_test.dart';
import 'package:ozvisa_alert/core/services/payslip_parser_service.dart';

void main() {
  group('PayslipParserService Tests', () {
    test('Correctly extracts ABN, Gross, Hours, Tax and Super from Xero-style payslip text', () {
      const xeroText = '''
        PAYSLIP FOR ALEJANDRO MORALES
        Employer: Australian Berry Farms Pty Ltd
        ABN: 51 824 753 556
        Pay Period: 01/08/2026 to 07/08/2026
        Payment Date: 08/08/2026

        EARNINGS:
        Ordinary Hours: 38.00 @ \$33.05/hr
        Total Gross: \$1,255.90
        Tax Withheld: \$188.38
        Superannuation: \$150.71
        Net Pay: \$1,067.52
      ''';

      final parsed = PayslipParserService.parse(xeroText, selectedAwardId: 'horticulture_lvl2');

      expect(parsed.hasAbn, isTrue);
      expect(parsed.abn, '51824753556');
      expect(parsed.isAbnChecksumValid, isTrue);
      expect(parsed.grossPay, closeTo(1255.90, 0.01));
      expect(parsed.hoursWorked, 38.0);
      expect(parsed.hourlyRate, closeTo(33.05, 0.01));
      expect(parsed.taxWithheld, closeTo(188.38, 0.01));
      expect(parsed.superannuation, closeTo(150.71, 0.01));
      expect(parsed.netPay, closeTo(1067.52, 0.01));

      // Auditoría Fair Work: no infrasueldo
      expect(parsed.fairWorkAudit, isNotNull);
      expect(parsed.fairWorkAudit!['isUnderpaid'], isFalse);

      // Auditoría Fiscal: retención WHM 15% correcta (~15%)
      expect(parsed.taxAudit, isNotNull);
      expect(parsed.taxAudit!['issueType'], 'correct_15');
    });

    test('Detects underpayment when hourly rate is below Modern Award minimum', () {
      const underpaidText = '''
        PAYSLIP
        ABN: 51 824 753 556
        Total Hours: 40.0
        Gross Pay: \$960.00
        Net Pay: \$960.00
      ''';

      // En Horticultura Nivel 1 Casual, el mínimo es $32.18/h ($1,287.20 para 40h)
      final parsed = PayslipParserService.parse(underpaidText, selectedAwardId: 'horticulture_lvl1');

      expect(parsed.grossPay, 960.0);
      expect(parsed.hoursWorked, 40.0);
      expect(parsed.hourlyRate, 24.0);
      expect(parsed.fairWorkAudit, isNotNull);
      expect(parsed.fairWorkAudit!['isUnderpaid'], isTrue);
      expect(parsed.fairWorkAudit!['underpaidAmount'], closeTo(1287.20 - 960.0, 0.5));
    });

    test('Detects missing TFN 45% withholding or unregistered 30% tax', () {
      const highTaxText = '''
        PAYSLIP
        Gross Pay: \$1,000.00
        PAYG: \$450.00
        Total Hours: 30.0
      ''';

      final parsed = PayslipParserService.parse(highTaxText);
      expect(parsed.taxAudit, isNotNull);
      expect(parsed.taxAudit!['issueType'], 'missing_tfn_45');
    });
  });
}
