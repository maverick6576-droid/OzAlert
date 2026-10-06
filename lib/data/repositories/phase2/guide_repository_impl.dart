import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../domain/models/phase2/guide_data.dart';
import '../../../domain/repositories/phase2/guide_repository.dart';

class GuideRepositoryImpl implements GuideRepository {
  Map<String, CategoryGuide>? _cachedGuides;

  @override
  Future<CategoryGuide?> getGuideForCategory(String categoryId) async {
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
        return null;
      }
    }
    return _cachedGuides?[categoryId];
  }
}
