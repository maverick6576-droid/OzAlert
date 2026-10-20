import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/abn_details.dart';
import '../constants/app_constants.dart';

class AbrService {
  final http.Client _client;

  AbrService({http.Client? client}) : _client = client ?? http.Client();

  /// Limpia el ABN quitando espacios, guiones y caracteres no numéricos.
  static String cleanAbn(String rawAbn) {
    return rawAbn.replaceAll(RegExp(r'\D'), '');
  }

  /// Algoritmo oficial de Checksum ATO (Modulo 89)
  ///
  /// Especificación oficial de la Australian Taxation Office:
  /// 1. El ABN consta de 11 dígitos numéricos.
  /// 2. Restar 1 al primer dígito.
  /// 3. Multiplicar cada uno de los 11 dígitos por su peso asignado:
  ///    [10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19]
  /// 4. Sumar todos los productos.
  /// 5. El ABN es matemáticamente válido si (Suma % 89 == 0).
  static bool isValidAbnChecksum(String rawAbn) {
    final clean = cleanAbn(rawAbn);
    if (clean.length != 11) return false;

    final digits = <int>[];
    for (int i = 0; i < 11; i++) {
      final d = int.tryParse(clean[i]);
      if (d == null) return false;
      digits.add(d);
    }

    // Restar 1 al primer dígito
    digits[0] -= 1;

    const weights = [10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19];
    int sum = 0;
    for (int i = 0; i < 11; i++) {
      sum += digits[i] * weights[i];
    }

    return sum % 89 == 0;
  }

  /// Construye la URL oficial para consultar la ficha pública en el portal del gobierno.
  static String getOfficialAbnUrl(String rawAbn) {
    final clean = cleanAbn(rawAbn);
    return 'https://abr.business.gov.au/ABN/View?id=$clean';
  }

  /// Consulta la API oficial gratuita de ABN Lookup (abr.business.gov.au).
  ///
  /// Retorna un objeto [AbnDetails] con el estado legal (Active / Cancelled),
  /// el nombre de la empresa y la sede registrada.
  Future<AbnDetails> lookupAbn(
    String rawAbn, {
    String? customGuid,
  }) async {
    final clean = cleanAbn(rawAbn);

    // 1. Validación de longitud
    if (clean.length != 11) {
      return AbnDetails(
        abn: clean,
        status: 'Invalid',
        errorMessage: 'El ABN debe tener exactamente 11 dígitos numéricos.',
      );
    }

    // 2. Validación instantánea del algoritmo matemático ATO (Offline)
    final checksumPassed = isValidAbnChecksum(clean);
    if (!checksumPassed) {
      return AbnDetails(
        abn: clean,
        status: 'Invalid',
        errorMessage: 'El ABN no supera el algoritmo de verificación oficial de la ATO (ficticio o erróneo).',
      );
    }

    // 3. Determinar GUID de autenticación (gratuito)
    final guid = (customGuid != null)
        ? customGuid.trim()
        : AppConstants.abrAuthenticationGuid.trim();

    if (guid.isEmpty) {
      // Checksum superado, pero aún no se ha configurado el GUID de la API
      return AbnDetails(
        abn: clean,
        status: 'Active',
        errorMessage: 'NO_GUID',
      );
    }

    // 4. Petición HTTP GET al endpoint oficial JSON de ABR
    try {
      final uri = Uri.parse(
        'https://abr.business.gov.au/json/AbnDetails.aspx?abn=$clean&guid=$guid',
      );

      final response = await _client.get(uri).timeout(
        const Duration(seconds: 8),
      );

      if (response.statusCode != 200) {
        return AbnDetails(
          abn: clean,
          status: 'Active',
          errorMessage: 'Error del servidor ABR (${response.statusCode}).',
        );
      }

      // La API de ABR retorna JSONP con formato: callback({ ... })
      String body = response.body.trim();
      if (body.startsWith('callback(') && body.endsWith(')')) {
        body = body.substring(9, body.length - 1).trim();
      } else if (body.startsWith('(') && body.endsWith(')')) {
        body = body.substring(1, body.length - 1).trim();
      }

      final Map<String, dynamic> data = jsonDecode(body);
      final details = AbnDetails.fromJson(data);

      return details;
    } catch (e) {
      debugPrint('Aviso en consulta ABR: $e');
      return AbnDetails(
        abn: clean,
        status: 'Active',
        errorMessage: 'Sin conexión para verificación en vivo: $e',
      );
    }
  }
}
