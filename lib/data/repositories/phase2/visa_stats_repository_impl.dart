import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/repositories/phase2/visa_stats_repository.dart';

class VisaStatsRepositoryImpl implements VisaStatsRepository {
  final FirebaseFirestore _firestore;

  VisaStatsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> submitVisaDates({
    required String uid,
    required String countryCode,
    required String subclass,
    required DateTime lodgementDate,
    required DateTime grantDate,
  }) async {
    final processingDays = grantDate.difference(lodgementDate).inDays;

    // 1. Guardar en el perfil privado del usuario (con timeout de 6s)
    await _firestore.collection('users').doc(uid).set({
      'visaLodgementDate': lodgementDate.toIso8601String(),
      'visaGrantDate': grantDate.toIso8601String(),
      'visaProcessingDays': processingDays,
      'datesSurveyCompleted': true,
      'currentPhase': 2,
    }, SetOptions(merge: true)).timeout(const Duration(seconds: 6));

    // 2. Guardar en colección anónima comunitaria de fondo
    try {
      _firestore.collection('visa_grant_reports').add({
        'countryCode': countryCode.toUpperCase(),
        'subclass': subclass,
        'lodgementDate': Timestamp.fromDate(lodgementDate),
        'grantDate': Timestamp.fromDate(grantDate),
        'processingDays': processingDays,
        'reportedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  @override
  Future<Map<String, dynamic>?> getCommunityVisaStats(String countryCode) async {
    try {
      final sixtyDaysAgo = DateTime.now().subtract(const Duration(days: 60));
      final query = await _firestore
          .collection('visa_grant_reports')
          .where('countryCode', isEqualTo: countryCode.toUpperCase())
          .where('grantDate', isGreaterThanOrEqualTo: Timestamp.fromDate(sixtyDaysAgo))
          .limit(50)
          .get();

      if (query.docs.isEmpty) return null;

      final List<int> daysList = [];
      for (final doc in query.docs) {
        final data = doc.data();
        final days = data['processingDays'] as num?;
        if (days != null) daysList.add(days.toInt());
      }

      if (daysList.isEmpty) return null;

      daysList.sort();
      final sum = daysList.reduce((a, b) => a + b);
      final avg = (sum / daysList.length).round();
      final min = daysList.first;
      final max = daysList.last;

      return {
        'count': daysList.length,
        'averageDays': avg,
        'minDays': min,
        'maxDays': max,
      };
    } catch (_) {
      return null;
    }
  }
}
