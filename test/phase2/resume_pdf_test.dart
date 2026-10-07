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

    test('Generate Regional Dossier PDF compiles valid bytes for 2nd and 3rd year', () async {
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

      // 2nd Year (88 Days)
      final dossier2ndYear = await PdfGeneratorService.generateRegionalDossier(
        applicantName: 'Test Applicant',
        passportNumber: 'ES123456',
        visaSubclass: '462',
        jobs: jobs,
        totalDays: 30,
        targetYear: 2,
      );
      expect(dossier2ndYear, isNotEmpty);
      expect(dossier2ndYear.length, greaterThan(1000));

      // 3rd Year (179 Days)
      final dossier3rdYear = await PdfGeneratorService.generateRegionalDossier(
        applicantName: 'Test Applicant',
        passportNumber: 'ES123456',
        visaSubclass: '462',
        jobs: jobs,
        totalDays: 120,
        targetYear: 3,
      );
      expect(dossier3rdYear, isNotEmpty);
      expect(dossier3rdYear.length, greaterThan(1000));
    });

    test('Generate Australian Cover Letter PDF compiles valid bytes', () async {
      final pdfBytes = await PdfGeneratorService.generateCoverLetter(
        applicantName: 'Alejandro Morales',
        phone: '+61 412 345 678',
        email: 'alejandro.whv@gmail.com',
        locationSuburb: 'Surry Hills, NSW 2010',
        targetRole: 'Head Barista & Café All-Rounder',
        companyName: 'Merivale Hospitality Group',
        visaStatus: 'Working Holiday Visa (Subclass 462) - Full Working Rights',
        coverLetterBody: 'I am writing to express my strong interest in the role. With over 3 years of hands-on experience in high-volume customer service and specialty coffee, I thrive in fast-paced environments while maintaining exceptional hospitality standards.\n\nI hold an active Working Holiday Visa with full working rights and a 6-month work commitment. I am available for immediate start across all shift rotations, including weekends and public holidays.',
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1500));
    });

    test('Generate Rental & Housemate Bio PDF compiles valid bytes', () async {
      final pdfBytes = await PdfGeneratorService.generateRentalBio(
        fullName: 'Alejandro Morales',
        phone: '+61 412 345 678',
        email: 'alejandro.whv@gmail.com',
        currentCity: 'Sydney Inner West / Eastern Suburbs',
        budgetAud: '350',
        moveInDate: 'Immediate',
        visaStatus: 'Working Holiday Visa (Subclass 462) - Full Working Rights',
        employmentStatus: 'Employed Full-Time Casual (Payslips Available)',
        aboutMe: 'Hi everyone! I am a 26-year-old professional on a Working Holiday Visa. I am clean, respectful, non-smoker, and very considerate of shared living spaces. I love coastal walks and keeping a quiet, peaceful home environment.',
        houseHabits: ['Non-smoker', 'Quiet after 10 PM', 'Clean & tidy common areas', 'Always pay rent on time'],
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1500));
    });

    test('Generate Fair Work Wage Claim Notice PDF compiles valid bytes', () async {
      final pdfBytes = await PdfGeneratorService.generateFairWorkClaimLetter(
        employeeName: 'Alejandro Morales',
        employeePhone: '+61 412 345 678',
        employeeEmail: 'alejandro.whv@gmail.com',
        employerName: 'Sunny Coast Hospitality Pty Ltd',
        employerAbn: '45 123 456 789',
        employmentPeriod: '12/01/2026 - 28/02/2026',
        totalOwedAud: 1420.50,
        underpaymentDetails: 'Audit of timesheets and payslips indicates non-compliance with the Hospitality Industry (General) Award 2020. The statutory minimum casual base rate of \$30.91/hr was paid at \$24.00/hr cash-in-hand, omitting 25% casual loading, weekend penalty rates, and statutory 12% superannuation contributions.',
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1500));
    });

    test('Generate Two-Week Notice Resignation Letter PDF compiles valid bytes', () async {
      final pdfBytes = await PdfGeneratorService.generateResignationLetter(
        employeeName: 'Alejandro Morales',
        employerName: 'The Grounds of Alexandria',
        role: 'Barista / All-Rounder',
        lastWorkingDay: DateTime.now().add(const Duration(days: 14)),
        gratitudeMessage: 'I would like to sincerely thank you for the wonderful opportunity to work with the team. I have thoroughly enjoyed my time here and greatly appreciate the support and experience gained during my tenure.',
      );

      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1500));
    });
  });
}
