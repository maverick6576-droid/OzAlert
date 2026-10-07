import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ozvisa_alert/domain/models/phase2/guide_data.dart';
import 'package:ozvisa_alert/domain/models/phase2/affiliate_partner.dart';

void main() {
  group('Guides & Comparisons Data Tests', () {
    test('All 6 key categories are present in guides_data.json with steps and comparisons', () {
      final file = File('assets/data/guides_data.json');
      expect(file.existsSync(), isTrue);

      final jsonStr = file.readAsStringSync();
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final guidesMap = data['guides'] as Map<String, dynamic>;

      final expectedCategories = [
        'banking',
        'telecom',
        'insurance',
        'housing',
        'tax',
        'certifications',
        'savings',
        'visa_renewal',
        'departure'
      ];

      for (final cat in expectedCategories) {
        expect(guidesMap.containsKey(cat), isTrue, reason: 'Category $cat should be in guides_data.json');
        final catGuide = CategoryGuide.fromJson(guidesMap[cat] as Map<String, dynamic>);

        expect(catGuide.title.isNotEmpty, isTrue);
        expect(catGuide.titleEn.isNotEmpty, isTrue);
        expect(catGuide.steps.length, greaterThanOrEqualTo(3), reason: '$cat should have at least 3 detailed steps');
        expect(catGuide.comparisons.length, greaterThanOrEqualTo(2), reason: '$cat should compare at least 2 providers');

        for (final step in catGuide.steps) {
          expect(step.title.isNotEmpty, isTrue);
          expect(step.description.isNotEmpty, isTrue);
          expect(step.officialUrl, isNotNull, reason: 'Step ${step.number} in $cat should have an officialUrl');
          expect(step.officialUrl!.startsWith('http'), isTrue);
          expect(step.officialUrlLabel, isNotNull);
        }

        for (final comp in catGuide.comparisons) {
          expect(comp.name.isNotEmpty, isTrue);
          expect(comp.pros.isNotEmpty, isTrue);
          expect(comp.verdict.isNotEmpty, isTrue);
        }
      }
    });

    test('All 6 categories have default B2B / official partner options in b2b_partners_default.json', () {
      final file = File('assets/data/b2b_partners_default.json');
      expect(file.existsSync(), isTrue);

      final jsonStr = file.readAsStringSync();
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final partnersList = (data['partners'] as List<dynamic>)
          .map((p) => AffiliatePartner.fromJson(p as Map<String, dynamic>))
          .toList();

      final expectedCategories = [
        'banking',
        'telecom',
        'insurance',
        'housing',
        'tax',
        'certifications',
        'visa_renewal',
        'departure'
      ];

      for (final cat in expectedCategories) {
        final matching = partnersList.where((p) => p.category == cat).toList();
        expect(matching.isNotEmpty, isTrue, reason: 'Category $cat should have at least 1 partner in default JSON');
      }
    });
  });
}
