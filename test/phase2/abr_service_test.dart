import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ozvisa_alert/core/services/abr_service.dart';

void main() {
  group('AbrService - cleanAbn', () {
    test('removes spaces and hyphens correctly', () {
      expect(AbrService.cleanAbn('51 824 753 556'), '51824753556');
      expect(AbrService.cleanAbn('51-824-753-556'), '51824753556');
      expect(AbrService.cleanAbn('  51824753556  '), '51824753556');
      expect(AbrService.cleanAbn('ABN: 51 824 753 556!'), '51824753556');
    });
  });

  group('AbrService - isValidAbnChecksum (ATO Official Algorithm)', () {
    test('validates real Australian official ABNs', () {
      // Australian Taxation Office (ATO)
      expect(AbrService.isValidAbnChecksum('51 824 753 556'), isTrue);
      // BHP Group Limited
      expect(AbrService.isValidAbnChecksum('49 004 028 077'), isTrue);
      // Woolworths Group
      expect(AbrService.isValidAbnChecksum('88 000 014 675'), isTrue);
      // Telstra Corporation
      expect(AbrService.isValidAbnChecksum('33 051 775 556'), isTrue);
    });

    test('rejects invalid or fake ABNs', () {
      // Length != 11
      expect(AbrService.isValidAbnChecksum('1234567890'), isFalse);
      expect(AbrService.isValidAbnChecksum('123456789012'), isFalse);
      expect(AbrService.isValidAbnChecksum(''), isFalse);

      // 11 digits but failing modulo 89 checksum
      expect(AbrService.isValidAbnChecksum('11 111 111 111'), isFalse);
      expect(AbrService.isValidAbnChecksum('12 345 678 901'), isFalse);
      expect(AbrService.isValidAbnChecksum('51 824 753 557'), isFalse); // 1 digit off ATO
    });
  });

  group('AbrService - getOfficialAbnUrl', () {
    test('creates correct public deep link', () {
      expect(
        AbrService.getOfficialAbnUrl('51 824 753 556'),
        'https://abr.business.gov.au/ABN/View?id=51824753556',
      );
    });
  });

  group('AbrService - lookupAbn', () {
    test('returns invalid error when length is not 11', () async {
      final service = AbrService();
      final result = await service.lookupAbn('12345');
      expect(result.status, 'Invalid');
      expect(result.hasError, isTrue);
    });

    test('returns invalid error when checksum fails', () async {
      final service = AbrService();
      final result = await service.lookupAbn('12345678901');
      expect(result.status, 'Invalid');
      expect(result.hasError, isTrue);
    });

    test('returns Active with NO_GUID when no GUID is configured', () async {
      final service = AbrService();
      // Valid ATO ABN with empty GUID
      final result = await service.lookupAbn('51 824 753 556', customGuid: '');
      expect(result.status, 'Active');
      expect(result.errorMessage, 'NO_GUID');
    });

    test('parses JSONP response from ABR API correctly', () async {
      const mockJsonp = '''callback({
        "Abn": "51824753556",
        "AbnStatus": "Active",
        "AbnStatusEffectiveFrom": "1999-11-01",
        "Acn": "",
        "AddressPostcode": "2600",
        "AddressState": "ACT",
        "BusinessName": [],
        "EntityName": "AUSTRALIAN TAXATION OFFICE",
        "EntityTypeCode": "CGE",
        "EntityTypeName": "Commonwealth Government Entity",
        "Gst": "2000-07-01",
        "Message": ""
      })''';

      final mockClient = MockClient((request) async {
        return http.Response(mockJsonp, 200);
      });

      final service = AbrService(client: mockClient);
      final result = await service.lookupAbn('51 824 753 556', customGuid: 'test-guid');

      expect(result.abn, '51824753556');
      expect(result.isActive, isTrue);
      expect(result.isCancelled, isFalse);
      expect(result.entityName, 'AUSTRALIAN TAXATION OFFICE');
      expect(result.preferredName, 'AUSTRALIAN TAXATION OFFICE');
      expect(result.postcode, '2600');
      expect(result.state, 'ACT');
    });

    test('detects cancelled ABN correctly from ABR API', () async {
      const mockCancelledJsonp = '''callback({
        "Abn": "51824753556",
        "AbnStatus": "Cancelled",
        "AbnStatusEffectiveFrom": "2020-01-01",
        "Acn": "",
        "AddressPostcode": "4870",
        "AddressState": "QLD",
        "BusinessName": ["OLD FARM SERVICES"],
        "EntityName": "DEFUNCT ENTITY PTY LTD",
        "EntityTypeCode": "PRV",
        "EntityTypeName": "Australian Private Company",
        "Message": ""
      })''';

      final mockClient = MockClient((request) async {
        return http.Response(mockCancelledJsonp, 200);
      });

      final service = AbrService(client: mockClient);
      final result = await service.lookupAbn('51 824 753 556', customGuid: 'test-guid');

      expect(result.isCancelled, isTrue);
      expect(result.isActive, isFalse);
      expect(result.preferredName, 'OLD FARM SERVICES');
    });
  });
}
