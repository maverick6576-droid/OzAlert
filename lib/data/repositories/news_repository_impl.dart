import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Future<List<NewsItem>> fetchAlertNews() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('noticias')
        .orderBy('fecha_creacion', descending: true)
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return NewsItem(
        title: data['title'] ?? 'Sin título',
        link: data['link'] ?? '',
        pubDate: data['published_date'] ?? 'Reciente',
        description: data['summary'] ?? '',
        category: 'comunidad', // Mapeamos como comunidad para el estilo de Google Alerts
      );
    }).toList();
  }

  @override
  Future<void> openArticleUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      final success = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!success) {
        debugPrint('No se pudo abrir la URL (launchUrl devolvió false): $urlString');
      }
    } catch (e) {
      debugPrint('Error en openArticleUrl: $e');
    }
  }
}
