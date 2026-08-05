import '../../domain/models/country_config.dart';

class AppConstants {
  // Lista oficial de pasaportes seleccionables para Work and Holiday Visa Subclase 462 (Con cuota anual - status-of-country-caps)
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
      code: 'EC',
      name: 'Ecuador',
      flagEmoji: '🇪🇨',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'BR',
      name: 'Brasil',
      flagEmoji: '🇧🇷',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'PT',
      name: 'Portugal',
      flagEmoji: '🇵🇹',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'AT',
      name: 'Austria',
      flagEmoji: '🇦🇹',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'CH',
      name: 'Suiza',
      flagEmoji: '🇨🇭',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'GR',
      name: 'Grecia',
      flagEmoji: '🇬🇷',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'PL',
      name: 'Polonia',
      flagEmoji: '🇵🇱',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'US',
      name: 'Estados Unidos',
      flagEmoji: '🇺🇸',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'CN',
      name: 'China',
      flagEmoji: '🇨🇳',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'CZ',
      name: 'República Checa',
      flagEmoji: '🇨🇿',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'HU',
      name: 'Hungría',
      flagEmoji: '🇭🇺',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'IN',
      name: 'India',
      flagEmoji: '🇮🇳',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'ID',
      name: 'Indonesia',
      flagEmoji: '🇮🇩',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'IL',
      name: 'Israel',
      flagEmoji: '🇮🇱',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'LU',
      name: 'Luxemburgo',
      flagEmoji: '🇱🇺',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'MY',
      name: 'Malasia',
      flagEmoji: '🇲🇾',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'MN',
      name: 'Mongolia',
      flagEmoji: '🇲🇳',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'PG',
      name: 'Papúa Nueva Guinea',
      flagEmoji: '🇵🇬',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'SM',
      name: 'San Marino',
      flagEmoji: '🇸🇲',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'SG',
      name: 'Singapur',
      flagEmoji: '🇸🇬',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'SK',
      name: 'Eslovaquia',
      flagEmoji: '🇸🇰',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'SI',
      name: 'Eslovenia',
      flagEmoji: '🇸🇮',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'TH',
      name: 'Tailandia',
      flagEmoji: '🇹🇭',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'TR',
      name: 'Turquía',
      flagEmoji: '🇹🇷',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
    ),
    CountryConfig(
      code: 'VN',
      name: 'Vietnam',
      flagEmoji: '🇻🇳',
      visaSubclass: '462',
      defaultStatus: 'CLOSED',
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
