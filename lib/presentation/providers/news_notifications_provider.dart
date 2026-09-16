import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'locale_provider.dart';

class NewsNotificationsNotifier extends StateNotifier<bool> {
  final Ref ref;
  static const _newsNotifsKey = 'news_notifications_enabled';

  NewsNotificationsNotifier(this.ref) : super(true) {
    _load();
  }

  void _load() {
    final prefs = ref.read(sharedPreferencesProvider);
    state = prefs.getBool(_newsNotifsKey) ?? true;
  }

  Future<void> toggle(bool isEnabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_newsNotifsKey, isEnabled);
    state = isEnabled;
    
    try {
      if (isEnabled) {
        await FirebaseMessaging.instance.subscribeToTopic('all_users');
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');
      }
    } catch (e) {
      // Ignorar en caso de falta de permisos o entorno mock
    }
  }
}

final newsNotificationsProvider = StateNotifierProvider<NewsNotificationsNotifier, bool>((ref) {
  return NewsNotificationsNotifier(ref);
});
