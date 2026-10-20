import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPostcodeIntel {
  final String postcode;
  final int totalReports;
  final double averageHourlyRate;
  final double totalHoursLogged;
  final DateTime lastUpdated;

  const CommunityPostcodeIntel({
    required this.postcode,
    required this.totalReports,
    required this.averageHourlyRate,
    required this.totalHoursLogged,
    required this.lastUpdated,
  });

  factory CommunityPostcodeIntel.fromMap(String postcode, Map<String, dynamic> data) {
    final reports = (data['totalReports'] as num?)?.toInt() ?? 0;
    final gross = (data['totalGross'] as num?)?.toDouble() ?? 0.0;
    final hours = (data['totalHours'] as num?)?.toDouble() ?? 0.0;
    final avgRate = hours > 0 ? (gross / hours) : 0.0;
    final ts = data['lastUpdated'] as Timestamp?;

    return CommunityPostcodeIntel(
      postcode: postcode,
      totalReports: reports,
      averageHourlyRate: avgRate,
      totalHoursLogged: hours,
      lastUpdated: ts?.toDate() ?? DateTime.now(),
    );
  }
}

class CommunityEmployerIntel {
  final String abn;
  final int reportsCount;
  final int compliantReports;
  final double averageHourlyRate;
  final DateTime lastReportedAt;

  const CommunityEmployerIntel({
    required this.abn,
    required this.reportsCount,
    required this.compliantReports,
    required this.averageHourlyRate,
    required this.lastReportedAt,
  });

  double get complianceRatePercentage =>
      reportsCount > 0 ? (compliantReports / reportsCount) * 100 : 100.0;

  factory CommunityEmployerIntel.fromMap(String abn, Map<String, dynamic> data) {
    final reports = (data['reportsCount'] as num?)?.toInt() ?? 0;
    final compliant = (data['compliantCount'] as num?)?.toInt() ?? 0;
    final gross = (data['totalGross'] as num?)?.toDouble() ?? 0.0;
    final hours = (data['totalHours'] as num?)?.toDouble() ?? 0.0;
    final avgRate = hours > 0 ? (gross / hours) : 0.0;
    final ts = data['lastReportedAt'] as Timestamp?;

    return CommunityEmployerIntel(
      abn: abn,
      reportsCount: reports,
      compliantReports: compliant,
      averageHourlyRate: avgRate,
      lastReportedAt: ts?.toDate() ?? DateTime.now(),
    );
  }
}

class CommunityIntelRepository {
  final FirebaseFirestore _firestore;

  CommunityIntelRepository([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Registra métricas anónimas agregadas mediante FieldValue.increment
  /// Coste 0.00€: exactamente 1-2 escrituras atómicas sin lecturas previas ni escaneo de colecciones.
  Future<void> logAnonymousShiftMetrics({
    required String postcode,
    required String? abn,
    required double hours,
    required double grossPay,
    required bool isFairWorkCompliant,
  }) async {
    try {
      final cleanPostcode = postcode.trim();
      if (cleanPostcode.isNotEmpty && hours > 0 && grossPay > 0) {
        final postcodeRef = _firestore.collection('postcode_intel').doc(cleanPostcode);
        await postcodeRef.set({
          'totalReports': FieldValue.increment(1),
          'totalGross': FieldValue.increment(grossPay),
          'totalHours': FieldValue.increment(hours),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      final cleanAbn = abn?.replaceAll(RegExp(r'\s+'), '').trim();
      if (cleanAbn != null && cleanAbn.length == 11 && hours > 0 && grossPay > 0) {
        final employerRef = _firestore.collection('employer_intel').doc(cleanAbn);
        await employerRef.set({
          'reportsCount': FieldValue.increment(1),
          'compliantCount': FieldValue.increment(isFairWorkCompliant ? 1 : 0),
          'totalGross': FieldValue.increment(grossPay),
          'totalHours': FieldValue.increment(hours),
          'lastReportedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {
      // En caso de modo offline o sin permisos, silenciar para garantizar cero bloqueos en la UI
    }
  }

  /// Obtiene el resumen de inteligencia comunitaria de un código postal (1 sola lectura de Firestore)
  Future<CommunityPostcodeIntel?> getPostcodeIntel(String postcode) async {
    try {
      final doc = await _firestore.collection('postcode_intel').doc(postcode.trim()).get();
      if (doc.exists && doc.data() != null) {
        return CommunityPostcodeIntel.fromMap(postcode, doc.data()!);
      }
    } catch (_) {
      // Silenciar en modo offline
    }
    return null;
  }

  /// Obtiene el resumen de reputación y sueldo medio de un empleador por ABN (1 sola lectura)
  Future<CommunityEmployerIntel?> getEmployerIntel(String abn) async {
    try {
      final cleanAbn = abn.replaceAll(RegExp(r'\s+'), '').trim();
      final doc = await _firestore.collection('employer_intel').doc(cleanAbn).get();
      if (doc.exists && doc.data() != null) {
        return CommunityEmployerIntel.fromMap(cleanAbn, doc.data()!);
      }
    } catch (_) {
      // Silenciar en modo offline
    }
    return null;
  }
}
