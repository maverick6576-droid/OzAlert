import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../domain/models/phase2/postcode_info.dart';
import '../../../domain/repositories/phase2/postcode_repository.dart';

class PostcodeRepositoryImpl implements PostcodeRepository {
  final Map<String, PostcodeInfo> _cache = {};

  @override
  Future<void> init() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/regional_postcodes.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> list = data['postcodes'] ?? [];

      for (final item in list) {
        final info = PostcodeInfo.fromJson(item as Map<String, dynamic>);
        _cache[info.code] = info;
      }
    } catch (_) {}
  }

  @override
  PostcodeInfo? findPostcode(String code) {
    final clean = code.trim();
    return _cache[clean];
  }

  @override
  List<PostcodeInfo> getAllPostcodes() {
    return _cache.values.toList();
  }
}
