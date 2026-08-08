import 'package:flutter/material.dart';
import 'package:ozvisa_alert/l10n/app_localizations.dart';

class CountryConfig {
  final String code;
  final String name;
  final String flagEmoji;
  final String visaSubclass;
  final String defaultStatus; // 'OPEN' o 'CLOSED'

  const CountryConfig({
    required this.code,
    required this.name,
    required this.flagEmoji,
    required this.visaSubclass,
    required this.defaultStatus,
  });

  CountryConfig copyWith({
    String? code,
    String? name,
    String? flagEmoji,
    String? visaSubclass,
    String? defaultStatus,
  }) {
    return CountryConfig(
      code: code ?? this.code,
      name: name ?? this.name,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      visaSubclass: visaSubclass ?? this.visaSubclass,
      defaultStatus: defaultStatus ?? this.defaultStatus,
    );
  }

  factory CountryConfig.fromMap(Map<String, dynamic> map, String code) {
    return CountryConfig(
      code: code,
      name: map['name'] ?? '',
      flagEmoji: map['flagEmoji'] ?? '🇦🇺',
      visaSubclass: map['visaSubclass'] ?? '462',
      defaultStatus: map['status'] ?? 'CLOSED',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'flagEmoji': flagEmoji,
      'visaSubclass': visaSubclass,
      'status': defaultStatus,
    };
  }
}

extension CountryConfigLocalization on CountryConfig {
  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return name;
    
    switch (code) {
      case 'AR': return l10n.countryAR;
      case 'AT': return l10n.countryAT;
      case 'BR': return l10n.countryBR;
      case 'CL': return l10n.countryCL;
      case 'CN': return l10n.countryCN;
      case 'CZ': return l10n.countryCZ;
      case 'EC': return l10n.countryEC;
      case 'GR': return l10n.countryGR;
      case 'HU': return l10n.countryHU;
      case 'IN': return l10n.countryIN;
      case 'ID': return l10n.countryID;
      case 'IL': return l10n.countryIL;
      case 'LU': return l10n.countryLU;
      case 'MY': return l10n.countryMY;
      case 'MN': return l10n.countryMN;
      case 'PG': return l10n.countryPG;
      case 'PE': return l10n.countryPE;
      case 'PL': return l10n.countryPL;
      case 'PT': return l10n.countryPT;
      case 'SM': return l10n.countrySM;
      case 'SG': return l10n.countrySG;
      case 'SK': return l10n.countrySK;
      case 'SI': return l10n.countrySI;
      case 'ES': return l10n.countryES;
      case 'CH': return l10n.countryCH;
      case 'TH': return l10n.countryTH;
      case 'TR': return l10n.countryTR;
      case 'UY': return l10n.countryUY;
      case 'VN': return l10n.countryVN;
      default: return name;
    }
  }
}
