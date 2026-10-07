class WorkExperience {
  final String role;
  final String company;
  final String location;
  final String period;
  final List<String> bulletPoints;

  const WorkExperience({
    required this.role,
    required this.company,
    required this.location,
    required this.period,
    required this.bulletPoints,
  });

  WorkExperience copyWith({
    String? role,
    String? company,
    String? location,
    String? period,
    List<String>? bulletPoints,
  }) {
    return WorkExperience(
      role: role ?? this.role,
      company: company ?? this.company,
      location: location ?? this.location,
      period: period ?? this.period,
      bulletPoints: bulletPoints ?? this.bulletPoints,
    );
  }

  Map<String, dynamic> toJson() => {
    'role': role,
    'company': company,
    'location': location,
    'period': period,
    'bulletPoints': bulletPoints,
  };

  factory WorkExperience.fromJson(Map<String, dynamic> json) => WorkExperience(
    role: json['role'] as String? ?? '',
    company: json['company'] as String? ?? '',
    location: json['location'] as String? ?? '',
    period: json['period'] as String? ?? '',
    bulletPoints: List<String>.from(json['bulletPoints'] ?? []),
  );
}

class AustralianResumeData {
  final String fullName;
  final String phone;
  final String email;
  final String locationSuburb; // e.g. 'Surry Hills, NSW 2010'
  final String visaStatus; // e.g. 'Working Holiday Visa (Subclass 462) - Full Unlimited Work Rights'
  final String availability; // e.g. 'Immediate Start | Flexible 7 Days & Weekends | 6-Month Commitment'
  final String targetIndustry; // e.g. 'hospitality', 'construction', 'farm', 'retail', 'cleaning', 'office'
  final String jobTitle; // e.g. 'Experienced Barista & Hospitality All-Rounder'
  final String summary;
  final List<String> skills;
  final List<WorkExperience> experiences;
  final List<String> certifications; // e.g. ['RSA NSW (Responsible Service of Alcohol)', 'White Card']
  final String education; // e.g. 'Completed Higher Secondary Education'
  final String linkedIn; // optional e.g. 'linkedin.com/in/applicant'
  final String references; // Default: 'Available upon request'
  final String themeColorHex; // Hex color code for PDF accent e.g. '#D96B43'

  const AustralianResumeData({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.locationSuburb,
    required this.visaStatus,
    required this.availability,
    required this.targetIndustry,
    this.jobTitle = 'Experienced Candidate',
    required this.summary,
    required this.skills,
    required this.experiences,
    required this.certifications,
    this.education = 'Secondary Education Graduate',
    this.linkedIn = '',
    this.references = 'Available upon request',
    this.themeColorHex = '#D96B43',
  });

  AustralianResumeData copyWith({
    String? fullName,
    String? phone,
    String? email,
    String? locationSuburb,
    String? visaStatus,
    String? availability,
    String? targetIndustry,
    String? jobTitle,
    String? summary,
    List<String>? skills,
    List<WorkExperience>? experiences,
    List<String>? certifications,
    String? education,
    String? linkedIn,
    String? references,
    String? themeColorHex,
  }) {
    return AustralianResumeData(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      locationSuburb: locationSuburb ?? this.locationSuburb,
      visaStatus: visaStatus ?? this.visaStatus,
      availability: availability ?? this.availability,
      targetIndustry: targetIndustry ?? this.targetIndustry,
      jobTitle: jobTitle ?? this.jobTitle,
      summary: summary ?? this.summary,
      skills: skills ?? this.skills,
      experiences: experiences ?? this.experiences,
      certifications: certifications ?? this.certifications,
      education: education ?? this.education,
      linkedIn: linkedIn ?? this.linkedIn,
      references: references ?? this.references,
      themeColorHex: themeColorHex ?? this.themeColorHex,
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phone': phone,
    'email': email,
    'locationSuburb': locationSuburb,
    'visaStatus': visaStatus,
    'availability': availability,
    'targetIndustry': targetIndustry,
    'jobTitle': jobTitle,
    'summary': summary,
    'skills': skills,
    'experiences': experiences.map((e) => e.toJson()).toList(),
    'certifications': certifications,
    'education': education,
    'linkedIn': linkedIn,
    'references': references,
    'themeColorHex': themeColorHex,
  };

  factory AustralianResumeData.fromJson(Map<String, dynamic> json) => AustralianResumeData(
    fullName: json['fullName'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    email: json['email'] as String? ?? '',
    locationSuburb: json['locationSuburb'] as String? ?? '',
    visaStatus: json['visaStatus'] as String? ?? 'Working Holiday Visa (Subclass 462) - Full Work Rights',
    availability: json['availability'] as String? ?? 'Immediate Start - Full Time & Weekends',
    targetIndustry: json['targetIndustry'] as String? ?? 'hospitality',
    jobTitle: json['jobTitle'] as String? ?? 'Experienced Candidate',
    summary: json['summary'] as String? ?? '',
    skills: List<String>.from(json['skills'] ?? []),
    experiences: (json['experiences'] as List<dynamic>? ?? [])
        .map((e) => WorkExperience.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    certifications: List<String>.from(json['certifications'] ?? []),
    education: json['education'] as String? ?? 'Secondary Education Graduate',
    linkedIn: json['linkedIn'] as String? ?? '',
    references: json['references'] as String? ?? 'Available upon request',
    themeColorHex: json['themeColorHex'] as String? ?? '#D96B43',
  );
}
