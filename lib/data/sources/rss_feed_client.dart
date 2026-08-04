import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/news_item.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/mock_data.dart';

class RssFeedClient {
  final http.Client _client;

  RssFeedClient({http.Client? client}) : _client = client ?? http.Client();

  Future<List<NewsItem>> fetchMigrationNews() async {
    final List<NewsItem> parsedItems = [];

    // 1. Intentar obtener el RSS de la web oficial o feeds australianos
    try {
      final response = await _client
          .get(
            Uri.parse(AppConstants.sbsMigrationRssUrl),
            headers: {'User-Agent': 'OzVisaAlert/1.0 FlutterClient'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final bodyString = utf8.decode(response.bodyBytes);
        final feed = RssFeed.parse(bodyString);

        if (feed.items != null) {
          for (final item in feed.items!.take(6)) {
            parsedItems.add(
              NewsItem(
                title: item.title ?? 'Actualización de Inmigración Australia',
                link: item.link ?? 'https://immi.homeaffairs.gov.au',
                pubDate: _formatRssDate(item.pubDate),
                description: _cleanHtml(item.description ?? ''),
                imageUrl: item.enclosure?.url,
                category: 'oficial',
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('RSS feed client fallback al contenido offline predeterminado: $e');
    }

    // 2. Si falló o estamos offline, o para asegurar cobertura completa de Guías y Comunidad en Español,
    // fusionamos con nuestras noticias y guías predeterminadas:
    if (parsedItems.isEmpty) {
      return MockData.defaultNews;
    }

    // Añadir guías de interés y alertas de comunidad al listado final
    final guidesAndCommunity = MockData.defaultNews.where(
      (n) => n.category == 'guia' || n.category == 'comunidad',
    );
    return [...parsedItems, ...guidesAndCommunity];
  }

  String _formatRssDate(DateTime? pubDate) {
    if (pubDate == null) return 'HOY';
    final months = [
      'ENE',
      'FEB',
      'MAR',
      'ABR',
      'MAY',
      'JUN',
      'JUL',
      'AGO',
      'SEP',
      'OCT',
      'NOV',
      'DIC',
    ];
    final day = pubDate.day.toString().padLeft(2, '0');
    final month = months[pubDate.month - 1];
    final year = pubDate.year;
    return '$day $month $year';
  }

  String _cleanHtml(String htmlString) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    final text = htmlString.replaceAll(exp, '').trim();
    if (text.length > 180) {
      return '${text.substring(0, 177)}...';
    }
    return text;
  }
}
