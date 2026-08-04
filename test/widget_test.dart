import 'package:flutter_test/flutter_test.dart';
import 'package:ozvisa_alert/core/constants/app_constants.dart';

void main() {
  test('supportedCountries contiene exclusivamente países Subclase 462 con cuota anual de la web oficial', () {
    expect(AppConstants.supportedCountries.isNotEmpty, true);
    for (final country in AppConstants.supportedCountries) {
      expect(country.visaSubclass, '462', reason: '${country.name} debe ser Subclase 462');
    }
    // Verificar que países de la Subclase 417 (como Francia, Italia, Reino Unido o Alemania) no estén en la lista
    final names = AppConstants.supportedCountries.map((c) => c.name).toList();
    expect(names.contains('Francia'), false);
    expect(names.contains('Italia'), false);
    expect(names.contains('Reino Unido'), false);
    expect(names.contains('Alemania'), false);
  });
}
