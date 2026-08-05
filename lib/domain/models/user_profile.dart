class UserProfile {
  final String uid;
  final String language;
  final List<String> passports;
  final bool onboardingCompleted;
  final bool isPremium;

  UserProfile({
    required this.uid,
    this.language = 'es',
    this.passports = const [],
    this.onboardingCompleted = false,
    this.isPremium = false,
  });

  UserProfile copyWith({
    String? uid,
    String? language,
    List<String>? passports,
    bool? onboardingCompleted,
    bool? isPremium,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      language: language ?? this.language,
      passports: passports ?? this.passports,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'language': language,
      'passports': passports,
      'onboardingCompleted': onboardingCompleted,
      'isPremium': isPremium,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      language: map['language'] ?? 'es',
      passports: List<String>.from(map['passports'] ?? []),
      onboardingCompleted: map['onboardingCompleted'] ?? false,
      isPremium: map['isPremium'] ?? false,
    );
  }
}
