import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../../../domain/models/phase2/affiliate_partner.dart';
import '../../../domain/repositories/phase2/affiliate_repository.dart';

class AffiliateRepositoryImpl implements AffiliateRepository {
  final FirebaseRemoteConfig? _remoteConfig;
  List<AffiliatePartner> _cachedPartners = [];

  AffiliateRepositoryImpl({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig;

  @override
  Future<void> init() async {
    try {
      // 1. Cargar datos locales de respaldo por defecto
      final defaultJson = await rootBundle.loadString('assets/data/b2b_partners_default.json');
      _parseJson(defaultJson);

      // 2. Intentar actualizar desde Firebase Remote Config si está disponible
      if (_remoteConfig != null) {
        await _remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 2),
        ));
        await _remoteConfig.setDefaults({'affiliate_partners_config': defaultJson});
        final updated = await _remoteConfig.fetchAndActivate();
        if (updated) {
          final remoteValue = _remoteConfig.getString('affiliate_partners_config');
          if (remoteValue.isNotEmpty) {
            _parseJson(remoteValue);
          }
        }
      }
    } catch (e) {
      // Fallback silencioso a caché local offline
    }
  }

  void _parseJson(String jsonString) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      final List<dynamic> list = decoded['partners'] ?? [];
      _cachedPartners = list
          .map((item) => AffiliatePartner.fromJson(item as Map<String, dynamic>))
          .where((p) => p.isActive)
          .toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));
    } catch (_) {}
  }

  @override
  List<AffiliatePartner> getPartnersByCategory(String category) {
    return _cachedPartners.where((p) => p.category == category).toList();
  }

  @override
  List<AffiliatePartner> getAllPartners() {
    return _cachedPartners;
  }
}
