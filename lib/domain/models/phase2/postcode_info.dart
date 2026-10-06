class PostcodeInfo {
  final String code;
  final String location;
  final String state;
  final String zone; // 'northern', 'remote', 'regional_nsw', 'regional_vic', 'metro', etc.
  final Map<String, bool> subclass462;
  final Map<String, bool> subclass417;

  const PostcodeInfo({
    required this.code,
    required this.location,
    required this.state,
    required this.zone,
    required this.subclass462,
    required this.subclass417,
  });

  factory PostcodeInfo.fromJson(Map<String, dynamic> json) {
    Map<String, bool> parseMap(dynamic raw) {
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), v == true));
      }
      return {};
    }

    return PostcodeInfo(
      code: json['code'] as String? ?? '',
      location: json['location'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zone: json['zone'] as String? ?? '',
      subclass462: parseMap(json['subclass462']),
      subclass417: parseMap(json['subclass417']),
    );
  }

  bool isEligible(String subclass, String industry) {
    if (subclass == '462') {
      return subclass462[industry] ?? false;
    } else {
      return subclass417[industry] ?? false;
    }
  }
}
