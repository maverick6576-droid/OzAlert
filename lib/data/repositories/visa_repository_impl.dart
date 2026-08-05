import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/visa_repository.dart';
import '../../core/services/shared_prefs_service.dart';
import '../../core/constants/app_constants.dart';

class VisaRepositoryImpl implements VisaRepository {
  final SharedPrefsService _sharedPrefsService;
  final StreamController<String> _demoStatusController =
      StreamController<String>.broadcast();

  VisaRepositoryImpl(this._sharedPrefsService);

  @override
  Stream<String> watchVisaStatus(String countryCode) {
    // Si estamos en un entorno con Firebase Firestore conectado:
    try {
      final firestore = FirebaseFirestore.instance;
      return firestore
          .collection('visas')
          .doc(countryCode)
          .snapshots()
          .map((snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              final data = snapshot.data()!;
              final status = data['status'] as String?;
              if (status != null &&
                  (status == 'OPEN' || status == 'CLOSED' || status == 'PAUSED')) {
                return status;
              }
            }
            // Si el documento en Firestore aún no existe, devolver estado por defecto del país
            final defaultStatus =
                AppConstants.supportedCountries
                    .firstWhere(
                      (c) => c.code == countryCode,
                      orElse: () => AppConstants.supportedCountries.first,
                    )
                    .defaultStatus;
            return defaultStatus;
          })
          .handleError((e) {
            debugPrint('Error en Firestore watchVisaStatus: $e');
          });
    } catch (e) {
      debugPrint(
        'Firestore no inicializado o modo demo local. Usando stream simulado: $e',
      );
    }

    // Modo offline / simulación local:
    return _demoStatusController.stream;
  }

  @override
  Future<void> saveUserCountryPreference({
    required String uid,
    required String countryCode,
    String? email,
    String? fcmToken,
  }) async {
    await _sharedPrefsService.saveSelectedCountryCode(countryCode);

    try {
      final firestore = FirebaseFirestore.instance;
      final data = {
        'selectedCountryCode': countryCode,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (email != null && email.isNotEmpty) data['email'] = email;
      if (fcmToken != null && fcmToken.isNotEmpty) {
        data['fcmToken'] = fcmToken;
      }

      await firestore
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));
      debugPrint('Preferencia guardada en Firestore /users/$uid: $countryCode');
    } catch (e) {
      debugPrint('Guardado en Firestore omitido en modo local: $e');
    }
  }

  @override
  Future<void> toggleDemoStatus(String countryCode, bool isOpen) async {
    final statusStr = isOpen ? 'OPEN' : 'CLOSED';
    _demoStatusController.add(statusStr);
    await _sharedPrefsService.setDemoModeStatus(isOpen);

    // Intentar actualizar también Firestore si hay permisos de admin/demo:
    try {
      await FirebaseFirestore.instance.collection('visas').doc(countryCode).set({
        'status': statusStr,
        'updatedAt': FieldValue.serverTimestamp(),
        'countryCode': countryCode,
      }, SetOptions(merge: true));
    } catch (_) {
      // Ignorar si las reglas de seguridad restringen escritura del cliente
    }
  }
}
