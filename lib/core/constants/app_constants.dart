import '../../domain/models/country_config.dart';

class AppConstants {
  // Lista oficial de pasaportes seleccionables para Working Holiday Visa 417 y 462
  static const List<CountryConfig> supportedCountries = [
    CountryConfig(
      code: 'ES',
      name: 'España',
      flagEmoji: '🇪🇸',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'AR',
      name: 'Argentina',
      flagEmoji: '🇦🇷',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'CL',
      name: 'Chile',
      flagEmoji: '🇨🇱',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'UY',
      name: 'Uruguay',
      flagEmoji: '🇺🇾',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'PE',
      name: 'Perú',
      flagEmoji: '🇵🇪',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'IT',
      name: 'Italia',
      flagEmoji: '🇮🇹',
      visaSubclass: '417',
      defaultStatus: 'OPEN',
    ),
    CountryConfig(
      code: 'FR',
      name: 'Francia',
      flagEmoji: '🇫🇷',
      visaSubclass: '417',
      defaultStatus: 'OPEN',
    ),
    CountryConfig(
      code: 'GB',
      name: 'Reino Unido',
      flagEmoji: '🇬🇧',
      visaSubclass: '417',
      defaultStatus: 'OPEN',
    ),
    CountryConfig(
      code: 'DE',
      name: 'Alemania',
      flagEmoji: '🇩🇪',
      visaSubclass: '417',
      defaultStatus: 'OPEN',
    ),
  ];

  // Feeds RSS e Información de Inmigración de Australia
  static const String migrationRssUrl =
      'https://www.homeaffairs.gov.au/news-media/rss/news';
  static const String sbsMigrationRssUrl =
      'https://www.sbs.com.au/language/spanish/rss';

  // Banner Afiliado de Seguros de Viaje
  static const String affiliateInsuranceTitle =
      '¿Necesitas seguro médico para Australia? Obtén 15% de descuento con Chapka / IATI Seguros';
  static const String affiliateInsuranceUrl =
      'https://www.chapkadirect.es/index.php?app=cd_working_holiday&promo=OZVISA15';

  // RevenueCat Product IDs
  static const String rcMonthlyPlanId = 'ozvisa_monthly_199';
  static const String rcAnnualPlanId = 'ozvisa_annual_1499';
  static const String rcEntitlementId = 'ozvisa_pro_access';
}
