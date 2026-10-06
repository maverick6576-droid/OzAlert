abstract class VisaStatsRepository {
  Future<void> submitVisaDates({
    required String uid,
    required String countryCode,
    required String subclass,
    required DateTime lodgementDate,
    required DateTime grantDate,
  });

  Future<Map<String, dynamic>?> getCommunityVisaStats(String countryCode);
}
