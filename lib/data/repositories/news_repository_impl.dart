import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/news_item.dart';
import '../../domain/repositories/news_repository.dart';
import '../sources/rss_feed_client.dart';

class NewsRepositoryImpl implements NewsRepository {
  final RssFeedClient _rssFeedClient;

  NewsRepositoryImpl(this._rssFeedClient);

  @override
  Future<List<NewsItem>> fetchAllNews({bool forceRefresh = false}) async {
    try {
      return await _rssFeedClient.fetchMigrationNews();
    } catch (e) {
      debugPrint('Error en NewsRepositoryImpl fetchAllNews: $e');
      rethrow;
    }
  }

  @override
  Future<void> openArticleUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('No se pudo abrir la URL: $urlString');
      }
    } catch (e) {
      debugPrint('Error en openArticleUrl: $e');
    }
  }
}
