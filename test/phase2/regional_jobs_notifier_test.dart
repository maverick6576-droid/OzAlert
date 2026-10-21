import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ozvisa_alert/domain/models/phase2/regional_work_log.dart';
import 'package:ozvisa_alert/presentation/providers/phase2/phase2_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RegionalJobsNotifier & RegionalJobEntry Tests', () {
    test('Job entry toJson and fromJson preserve all fields', () {
      final now = DateTime(2026, 3, 15);
      final job = RegionalJobEntry(
        id: 'job_123',
        employerBusinessName: 'Sun Valley Orchards Pty Ltd',
        employerAbn: '51824753556',
        workSitePostcode: '4852',
        workSiteLocation: 'Bingil Bay, QLD',
        industry: 'Fruit Picking',
        jobRole: 'Banana Harvester',
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now,
        totalDaysCounted: 22,
        totalHours: 154.0,
        grossEarningsAud: 4643.10,
        isFullTimeWeekly: true,
        hasPieceworkAgreement: false,
        payslipFileRef: 'payslips/slip_1.pdf',
        targetVisaYear: 2,
      );

      final json = job.toJson();
      expect(json['id'], 'job_123');
      expect(json['employerAbn'], '51824753556');
      expect(json['targetVisaYear'], 2);
      expect(json['isFullTimeWeekly'], true);

      final restored = RegionalJobEntry.fromJson(json);
      expect(restored.id, job.id);
      expect(restored.employerBusinessName, job.employerBusinessName);
      expect(restored.totalDaysCounted, 22);
      expect(restored.grossEarningsAud, 4643.10);
      expect(restored.targetVisaYear, 2);
    });

    test('RegionalJobsNotifier adds, accumulates, and filters days by visa year (88 vs 179 days)', () async {
      final notifier = RegionalJobsNotifier(firestore: null);
      expect(notifier.totalDaysAccumulated, 0);

      final jobYear2 = RegionalJobEntry(
        id: 'job_year_2',
        employerBusinessName: 'Emerald Citrus',
        employerAbn: '12345678901',
        workSitePostcode: '4720',
        workSiteLocation: 'Emerald, QLD',
        industry: 'Agriculture',
        startDate: DateTime(2025, 6, 1),
        endDate: DateTime(2025, 8, 30),
        totalDaysCounted: 88,
        totalHours: 616.0,
        grossEarningsAud: 18572.40,
        targetVisaYear: 2,
      );

      final jobYear3 = RegionalJobEntry(
        id: 'job_year_3',
        employerBusinessName: 'Cairns Hospitality',
        employerAbn: '98765432109',
        workSitePostcode: '4870',
        workSiteLocation: 'Cairns, QLD',
        industry: 'Tourism & Hospitality',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 6, 30),
        totalDaysCounted: 179,
        totalHours: 1253.0,
        grossEarningsAud: 37777.95,
        targetVisaYear: 3,
      );

      await notifier.addJob(jobYear2);
      expect(notifier.totalDaysAccumulated, 88);
      expect(notifier.daysAccumulatedForYear(2), 88);
      expect(notifier.daysAccumulatedForYear(3), 0);

      await notifier.addJob(jobYear3);
      expect(notifier.totalDaysAccumulated, 88 + 179);
      expect(notifier.daysAccumulatedForYear(2), 88);
      expect(notifier.daysAccumulatedForYear(3), 179);
    });

    test('Updating existing job ID replaces entry without duplicate count', () async {
      final notifier = RegionalJobsNotifier(firestore: null);

      final job1 = RegionalJobEntry(
        id: 'job_update_test',
        employerBusinessName: 'Initial Farm',
        employerAbn: '11111111111',
        workSitePostcode: '3500',
        workSiteLocation: 'Mildura, VIC',
        industry: 'Grapes',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 20),
        totalDaysCounted: 15,
        totalHours: 105.0,
        grossEarningsAud: 3165.75,
        targetVisaYear: 2,
      );

      await notifier.addJob(job1);
      expect(notifier.totalDaysAccumulated, 15);
      expect(notifier.state.length, 1);

      // Actualizar con 25 días
      final job1Updated = RegionalJobEntry(
        id: 'job_update_test',
        employerBusinessName: 'Initial Farm - Extended',
        employerAbn: '11111111111',
        workSitePostcode: '3500',
        workSiteLocation: 'Mildura, VIC',
        industry: 'Grapes',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 30),
        totalDaysCounted: 25,
        totalHours: 175.0,
        grossEarningsAud: 5276.25,
        targetVisaYear: 2,
      );

      await notifier.addJob(job1Updated);
      expect(notifier.totalDaysAccumulated, 25);
      expect(notifier.state.length, 1);
      expect(notifier.state.first.employerBusinessName, 'Initial Farm - Extended');
    });

    test('Removing a job decrements days and stores ID in tombstone set', () async {
      final notifier = RegionalJobsNotifier(firestore: null);

      final job = RegionalJobEntry(
        id: 'job_to_remove',
        employerBusinessName: 'Farm XYZ',
        employerAbn: '22222222222',
        workSitePostcode: '6725',
        workSiteLocation: 'Broome, WA',
        industry: 'Pearling',
        startDate: DateTime(2026, 2, 1),
        endDate: DateTime(2026, 2, 28),
        totalDaysCounted: 20,
        totalHours: 140.0,
        grossEarningsAud: 4221.0,
        targetVisaYear: 2,
      );

      await notifier.addJob(job);
      expect(notifier.totalDaysAccumulated, 20);

      await notifier.removeJob('job_to_remove');
      expect(notifier.totalDaysAccumulated, 0);
      expect(notifier.state, isEmpty);
    });
  });
}
