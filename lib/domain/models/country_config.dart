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
