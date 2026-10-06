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
  final String locationSuburb; // e.g., 'Bondi, NSW' (NO full home address needed in Australia)
  final String visaStatus; // e.g., 'Work & Holiday Visa (Subclass 462) - Full Working Rights'
  final String availability; // e.g., 'Immediate start, flexible 7 days including weekends'
  final String targetIndustry; // 'hospitality', 'construction', 'farm', 'corporate'
  final String summary;
  final List<String> skills;
  final List<WorkExperience> experiences;
  final List<String> certifications; // e.g. ['RSA NSW', 'White Card', 'Barista Skills']
  final String references; // Default: 'Available upon request'

  const AustralianResumeData({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.locationSuburb,
    required this.visaStatus,
    required this.availability,
    required this.targetIndustry,
    required this.summary,
    required this.skills,
    required this.experiences,
    required this.certifications,
    this.references = 'Available upon request',
  });
}
