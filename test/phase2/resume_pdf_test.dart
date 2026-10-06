import 'package:flutter_test/flutter_test.dart';
import 'package:ozvisa_alert/core/services/pdf_generator_service.dart';
import 'package:ozvisa_alert/domain/models/phase2/resume_data.dart';
import 'package:ozvisa_alert/domain/models/phase2/regional_work_log.dart';

void main() {
  group('PdfGeneratorService Tests', () {
    test('Generate Australian Resume PDF compiles valid bytes', () async {
      const sampleResume = AustralianResumeData(
        fullName: 'Test User',
        phone: '+61 400 111 222',
        email: 'test@gmail.com',
        locationSuburb: 'Cairns, QLD',
        visaStatus: 'Work & Holiday (Subclass 462)',
        availability: 'Immediate Start',
        targetIndustry: 'hospitality',
        summary: 'Reliable team player.',
        skills: ['Coffee', 'Customer Service'],
        experiences: [
          WorkExperience(
            role: 'Barista',
            company: 'Cafe Oz',
            location: 'Cairns, QLD',
            period: '2025 - 2026',
            bulletPoints: ['Made 100 coffees/hour'],
          ),
        ],
        certifications: ['RSA QLD'],
      );

      final pdfBytes = await PdfGeneratorService.generateAustralianResume(sampleResume);
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
    });

    test('Generate Regional Dossier PDF compiles valid bytes', () async {
      final jobs = [
        RegionalJobEntry(
          id: '1',
          employerBusinessName: 'Mango Farm',
          employerAbn: '12345678901',
          workSitePostcode: '4870',
          workSiteLocation: 'Cairns, QLD',
          industry: 'agriculture',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 2, 1),
          totalDaysCounted: 30,
          totalHours: 240,
          grossEarningsAud: 7500,
        ),
      ];

      final dossierBytes = await PdfGeneratorService.generateRegionalDossier(
        applicantName: 'Test Applicant',
        passportNumber: 'ES123456',
        visaSubclass: '462',
        jobs: jobs,
        totalDays: 30,
      );

      expect(dossierBytes, isNotEmpty);
      expect(dossierBytes.length, greaterThan(1000));
    });
  });
}
