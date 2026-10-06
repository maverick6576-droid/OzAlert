class AffiliatePartner {
  final String id;
  final String name;
  final String category; // 'banking', 'telecom', 'insurance', 'housing', 'certifications'
  final String affiliateUrl;
  final String? promoCode;
  final String badgeText;
  final String badgeTextEn;
  final String description;
  final String descriptionEn;
  final bool isActive;
  final int priority;

  const AffiliatePartner({
    required this.id,
    required this.name,
    required this.category,
    required this.affiliateUrl,
    this.promoCode,
    required this.badgeText,
    required this.badgeTextEn,
    required this.description,
    required this.descriptionEn,
    this.isActive = true,
    this.priority = 1,
  });

  factory AffiliatePartner.fromJson(Map<String, dynamic> json) {
    return AffiliatePartner(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      affiliateUrl: json['affiliateUrl'] as String? ?? '',
      promoCode: json['promoCode'] as String?,
      badgeText: json['badgeText'] as String? ?? '',
      badgeTextEn: json['badgeTextEn'] as String? ?? (json['badgeText'] as String? ?? ''),
      description: json['description'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? (json['description'] as String? ?? ''),
      isActive: json['isActive'] as bool? ?? true,
      priority: (json['priority'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'affiliateUrl': affiliateUrl,
      if (promoCode != null) 'promoCode': promoCode,
      'badgeText': badgeText,
      'badgeTextEn': badgeTextEn,
      'description': description,
      'descriptionEn': descriptionEn,
      'isActive': isActive,
      'priority': priority,
    };
  }
}
