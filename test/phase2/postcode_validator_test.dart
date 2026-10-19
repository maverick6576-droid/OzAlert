import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ozvisa_alert/domain/models/phase2/postcode_info.dart';
import 'package:ozvisa_alert/data/repositories/phase2/postcode_repository_impl.dart';

void main() {
  group('PostcodeValidator Tests', () {
    const sampleJson = '''
    {
      "postcodes": [
        {
          "code": "4870",
          "location": "Cairns, QLD",
          "state": "QLD",
          "zone": "northern",
          "subclass462": {
            "agriculture": true,
            "tourism_hospitality": true,
            "construction": true
          },
          "subclass417": {
            "agriculture": true,
            "tourism_hospitality": false,
            "construction": true
          }
        },
        {
          "code": "2481",
          "location": "Byron Bay, NSW",
          "state": "NSW",
          "zone": "regional_nsw",
          "subclass462": {
            "agriculture": true,
            "tourism_hospitality": false,
            "construction": false
          },
          "subclass417": {
            "agriculture": true,
            "tourism_hospitality": false,
            "construction": true
          }
        },
        {
          "code": "2000",
          "location": "Sydney CBD, NSW",
          "state": "NSW",
          "zone": "metro",
          "subclass462": {
            "agriculture": false,
            "tourism_hospitality": false
          },
          "subclass417": {
            "agriculture": false,
            "tourism_hospitality": false
          }
        }
      ]
    }
    ''';

    final decoded = jsonDecode(sampleJson);
    final List<dynamic> list = decoded['postcodes'];
    final postcodes = list.map((e) => PostcodeInfo.fromJson(e as Map<String, dynamic>)).toList();

    test('Cairns (4870) is eligible for tourism in Subclass 462', () {
      final cairns = postcodes.firstWhere((p) => p.code == '4870');
      expect(cairns.isEligible('462', 'tourism_hospitality'), isTrue);
      expect(cairns.isEligible('417', 'tourism_hospitality'), isFalse);
    });

    test('Byron Bay (2481) is NOT eligible for tourism in 462, but YES for agriculture', () {
      final byron = postcodes.firstWhere((p) => p.code == '2481');
      expect(byron.isEligible('462', 'tourism_hospitality'), isFalse);
      expect(byron.isEligible('462', 'agriculture'), isTrue);
      expect(byron.isEligible('417', 'agriculture'), isTrue);
    });

    test('Sydney CBD (2000) is ineligible for all categories', () {
      final sydney = postcodes.firstWhere((p) => p.code == '2000');
      expect(sydney.isEligible('462', 'agriculture'), isFalse);
      expect(sydney.isEligible('462', 'tourism_hospitality'), isFalse);
    });
  });

  group('PostcodeRepositoryImpl LIN 22/050 Comprehensive Tests', () {
    final repo = PostcodeRepositoryImpl();

    test('All SA, TAS and NT postcodes are regional for Agriculture and Construction', () {
      final sa = repo.findPostcode('5251')!; // Mount Barker, SA
      expect(sa.isEligible('462', 'agriculture'), isTrue);
      expect(sa.isEligible('417', 'construction'), isTrue);

      final tas = repo.findPostcode('7250')!; // Launceston, TAS
      expect(tas.isEligible('462', 'agriculture'), isTrue);
      expect(tas.isEligible('417', 'agriculture'), isTrue);

      final nt = repo.findPostcode('0800')!; // Darwin, NT
      expect(nt.isEligible('462', 'agriculture'), isTrue);
      expect(nt.isEligible('462', 'tourism_hospitality'), isTrue);
    });

    test('Northern Australia fishing/forestry and tourism rules for Subclass 462', () {
      // Cairns 4870 (Northern QLD)
      final cairns = repo.findPostcode('4870')!;
      expect(cairns.isEligible('462', 'tourism_hospitality'), isTrue);
      expect(cairns.isEligible('462', 'forestry_fishing'), isTrue);
      expect(cairns.isEligible('417', 'tourism_hospitality'), isFalse);

      // Broome 6725 (Northern WA)
      final broome = repo.findPostcode('6725')!;
      expect(broome.isEligible('462', 'tourism_hospitality'), isTrue);
      expect(broome.isEligible('462', 'forestry_fishing'), isTrue);
      expect(broome.isEligible('417', 'tourism_hospitality'), isFalse);
    });

    test('Remote Australia tourism qualifies for 462, but not for 417', () {
      // Tara / Western Downs QLD (4406) - Remote
      final tara = repo.findPostcode('4406')!;
      expect(tara.isEligible('462', 'tourism_hospitality'), isTrue);
      expect(tara.isEligible('417', 'tourism_hospitality'), isFalse);

      // Cobar NSW (2825) - Remote NSW
      final cobar = repo.findPostcode('2825')!;
      expect(cobar.isEligible('462', 'tourism_hospitality'), isTrue);
      expect(cobar.isEligible('417', 'tourism_hospitality'), isFalse);
    });

    test('Regional non-remote areas qualify for agriculture/construction, but NOT tourism in 462', () {
      // Byron Bay NSW (2481)
      final byron = repo.findPostcode('2481')!;
      expect(byron.isEligible('462', 'agriculture'), isTrue);
      expect(byron.isEligible('462', 'construction'), isTrue);
      expect(byron.isEligible('462', 'tourism_hospitality'), isFalse);

      // Bendigo VIC (3550)
      final bendigo = repo.findPostcode('3550')!;
      expect(bendigo.isEligible('462', 'agriculture'), isTrue);
      expect(bendigo.isEligible('462', 'tourism_hospitality'), isFalse);
    });

    test('Metropolitan postcodes are completely ineligible', () {
      final sydney = repo.findPostcode('2000')!;
      expect(sydney.isEligible('462', 'agriculture'), isFalse);
      expect(sydney.isEligible('417', 'construction'), isFalse);
      expect(sydney.zone, 'metro');

      final melbourne = repo.findPostcode('3000')!;
      expect(melbourne.isEligible('462', 'agriculture'), isFalse);
      expect(melbourne.zone, 'metro');

      final brisbane = repo.findPostcode('4000')!;
      expect(brisbane.isEligible('462', 'agriculture'), isFalse);
      expect(brisbane.zone, 'metro');

      final perth = repo.findPostcode('6000')!;
      expect(perth.isEligible('462', 'agriculture'), isFalse);
      expect(perth.zone, 'metro');
    });

    test('Home Affairs specified-462-work Tables 1, 2, 5, 6, Mining & Healthcare rules', () {
      // Table 1 & 2 Remote postcodes for Tourism & Hospitality (462)
      final rottnest = repo.findPostcode('6161')!; // WA Table 2 Remote
      expect(rottnest.isEligible('462', 'tourism_hospitality'), isTrue);

      final moreton = repo.findPostcode('4025')!; // QLD Table 2 Remote
      expect(moreton.isEligible('462', 'tourism_hospitality'), isTrue);

      final colesBay = repo.findPostcode('7215')!; // TAS Table 1 Remote
      expect(colesBay.isEligible('462', 'tourism_hospitality'), isTrue);

      // Mining is ONLY eligible for 417 in Regional Australia, NOT for 462
      final cairns = repo.findPostcode('4870')!;
      expect(cairns.isEligible('462', 'mining'), isFalse);
      expect(cairns.isEligible('417', 'mining'), isTrue);

      // Table 5 Bushfire Declared Area (e.g., Canberra 2600 is in Table 5 ACT)
      final canberra = repo.findPostcode('2600')!;
      expect(canberra.isEligible('462', 'bushfire_recovery'), isTrue);
      expect(canberra.isEligible('462', 'agriculture'), isFalse);

      // Table 6 Natural Disaster / Flood Declared Area (e.g., Lismore 2480, Brisbane 4000)
      final lismore = repo.findPostcode('2480')!;
      expect(lismore.isEligible('462', 'flood_recovery'), isTrue);
      expect(lismore.isEligible('462', 'bushfire_recovery'), isTrue);

      // Critical COVID-19 Healthcare & Medical is eligible anywhere in Australia
      final sydney = repo.findPostcode('2000')!;
      expect(sydney.isEligible('462', 'healthcare_covid'), isTrue);
    });
  });
}
