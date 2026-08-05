import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/news_item.dart';
import 'repository_providers.dart';

final newsListProvider = FutureProvider<List<NewsItem>>((ref) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.fetchAllNews();
});

final alertNewsListProvider = FutureProvider<List<NewsItem>>((ref) async {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.fetchAlertNews();
});
