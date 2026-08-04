import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/shared_prefs_service.dart';
import '../../core/services/notification_service.dart';
import '../../domain/repositories/visa_repository.dart';
import '../../domain/repositories/paywall_repository.dart';
import '../../domain/repositories/news_repository.dart';
import '../../data/repositories/visa_repository_impl.dart';
import '../../data/repositories/paywall_repository_impl.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../../data/sources/rss_feed_client.dart';

final sharedPrefsServiceProvider = Provider<SharedPrefsService>((ref) {
  return SharedPrefsService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final visaRepositoryProvider = Provider<VisaRepository>((ref) {
  final prefs = ref.watch(sharedPrefsServiceProvider);
  return VisaRepositoryImpl(prefs);
});

final paywallRepositoryProvider = Provider<PaywallRepository>((ref) {
  return PaywallRepositoryImpl();
});

final rssFeedClientProvider = Provider<RssFeedClient>((ref) {
  return RssFeedClient();
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final client = ref.watch(rssFeedClientProvider);
  return NewsRepositoryImpl(client);
});
