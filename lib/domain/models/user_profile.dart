class UserProfile {
  final String uid;
  final String language;
  final List<String> passports;
  final bool onboardingCompleted;
  final bool isPremium;
  final String? referralSource;
  final int currentPhase; // 1 = Buscando Visa, 2 = En Australia
  final String visaSubclass; // '462' o '417'
  final DateTime? visaLodgementDate;
  final DateTime? visaGrantDate;
  final int? visaProcessingDays;
  final bool datesSurveyCompleted;

  UserProfile({
    required this.uid,
    this.language = 'es',
    this.passports = const [],
    this.onboardingCompleted = false,
    this.isPremium = false,
    this.referralSource,
    this.currentPhase = 1,
    this.visaSubclass = '462',
    this.visaLodgementDate,
    this.visaGrantDate,
    this.visaProcessingDays,
    this.datesSurveyCompleted = false,
  });

  UserProfile copyWith({
    String? uid,
    String? language,
    List<String>? passports,
    bool? onboardingCompleted,
    bool? isPremium,
    String? referralSource,
    int? currentPhase,
    String? visaSubclass,
    DateTime? visaLodgementDate,
    DateTime? visaGrantDate,
    int? visaProcessingDays,
    bool? datesSurveyCompleted,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      language: language ?? this.language,
      passports: passports ?? this.passports,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isPremium: isPremium ?? this.isPremium,
      referralSource: referralSource ?? this.referralSource,
      currentPhase: currentPhase ?? this.currentPhase,
      visaSubclass: visaSubclass ?? this.visaSubclass,
      visaLodgementDate: visaLodgementDate ?? this.visaLodgementDate,
      visaGrantDate: visaGrantDate ?? this.visaGrantDate,
      visaProcessingDays: visaProcessingDays ?? this.visaProcessingDays,
      datesSurveyCompleted: datesSurveyCompleted ?? this.datesSurveyCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'language': language,
      'passports': passports,
      'onboardingCompleted': onboardingCompleted,
      'isPremium': isPremium,
      if (referralSource != null) 'referralSource': referralSource,
      'currentPhase': currentPhase,
      'visaSubclass': visaSubclass,
      if (visaLodgementDate != null) 'visaLodgementDate': visaLodgementDate!.toIso8601String(),
      if (visaGrantDate != null) 'visaGrantDate': visaGrantDate!.toIso8601String(),
      if (visaProcessingDays != null) 'visaProcessingDays': visaProcessingDays,
      'datesSurveyCompleted': datesSurveyCompleted,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return UserProfile(
      uid: uid,
      language: map['language'] ?? 'es',
      passports: List<String>.from(map['passports'] ?? []),
      onboardingCompleted: map['onboardingCompleted'] ?? false,
      isPremium: map['isPremium'] ?? false,
      referralSource: map['referralSource'],
      currentPhase: map['currentPhase'] ?? 1,
      visaSubclass: map['visaSubclass'] ?? '462',
      visaLodgementDate: parseDate(map['visaLodgementDate']),
      visaGrantDate: parseDate(map['visaGrantDate']),
      visaProcessingDays: map['visaProcessingDays'] is int ? map['visaProcessingDays'] : null,
      datesSurveyCompleted: map['datesSurveyCompleted'] ?? false,
    );
  }
}
