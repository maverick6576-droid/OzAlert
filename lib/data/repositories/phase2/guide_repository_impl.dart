import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/models/phase2/guide_data.dart';
import '../../../domain/repositories/phase2/guide_repository.dart';

class GuideRepositoryImpl implements GuideRepository {
  final FirebaseFirestore? _firestore;
  final SharedPreferences? _prefs;

  Map<String, CategoryGuide>? _cachedGuides;
  final Map<String, Map<String, dynamic>> _memoryOverrides = {};

  static const String _collectionName = 'official_links';
  static const int _cacheTtlMs = 24 * 60 * 60 * 1000; // 24 horas para garantizar Coste $0 en Firebase

  GuideRepositoryImpl({
    FirebaseFirestore? firestore,
    SharedPreferences? prefs,
  })  : _firestore = firestore,
        _prefs = prefs;

  @override
  Future<CategoryGuide?> getGuideForCategory(String categoryId) async {
    // 1. Cargar datos locales de assets/data/guides_data.json si no están en memoria
    if (_cachedGuides == null) {
      try {
        final jsonStr = await rootBundle.loadString('assets/data/guides_data.json');
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        final guidesMap = data['guides'] as Map<String, dynamic>? ?? {};

        final loaded = <String, CategoryGuide>{};
        for (final entry in guidesMap.entries) {
          loaded[entry.key] = CategoryGuide.fromJson(entry.value as Map<String, dynamic>);
        }
        _cachedGuides = loaded;
      } catch (e) {
        debugPrint('Error cargando assets/data/guides_data.json: $e');
        return null;
      }
    }

    final baseGuide = _cachedGuides?[categoryId];
    if (baseGuide == null) return null;

    // 2. Obtener overrides dinámicos de Firebase Firestore (o de la caché local de 24h)
    final overrides = await _getOverridesForCategory(categoryId);
    if (overrides == null || overrides.isEmpty) {
      return baseGuide;
    }

    // 3. Fusionar enlaces remotos actualizados
    return _applyOverrides(baseGuide, overrides);
  }

  /// Obtiene los enlaces actualizados con estrategia Local-First y caché de 24h (Coste $0).
  Future<Map<String, dynamic>?> _getOverridesForCategory(String categoryId) async {
    if (_memoryOverrides.containsKey(categoryId)) {
      return _memoryOverrides[categoryId];
    }

    SharedPreferences? prefs = _prefs;
    try {
      prefs ??= await SharedPreferences.getInstance();
    } catch (_) {
      // Entorno de prueba o sin SharedPreferences disponible
    }

    final cacheKey = 'official_links_$categoryId';
    final tsKey = 'official_links_ts_$categoryId';

    if (prefs != null) {
      final cachedJson = prefs.getString(cacheKey);
      final lastFetch = prefs.getInt(tsKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          final decoded = json.decode(cachedJson) as Map<String, dynamic>;
          _memoryOverrides[categoryId] = decoded;

          // Si el caché local tiene menos de 24 horas, no consume lecturas de Firestore
          if (now - lastFetch < _cacheTtlMs) {
            return decoded;
          }
        } catch (_) {}
      }
    }

    // Intentar consultar Firebase Firestore si la caché expiró o está vacía
    try {
      final fs = _firestore ?? FirebaseFirestore.instance;
      final doc = await fs.collection(_collectionName).doc(categoryId).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _memoryOverrides[categoryId] = data;

        if (prefs != null) {
          await prefs.setString(cacheKey, json.encode(data));
          await prefs.setInt(tsKey, DateTime.now().millisecondsSinceEpoch);
        }
        return data;
      }
    } catch (e) {
      debugPrint('Firestore official_links no disponible o modo offline para $categoryId: $e');
    }

    return _memoryOverrides[categoryId];
  }

  CategoryGuide _applyOverrides(CategoryGuide baseGuide, Map<String, dynamic> overrides) {
    var updatedSteps = baseGuide.steps;
    final stepsMap = overrides['steps'] as Map<String, dynamic>?;
    if (stepsMap != null && stepsMap.isNotEmpty) {
      updatedSteps = baseGuide.steps.map((step) {
        final override = stepsMap[step.number.toString()] as Map<String, dynamic>?;
        if (override != null) {
          return step.copyWith(
            officialUrl: override['officialUrl'] as String? ?? step.officialUrl,
            officialUrlLabel: override['officialUrlLabel'] as String? ?? step.officialUrlLabel,
            officialUrlLabelEn: override['officialUrlLabelEn'] as String? ?? step.officialUrlLabelEn,
          );
        }
        return step;
      }).toList();
    }

    var updatedComps = baseGuide.comparisons;
    final compsMap = overrides['comparisons'] as Map<String, dynamic>?;
    if (compsMap != null && compsMap.isNotEmpty) {
      updatedComps = baseGuide.comparisons.map((comp) {
        final override = compsMap[comp.id] as Map<String, dynamic>?;
        if (override != null) {
          return comp.copyWith(
            officialUrl: override['officialUrl'] as String? ?? comp.officialUrl,
            officialUrlLabel: override['officialUrlLabel'] as String? ?? comp.officialUrlLabel,
            officialUrlLabelEn: override['officialUrlLabelEn'] as String? ?? comp.officialUrlLabelEn,
          );
        }
        return comp;
      }).toList();
    }

    return baseGuide.copyWith(
      steps: updatedSteps,
      comparisons: updatedComps,
    );
  }

  @override
  Future<bool> syncOfficialLinksToFirestore() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/official_links_seed.json');
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final fs = _firestore ?? FirebaseFirestore.instance;
      final batch = fs.batch();

      for (final entry in data.entries) {
        final docRef = fs.collection(_collectionName).doc(entry.key);
        batch.set(docRef, entry.value as Map<String, dynamic>, SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('Sincronizados exitosamente los 12 documentos de official_links en Firestore');
      return true;
    } catch (e) {
      debugPrint('Error sincronizando official_links en Firestore: ');
      return false;
    }
  }
}