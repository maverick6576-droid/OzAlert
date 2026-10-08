class RegionalJobEntry {
  final String id;
  final String employerBusinessName;
  final String employerAbn;
  final String workSitePostcode;
  final String workSiteLocation;
  final String industry; // 'agriculture', 'tourism_hospitality', 'construction', etc.
  final String jobRole; // 'Fruit Picker', 'Farm Hand', 'Kitchen Hand', etc.
  final DateTime startDate;
  final DateTime endDate;
  final int totalDaysCounted;
  final double totalHours;
  final double grossEarningsAud;
  final bool isFullTimeWeekly; // If true (5 days >= 35h), counts as 7 days towards visa
  final bool hasPieceworkAgreement;
  final String? payslipFileRef;

  const RegionalJobEntry({
    required this.id,
    required this.employerBusinessName,
    required this.employerAbn,
    required this.workSitePostcode,
    required this.workSiteLocation,
    required this.industry,
    this.jobRole = 'Specified Worker',
    required this.startDate,
    required this.endDate,
    required this.totalDaysCounted,
    required this.totalHours,
    required this.grossEarningsAud,
    this.isFullTimeWeekly = false,
    this.hasPieceworkAgreement = false,
    this.payslipFileRef,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'employerBusinessName': employerBusinessName,
    'employerAbn': employerAbn,
    'workSitePostcode': workSitePostcode,
    'workSiteLocation': workSiteLocation,
    'industry': industry,
    'jobRole': jobRole,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'totalDaysCounted': totalDaysCounted,
    'totalHours': totalHours,
    'grossEarningsAud': grossEarningsAud,
    'isFullTimeWeekly': isFullTimeWeekly,
    'hasPieceworkAgreement': hasPieceworkAgreement,
    if (payslipFileRef != null) 'payslipFileRef': payslipFileRef,
  };

  factory RegionalJobEntry.fromJson(Map<String, dynamic> json) => RegionalJobEntry(
    id: json['id'] as String? ?? '',
    employerBusinessName: json['employerBusinessName'] as String? ?? '',
    employerAbn: json['employerAbn'] as String? ?? '',
    workSitePostcode: json['workSitePostcode'] as String? ?? '',
    workSiteLocation: json['workSiteLocation'] as String? ?? '',
    industry: json['industry'] as String? ?? 'agriculture',
    jobRole: json['jobRole'] as String? ?? 'Specified Worker',
    startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
    endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
    totalDaysCounted: (json['totalDaysCounted'] as num?)?.toInt() ?? 0,
    totalHours: (json['totalHours'] as num?)?.toDouble() ?? 0.0,
    grossEarningsAud: (json['grossEarningsAud'] as num?)?.toDouble() ?? 0.0,
    isFullTimeWeekly: json['isFullTimeWeekly'] as bool? ?? false,
    hasPieceworkAgreement: json['hasPieceworkAgreement'] as bool? ?? false,
    payslipFileRef: json['payslipFileRef'] as String?,
  );
}
