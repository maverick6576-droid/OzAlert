
abstract class VisaRepository {
  /// Stream que observa el documento /visas/{countryCode} en Firestore en tiempo real.
  /// En modo demo o si no hay credenciales de Firebase configuradas, emite el estado mock.
  Stream<String> watchVisaStatus(String countryCode);

  /// Actualiza la preferencia del usuario en Firestore /users/{uid}
  Future<void> saveUserCountryPreference({
    required String uid,
    required String countryCode,
    String? email,
    String? fcmToken,
  });

  /// Permite alternar manualmente entre ABIERTA y CERRADA para pruebas locales (Modo Demo)
  Future<void> toggleDemoStatus(String countryCode, bool isOpen);
}
