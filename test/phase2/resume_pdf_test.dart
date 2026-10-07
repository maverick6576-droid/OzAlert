import 'package:flutter_test/flutter_test.dart';
import 'package:ozvisa_alert/core/services/pdf_generator_service.dart';
import 'package:ozvisa_alert/domain/models/phase2/resume_data.dart';
import 'package:ozvisa_alert/domain/models/phase2/resume_presets.dart';
import 'package:ozvisa_alert/domain/models/phase2/regional_work_log.dart';

void main() {
  group('PdfGeneratorService Tests', () {
    test('Generate Australian Resume PDF compiles valid bytes', () async {
      const sampleResume = AustralianResumeData(
        fullName: 'Alejandro Morales',
        phone: '+61 412 345 678',
        email: 'alejandro.whv@gmail.com',
        locationSuburb: 'Surry Hills, NSW 2010',
        visaStatus: 'Working Holiday Visa (Subclass 462) - Full Working Rights',
        availability: 'Immediate Start | Flexible 7 Days & Weekends | 6-Month Commitment',
        targetIndustry: 'hospitality',
        jobTitle: 'Experienced Barista & Hospitality All-Rounder',
        summary: 'Enthusiastic and fast-paced hospitality professional with over 3 years experience.',
        skills: ['Specialty Coffee', 'La Marzocco', 'Latte Art', 'Square POS'],
        experiences: [
          WorkExperience(
            role: 'Head Barista',
            company: 'The Daily Grind Café',
            location: 'Sydney, NSW',
            period: '2024 - Present',
            bulletPoints: ['Operated 3-group espresso machine preparing 200+ specialty coffees daily.'],
          ),
        ],
        certifications: ['RSA (Responsible Service of Alcohol)', 'Barista Level 1 & 2'],
        themeColorHex: '#D96B43',
      );

      final pdfBytes = await PdfGeneratorService.generateAustralianResume(sampleResume);
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1500));
    });

    test('All 6 Resume Presets generate valid recruiter-compliant PDFs', () async {
      expect(ResumePresets.presets.length, equals(6));

      for (final preset in ResumePresets.presets) {
        final resumeData = AustralianResumeData(
          fullName: 'Applicant Test',
          phone: '+61 400 000 000',
          email: 'test@email.com',
          locationSuburb: 'Brisbane, QLD 4000',
          visaStatus: 'Working Holiday Visa (Subclass 462) - Full Working Rights',
          availability: 'Immediate Start | Flexible 7 Days & Weekends',
          targetIndustry: preset.id,
          jobTitle: preset.defaultJobTitle,
          summary: preset.summary,
          skills: preset.skills,
          experiences: preset.experiences,
          certifications: preset.certifications,
          themeColorHex: preset.colorHex,
        );

        final pdfBytes = await PdfGeneratorService.generateAustralianResume(resumeData);
        expect(pdfBytes, isNotEmpty);
        expect(pdfBytes.length, greaterThan(2000), reason: 'Failed for preset: ${preset.id}');
      }
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
