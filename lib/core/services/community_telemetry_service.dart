import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Servicio silencioso de telemetría y benchmark comunitario anónimo.
///
/// Recopila de forma pasiva métricas reales de mercado (granjas, sueldos, alquileres,
/// compras de coches, tiempos de visado y ahorros de impuestos) SIN recopilar ningún
/// dato personal identificable (PII), para acumular la base de datos exclusiva de OzAlert.
class CommunityTelemetryService {
  static final CommunityTelemetryService _instance = CommunityTelemetryService._internal();
  factory CommunityTelemetryService() => _instance;
  CommunityTelemetryService._internal();

  FirebaseFirestore? _firestoreInstance;
  FirebaseFirestore get _firestore => _firestoreInstance ?? FirebaseFirestore.instance;

  @visibleForTesting
  void setFirestoreInstance(FirebaseFirestore firestore) {
    _firestoreInstance = firestore;
  }

  // ===========================================================================
  // 1. RADAR DE GRANJAS Y EMPLEADORES REGIONALES (GLASSDOOR MOCHILERO)
  // ===========================================================================
  Future<void> logFarmShift({
    required String? abn,
    required String postcode,
    required String industry,
    required double hourlyRateAud,
    required double hoursWorked,
    required double grossPayAud,
    required bool isFairWorkCompliant,
    bool hasPiecework = false,
    bool form1263Signed = false,
    int targetVisaYear = 2,
  }) async {
    try {
      final cleanAbn = abn?.replaceAll(RegExp(r'\s+'), '').trim() ?? '';
      final cleanPostcode = postcode.trim();

      if (cleanPostcode.isEmpty && cleanAbn.isEmpty) return;

      // Evento individual anónimo
      await _firestore.collection('crowdsourced_farm_reports').add({
        'abn': cleanAbn,
        'postcode': cleanPostcode,
        'industry': industry,
        'hourlyRateAud': hourlyRateAud > 0 ? hourlyRateAud : (hoursWorked > 0 ? grossPayAud / hoursWorked : 0.0),
        'hoursWorked': hoursWorked,
        'grossPayAud': grossPayAud,
        'isFairWorkCompliant': isFairWorkCompliant,
        'hasPiecework': hasPiecework,
        'form1263Signed': form1263Signed,
        'targetVisaYear': targetVisaYear,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Agregado atómico por empleador para consulta ultrarrápida
      if (cleanAbn.length == 11 && hoursWorked > 0) {
        final empRef = _firestore.collection('employer_intel').doc(cleanAbn);
        await empRef.set({
          'reportsCount': FieldValue.increment(1),
          'compliantCount': FieldValue.increment(isFairWorkCompliant ? 1 : 0),
          'form1263SignedCount': FieldValue.increment(form1263Signed ? 1 : 0),
          'totalGross': FieldValue.increment(grossPayAud),
          'totalHours': FieldValue.increment(hoursWorked),
          'lastReportedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Agregado atómico por código postal
      if (cleanPostcode.isNotEmpty && hoursWorked > 0) {
        final pcRef = _firestore.collection('postcode_intel').doc(cleanPostcode);
        await pcRef.set({
          'totalReports': FieldValue.increment(1),
          'totalGross': FieldValue.increment(grossPayAud),
          'totalHours': FieldValue.increment(hoursWorked),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('CommunityTelemetry logFarmShift silenciado: $e');
    }
  }

  // ===========================================================================
  // 2. SEMÁFORO EN TIEMPO REAL DE RESOLUCIÓN DE VISADOS (HOME AFFAIRS)
  // ===========================================================================
  Future<void> logVisaProcessing({
    required String countryCode,
    required String subclass,
    required int visaYear,
    required int processingDays,
    bool hadS56 = false,
  }) async {
    try {
      if (countryCode.isEmpty || processingDays < 0) return;

      // Evento individual anónimo
      await _firestore.collection('crowdsourced_visa_benchmarks').add({
        'countryCode': countryCode.toUpperCase(),
        'subclass': subclass,
        'visaYear': visaYear,
        'processingDays': processingDays,
        'hadS56': hadS56,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Agregado atómico por país
      final statRef = _firestore.collection('community_visa_benchmarks').doc('${countryCode.toUpperCase()}_$subclass');
      await statRef.set({
        'totalGrants': FieldValue.increment(1),
        'totalDays': FieldValue.increment(processingDays),
        's56AuditsCount': FieldValue.increment(hadS56 ? 1 : 0),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('CommunityTelemetry logVisaProcessing silenciado: $e');
    }
  }

  // ===========================================================================
  // 3. RADAR DE ALQUILERES Y FIANZAS RECUPERADAS
  // ===========================================================================
  Future<void> logRentalBond({
    required String stateAuthority,
    required double weeklyRentAud,
    required double bondAmountAud,
    String? propertyAddress,
    double bondReturnedPercent = 100.0,
  }) async {
    try {
      if (weeklyRentAud <= 0 && bondAmountAud <= 0) return;

      String extractedState = stateAuthority.trim();
      if (extractedState.isEmpty && propertyAddress != null) {
        final upper = propertyAddress.toUpperCase();
        if (upper.contains('NSW') || upper.contains('SYDNEY')) {
          extractedState = 'NSW';
        } else if (upper.contains('VIC') || upper.contains('MELBOURNE')) {
          extractedState = 'VIC';
        } else if (upper.contains('QLD') || upper.contains('BRISBANE')) {
          extractedState = 'QLD';
        } else if (upper.contains('WA') || upper.contains('PERTH')) {
          extractedState = 'WA';
        } else if (upper.contains('SA') || upper.contains('ADELAIDE')) {
          extractedState = 'SA';
        } else if (upper.contains('TAS') || upper.contains('HOBART')) {
          extractedState = 'TAS';
        }
      }

      await _firestore.collection('crowdsourced_rental_benchmarks').add({
        'state': extractedState.isNotEmpty ? extractedState : 'AU',
        'weeklyRentAud': weeklyRentAud,
        'bondAmountAud': bondAmountAud,
        'bondReturnedPercent': bondReturnedPercent,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Agregado por estado australiano
      if (extractedState.isNotEmpty) {
        final stateRef = _firestore.collection('community_rent_benchmarks').doc(extractedState);
        await stateRef.set({
          'totalReports': FieldValue.increment(1),
          'totalRentSum': FieldValue.increment(weeklyRentAud),
          'totalBondSum': FieldValue.increment(bondAmountAud),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('CommunityTelemetry logRentalBond silenciado: $e');
    }
  }

  // ===========================================================================
  // 4. ÍNDICE DE COMPRAVENTA DE VEHÍCULOS / VANS Y REGO WA
  // ===========================================================================
  Future<void> logVehicleTransaction({
    required String makeModel,
    required String year,
    required String regoState,
    required double salePriceAud,
    String? odometerKm,
  }) async {
    try {
      final cleanModel = makeModel.trim();
      if (cleanModel.isEmpty || salePriceAud <= 0) return;

      final parsedOdo = double.tryParse(odometerKm?.replaceAll(RegExp(r'[^0-9]'), '') ?? '') ?? 0.0;

      await _firestore.collection('crowdsourced_vehicle_benchmarks').add({
        'makeModel': cleanModel,
        'year': year.trim(),
        'regoState': regoState.trim().toUpperCase(),
        'salePriceAud': salePriceAud,
        'odometerKm': parsedOdo,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final vehRef = _firestore.collection('community_vehicle_benchmarks').doc(regoState.trim().toUpperCase());
      await vehRef.set({
        'totalTransactions': FieldValue.increment(1),
        'totalValueAud': FieldValue.increment(salePriceAud),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('CommunityTelemetry logVehicleTransaction silenciado: $e');
    }
  }

  // ===========================================================================
  // 5. SIMULADOR DE AHORRO Y DEVOLUCIÓN FISCAL REAL (MEDICARE MES Y DASP)
  // ===========================================================================
  Future<void> logTaxSaving({
    required double annualIncomeAud,
    required double mesSavingAud,
    required double accumulatedSuperAud,
    required double netDaspRefundAud,
    required bool isWhv,
  }) async {
    try {
      if (annualIncomeAud <= 0 && accumulatedSuperAud <= 0) return;

      await _firestore.collection('crowdsourced_tax_benchmarks').add({
        'annualIncomeAud': annualIncomeAud,
        'mesSavingAud': mesSavingAud,
        'accumulatedSuperAud': accumulatedSuperAud,
        'netDaspRefundAud': netDaspRefundAud,
        'isWhv': isWhv,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final totalRef = _firestore.collection('community_tax_benchmarks').doc('global_summary');
      await totalRef.set({
        'totalCalculations': FieldValue.increment(1),
        'totalMesSavingsCalculated': FieldValue.increment(mesSavingAud),
        'totalDaspRefundCalculated': FieldValue.increment(netDaspRefundAud),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('CommunityTelemetry logTaxSaving silenciado: $e');
    }
  }
}
