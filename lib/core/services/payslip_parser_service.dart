import 'abr_service.dart';
import 'fair_work_service.dart';

class ParsedPayslip {
  final String rawText;
  final String? employerName;
  final String? abn;
  final double? grossPay;
  final double? netPay;
  final double? hoursWorked;
  final double? hourlyRate;
  final double? taxWithheld;
  final double? superannuation;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  // Auditoría automática
  final bool hasAbn;
  final bool isAbnChecksumValid;
  final Map<String, dynamic>? fairWorkAudit;
  final Map<String, dynamic>? taxAudit;
  final Map<String, dynamic>? paydaySuper;

  const ParsedPayslip({
    required this.rawText,
    this.employerName,
    this.abn,
    this.grossPay,
    this.netPay,
    this.hoursWorked,
    this.hourlyRate,
    this.taxWithheld,
    this.superannuation,
    this.periodStart,
    this.periodEnd,
    required this.hasAbn,
    required this.isAbnChecksumValid,
    this.fairWorkAudit,
    this.taxAudit,
    this.paydaySuper,
  });

  bool get isValid => (grossPay != null && grossPay! > 0) || hasAbn;
}

class PayslipParserService {
  /// Analiza el texto de una nómina australiana digital (Xero, MYOB, KeyPay, etc.)
  static ParsedPayslip parse(String rawText, {String? selectedAwardId, bool isCasual = true}) {
    if (rawText.trim().isEmpty) {
      return ParsedPayslip(
        rawText: rawText,
        hasAbn: false,
        isAbnChecksumValid: false,
      );
    }

    final cleanText = rawText.replaceAll(r'$', ' ');

    // 1. Extracción de ABN (11 dígitos, con o sin espacios)
    String? extractedAbn;
    final abnMatch = RegExp(r'\b(?:ABN|A\.B\.N\.?|A\.B\.N|Business\s*No\.?)[\s:]*([0-9\s]{11,16})\b', caseSensitive: false)
        .firstMatch(cleanText);

    if (abnMatch != null) {
      final candidate = AbrService.cleanAbn(abnMatch.group(1) ?? '');
      if (candidate.length == 11) {
        extractedAbn = candidate;
      }
    }

    // Búsqueda alternativa de ABN por patrón de 11 dígitos si no tenía prefijo explícito
    if (extractedAbn == null) {
      final raw11Matches = RegExp(r'\b(\d{2}\s?\d{3}\s?\d{3}\s?\d{3})\b').allMatches(cleanText);
      for (final m in raw11Matches) {
        final candidate = AbrService.cleanAbn(m.group(0) ?? '');
        if (candidate.length == 11 && AbrService.isValidAbnChecksum(candidate)) {
          extractedAbn = candidate;
          break;
        }
      }
    }

    final isChecksumValid = extractedAbn != null && AbrService.isValidAbnChecksum(extractedAbn);

    // 2. Extracción de Salario Bruto (Gross Pay / Total Earnings / Gross)
    double? gross;
    final grossMatch = RegExp(
      r'(?:Total\s*Gross|Gross\s*Pay|Gross\s*Earnings|Gross\s*Taxable|Gross)[\s:]*([0-9,]+\.[0-9]{2})',
      caseSensitive: false,
    ).firstMatch(cleanText);

    if (grossMatch != null) {
      gross = double.tryParse(grossMatch.group(1)!.replaceAll(',', ''));
    }

    // 3. Extracción de Horas Trabajadas (Total Hours / Hours Worked)
    double? hours;
    final hoursMatch = RegExp(
      r'(?:Total\s*Hours|Hours\s*Worked|Ordinary\s*Hours|Total\s*Units)[\s:]*([0-9,]+(?:\.[0-9]{1,2})?)',
      caseSensitive: false,
    ).firstMatch(cleanText);

    if (hoursMatch != null) {
      hours = double.tryParse(hoursMatch.group(1)!.replaceAll(',', ''));
    }

    // 4. Extracción de Tarifa por Hora (Rate / Hourly Rate)
    double? rate;
    final rateMatch = RegExp(
      r'(?:Rate|Hourly\s*Rate|Pay\s*Rate)[\s:]*([0-9,]+\.[0-9]{2})',
      caseSensitive: false,
    ).firstMatch(cleanText);

    if (rateMatch != null) {
      rate = double.tryParse(rateMatch.group(1)!.replaceAll(',', ''));
    } else if (gross != null && hours != null && hours > 0) {
      rate = double.parse((gross / hours).toStringAsFixed(2));
    }

    // 5. Extracción de Impuesto Retenido (PAYG / Tax Withheld / Withholding)
    double? tax;
    final taxMatch = RegExp(
      r'(?:PAYG|Tax\s*Withheld|Tax|PAYGW)[\s:]*([0-9,]+\.[0-9]{2})',
      caseSensitive: false,
    ).firstMatch(cleanText);

    if (taxMatch != null) {
      tax = double.tryParse(taxMatch.group(1)!.replaceAll(',', ''));
    }

    // 6. Extracción de Superannuation (12% Super / Superannuation Guarantee)
    double? superAmount;
    final superMatch = RegExp(
      r'(?:Superannuation|Super\s*Guarantee|Super)[\s:]*([0-9,]+\.[0-9]{2})',
      caseSensitive: false,
    ).firstMatch(cleanText);

    if (superMatch != null) {
      superAmount = double.tryParse(superMatch.group(1)!.replaceAll(',', ''));
    }

    // 7. Extracción de Salario Neto (Net Pay)
    double? net;
    final netMatch = RegExp(
      r'(?:Net\s*Pay|Net\s*Earnings|Total\s*Net)[\s:]*([0-9,]+\.[0-9]{2})',
      caseSensitive: false,
    ).firstMatch(cleanText);

    if (netMatch != null) {
      net = double.tryParse(netMatch.group(1)!.replaceAll(',', ''));
    }

    // 8. Auditoría Fair Work en Tiempo Real si tenemos horas y bruto
    Map<String, dynamic>? fwAudit;
    if (hours != null && gross != null && hours > 0) {
      fwAudit = FairWorkService.auditPayslip(
        hoursWorked: hours,
        grossPaid: gross,
        isCasual: isCasual,
        awardId: selectedAwardId,
      );
    }

    // 9. Auditoría de Retención de Impuestos WHM
    Map<String, dynamic>? taxAudit;
    if (gross != null && tax != null && gross > 0) {
      taxAudit = FairWorkService.auditTaxWithholding(
        grossPaid: gross,
        taxWithheld: tax,
      );
    }

    // 10. Vigilante de Payday Super (12% a 7 días hábiles)
    Map<String, dynamic>? paydaySuper;
    if (gross != null && gross > 0) {
      paydaySuper = FairWorkService.calculatePaydaySuper(
        grossPaid: gross,
        paymentDate: DateTime.now(),
      );
    }

    return ParsedPayslip(
      rawText: rawText,
      abn: extractedAbn,
      grossPay: gross,
      netPay: net,
      hoursWorked: hours,
      hourlyRate: rate,
      taxWithheld: tax,
      superannuation: superAmount,
      hasAbn: extractedAbn != null,
      isAbnChecksumValid: isChecksumValid,
      fairWorkAudit: fwAudit,
      taxAudit: taxAudit,
      paydaySuper: paydaySuper,
    );
  }
}
