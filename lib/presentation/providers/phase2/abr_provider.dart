import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/abr_service.dart';
import '../../../domain/models/abn_details.dart';

final abrServiceProvider = Provider<AbrService>((ref) {
  return AbrService();
});

/// Proveedor para consultar y verificar en vivo un ABN con caché automática en memoria
final abnLookupProvider = FutureProvider.family<AbnDetails, String>((ref, rawAbn) async {
  final clean = AbrService.cleanAbn(rawAbn);
  if (clean.length != 11) {
    return AbnDetails(
      abn: clean,
      status: 'Invalid',
      errorMessage: 'El ABN debe tener 11 dígitos.',
    );
  }
  final service = ref.watch(abrServiceProvider);
  return await service.lookupAbn(clean);
});
