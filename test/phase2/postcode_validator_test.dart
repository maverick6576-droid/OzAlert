import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:ozvisa_alert/domain/models/phase2/postcode_info.dart';

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
}
