import 'package:flutter_test/flutter_test.dart';
import 'package:ozvisa_alert/core/services/url_launcher_service.dart';

void main() {
  group('UrlLauncherService Tests', () {
    test('Null or empty URL returns false safely', () async {
      expect(await UrlLauncherService.openUrl(null, null), isFalse);
      expect(await UrlLauncherService.openUrl(null, ''), isFalse);
      expect(await UrlLauncherService.openUrl(null, '   '), isFalse);
    });
  });
}
