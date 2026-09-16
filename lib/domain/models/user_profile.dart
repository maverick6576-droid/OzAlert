class UserProfile {
  final String uid;
  final String language;
  final List<String> passports;
  final bool onboardingCompleted;
  final bool isPremium;
  final String? referralSource;

  UserProfile({
    required this.uid,
    this.language = 'es',
    this.passports = const [],
    this.onboardingCompleted = false,
    this.isPremium = false,
    this.referralSource,
  });

  UserProfile copyWith({
    String? uid,
    String? language,
    List<String>? passports,
    bool? onboardingCompleted,
    bool? isPremium,
    String? referralSource,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      language: language ?? this.language,
      passports: passports ?? this.passports,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isPremium: isPremium ?? this.isPremium,
      referralSource: referralSource ?? this.referralSource,
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
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      language: map['language'] ?? 'es',
      passports: List<String>.from(map['passports'] ?? []),
      onboardingCompleted: map['onboardingCompleted'] ?? false,
      isPremium: map['isPremium'] ?? false,
      referralSource: map['referralSource'],
    );
  }
}
