class AbnDetails {
  final String abn;
  final String status; // "Active" | "Cancelled" | "Unknown"
  final DateTime? statusEffectiveDate;
  final String acn;
  final String postcode;
  final String state;
  final String entityName;
  final List<String> businessNames;
  final String entityTypeCode;
  final String entityTypeName;
  final DateTime? gstDate;
  final String? errorMessage;

  const AbnDetails({
    required this.abn,
    required this.status,
    this.statusEffectiveDate,
    this.acn = '',
    this.postcode = '',
    this.state = '',
    this.entityName = '',
    this.businessNames = const [],
    this.entityTypeCode = '',
    this.entityTypeName = '',
    this.gstDate,
    this.errorMessage,
  });

  bool get isActive => status.toLowerCase() == 'active';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  String get preferredName {
    if (businessNames.isNotEmpty && businessNames.first.trim().isNotEmpty) {
      return businessNames.first.trim();
    }
    return entityName.trim();
  }

  factory AbnDetails.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null || val is! String || val.isEmpty) return null;
      return DateTime.tryParse(val);
    }

    final rawBusinessNames = json['BusinessName'];
    final List<String> names = [];
    if (rawBusinessNames is List) {
      for (final item in rawBusinessNames) {
        if (item != null && item.toString().trim().isNotEmpty) {
          names.add(item.toString().trim());
        }
      }
    }

    final message = json['Message']?.toString().trim();

    return AbnDetails(
      abn: json['Abn']?.toString() ?? '',
      status: json['AbnStatus']?.toString() ?? 'Unknown',
      statusEffectiveDate: parseDate(json['AbnStatusEffectiveFrom']),
      acn: json['Acn']?.toString() ?? '',
      postcode: json['AddressPostcode']?.toString() ?? '',
      state: json['AddressState']?.toString() ?? '',
      entityName: json['EntityName']?.toString() ?? '',
      businessNames: names,
      entityTypeCode: json['EntityTypeCode']?.toString() ?? '',
      entityTypeName: json['EntityTypeName']?.toString() ?? '',
      gstDate: parseDate(json['Gst']),
      errorMessage: (message != null && message.isNotEmpty) ? message : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'abn': abn,
      'status': status,
      'statusEffectiveDate': statusEffectiveDate?.toIso8601String(),
      'acn': acn,
      'postcode': postcode,
      'state': state,
      'entityName': entityName,
      'businessNames': businessNames,
      'entityTypeCode': entityTypeCode,
      'entityTypeName': entityTypeName,
      'gstDate': gstDate?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }
}
