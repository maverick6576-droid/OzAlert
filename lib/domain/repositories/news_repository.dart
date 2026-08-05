import '../models/news_item.dart';

abstract class NewsRepository {
  /// Devuelve los avisos oficiales extraídos del feed RSS y artículos de comunidad
  Future<List<NewsItem>> fetchAllNews({bool forceRefresh = false});

  /// Abre un artículo o el banner afiliado en el navegador integrado del sistema
  Future<void> openArticleUrl(String url);

  /// Devuelve las alertas guardadas en Firestore desde Google Alerts
  Future<List<NewsItem>> fetchAlertNews();
}
