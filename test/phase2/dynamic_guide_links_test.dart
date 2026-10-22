import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ozvisa_alert/data/repositories/phase2/guide_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dynamic Guide Links & Zero-Cost Caching Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Loads base guide from local JSON when no remote overrides exist', () async {
      final repo = GuideRepositoryImpl();
      final guide = await repo.getGuideForCategory('banking');

      expect(guide, isNotNull);
      expect(guide!.id, 'banking');
      expect(guide.steps.isNotEmpty, isTrue);

      // Default URL for step 1
      expect(guide.steps[0].officialUrl, 'https://www.commbank.com.au/moving-to-australia.html');
      expect(guide.steps[0].officialUrlLabel, 'CommBank - Apertura Pre-Llegada Oficial');
    });

    test('Applies dynamic override from cached JSON correctly', () async {
      final testOverrides = {
        'categoryId': 'banking',
        'steps': {
          '1': {
            'officialUrl': 'https://www.commbank.com.au/updated-direct-link.html',
            'officialUrlLabel': 'CommBank - Nuevo Enlace Oficial',
            'officialUrlLabelEn': 'CommBank - New Official Link',
          }
        },
        'comparisons': {
          'nab': {
            'officialUrl': 'https://www.nab.com.au/new-classic-account',
            'officialUrlLabel': 'NAB - Nueva Cuenta Sin Comisiones',
            'officialUrlLabelEn': 'NAB - New Fee-Free Account',
          }
        }
      };

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('official_links_banking', json.encode(testOverrides));
      await prefs.setInt('official_links_ts_banking', DateTime.now().millisecondsSinceEpoch);

      final repo = GuideRepositoryImpl(prefs: prefs);
      final guide = await repo.getGuideForCategory('banking');

      expect(guide, isNotNull);

      // Step 1 should have overridden URL and labels
      final step1 = guide!.steps.firstWhere((s) => s.number == 1);
      expect(step1.officialUrl, 'https://www.commbank.com.au/updated-direct-link.html');
      expect(step1.officialUrlLabel, 'CommBank - Nuevo Enlace Oficial');
      expect(step1.officialUrlLabelEn, 'CommBank - New Official Link');

      // Step 2 should remain unchanged
      final step2 = guide.steps.firstWhere((s) => s.number == 2);
      expect(step2.officialUrl, 'https://wise.com/au/compare/');

      // Comparison for NAB should have overridden URL
      final nabComp = guide.comparisons.firstWhere((c) => c.id == 'nab');
      expect(nabComp.officialUrl, 'https://www.nab.com.au/new-classic-account');
      expect(nabComp.officialUrlLabel, 'NAB - Nueva Cuenta Sin Comisiones');
      expect(nabComp.officialUrlLabelEn, 'NAB - New Fee-Free Account');

      // Comparison for CommBank should remain unchanged
      final commbankComp = guide.comparisons.firstWhere((c) => c.id == 'commbank');
      expect(commbankComp.officialUrl, 'https://www.commbank.com.au/moving-to-australia.html');
    });

    test('Zero-cost guarantee: Cache younger than 24 hours does not expire', () async {
      final prefs = await SharedPreferences.getInstance();
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch;

      final testOverrides = {
        'categoryId': 'telecom',
        'steps': {
          '3': {
            'officialUrl': 'https://mobile.woolworths.com.au/special-deal',
            'officialUrlLabel': 'Woolworths - Promo 50%',
            'officialUrlLabelEn': 'Woolworths - 50% Promo',
          }
        }
      };

      await prefs.setString('official_links_telecom', json.encode(testOverrides));
      await prefs.setInt('official_links_ts_telecom', twoHoursAgo);

      final repo = GuideRepositoryImpl(prefs: prefs);
      final guide = await repo.getGuideForCategory('telecom');

      expect(guide, isNotNull);
      final step3 = guide!.steps.firstWhere((s) => s.number == 3);
      expect(step3.officialUrl, 'https://mobile.woolworths.com.au/special-deal');
    });

    test('Recovers gracefully and falls back to local JSON when error occurs', () async {
      final repo = GuideRepositoryImpl();
      // Non-existent or invalid categories return null gracefully
      final invalidGuide = await repo.getGuideForCategory('non_existent_category');
      expect(invalidGuide, isNull);

      // Existing categories load fine even if network is offline
      final taxGuide = await repo.getGuideForCategory('tax');
      expect(taxGuide, isNotNull);
      expect(taxGuide!.steps.length, greaterThanOrEqualTo(5));
    });
  });
}
